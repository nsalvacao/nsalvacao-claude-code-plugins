import fs from 'node:fs';
import path from 'node:path';
import { buildTree, isValidPluginRoot, sanitizePath } from '../../api/fs.js';

const DEFAULT_TIMEOUT_MS = 30_000;
const DEFAULT_RETRY_COUNT = 1;

const VALID_HOOK_EVENTS = new Set([
  'PreToolUse',
  'PostToolUse',
  'UserPromptSubmit',
  'Stop',
  'SubagentStop',
  'SessionStart',
  'SessionEnd',
  'PreCompact',
  'Notification',
]);

const PROMPT_HOOK_EVENTS = new Set(['Stop', 'SubagentStop', 'UserPromptSubmit', 'PreToolUse']);
const VALID_AGENT_MODELS = new Set(['inherit', 'sonnet', 'opus', 'haiku']);
const VALID_AGENT_COLORS = new Set(['blue', 'cyan', 'green', 'yellow', 'magenta', 'red']);
const TRANSIENT_ERROR_CODES = new Set(['EAGAIN', 'EBUSY', 'EMFILE', 'ENFILE', 'ETXTBSY']);

export class ValidationEngineError extends Error {
  constructor(message, options = {}) {
    super(message, options.cause ? { cause: options.cause } : undefined);
    this.name = 'ValidationEngineError';
    this.code = options.code ?? 'EVALIDATION';
    this.status = options.status ?? 500;
    this.transient = options.transient ?? false;
    this.attempts = options.attempts ?? 1;
  }
}

