/**
 * Plugin Studio — Filesystem API Unit Tests
 *
 * Run: node --test api/fs.test.js  (from server/ directory)
 *   or: pnpm test
 *
 * Uses node:test + node:assert (Node.js 18+ built-ins, zero extra deps).
 * Integration tests spin up a real temp plugin directory.
 */

import { describe, it, before, after } from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import { EventEmitter } from 'node:events';

import {
  sanitizePath,
  isValidPluginRoot,
  classifyFile,
  buildTree,
  handleFsRoute,
} from './fs.js';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

function makeTempPlugin() {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'ps-test-'));
  // Minimal plugin structure
  fs.mkdirSync(path.join(dir, '.claude-plugin'));
  fs.writeFileSync(
    path.join(dir, '.claude-plugin', 'plugin.json'),
    JSON.stringify({ name: 'test-plugin', version: '0.1.0', description: 'test', author: { name: 'T', email: 't@t.com' } }),
  );
  return dir;
}

function removeTempPlugin(dir) {
  fs.rmSync(dir, { recursive: true, force: true });
}

/** Minimal mock req for GET requests */
function mockGet(url) {
  const req = new EventEmitter();
  req.method = 'GET';
  req.url = url;
  req.headers = {};
  return req;
}

/** Minimal mock req for requests with a JSON body */
function mockWithBody(method, url, bodyObj) {
  const req = new EventEmitter();
  req.method = method;
  req.url = url;
  req.headers = { 'content-type': 'application/json' };
  process.nextTick(() => {
    req.emit('data', JSON.stringify(bodyObj));
    req.emit('end');
  });
  return req;
}

/** Minimal mock res that captures status + body */
function mockRes() {
  const res = {
    statusCode: null,
    _body: '',
    writeHead(status) { this.statusCode = status; },
    end(data = '') { this._body = data; },
    get json() { return JSON.parse(this._body); },
  };
  return res;
}

// ---------------------------------------------------------------------------
// sanitizePath
// ---------------------------------------------------------------------------

describe('sanitizePath', () => {
  const root = '/tmp/plugin';

  it('allows paths inside root', () => {
    assert.equal(sanitizePath(root, 'commands/open.md'), '/tmp/plugin/commands/open.md');
  });

  it('allows .claude-plugin/plugin.json', () => {
    assert.equal(sanitizePath(root, '.claude-plugin/plugin.json'), '/tmp/plugin/.claude-plugin/plugin.json');
  });

  it('blocks path traversal with ..', () => {
    assert.equal(sanitizePath(root, '../../etc/passwd'), null);
  });

  it('blocks absolute path injection', () => {
    assert.equal(sanitizePath(root, '/etc/passwd'), null);
  });

  it('blocks Windows-style absolute path injection', () => {
    assert.equal(sanitizePath(root, 'C:\\Windows\\system32'), null);
  });

  it('normalises Windows backslashes', () => {
    const result = sanitizePath(root, 'commands\\open.md');
    assert.equal(result, '/tmp/plugin/commands/open.md');
  });

  it('returns null for empty path', () => {
    assert.equal(sanitizePath(root, ''), null);
  });
});

// ---------------------------------------------------------------------------
// isValidPluginRoot
// ---------------------------------------------------------------------------

describe('isValidPluginRoot', () => {
  let dir;
  before(() => { dir = makeTempPlugin(); });
  after(() => { removeTempPlugin(dir); });

  it('returns true for valid plugin directory', () => {
    assert.ok(isValidPluginRoot(dir));
  });

  it('returns false for directory without plugin.json', () => {
    assert.equal(isValidPluginRoot(os.tmpdir()), false);
  });

  it('returns false for null/undefined', () => {
    assert.equal(isValidPluginRoot(null), false);
    assert.equal(isValidPluginRoot(undefined), false);
  });

  it('returns false for non-existent path', () => {
    assert.equal(isValidPluginRoot('/nonexistent/path/xyz'), false);
  });
});

// ---------------------------------------------------------------------------
// classifyFile
// ---------------------------------------------------------------------------

