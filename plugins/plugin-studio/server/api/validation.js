import {
  ValidationEngineError,
  validateAgent,
  validateHealth,
  validateHook,
  validatePlugin,
} from '../lib/plugin-runtime/validation.js';

const MAX_BODY_BYTES = 1024 * 1024;

function parseBody(req) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    let size = 0;

    req.on('data', (chunk) => {
      const buffer = Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk);
      size += buffer.length;
      if (size > MAX_BODY_BYTES) {
        reject(new ValidationEngineError('Request body too large', {
          status: 413,
          code: 'ETOOLARGE',
        }));
        return;
      }
      chunks.push(buffer);
    });

    req.on('end', () => {
      try {
        const raw = Buffer.concat(chunks).toString('utf8');
        resolve(JSON.parse(raw || '{}'));
      } catch {
        reject(new ValidationEngineError('Invalid JSON body', {
          status: 400,
          code: 'EBADJSON',
        }));
      }
    });

    req.on('error', (error) => reject(error));
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

  try {
    if (validationPath === '/plugin' && method === 'POST') {
      const body = await parseBody(req);
      if (!body.root) return sendError(res, 400, 'Body must include root');
      return sendJson(res, 200, await validatePlugin(body.root));
    }

    if (validationPath === '/hook' && method === 'POST') {
      const body = await parseBody(req);
      if (!body.root || !body.path) return sendError(res, 400, 'Body must include root and path');
      return sendJson(res, 200, await validateHook(body.root, body.path));
    }

    if (validationPath === '/agent' && method === 'POST') {
      const body = await parseBody(req);
      if (!body.root || !body.path) return sendError(res, 400, 'Body must include root and path');
      return sendJson(res, 200, await validateAgent(body.root, body.path));
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
    if (error.code === 'ETOOLARGE') return sendError(res, 413, 'Request body too large');

    console.error('[validation-api] Unhandled error:', error);
    return sendError(res, 500, 'Internal server error');
  }
}