function escapeRegExp(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

function splitLines(content) {
  return content.split(/\r?\n/);
}

function normalizeLineEndings(content) {
  return content.replace(/\r\n/g, '\n');
}

function stripQuotes(value) {
  if (
    (value.startsWith('"') && value.endsWith('"')) ||
    (value.startsWith("'") && value.endsWith("'"))
  ) {
    return value.slice(1, -1);
  }
  return value;
}

function hasMeaningfulText(value, minimumLength = 1) {
  return value.replace(/\s+/g, ' ').trim().length >= minimumLength;
}

function createIssue({
  severity,
  file = null,
  line = null,
  col = null,
  message,
  source,
}) {
  return { severity, file, line, col, message, source };
}

function dedupeIssues(issues) {
  const seen = new Set();
  return issues.filter((issue) => {
    const key = JSON.stringify([
      issue.severity,
      issue.file,
      issue.line,
      issue.col,
      issue.message,
      issue.source,
    ]);
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });
}

function sortIssues(issues) {
  const weight = { error: 0, warning: 1 };
  return [...issues].sort((left, right) => {
    const severityDelta = (weight[left.severity] ?? 99) - (weight[right.severity] ?? 99);
    if (severityDelta !== 0) return severityDelta;
    const fileDelta = String(left.file ?? '').localeCompare(String(right.file ?? ''));
    if (fileDelta !== 0) return fileDelta;
    return (left.line ?? Number.MAX_SAFE_INTEGER) - (right.line ?? Number.MAX_SAFE_INTEGER);
  });
}

function getStatusFromIssues(issues) {
  if (issues.some((issue) => issue.severity === 'error')) return 'error';
  if (issues.some((issue) => issue.severity === 'warning')) return 'warning';
  return 'passed';
}

function offsetToLineCol(content, offset) {
  const safeOffset = Math.max(0, Math.min(offset, content.length));
  const before = content.slice(0, safeOffset);
  const lines = before.split('\n');
  return {
    line: lines.length,
    col: lines[lines.length - 1].length + 1,
  };
}

function findLineNumber(lines, matcher, startIndex = 0) {
  for (let index = startIndex; index < lines.length; index += 1) {
    const line = lines[index];
    const matched = typeof matcher === 'string' ? line.includes(matcher) : matcher.test(line);
    if (matched) return index + 1;
  }
  return null;
}

function findJsonKeyLine(content, key) {
  return findLineNumber(splitLines(content), new RegExp(`"${escapeRegExp(key)}"\\s*:`));
}

function parseJsonWithLocation(content) {
  try {
    return { value: JSON.parse(content), error: null };
  } catch (error) {
    const match = /position (\d+)/i.exec(error.message);
    const location = match ? offsetToLineCol(content, Number.parseInt(match[1], 10)) : { line: 1, col: 1 };
    return { value: null, error: { message: error.message, ...location } };
  }
}

function parseFrontmatterDocument(content) {
  const normalized = normalizeLineEndings(content);
  const lines = splitLines(normalized);

  if (lines[0] !== '---') {
    return {
      hasFrontmatter: false,
      closed: false,
      fields: new Map(),
      fieldLines: new Map(),
      body: normalized,
      bodyLineStart: 1,
      closingLine: null,
    };
  }

  let closingIndex = -1;
  for (let index = 1; index < lines.length; index += 1) {
    if (lines[index] === '---') {
      closingIndex = index;
      break;
    }
  }

  if (closingIndex === -1) {
    return {
      hasFrontmatter: true,
      closed: false,
      fields: new Map(),
      fieldLines: new Map(),
      body: '',
      bodyLineStart: lines.length + 1,
      closingLine: null,
    };
  }

  const fields = new Map();
  const fieldLines = new Map();
  const frontmatterLines = lines.slice(1, closingIndex);

  for (let index = 0; index < frontmatterLines.length; index += 1) {
    const rawLine = frontmatterLines[index];
    const match = rawLine.match(/^([A-Za-z0-9_-]+):(?:\s*(.*))?$/);
    if (!match) continue;

    const key = match[1];
    const rawValue = match[2] ?? '';
    const absoluteLine = index + 2;
    fieldLines.set(key, absoluteLine);

    if (/^[>|]/.test(rawValue)) {
      const blockLines = [];
      let cursor = index + 1;
      while (cursor < frontmatterLines.length) {
        const candidate = frontmatterLines[cursor];
        if (candidate.trim() && !candidate.startsWith(' ') && !candidate.startsWith('\t')) break;
        blockLines.push(candidate.replace(/^[ \t]{2}/, ''));
        cursor += 1;
      }
      fields.set(key, blockLines.join('\n').trim());
      index = cursor - 1;
      continue;
    }

    fields.set(key, stripQuotes(rawValue.trim()));
  }

  const bodyLines = lines.slice(closingIndex + 1);
  return {
    hasFrontmatter: true,
    closed: true,
    fields,
    fieldLines,
    body: bodyLines.join('\n'),
    bodyLineStart: closingIndex + 2,
    closingLine: closingIndex + 1,
  };
}

function makeCheck(id, name, file, source, run, options = {}) {
  return { id, name, file, source, run, ...options };
}

function toCheckIssue(check, message, severity = 'error', line = null, col = null) {
  return createIssue({
    severity,
    file: check.file,
    line,
    col,
    message,
    source: check.source,
  });
}

function normalizeRelativePath(relPath) {
  return String(relPath).replace(/\\/g, '/');
}

function withTimeout(promise, timeoutMs, label) {
  let timer = null;
  return Promise.race([
    promise,
    new Promise((_, reject) => {
      timer = setTimeout(() => {
        reject(
          new ValidationEngineError(`Validation timed out for ${label}`, {
            code: 'ETIMEDOUT',
            status: 504,
          }),
        );
      }, timeoutMs);
    }),
  ]).finally(() => {
    if (timer) clearTimeout(timer);
  });
}

function formatCheckFailureMessage(check, error) {
  if (error.code === 'ETIMEDOUT') {
    return `Validation check timed out after ${check.timeoutMs ?? DEFAULT_TIMEOUT_MS}ms`;
  }

  if (error.code === 'ENOENT') {
    return `Validation target not found: ${check.file ?? check.name}`;
  }

  if (error.code === 'EACCES') {
    return `Permission denied while reading ${check.file ?? check.name}`;
  }

  return error.message;
}

function isTransientValidationError(error) {
  if (error instanceof ValidationEngineError) return error.transient;
  return TRANSIENT_ERROR_CODES.has(error?.code);
}

function normalizeUnexpectedError(error) {
  if (error instanceof ValidationEngineError) return error;
  return new ValidationEngineError(error.message || 'Unexpected validation error', {
    code: error.code || 'EVALIDATION',
    status: error.code === 'ENOENT' ? 404 : 500,
    transient: TRANSIENT_ERROR_CODES.has(error.code),
    cause: error,
  });
}

export async function runValidationTask(task, options = {}) {
  const timeoutMs = options.timeoutMs ?? DEFAULT_TIMEOUT_MS;
  const retryCount = options.retryCount ?? DEFAULT_RETRY_COUNT;
  const label = options.name ?? 'validation-task';

  let attempt = 0;
  while (attempt <= retryCount) {
    attempt += 1;
    try {
      const result = await withTimeout(Promise.resolve().then(task), timeoutMs, label);
      return { result, attempts: attempt };
    } catch (error) {
      const normalized = normalizeUnexpectedError(error);
      normalized.attempts = attempt;
      if (attempt > retryCount || !isTransientValidationError(normalized)) {
        throw normalized;
      }
    }
  }

  throw new ValidationEngineError(`Validation failed unexpectedly for ${label}`);
}

async function executeCheck(check) {
  const startedAt = Date.now();
  try {
    const { result, attempts } = await runValidationTask(() => check.run(), {
      name: check.id,
      timeoutMs: check.timeoutMs,
      retryCount: check.retryCount,
    });
    const issues = sortIssues(dedupeIssues(result?.issues ?? []));
    return {
      id: check.id,
      name: check.name,
      file: check.file,
      source: check.source,
      status: getStatusFromIssues(issues),
      attempts,
      durationMs: Date.now() - startedAt,
      issues,
    };
  } catch (error) {
    return {
      id: check.id,
      name: check.name,
      file: check.file,
      source: check.source,
      status: 'error',
      attempts: error.attempts ?? 1,
      durationMs: Date.now() - startedAt,
      issues: [
        toCheckIssue(
          check,
          formatCheckFailureMessage(check, error),
          'error',
        ),
      ],
    };
  }
}

async function readTextFile(filePath) {
  return fs.promises.readFile(filePath, 'utf8');
}

async function validateManifestFile(filePath, relPath) {
  const issues = [];
  let content;

  try {
    content = await readTextFile(filePath);
  } catch (error) {
    throw normalizeUnexpectedError(error);
  }

  const { value, error } = parseJsonWithLocation(content);
  if (error) {
    issues.push(
      createIssue({
        severity: 'error',
        file: relPath,
        line: error.line,
        col: error.col,
        message: `Invalid JSON syntax: ${error.message}`,
        source: 'manifest',
      }),
    );
    return { issues };
  }

  const lines = splitLines(content);

  if (typeof value !== 'object' || value === null || Array.isArray(value)) {
    issues.push(
      createIssue({
        severity: 'error',
        file: relPath,
        line: 1,
        col: 1,
        message: 'Manifest must be a JSON object',
        source: 'manifest',
      }),
    );
    return { issues };
  }

  if (!value.name || typeof value.name !== 'string') {
    issues.push(
      createIssue({
        severity: 'error',
        file: relPath,
        line: findJsonKeyLine(content, 'name') ?? 1,
        message: 'Missing required field: name',
        source: 'manifest',
      }),
    );
  } else if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(value.name)) {
    issues.push(
      createIssue({
        severity: 'error',
        file: relPath,
        line: findJsonKeyLine(content, 'name') ?? 1,
        message: 'Manifest name must be kebab-case',
        source: 'manifest',
      }),
    );
  }

  if (!value.version || typeof value.version !== 'string') {
    issues.push(
      createIssue({
        severity: 'error',
        file: relPath,
        line: findJsonKeyLine(content, 'version') ?? 1,
        message: 'Missing required field: version',
        source: 'manifest',
      }),
    );
  } else if (!/^\d+\.\d+\.\d+$/.test(value.version)) {
    issues.push(
      createIssue({
        severity: 'warning',
        file: relPath,
        line: findJsonKeyLine(content, 'version') ?? 1,
        message: 'Version should follow semantic versioning (X.Y.Z)',
        source: 'manifest',
      }),
    );
  }

  if (!value.description || typeof value.description !== 'string' || !value.description.trim()) {
    issues.push(
      createIssue({
        severity: 'error',
        file: relPath,
        line: findJsonKeyLine(content, 'description') ?? 1,
        message: 'Missing required field: description',
        source: 'manifest',
      }),
    );
  }

  if (typeof value.author !== 'object' || value.author === null || Array.isArray(value.author)) {
    issues.push(
      createIssue({
        severity: 'error',
        file: relPath,
        line: findJsonKeyLine(content, 'author') ?? lines.length,
        message: 'Missing required object: author',
        source: 'manifest',
      }),
    );
  } else {
    if (!value.author.name || typeof value.author.name !== 'string') {
      issues.push(
        createIssue({
          severity: 'error',
          file: relPath,
          line: findJsonKeyLine(content, 'author') ?? lines.length,
          message: 'Missing required field: author.name',
          source: 'manifest',
        }),
      );
    }
    if (!value.author.email || typeof value.author.email !== 'string') {
      issues.push(
        createIssue({
          severity: 'error',
          file: relPath,
          line: findJsonKeyLine(content, 'author') ?? lines.length,
          message: 'Missing required field: author.email',
          source: 'manifest',
        }),
      );
    }
  }

  return { issues };
}