describe('classifyFile', () => {
  function emptyComponents() {
    return {
      manifest: null,
      commands: [],
      skills: [],
      agents: [],
      hooks: { config: null, scripts: [] },
      mcp: null,
      readme: null,
    };
  }

  it('classifies manifest', () => {
    const c = emptyComponents();
    classifyFile(c, '.claude-plugin/plugin.json', '/x/.claude-plugin/plugin.json');
    assert.ok(c.manifest);
    assert.equal(c.manifest.rel, '.claude-plugin/plugin.json');
  });

  it('classifies command', () => {
    const c = emptyComponents();
    classifyFile(c, 'commands/open.md', '/x/commands/open.md');
    assert.equal(c.commands.length, 1);
    assert.equal(c.commands[0].name, 'open');
  });

  it('classifies skill', () => {
    const c = emptyComponents();
    classifyFile(c, 'skills/plugin-anatomy/SKILL.md', '/x/skills/plugin-anatomy/SKILL.md');
    assert.equal(c.skills.length, 1);
    assert.equal(c.skills[0].name, 'plugin-anatomy');
  });

  it('classifies agent', () => {
    const c = emptyComponents();
    classifyFile(c, 'agents/explorer.md', '/x/agents/explorer.md');
    assert.equal(c.agents.length, 1);
    assert.equal(c.agents[0].name, 'explorer');
  });

  it('classifies hooks config', () => {
    const c = emptyComponents();
    classifyFile(c, 'hooks/hooks.json', '/x/hooks/hooks.json');
    assert.ok(c.hooks.config);
  });

  it('classifies hooks script', () => {
    const c = emptyComponents();
    classifyFile(c, 'hooks/scripts/on-start.sh', '/x/hooks/scripts/on-start.sh');
    assert.equal(c.hooks.scripts.length, 1);
  });

  it('classifies mcp-template', () => {
    const c = emptyComponents();
    classifyFile(c, 'mcp-template.json', '/x/mcp-template.json');
    assert.ok(c.mcp);
  });

  it('classifies readme (case-insensitive)', () => {
    const c = emptyComponents();
    classifyFile(c, 'README.md', '/x/README.md');
    assert.ok(c.readme);
  });

  it('ignores unrecognised files silently', () => {
    const c = emptyComponents();
    classifyFile(c, 'some-random-file.txt', '/x/some-random-file.txt');
    // No crash, nothing classified
    assert.equal(c.manifest, null);
    assert.equal(c.commands.length, 0);
  });
});

// ---------------------------------------------------------------------------
// buildTree (integration — uses real filesystem)
// ---------------------------------------------------------------------------

describe('buildTree', () => {
  let dir;

  before(() => {
    dir = makeTempPlugin();
    // Add some components
    fs.mkdirSync(path.join(dir, 'commands'));
    fs.writeFileSync(path.join(dir, 'commands', 'open.md'), '---\ndescription: Open\n---\n# Open\n');
    fs.mkdirSync(path.join(dir, 'skills', 'my-skill'), { recursive: true });
    fs.writeFileSync(path.join(dir, 'skills', 'my-skill', 'SKILL.md'), '---\nname: my-skill\ndescription: A skill\n---\n');
    fs.writeFileSync(path.join(dir, 'README.md'), '# Test Plugin\n');
    // node_modules should be ignored
    fs.mkdirSync(path.join(dir, 'node_modules', 'some-pkg'), { recursive: true });
    fs.writeFileSync(path.join(dir, 'node_modules', 'some-pkg', 'index.js'), '');
  });

  after(() => { removeTempPlugin(dir); });

  it('returns correct root and name', async () => {
    const tree = await buildTree(dir);
    assert.equal(tree.root, dir);
    assert.equal(tree.name, path.basename(dir));
  });

  it('includes manifest', async () => {
    const { components } = await buildTree(dir);
    assert.ok(components.manifest);
  });

  it('includes command', async () => {
    const { components } = await buildTree(dir);
    assert.equal(components.commands.length, 1);
    assert.equal(components.commands[0].name, 'open');
  });

  it('includes skill', async () => {
    const { components } = await buildTree(dir);
    assert.equal(components.skills.length, 1);
    assert.equal(components.skills[0].name, 'my-skill');
  });

  it('includes readme', async () => {
    const { components } = await buildTree(dir);
    assert.ok(components.readme);
  });

  it('ignores node_modules', async () => {
    const { components } = await buildTree(dir);
    // No command named 'index' from node_modules
    assert.ok(components.commands.every((c) => c.name !== 'index'));
  });
});

// ---------------------------------------------------------------------------
// handleFsRoute — HTTP route handler integration tests
// ---------------------------------------------------------------------------

