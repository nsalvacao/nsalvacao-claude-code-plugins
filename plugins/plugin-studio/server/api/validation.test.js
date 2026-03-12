import { after, before, describe, it } from 'node:test';
import assert from 'node:assert/strict';
import { EventEmitter } from 'node:events';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

import { handleValidationRoute } from './validation.js';
import {
  ValidationEngineError,
  runValidationTask,
  validateAgent,
  validateHook,
  validatePlugin,
} from '../lib/plugin-runtime/validation.js';

function writeFile(filePath, content) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, content, 'utf8');
}

function createPlugin(options = {}) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'ps-validate-'));

  writeFile(
    path.join(dir, '.claude-plugin', 'plugin.json'),
    JSON.stringify(
      options.manifest ?? {
        name: 'test-plugin',
        version: '0.1.0',
        description: 'Test plugin for validation',
        author: { name: 'Test User', email: 'test@example.com' },
      },
      null,
      2,
    ),
  );

  if (options.readme !== false) {
    writeFile(
      path.join(dir, 'README.md'),
      typeof options.readme === 'string'
        ? options.readme
        : '# Test Plugin\n\nThis README documents the plugin.\n',
    );
  }

  if (options.command !== false) {
    writeFile(
      path.join(dir, 'commands', 'open.md'),
      options.command ??
        '---\ndescription: Open the plugin\n---\n# Open\n\nUse this command to open the plugin.\n',
    );
  }

  if (options.hooks !== false) {
    writeFile(
      path.join(dir, 'hooks', 'hooks.json'),
      options.hooks ??
        JSON.stringify(
          {
            hooks: {
              SessionStart: [
                {
                  matcher: '.*',
                  hooks: [
                    {
                      type: 'command',
                      command: 'bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/on-start.sh',
                      timeout: 5,
                    },
                  ],
                },
              ],
            },
          },
          null,
          2,
        ),
    );
  }

  if (options.agent !== false) {
    writeFile(
      path.join(dir, 'agents', 'plugin-editor.md'),
      options.agent ??
        [
          '---',
          'name: plugin-editor',
          'description: |',
          '  Use this agent when the user wants plugin validation.',
          '  <example>',
          '  user: "Validate the plugin"',
          '  </example>',
          'model: inherit',
          'color: blue',
          '---',
          'You are a plugin editor.',
          '',
          'Responsibilities:',
          '1. Validate plugin structure.',
          '2. Report findings clearly.',
          '',
          'Output format: concise.',
          '',
        ].join('\n'),
    );
  }

  if (options.hookScript) {
    writeFile(path.join(dir, 'hooks', 'scripts', 'on-start.sh'), options.hookScript);
  }

  return dir;
}

function removePlugin(dir) {
  fs.rmSync(dir, { recursive: true, force: true });
}

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

function mockGet(url) {
  const req = new EventEmitter();
  req.method = 'GET';
  req.url = url;
  req.headers = {};
  return req;
}

function mockRes() {
  return {
    statusCode: null,
    _body: '',
    writeHead(status) {
      this.statusCode = status;
    },
    end(data = '') {
      this._body = data;
    },
    get json() {
      return JSON.parse(this._body || 'null');
    },
  };
}

describe('runValidationTask', () => {
  it('retries once for transient errors', async () => {
    let attempts = 0;

    const { result, attempts: completedAttempts } = await runValidationTask(() => {
      attempts += 1;
      if (attempts === 1) {
        throw new ValidationEngineError('busy', {
          code: 'EBUSY',
          transient: true,
        });
      }
      return 'ok';
    }, { name: 'transient-check' });

    assert.equal(result, 'ok');
    assert.equal(completedAttempts, 2);
  });

  it('fails fast on timeout', async () => {
    await assert.rejects(
      runValidationTask(
        () => new Promise(() => {}),
        { name: 'timeout-check', timeoutMs: 20, retryCount: 0 },
      ),
      (error) => error instanceof ValidationEngineError && error.code === 'ETIMEDOUT',
    );
  });
});

describe('validation engine', () => {
  let validPlugin;

  before(() => {
    validPlugin = createPlugin();
  });

  after(() => {
    removePlugin(validPlugin);
  });

  it('validates a complete plugin successfully', async () => {
    const result = await validatePlugin(validPlugin);

    assert.equal(result.ok, true);
    assert.equal(result.summary.errors, 0);
    assert.ok(result.summary.totalChecks >= 4);
    assert.equal(result.issues.length, 0);
  });

  it('returns line-aware issues for invalid hooks', async () => {
    const plugin = createPlugin({
      hooks: JSON.stringify(
        {
          hooks: {
            SessionStart: [
              {
                hooks: [{ type: 'command', command: '/tmp/script.sh' }],
              },
            ],
          },
        },
        null,
        2,
      ),
      agent: false,
    });

    try {
      const result = await validateHook(plugin, 'hooks/hooks.json');
      assert.equal(result.ok, false);
      assert.equal(result.summary.errors, 1);
      assert.ok(result.issues[0].line !== null);
      assert.equal(result.issues[0].file, 'hooks/hooks.json');
    } finally {
      removePlugin(plugin);
    }
  });

  it('returns structured agent validation errors', async () => {
    const plugin = createPlugin({
      agent: [
        '---',
        'name: helper',
        'description: short',
        'model: inherit',
        '---',
        'tiny',
        '',
      ].join('\n'),
      hooks: false,
    });

    try {
      const result = await validateAgent(plugin, 'agents/plugin-editor.md');
      assert.equal(result.ok, false);
      assert.ok(result.issues.some((issue) => issue.message.includes('Missing required field: color')));
      assert.ok(result.issues.some((issue) => issue.severity === 'warning'));
    } finally {
      removePlugin(plugin);
    }
  });

  it('surfaces plugin-wide issues with files and score', async () => {
    const plugin = createPlugin({
      readme: false,
      command: '---\nargument-hint: "[path]"\n---\n# Broken\n',
      hooks: false,
      agent: false,
    });

    try {
      const result = await validatePlugin(plugin);
      assert.equal(result.ok, false);
      assert.ok(result.summary.score < 100);
      assert.ok(result.issues.some((issue) => issue.file === 'README.md'));
      assert.ok(result.issues.some((issue) => issue.file === 'commands/open.md'));
    } finally {
      removePlugin(plugin);
    }
  });
});

describe('validation api routes', () => {
  let plugin;

  before(() => {
    plugin = createPlugin();
  });

  after(() => {
    removePlugin(plugin);
  });

  it('POST /api/validate/plugin returns validation result', async () => {
    const req = mockWithBody('POST', '/api/validate/plugin', { root: plugin });
    const res = mockRes();

    await handleValidationRoute(req, res, req.url);

    assert.equal(res.statusCode, 200);
    assert.equal(res.json.ok, true);
    assert.ok(res.json.summary.totalChecks >= 4);
  });

  it('GET /api/validate/health returns the same summary model', async () => {
    const req = mockGet(`/api/validate/health?root=${encodeURIComponent(plugin)}`);
    const res = mockRes();

    await handleValidationRoute(req, res, req.url);

    assert.equal(res.statusCode, 200);
    assert.equal(typeof res.json.summary.score, 'number');
    assert.equal(typeof res.json.summary.passedChecks, 'number');
  });

  it('POST /api/validate/hook rejects missing path', async () => {
    const req = mockWithBody('POST', '/api/validate/hook', { root: plugin });
    const res = mockRes();

    await handleValidationRoute(req, res, req.url);

    assert.equal(res.statusCode, 400);
    assert.equal(res.json.error, 'Body must include root and path');
  });
});
