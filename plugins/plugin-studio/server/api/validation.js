import {
  ValidationEngineError,
  validateAgent,
  validateHealth,
  validateHook,
  validatePlugin,
} from '../lib/plugin-runtime/validation.js';

const MAX_BODY_BYTES = 1024 * 1024;
const BODY_TIMEOUT_MS = 10_000;

const POST_VALIDATORS = {
  '/plugin': {
    requiredFields: ['root'],
    run: (body) => validatePlugin(body.root),
  },
  '/hook': {
    requiredFields: ['root', 'path'],
    run: (body) => validateHook(body.root, body.path),
  },
  '/agent': {
    requiredFields: ['root', 'path'],
    run: (body) => validateAgent(body.root, body.path),
  },
};

function armBodyTimeout(req, onTimeout) {
  if (typeof req.setTimeout === 'function') {
    req.setTimeout(BODY_TIMEOUT_MS, onTimeout);
    return () => req.setTimeout(0);
  }

  const timer = setTimeout(onTimeout, BODY_TIMEOUT_MS);
  return () => clearTimeout(timer);
}

function formatRequiredFieldsMessage(fields) {
  return `Body must include ${fields.join(' and ')}`;
}

function ensureBodyFields(body, fields) {
  const hasMissingField = fields.some((field) => !body?.[field]);
  if (!hasMissingField) return;

  throw new ValidationEngineError(formatRequiredFieldsMessage(fields), {
    status: 400,
    code: 'EBADREQUEST',
  });
}

function parseBody(req) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    let size = 0;
    let settled = false;

    const clearBodyTimeout = armBodyTimeout(req, () => {
      finish(reject, new ValidationEngineError('Request body timeout', {
        status: 408,
        code: 'EBODYTIMEOUT',
      }));
    });

    const cleanup = () => {
      clearBodyTimeout();
      req.off('data', onData);
      req.off('end', onEnd);
      req.off('error', onError);
    };

    const finish = (callback, value) => {
      if (settled) return;
      settled = true;
      cleanup();
      callback(value);
    };

    function onData(chunk) {
      const buffer = Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk);
      size += buffer.length;
      if (size > MAX_BODY_BYTES) {
        finish(reject, new ValidationEngineError('Request body too large', {
          status: 413,
          code: 'ETOOLARGE',
        }));
        return;
      }
      chunks.push(buffer);
    }

    function onEnd() {
      try {
        const raw = Buffer.concat(chunks).toString('utf8');
        finish(resolve, JSON.parse(raw || '{}'));
      } catch {
        finish(reject, new ValidationEngineError('Invalid JSON body', {
          status: 400,
          code: 'EBADJSON',
        }));
      }
    }

    function onError(error) {
      finish(reject, error);
    }

    req.on('data', onData);
    req.on('end', onEnd);
    req.on('error', onError);
  });
}

function sendJson(res, status, data) {
  res.writeHead(status, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(data));
}

function sendError(res, status, message) {
  sendJson(res, status, { error: message });
}

export async function handleValidationRoute(req, res, url) {
  const parsedUrl = new URL(url, 'http://localhost');
  const validationPath = parsedUrl.pathname.replace(/^\/api\/validate/, '') || '/';
  const method = (req.method ?? 'GET').toUpperCase();
  const postValidator = POST_VALIDATORS[validationPath];

  try {
    if (method === 'POST' && postValidator) {
      const body = await parseBody(req);
      ensureBodyFields(body, postValidator.requiredFields);
      return sendJson(res, 200, await postValidator.run(body));
    }

    if (validationPath === '/health' && method === 'GET') {
      const root = parsedUrl.searchParams.get('root');
      if (!root) return sendError(res, 400, 'Missing ?root= query parameter');
      return sendJson(res, 200, await validateHealth(root));
    }

    return sendError(res, 404, `Unknown route: ${method} /api/validate${validationPath}`);
  } catch (error) {
    if (error instanceof ValidationEngineError) {
      return sendError(res, error.status, error.message);
    }

    if (error.code === 'ENOENT') return sendError(res, 404, 'File not found');
    if (error.code === 'EACCES') return sendError(res, 403, 'Permission denied');
    if (error.code === 'ETIMEDOUT') return sendError(res, 504, 'Validation timed out');

    console.error('[validation-api] Unhandled error:', error);
    return sendError(res, 500, 'Internal server error');
  }
}
