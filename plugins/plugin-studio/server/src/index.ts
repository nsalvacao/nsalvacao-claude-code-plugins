/**
 * Plugin Studio — TypeScript dev-mode entry point
 *
 * Used only during development via: pnpm dev (tsx watch src/index.ts)
 * Production uses the pre-compiled server/index.js via: node server/index.js
 *
 * Imports the production entry point so tsx actually starts the server
 * with hot-reload during development.
 */

import '../index.js';