async function validateReadmeFile(filePath, relPath) {
  const issues = [];
  let content;

  try {
    content = await readTextFile(filePath);
  } catch (error) {
    throw normalizeUnexpectedError(error);
  }

  if (!hasMeaningfulText(content, 10)) {
    issues.push(
      createIssue({
        severity: 'error',
        file: relPath,
        line: 1,
        message: 'README.md is present but empty or too short',
        source: 'readme',
      }),
    );
  }

  return { issues };
}

async function validateMarkdownComponent(filePath, relPath, componentType) {
  const issues = [];
  const content = await readTextFile(filePath);
  const parsed = parseFrontmatterDocument(content);

  if (!parsed.hasFrontmatter) {
    issues.push(
      createIssue({
        severity: 'error',
        file: relPath,
        line: 1,
        message: 'Missing YAML frontmatter (expected opening ---)',
        source: componentType,
      }),
    );
    return { issues };
  }

  if (!parsed.closed) {
    issues.push(
      createIssue({
        severity: 'error',
        file: relPath,
        line: parsed.closingLine ?? 1,
        message: 'Frontmatter not closed (missing second ---)',
        source: componentType,
      }),
    );
    return { issues };
  }

  if (componentType === 'command') {
    if (!parsed.fields.get('description')) {
      issues.push(
        createIssue({
          severity: 'error',
          file: relPath,
          line: 1,
          message: 'Missing required frontmatter field: description',
          source: componentType,
        }),
      );
    }
  }

  if (componentType === 'skill') {
    if (!parsed.fields.get('name')) {
      issues.push(
        createIssue({
          severity: 'error',
          file: relPath,
          line: 1,
          message: 'Missing required frontmatter field: name',
          source: componentType,
        }),
      );
    }
    if (!parsed.fields.get('description')) {
      issues.push(
        createIssue({
          severity: 'error',
          file: relPath,
          line: 1,
          message: 'Missing required frontmatter field: description',
          source: componentType,
        }),
      );
    }
  }

  if (!hasMeaningfulText(parsed.body, 10)) {
    issues.push(
      createIssue({
        severity: 'error',
        file: relPath,
        line: parsed.bodyLineStart,
        message: 'Markdown body is empty or too short',
        source: componentType,
      }),
    );
  }

  return { issues };
}

