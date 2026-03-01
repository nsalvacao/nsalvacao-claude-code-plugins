/**
 * Plugin Studio — Filesystem API Route Handlers
 *
 * Endpoints:
 *   GET  /api/fs/tree?path=<plugin_root>
 *   GET  /api/fs/file?root=<plugin_root>&path=<rel_path>
 *   PUT  /api/fs/file        { root, path, content }  → update existing
 *   POST /api/fs/file        { root, path, content }  → create new
 *   DELETE /api/fs/file      { root, path }
 *   POST /api/fs/rename      { root, oldPath, newPath }
 *   POST /api/fs/duplicate   { root, sourcePath, targetPath }
 *
 * Security: all paths are validated to stay within the plugin root.
 * A valid plugin root must contain .claude-plugin/plugin.json.
 */

import fs from 'node:fs';
import path from 'node:path';

const TIMEOUT_MS = 10_000;

// ---------------------------------------------------------------------------
// Utility — exported for unit tests
// ---------------------------------------------------------------------------

/**
 * Resolve a user-supplied path safely within a trusted root.
 * Strips leading slashes to prevent absolute-path injection (path.resolve
 * treats an absolute second argument as a new root).
 * Returns null on path traversal attempts.
 */
export function sanitizePath(root, userPath) {
  if (!userPath) return null;
  const normalized = String(userPath).replace(/\\/g, '/');

  // Reject absolute paths — POSIX (/etc/passwd) and Windows (C:/...) style
  if (path.isAbsolute(normalized) || /^[A-Za-z]:/.test(normalized)) return null;
  if (!normalized.trim()) return null;

  const resolved = path.resolve(root, normalized);
  const rootNorm = root.endsWith(path.sep) ? root.slice(0, -1) : root;

  if (resolved !== rootNorm && !resolved.startsWith(rootNorm + path.sep)) {
    return null; // traversal attempt
  }
  return resolved;
}

/**
 * Return true if dir contains .claude-plugin/plugin.json.
 */
export function isValidPluginRoot(dir) {
  if (!dir || typeof dir !== 'string') return false;
  try {
    fs.statSync(path.join(dir, '.claude-plugin', 'plugin.json'));
    return true;
  } catch {
    return false;
  }
}

/**
 * Classify a single file (by repo-relative path) into the components tree.
 * Exported for unit tests.
 */
export function classifyFile(components, rel, absPath) {
  if (rel === '.claude-plugin/plugin.json') {
    components.manifest = { path: absPath, rel };
  } else if (rel.toLowerCase() === 'readme.md') {
    components.readme = { path: absPath, rel };
  } else if (/^commands\/[^/]+\.md$/.test(rel)) {
    components.commands.push({ name: path.basename(rel, '.md'), path: absPath, rel });
  } else if (/^skills\/[^/]+\/SKILL\.md$/.test(rel)) {
    components.skills.push({ name: rel.split('/')[1], path: absPath, rel });
  } else if (/^agents\/[^/]+\.md$/.test(rel)) {
    components.agents.push({ name: path.basename(rel, '.md'), path: absPath, rel });
  } else if (rel === 'hooks/hooks.json') {
    components.hooks.config = { path: absPath, rel };
  } else if (rel.startsWith('hooks/scripts/')) {
    components.hooks.scripts.push({ name: path.basename(rel), path: absPath, rel });
  } else if (rel === 'mcp-template.json') {
    components.mcp = { path: absPath, rel };
  }
}

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

function withTimeout(promise) {
  return Promise.race([
    promise,
    new Promise((_, reject) =>
      setTimeout(
        () => reject(Object.assign(new Error('Operation timed out'), { code: 'ETIMEDOUT' })),
        TIMEOUT_MS,
      ).unref(),
    ),
  ]);
}

async function walk(rootDir, dir, components) {
  let entries;
  try {
    entries = await withTimeout(fs.promises.readdir(dir, { withFileTypes: true }));
  } catch {
    return;
  }
  for (const entry of entries) {
    // Skip hidden dirs except .claude-plugin
    if (entry.name.startsWith('.') && entry.name !== '.claude-plugin') continue;
    if (entry.name === 'node_modules') continue;

    const abs = path.join(dir, entry.name);
    const rel = path.relative(rootDir, abs).replace(/\\/g, '/');

    if (entry.isDirectory()) {
      await walk(rootDir, abs, components);
    } else {
      classifyFile(components, rel, abs);
    }
  }
}

