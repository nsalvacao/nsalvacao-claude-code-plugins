/**
 * Plugin Studio — TypeScript dev-mode entry point
 *
 * Used only during development via: pnpm dev (tsx watch src/index.ts)
 * Production uses the pre-compiled server/index.js via: node server/index.js
 *
 * This file is a thin re-export so tsx can pick up type errors during dev.
 * All logic lives in ../index.js to keep the zero-dependency production binary.
 */

// In dev mode tsx transpiles this on the fly; all type checking happens here.
// The actual implementation is in ../index.js (pure Node.js built-ins, no build step).
// If you want to iterate on the server logic with TypeScript type safety,
// move logic into this file and import from it in ../index.js.

export {};