async function validateAgentMarkdownFile(filePath, relPath) {
  const issues = [];
  const content = await readTextFile(filePath);
  const parsed = parseFrontmatterDocument(content);

  if (!parsed.hasFrontmatter) {
    issues.push(
      createIssue({
        severity: 'error',
        file: relPath,
        line: 1,
        message: 'File must start with YAML frontmatter (---)',
        source: 'agent',
      }),
    );
    return { issues };
  }

  if (!parsed.closed) {
    issues.push(
      createIssue({
        severity: 'error',
        file: relPath,
        line: parsed.closingLine ?? 1,
        message: 'Frontmatter not closed (missing second ---)',
        source: 'agent',
      }),
    );
    return { issues };
  }

  const name = parsed.fields.get('name');
  if (!name) {
    issues.push(createIssue({
      severity: 'error',
      file: relPath,
      line: 1,
      message: 'Missing required field: name',
      source: 'agent',
    }));
  } else {
    const line = parsed.fieldLines.get('name') ?? 1;
    if (!/^[A-Za-z0-9][A-Za-z0-9-]*[A-Za-z0-9]$/.test(name)) {
      issues.push(createIssue({
        severity: 'error',
        file: relPath,
        line,
        message: 'name must start/end with alphanumeric and contain only letters, numbers, hyphens',
        source: 'agent',
      }));
    }
    if (name.length < 3) {
      issues.push(createIssue({
        severity: 'error',
        file: relPath,
        line,
        message: 'name too short (minimum 3 characters)',
        source: 'agent',
      }));
    } else if (name.length > 50) {
      issues.push(createIssue({
        severity: 'error',
        file: relPath,
        line,
        message: 'name too long (maximum 50 characters)',
        source: 'agent',
      }));
    }
    if (/^(helper|assistant|agent|tool)$/i.test(name)) {
      issues.push(createIssue({
        severity: 'warning',
        file: relPath,
        line,
        message: `name is too generic: ${name}`,
        source: 'agent',
      }));
    }
  }

  const description = parsed.fields.get('description');
  if (!description) {
    issues.push(createIssue({
      severity: 'error',
      file: relPath,
      line: 1,
      message: 'Missing required field: description',
      source: 'agent',
    }));
  } else {
    const line = parsed.fieldLines.get('description') ?? 1;
    if (description.length < 10) {
      issues.push(createIssue({
        severity: 'warning',
        file: relPath,
        line,
        message: 'description too short (minimum 10 characters recommended)',
        source: 'agent',
      }));
    }
    if (!description.includes('<example>')) {
      issues.push(createIssue({
        severity: 'warning',
        file: relPath,
        line,
        message: 'description should include <example> blocks for triggering',
        source: 'agent',
      }));
    }
    if (!/use this agent when/i.test(description)) {
      issues.push(createIssue({
        severity: 'warning',
        file: relPath,
        line,
        message: "description should start with 'Use this agent when...'",
        source: 'agent',
      }));
    }
  }

  const model = parsed.fields.get('model');
  if (!model) {
    issues.push(createIssue({
      severity: 'error',
      file: relPath,
      line: 1,
      message: 'Missing required field: model',
      source: 'agent',
    }));
  } else if (!VALID_AGENT_MODELS.has(model)) {
    issues.push(createIssue({
      severity: 'warning',
      file: relPath,
      line: parsed.fieldLines.get('model') ?? 1,
      message: `Unknown model: ${model} (valid: inherit, sonnet, opus, haiku)`,
      source: 'agent',
    }));
  }

  const color = parsed.fields.get('color');
  if (!color) {
    issues.push(createIssue({
      severity: 'error',
      file: relPath,
      line: 1,
      message: 'Missing required field: color',
      source: 'agent',
    }));
  } else if (!VALID_AGENT_COLORS.has(color)) {
    issues.push(createIssue({
      severity: 'warning',
      file: relPath,
      line: parsed.fieldLines.get('color') ?? 1,
      message: `Unknown color: ${color} (valid: blue, cyan, green, yellow, magenta, red)`,
      source: 'agent',
    }));
  }

  if (!hasMeaningfulText(parsed.body, 20)) {
    issues.push(createIssue({
      severity: 'error',
      file: relPath,
      line: parsed.bodyLineStart,
      message: 'System prompt is empty or too short',
      source: 'agent',
    }));
  } else {
    if (!/You are|You will|Your/.test(parsed.body)) {
      issues.push(createIssue({
        severity: 'warning',
        file: relPath,
        line: parsed.bodyLineStart,
        message: 'System prompt should use second person (You are..., You will..., Your...)',
        source: 'agent',
      }));
    }
    if (!/responsibilities|process|steps/i.test(parsed.body)) {
      issues.push(createIssue({
        severity: 'warning',
        file: relPath,
        line: parsed.bodyLineStart,
        message: 'System prompt should outline responsibilities or process steps',
        source: 'agent',
      }));
    }
  }

  return { issues };
}