describe('GET /api/fs/tree', () => {
  let dir;
  before(() => { dir = makeTempPlugin(); });
  after(() => { removeTempPlugin(dir); });

  it('returns 200 with tree for valid plugin root', async () => {
    const req = mockGet(`/api/fs/tree?path=${encodeURIComponent(dir)}`);
    const res = mockRes();
    await handleFsRoute(req, res, req.url);
    assert.equal(res.statusCode, 200);
    assert.ok(res.json.components);
  });

  it('returns 400 when ?path= is missing', async () => {
    const req = mockGet('/api/fs/tree');
    const res = mockRes();
    await handleFsRoute(req, res, req.url);
    assert.equal(res.statusCode, 400);
  });

  it('returns 400 for non-plugin directory', async () => {
    const req = mockGet(`/api/fs/tree?path=${encodeURIComponent(os.tmpdir())}`);
    const res = mockRes();
    await handleFsRoute(req, res, req.url);
    assert.equal(res.statusCode, 400);
  });
});

describe('GET /api/fs/file', () => {
  let dir;
  before(() => {
    dir = makeTempPlugin();
    fs.writeFileSync(path.join(dir, 'README.md'), '# Hello\n');
  });
  after(() => { removeTempPlugin(dir); });

  it('returns 200 with file content', async () => {
    const url = `/api/fs/file?root=${encodeURIComponent(dir)}&path=README.md`;
    const req = mockGet(url);
    const res = mockRes();
    await handleFsRoute(req, res, req.url);
    assert.equal(res.statusCode, 200);
    assert.equal(res.json.content, '# Hello\n');
  });

  it('returns 404 for non-existent file', async () => {
    const url = `/api/fs/file?root=${encodeURIComponent(dir)}&path=nope.md`;
    const req = mockGet(url);
    const res = mockRes();
    await handleFsRoute(req, res, req.url);
    assert.equal(res.statusCode, 404);
  });

  it('returns 403 for path traversal', async () => {
    const url = `/api/fs/file?root=${encodeURIComponent(dir)}&path=../../etc/passwd`;
    const req = mockGet(url);
    const res = mockRes();
    await handleFsRoute(req, res, req.url);
    assert.equal(res.statusCode, 403);
  });
});

describe('PUT /api/fs/file', () => {
  let dir;
  before(() => {
    dir = makeTempPlugin();
    fs.writeFileSync(path.join(dir, 'README.md'), '# Original\n');
  });
  after(() => { removeTempPlugin(dir); });

  it('returns 200 and updates file content', async () => {
    const req = mockWithBody('PUT', '/api/fs/file', {
      root: dir,
      path: 'README.md',
      content: '# Updated\n',
    });
    const res = mockRes();
    await handleFsRoute(req, res, req.url);
    assert.equal(res.statusCode, 200);
    assert.ok(res.json.ok);
    assert.equal(fs.readFileSync(path.join(dir, 'README.md'), 'utf8'), '# Updated\n');
  });

  it('returns 404 for non-existent file', async () => {
    const req = mockWithBody('PUT', '/api/fs/file', {
      root: dir,
      path: 'ghost.md',
      content: 'x',
    });
    const res = mockRes();
    await handleFsRoute(req, res, req.url);
    assert.equal(res.statusCode, 404);
  });

  it('returns 403 for path traversal', async () => {
    const req = mockWithBody('PUT', '/api/fs/file', {
      root: dir,
      path: '../../evil.md',
      content: 'x',
    });
    const res = mockRes();
    await handleFsRoute(req, res, req.url);
    assert.equal(res.statusCode, 403);
  });
});

describe('POST /api/fs/file', () => {
  let dir;
  before(() => { dir = makeTempPlugin(); });
  after(() => { removeTempPlugin(dir); });

  it('returns 201 and creates the file', async () => {
    const req = mockWithBody('POST', '/api/fs/file', {
      root: dir,
      path: 'commands/new-cmd.md',
      content: '---\ndescription: New\n---\n# New\n',
    });
    const res = mockRes();
    await handleFsRoute(req, res, req.url);
    assert.equal(res.statusCode, 201);
    assert.ok(fs.existsSync(path.join(dir, 'commands', 'new-cmd.md')));
  });

  it('returns 409 if file already exists', async () => {
    fs.mkdirSync(path.join(dir, 'commands'), { recursive: true });
    fs.writeFileSync(path.join(dir, 'commands', 'exists.md'), 'x');
    const req = mockWithBody('POST', '/api/fs/file', {
      root: dir,
      path: 'commands/exists.md',
      content: 'y',
    });
    const res = mockRes();
    await handleFsRoute(req, res, req.url);
    assert.equal(res.statusCode, 409);
  });
});