/**
 * Build the full component tree for a plugin root.
 * Exported for unit tests.
 */
export async function buildTree(rootDir) {
  const components = {
    manifest: null,
    commands: [],
    skills: [],
    agents: [],
    hooks: { config: null, scripts: [] },
    mcp: null,
    readme: null,
  };
  await walk(rootDir, rootDir, components);
  return { root: rootDir, name: path.basename(rootDir), components };
}

function parseBody(req) {
  return new Promise((resolve, reject) => {
    let raw = '';
    const timer = setTimeout(
      () => reject(Object.assign(new Error('Request body timeout'), { code: 'ETIMEDOUT' })),
      TIMEOUT_MS,
    );
    req.on('data', (chunk) => { raw += chunk; });
    req.on('end', () => {
      clearTimeout(timer);
      try { resolve(JSON.parse(raw || '{}')); } catch { reject(new Error('Invalid JSON body')); }
    });
    req.on('error', (err) => { clearTimeout(timer); reject(err); });
  });
}

function sendJson(res, status, data) {
  res.writeHead(status, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(data));
}

function sendError(res, status, message) {
  sendJson(res, status, { error: message });
}

// ---------------------------------------------------------------------------
// Route handler — called by server/index.js for /api/fs/* requests
// ---------------------------------------------------------------------------