async function validateHooksConfigFile(filePath, relPath) {
  const issues = [];
  const content = await readTextFile(filePath);
  const { value, error } = parseJsonWithLocation(content);

  if (error) {
    issues.push(createIssue({
      severity: 'error',
      file: relPath,
      line: error.line,
      col: error.col,
      message: `Invalid JSON syntax: ${error.message}`,
      source: 'hook-schema',
    }));
    return { issues };
  }

  if (typeof value !== 'object' || value === null || Array.isArray(value)) {
    issues.push(createIssue({
      severity: 'error',
      file: relPath,
      line: 1,
      col: 1,
      message: 'hooks.json must be a JSON object',
      source: 'hook-schema',
    }));
    return { issues };
  }

  if (!value.hooks || typeof value.hooks !== 'object' || Array.isArray(value.hooks)) {
    issues.push(createIssue({
      severity: 'error',
      file: relPath,
      line: 1,
      col: 1,
      message: 'hooks.json must use wrapper format: {\"hooks\": {...}}',
      source: 'hook-schema',
    }));
    return { issues };
  }

  for (const [eventName, groups] of Object.entries(value.hooks)) {
    const eventLine = findJsonKeyLine(content, eventName) ?? findJsonKeyLine(content, 'hooks') ?? 1;

    if (!VALID_HOOK_EVENTS.has(eventName)) {
      issues.push(createIssue({
        severity: 'warning',
        file: relPath,
        line: eventLine,
        message: `Unknown event type: ${eventName}`,
        source: 'hook-schema',
      }));
    }

    if (!Array.isArray(groups)) {
      issues.push(createIssue({
        severity: 'error',
        file: relPath,
        line: eventLine,
        message: `Event ${eventName} must be an array`,
        source: 'hook-schema',
      }));
      continue;
    }

    for (const group of groups) {
      if (!group || typeof group !== 'object' || Array.isArray(group)) {
        issues.push(createIssue({
          severity: 'error',
          file: relPath,
          line: eventLine,
          message: `${eventName}: hook group must be an object`,
          source: 'hook-schema',
        }));
        continue;
      }

      if (typeof group.matcher !== 'string' || !group.matcher.trim()) {
        issues.push(createIssue({
          severity: 'error',
          file: relPath,
          line: eventLine,
          message: `${eventName}: Missing 'matcher' field`,
          source: 'hook-schema',
        }));
      }

      if (!Array.isArray(group.hooks)) {
        issues.push(createIssue({
          severity: 'error',
          file: relPath,
          line: eventLine,
          message: `${eventName}: Missing 'hooks' array`,
          source: 'hook-schema',
        }));
        continue;
      }

      for (const hook of group.hooks) {
        if (!hook || typeof hook !== 'object' || Array.isArray(hook)) {
          issues.push(createIssue({
            severity: 'error',
            file: relPath,
            line: eventLine,
            message: `${eventName}: Hook entry must be an object`,
            source: 'hook-schema',
          }));
          continue;
        }

        if (!hook.type) {
          issues.push(createIssue({
            severity: 'error',
            file: relPath,
            line: eventLine,
            message: `${eventName}: Missing 'type' field`,
            source: 'hook-schema',
          }));
          continue;
        }

        if (!['command', 'prompt'].includes(hook.type)) {
          issues.push(createIssue({
            severity: 'error',
            file: relPath,
            line: eventLine,
            message: `${eventName}: Invalid hook type '${hook.type}' (must be 'command' or 'prompt')`,
            source: 'hook-schema',
          }));
          continue;
        }

        if (hook.type === 'command') {
          if (typeof hook.command !== 'string' || !hook.command.trim()) {
            issues.push(createIssue({
              severity: 'error',
              file: relPath,
              line: eventLine,
              message: `${eventName}: Command hooks must have 'command' field`,
              source: 'hook-schema',
            }));
          } else if (
            hook.command.trim().startsWith('/') &&
            !hook.command.includes('${CLAUDE_PLUGIN_ROOT}')
          ) {
            issues.push(createIssue({
              severity: 'warning',
              file: relPath,
              line: eventLine,
              message: `${eventName}: Hardcoded absolute path detected. Consider using \${CLAUDE_PLUGIN_ROOT}`,
              source: 'hook-schema',
            }));
          }
        }

        if (hook.type === 'prompt') {
          if (typeof hook.prompt !== 'string' || !hook.prompt.trim()) {
            issues.push(createIssue({
              severity: 'error',
              file: relPath,
              line: eventLine,
              message: `${eventName}: Prompt hooks must have 'prompt' field`,
              source: 'hook-schema',
            }));
          }
          if (!PROMPT_HOOK_EVENTS.has(eventName)) {
            issues.push(createIssue({
              severity: 'warning',
              file: relPath,
              line: eventLine,
              message: `${eventName}: Prompt hooks may not be fully supported on this event`,
              source: 'hook-schema',
            }));
          }
        }

        if (hook.timeout !== undefined && hook.timeout !== null) {
          if (!Number.isInteger(hook.timeout)) {
            issues.push(createIssue({
              severity: 'error',
              file: relPath,
              line: eventLine,
              message: `${eventName}: Timeout must be an integer number`,
              source: 'hook-schema',
            }));
          } else if (hook.timeout > 600) {
            issues.push(createIssue({
              severity: 'warning',
              file: relPath,
              line: eventLine,
              message: `${eventName}: Timeout ${hook.timeout} seconds is very high (max 600s)`,
              source: 'hook-schema',
            }));
          } else if (hook.timeout < 5) {
            issues.push(createIssue({
              severity: 'warning',
              file: relPath,
              line: eventLine,
              message: `${eventName}: Timeout ${hook.timeout} seconds is very low`,
              source: 'hook-schema',
            }));
          }
        }
      }
    }
  }

  return { issues };
}

