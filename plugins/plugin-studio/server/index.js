#!/usr/bin/env node
/**
 * Plugin Studio — Production Server
 *
 * Entry point: node server/index.js
 * No external dependencies — only Node.js built-in modules.
 * Serves app/dist/ as static files + REST API stub (filled in by issues #3, #4, #12).
 */

import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import net from 'node:net';
import { exec } from 'node:child_process';
import { platform } from 'node:os';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const PLUGIN_ROOT = path.join(__dirname, '..');
const DIST_DIR = path.join(PLUGIN_ROOT, 'app', 'dist');
const PID_FILE = path.join(__dirname, '.pid');
const PORT_START = 3847;
const PORT_MAX = 3857;

const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.mjs': 'application/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.ico': 'image/x-icon',
  '.woff2': 'font/woff2',
  '.woff': 'font/woff',
};

// ---------------------------------------------------------------------------
// Port detection
// ---------------------------------------------------------------------------

function findAvailablePort(start) {
  return new Promise((resolve, reject) => {
    if (start > PORT_MAX) {
      reject(new Error(`No available port found in range ${PORT_START}–${PORT_MAX}`));
      return;
    }
    const probe = net.createServer();
    probe.listen(start, '127.0.0.1', () => {
      probe.close(() => resolve(start));
    });
    probe.on('error', () => resolve(findAvailablePort(start + 1)));
  });
}

// ---------------------------------------------------------------------------
// Browser open (WSL / macOS / Linux)
// ---------------------------------------------------------------------------

function openBrowser(url) {
  const os = platform();
  let cmd;
  if (os === 'win32') {
    cmd = `start "" "${url}"`;
  } else if (os === 'darwin') {
    cmd = `open "${url}"`;
  } else {
    // Linux — detect WSL
    let isWsl = false;
    try {
      const procVersion = fs.readFileSync('/proc/version', 'utf8').toLowerCase();
      isWsl = procVersion.includes('microsoft');
    } catch {
      // not WSL
    }
    cmd = isWsl ? `powershell.exe -c "start '${url}'"` : `xdg-open "${url}"`;
  }
  exec(cmd, (err) => {
    if (err) {
      console.warn(`⚠ Could not open browser automatically. Navigate to: ${url}`);
    }
  });
}

// ---------------------------------------------------------------------------
// Static file serving with SPA fallback
// ---------------------------------------------------------------------------

function serveStatic(req, res) {
  const rawPath = (req.url ?? '/').split('?')[0];
  let filePath = path.join(DIST_DIR, rawPath === '/' ? 'index.html' : rawPath);

  // Path traversal guard
  if (!filePath.startsWith(DIST_DIR + path.sep) && filePath !== DIST_DIR) {
    res.writeHead(403, { 'Content-Type': 'text/plain' });
    res.end('Forbidden');
    return;
  }

  // SPA fallback — any missing path serves index.html for client-side routing
  if (!fs.existsSync(filePath) || fs.statSync(filePath).isDirectory()) {
    filePath = path.join(DIST_DIR, 'index.html');
  }

  if (!fs.existsSync(filePath)) {
    res.writeHead(404, { 'Content-Type': 'text/plain' });
    res.end('Not found — run pnpm build in app/ to generate dist/');
    return;
  }

  const ext = path.extname(filePath);
  const contentType = MIME_TYPES[ext] ?? 'application/octet-stream';
  res.writeHead(200, { 'Content-Type': contentType });
  fs.createReadStream(filePath).pipe(res);
}

// ---------------------------------------------------------------------------
// Request handler
// ---------------------------------------------------------------------------

function requestHandler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');

  // API routes — stubs, filled in by issues #3, #4, #12, #16
  if (req.url?.startsWith('/api/')) {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'ok', version: '0.1.0', note: 'API routes implemented in subsequent issues' }));
    return;
  }

  serveStatic(req, res);
}

// ---------------------------------------------------------------------------
// PID file management
// ---------------------------------------------------------------------------

function writePid() {
  fs.writeFileSync(PID_FILE, String(process.pid), 'utf8');
}

function makeCleanupHandler(server) {
  return () => {
    try { fs.unlinkSync(PID_FILE); } catch { /* already gone */ }
    server.close(() => process.exit(0));
    // Force-exit if graceful shutdown hangs
    setTimeout(() => process.exit(0), 1000).unref();
  };
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

async function main() {
  const port = await findAvailablePort(PORT_START);
  const server = http.createServer(requestHandler);

  await new Promise((resolve) => {
    server.listen(port, '127.0.0.1', () => resolve(undefined));
  });

  writePid();

  const url = `http://localhost:${port}`;
  console.log(`✓ Plugin Studio running at ${url}`);
  console.log(`  Dist: ${DIST_DIR}`);
  console.log(`  PID:  ${process.pid}`);

  const cleanup = makeCleanupHandler(server);
  process.on('SIGINT', cleanup);
  process.on('SIGTERM', cleanup);

  openBrowser(url);
}

main().catch((err) => {
  console.error('✗ Failed to start Plugin Studio server:', err.message);
  process.exit(1);
});