export async function handleFsRoute(req, res, url) {
  const u = new URL(url, 'http://localhost');
  const fsPath = u.pathname.replace(/^\/api\/fs/, '') || '/';
  const method = (req.method ?? 'GET').toUpperCase();
  const params = u.searchParams;

  try {
    // ------------------------------------------------------------------
    // GET /api/fs/tree?path=<plugin_root>
    // ------------------------------------------------------------------
    if (fsPath === '/tree' && method === 'GET') {
      const rootDir = params.get('path');
      if (!rootDir) return sendError(res, 400, 'Missing ?path= query parameter');
      if (!isValidPluginRoot(rootDir)) {
        return sendError(res, 400, 'Not a valid plugin directory (missing .claude-plugin/plugin.json)');
      }
      const tree = await withTimeout(buildTree(rootDir));
      return sendJson(res, 200, tree);
    }

    // ------------------------------------------------------------------
    // GET /api/fs/file?root=<plugin_root>&path=<rel_path>
    // ------------------------------------------------------------------
    if (fsPath === '/file' && method === 'GET') {
      const root = params.get('root');
      const filePath = params.get('path');
      if (!root || !filePath) return sendError(res, 400, 'Missing ?root= or ?path= query parameters');
      if (!isValidPluginRoot(root)) return sendError(res, 403, 'Invalid plugin root');
      const safe = sanitizePath(root, filePath);
      if (!safe) return sendError(res, 403, 'Path outside plugin root');
      const content = await withTimeout(fs.promises.readFile(safe, 'utf8'));
      return sendJson(res, 200, { path: filePath, content });
    }

    // ------------------------------------------------------------------
    // PUT /api/fs/file — update existing file
    // ------------------------------------------------------------------
    if (fsPath === '/file' && method === 'PUT') {
      const body = await parseBody(req);
      const { root, path: filePath, content } = body;
      if (!root || !filePath || content === undefined) {
        return sendError(res, 400, 'Body must include root, path, and content');
      }
      if (!isValidPluginRoot(root)) return sendError(res, 403, 'Invalid plugin root');
      const safe = sanitizePath(root, filePath);
      if (!safe) return sendError(res, 403, 'Path outside plugin root');
      try { await withTimeout(fs.promises.access(safe)); }
      catch { return sendError(res, 404, 'File not found'); }
      await withTimeout(fs.promises.writeFile(safe, content, 'utf8'));
      return sendJson(res, 200, { ok: true, path: filePath });
    }

    // ------------------------------------------------------------------
    // POST /api/fs/file — create new file
    // ------------------------------------------------------------------
    if (fsPath === '/file' && method === 'POST') {
      const body = await parseBody(req);
      const { root, path: filePath, content } = body;
      if (!root || !filePath || content === undefined) {
        return sendError(res, 400, 'Body must include root, path, and content');
      }
      if (!isValidPluginRoot(root)) return sendError(res, 403, 'Invalid plugin root');
      const safe = sanitizePath(root, filePath);
      if (!safe) return sendError(res, 403, 'Path outside plugin root');
      try {
        await withTimeout(fs.promises.access(safe));
        return sendError(res, 409, 'File already exists — use PUT to update');
      } catch { /* good: file does not exist */ }
      await withTimeout(fs.promises.mkdir(path.dirname(safe), { recursive: true }));
      await withTimeout(fs.promises.writeFile(safe, content, 'utf8'));
      return sendJson(res, 201, { ok: true, path: filePath });
    }

    // ------------------------------------------------------------------
    // DELETE /api/fs/file — body or query params
    // ------------------------------------------------------------------
    if (fsPath === '/file' && method === 'DELETE') {
      let root, filePath;
      if (params.get('root')) {
        root = params.get('root');
        filePath = params.get('path');
      } else {
        const body = await parseBody(req);
        root = body.root;
        filePath = body.path;
      }
      if (!root || !filePath) return sendError(res, 400, 'Missing root and path');
      if (!isValidPluginRoot(root)) return sendError(res, 403, 'Invalid plugin root');
      const safe = sanitizePath(root, filePath);
      if (!safe) return sendError(res, 403, 'Path outside plugin root');
      await withTimeout(fs.promises.unlink(safe));
      return sendJson(res, 200, { ok: true, path: filePath });
    }

    // ------------------------------------------------------------------
    // POST /api/fs/rename — { root, oldPath, newPath }
    // ------------------------------------------------------------------
    if (fsPath === '/rename' && method === 'POST') {
      const body = await parseBody(req);
      const { root, oldPath, newPath } = body;
      if (!root || !oldPath || !newPath) {
        return sendError(res, 400, 'Body must include root, oldPath, and newPath');
      }
      if (!isValidPluginRoot(root)) return sendError(res, 403, 'Invalid plugin root');
      const safeOld = sanitizePath(root, oldPath);
      const safeNew = sanitizePath(root, newPath);
      if (!safeOld || !safeNew) return sendError(res, 403, 'Path outside plugin root');
      await withTimeout(fs.promises.mkdir(path.dirname(safeNew), { recursive: true }));
      await withTimeout(fs.promises.rename(safeOld, safeNew));
      return sendJson(res, 200, { ok: true, oldPath, newPath });
    }

    // ------------------------------------------------------------------
    // POST /api/fs/duplicate — { root, sourcePath, targetPath }
    // ------------------------------------------------------------------
    if (fsPath === '/duplicate' && method === 'POST') {
      const body = await parseBody(req);
      const { root, sourcePath, targetPath } = body;
      if (!root || !sourcePath || !targetPath) {
        return sendError(res, 400, 'Body must include root, sourcePath, and targetPath');
      }
      if (!isValidPluginRoot(root)) return sendError(res, 403, 'Invalid plugin root');
      const safeSrc = sanitizePath(root, sourcePath);
      const safeTgt = sanitizePath(root, targetPath);
      if (!safeSrc || !safeTgt) return sendError(res, 403, 'Path outside plugin root');
      try {
        await withTimeout(fs.promises.access(safeTgt));
        return sendError(res, 409, 'Target path already exists');
      } catch { /* good: target does not exist */ }
      await withTimeout(fs.promises.mkdir(path.dirname(safeTgt), { recursive: true }));
      await withTimeout(fs.promises.copyFile(safeSrc, safeTgt));
      return sendJson(res, 201, { ok: true, sourcePath, targetPath });
    }

    return sendError(res, 404, `Unknown route: ${method} /api/fs${fsPath}`);

  } catch (err) {
    if (err.code === 'ENOENT') return sendError(res, 404, 'File or directory not found');
    if (err.code === 'EACCES') return sendError(res, 403, 'Permission denied');
    if (err.code === 'ETIMEDOUT') return sendError(res, 504, 'Filesystem operation timed out');
    console.error('[fs-api] Unhandled error:', err);
    return sendError(res, 500, 'Internal server error');
  }
}