describe('DELETE /api/fs/file', () => {
  let dir;
  before(() => {
    dir = makeTempPlugin();
    fs.writeFileSync(path.join(dir, 'to-delete.md'), 'bye\n');
  });
  after(() => { removeTempPlugin(dir); });

  it('returns 200 and removes the file', async () => {
    const req = mockWithBody('DELETE', '/api/fs/file', { root: dir, path: 'to-delete.md' });
    const res = mockRes();
    await handleFsRoute(req, res, req.url);
    assert.equal(res.statusCode, 200);
    assert.ok(!fs.existsSync(path.join(dir, 'to-delete.md')));
  });

  it('returns 404 for non-existent file', async () => {
    const req = mockWithBody('DELETE', '/api/fs/file', { root: dir, path: 'ghost.md' });
    const res = mockRes();
    await handleFsRoute(req, res, req.url);
    assert.equal(res.statusCode, 404);
  });
});

describe('POST /api/fs/rename', () => {
  let dir;
  before(() => {
    dir = makeTempPlugin();
    fs.writeFileSync(path.join(dir, 'old-name.md'), 'content\n');
  });
  after(() => { removeTempPlugin(dir); });

  it('returns 200 and renames the file', async () => {
    const req = mockWithBody('POST', '/api/fs/rename', {
      root: dir,
      oldPath: 'old-name.md',
      newPath: 'new-name.md',
    });
    const res = mockRes();
    await handleFsRoute(req, res, req.url);
    assert.equal(res.statusCode, 200);
    assert.ok(!fs.existsSync(path.join(dir, 'old-name.md')));
    assert.ok(fs.existsSync(path.join(dir, 'new-name.md')));
  });

  it('returns 403 for path traversal in newPath', async () => {
    const req = mockWithBody('POST', '/api/fs/rename', {
      root: dir,
      oldPath: 'new-name.md',
      newPath: '../../evil.md',
    });
    const res = mockRes();
    await handleFsRoute(req, res, req.url);
    assert.equal(res.statusCode, 403);
  });
});

describe('POST /api/fs/duplicate', () => {
  let dir;
  before(() => {
    dir = makeTempPlugin();
    fs.writeFileSync(path.join(dir, 'original.md'), 'orig\n');
  });
  after(() => { removeTempPlugin(dir); });

  it('returns 201 and duplicates the file', async () => {
    const req = mockWithBody('POST', '/api/fs/duplicate', {
      root: dir,
      sourcePath: 'original.md',
      targetPath: 'copy.md',
    });
    const res = mockRes();
    await handleFsRoute(req, res, req.url);
    assert.equal(res.statusCode, 201);
    assert.ok(fs.existsSync(path.join(dir, 'original.md')));
    assert.ok(fs.existsSync(path.join(dir, 'copy.md')));
    assert.equal(fs.readFileSync(path.join(dir, 'copy.md'), 'utf8'), 'orig\n');
  });

  it('returns 409 if target already exists', async () => {
    fs.writeFileSync(path.join(dir, 'taken.md'), 'x');
    const req = mockWithBody('POST', '/api/fs/duplicate', {
      root: dir,
      sourcePath: 'original.md',
      targetPath: 'taken.md',
    });
    const res = mockRes();
    await handleFsRoute(req, res, req.url);
    assert.equal(res.statusCode, 409);
  });

  it('returns 403 for path traversal in targetPath', async () => {
    const req = mockWithBody('POST', '/api/fs/duplicate', {
      root: dir,
      sourcePath: 'original.md',
      targetPath: '../../evil.md',
    });
    const res = mockRes();
    await handleFsRoute(req, res, req.url);
    assert.equal(res.statusCode, 403);
  });
});

describe('Unknown route', () => {
  it('returns 404 for unrecognised /api/fs/* path', async () => {
    const req = mockGet('/api/fs/unknown-endpoint');
    const res = mockRes();
    await handleFsRoute(req, res, req.url);
    assert.equal(res.statusCode, 404);
  });
});
