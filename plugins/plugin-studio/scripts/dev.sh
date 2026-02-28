#!/usr/bin/env bash
# dev.sh — Development mode launcher for Plugin Studio
# Starts Vite dev server (app/) + Node.js API server (server/) with hot-reload.
# Requires pnpm and Node.js >=18.

set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Pre-flight: pnpm
if ! command -v pnpm &>/dev/null; then
  echo "✗ pnpm is required for dev mode."
  echo "  Install via: npm install -g pnpm"
  exit 1
fi

# Install deps if needed
if [ ! -d "${PLUGIN_ROOT}/server/node_modules" ]; then
  echo "→ Installing server dependencies..."
  pnpm install --prefix "${PLUGIN_ROOT}/server"
fi
if [ ! -d "${PLUGIN_ROOT}/app/node_modules" ]; then
  echo "→ Installing app dependencies..."
  pnpm install --prefix "${PLUGIN_ROOT}/app"
fi

echo "✓ Starting Plugin Studio in development mode"
echo "  API server : tsx watch (hot-reload)"
echo "  Vite app   : http://localhost:5173"
echo ""

# Run both concurrently; Ctrl-C kills both
trap 'kill 0' EXIT

pnpm --prefix "${PLUGIN_ROOT}/server" run dev &
SERVER_PID=$!

pnpm --prefix "${PLUGIN_ROOT}/app" run dev &
APP_PID=$!

wait "${SERVER_PID}" "${APP_PID}"