async function validateHookScriptFile(filePath, relPath) {
  const issues = [];
  const content = await readTextFile(filePath);
  const lines = splitLines(content);

  if (!lines[0]?.startsWith('#!')) {
    issues.push(createIssue({
      severity: 'error',
      file: relPath,
      line: 1,
      message: 'Missing shebang (#!/usr/bin/env bash or similar)',
      source: 'hook-linter',
    }));
  }

  if (!content.includes('set -euo pipefail')) {
    issues.push(createIssue({
      severity: 'warning',
      file: relPath,
      line: 1,
      message: "Missing 'set -euo pipefail' (recommended for safety)",
      source: 'hook-linter',
    }));
  }

  if (!/\b(cat|read)\b/.test(content)) {
    issues.push(createIssue({
      severity: 'warning',
      file: relPath,
      line: 1,
      message: "Script doesn't appear to read input from stdin",
      source: 'hook-linter',
    }));
  }

  if (/(tool_input|tool_name)/.test(content) && !/\bjq\b/.test(content)) {
    issues.push(createIssue({
      severity: 'warning',
      file: relPath,
      line: findLineNumber(lines, /(tool_input|tool_name)/) ?? 1,
      message: "Script parses hook input but doesn't use jq",
      source: 'hook-linter',
    }));
  }

  const hardcodedPathLine = findLineNumber(lines, /\/(home|usr|opt)\//);
  if (hardcodedPathLine) {
    issues.push(createIssue({
      severity: 'warning',
      file: relPath,
      line: hardcodedPathLine,
      message: 'Hardcoded absolute paths detected. Use $CLAUDE_PROJECT_DIR or $CLAUDE_PLUGIN_ROOT',
      source: 'hook-linter',
    }));
  }

  if (!/\bexit\s+(0|2)\b/.test(content)) {
    issues.push(createIssue({
      severity: 'warning',
      file: relPath,
      line: lines.length,
      message: 'No explicit exit codes detected (hooks should exit 0 or 2)',
      source: 'hook-linter',
    }));
  }

  const longRunningLine = findLineNumber(lines, /(sleep\s+[0-9]{3,}|while true)/);
  if (longRunningLine) {
    issues.push(createIssue({
      severity: 'warning',
      file: relPath,
      line: longRunningLine,
      message: 'Potentially long-running code detected; hooks should complete quickly',
      source: 'hook-linter',
    }));
  }

  const errorEchoLine = findLineNumber(lines, /echo .*?(error|Error|denied|Denied)/);
  if (errorEchoLine && !content.includes('>&2')) {
    issues.push(createIssue({
      severity: 'warning',
      file: relPath,
      line: errorEchoLine,
      message: 'Error messages should be written to stderr (>&2)',
      source: 'hook-linter',
    }));
  }

  return { issues };
}

function buildPluginChecks(root, tree) {
  const checks = [];
  const manifest = tree.components.manifest;
  const readme = tree.components.readme;

  checks.push(
    makeCheck(
      'manifest',
      'Manifest validation',
      manifest?.rel ?? '.claude-plugin/plugin.json',
      'manifest',
      async () => {
        if (!manifest) {
          return {
            issues: [createIssue({
              severity: 'error',
              file: '.claude-plugin/plugin.json',
              line: null,
              col: null,
              message: 'Missing plugin manifest (.claude-plugin/plugin.json)',
              source: 'manifest',
            })],
          };
        }
        return validateManifestFile(manifest.path, manifest.rel);
      },
    ),
  );

  checks.push(
    makeCheck(
      'readme',
      'README presence',
      readme?.rel ?? 'README.md',
      'readme',
      async () => {
        if (!readme) {
          return {
            issues: [createIssue({
              severity: 'error',
              file: 'README.md',
              line: null,
              col: null,
              message: 'Missing README.md',
              source: 'readme',
            })],
          };
        }
        return validateReadmeFile(readme.path, readme.rel);
      },
    ),
  );

  checks.push(
    makeCheck(
      'components',
      'Component presence',
      null,
      'structure',
      async () => {
        const hasComponents =
          tree.components.commands.length > 0 ||
          tree.components.skills.length > 0 ||
          tree.components.agents.length > 0 ||
          Boolean(tree.components.hooks.config) ||
          tree.components.hooks.scripts.length > 0 ||
          Boolean(tree.components.mcp);

        return {
          issues: hasComponents
            ? []
            : [createIssue({
                severity: 'error',
                file: null,
                line: null,
                col: null,
                message: 'Plugin must include at least one functional component (command, skill, agent, hook, or MCP config)',
                source: 'structure',
              })],
        };
      },
    ),
  );

  for (const command of tree.components.commands) {
    checks.push(
      makeCheck(
        `command:${command.rel}`,
        `Command frontmatter: ${command.name}`,
        command.rel,
        'command',
        () => validateMarkdownComponent(command.path, command.rel, 'command'),
      ),
    );
  }

  for (const skill of tree.components.skills) {
    checks.push(
      makeCheck(
        `skill:${skill.rel}`,
        `Skill frontmatter: ${skill.name}`,
        skill.rel,
        'skill',
        () => validateMarkdownComponent(skill.path, skill.rel, 'skill'),
      ),
    );
  }

  if (tree.components.hooks.config) {
    checks.push(
      makeCheck(
        `hooks:${tree.components.hooks.config.rel}`,
        'Hook configuration',
        tree.components.hooks.config.rel,
        'hook-schema',
        () => validateHooksConfigFile(tree.components.hooks.config.path, tree.components.hooks.config.rel),
      ),
    );
  }

  for (const agent of tree.components.agents) {
    checks.push(
      makeCheck(
        `agent:${agent.rel}`,
        `Agent validation: ${agent.name}`,
        agent.rel,
        'agent',
        () => validateAgentMarkdownFile(agent.path, agent.rel),
      ),
    );
  }

  for (const script of tree.components.hooks.scripts) {
    checks.push(
      makeCheck(
        `hook-script:${script.rel}`,
        `Hook script lint: ${script.name}`,
        script.rel,
        'hook-linter',
        () => validateHookScriptFile(script.path, script.rel),
      ),
    );
  }

  return checks;
}

function summarizeChecks(root, checks) {
  const issues = sortIssues(dedupeIssues(checks.flatMap((check) => check.issues)));
  const summary = {
    score: checks.length === 0 ? 100 : Math.round((checks.filter((check) => check.status === 'passed').length / checks.length) * 100),
    totalChecks: checks.length,
    passedChecks: checks.filter((check) => check.status === 'passed').length,
    warnings: issues.filter((issue) => issue.severity === 'warning').length,
    errors: issues.filter((issue) => issue.severity === 'error').length,
  };

  return {
    ok: summary.errors === 0,
    plugin: { root, name: path.basename(root) },
    summary,
    issues,
    checks,
  };
}

async function ensurePluginRoot(root) {
  if (!root || typeof root !== 'string') {
    throw new ValidationEngineError('Missing plugin root', { status: 400, code: 'EBADREQUEST' });
  }
  if (!await isValidPluginRoot(root)) {
    throw new ValidationEngineError('Invalid plugin root', { status: 403, code: 'EINVALROOT' });
  }
}

async function ensureTypedFile(root, relPath, expected) {
  if (!relPath || typeof relPath !== 'string') {
    throw new ValidationEngineError('Missing file path', { status: 400, code: 'EBADREQUEST' });
  }

  const normalizedRelPath = normalizeRelativePath(relPath);
  const safePath = sanitizePath(root, normalizedRelPath);
  if (!safePath) {
    throw new ValidationEngineError('Path outside plugin root', { status: 403, code: 'EPATH' });
  }

  if (expected === 'hook' && normalizedRelPath !== 'hooks/hooks.json') {
    throw new ValidationEngineError('Hook validation expects path "hooks/hooks.json"', {
      status: 400,
      code: 'EBADREQUEST',
    });
  }

  if (expected === 'agent' && !/^agents\/[^/]+\.md$/.test(normalizedRelPath)) {
    throw new ValidationEngineError('Agent validation expects a file under agents/*.md', {
      status: 400,
      code: 'EBADREQUEST',
    });
  }

  return { safePath, relPath: normalizedRelPath };
}

export async function validatePlugin(root) {
  await ensurePluginRoot(root);
  const tree = await buildTree(root);
  const checks = await Promise.all(buildPluginChecks(root, tree).map((check) => executeCheck(check)));
  return summarizeChecks(root, checks);
}

export async function validateHealth(root) {
  return validatePlugin(root);
}

export async function validateHook(root, relPath) {
  await ensurePluginRoot(root);
  const { safePath: filePath, relPath: normalizedRelPath } = await ensureTypedFile(root, relPath, 'hook');
  const check = await executeCheck(
    makeCheck(
      `hooks:${normalizedRelPath}`,
      'Hook configuration',
      normalizedRelPath,
      'hook-schema',
      () => validateHooksConfigFile(filePath, normalizedRelPath),
    ),
  );
  return summarizeChecks(root, [check]);
}

export async function validateAgent(root, relPath) {
  await ensurePluginRoot(root);
  const { safePath: filePath, relPath: normalizedRelPath } = await ensureTypedFile(root, relPath, 'agent');
  const check = await executeCheck(
    makeCheck(
      `agent:${normalizedRelPath}`,
      'Agent validation',
      normalizedRelPath,
      'agent',
      () => validateAgentMarkdownFile(filePath, normalizedRelPath),
    ),
  );
  return summarizeChecks(root, [check]);
}
