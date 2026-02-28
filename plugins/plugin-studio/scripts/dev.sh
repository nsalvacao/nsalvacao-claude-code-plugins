#!/usr/bin/env bash
# dev.sh — Development mode launcher for Plugin Studio
# Starts Vite dev server (app/) + Node.js API server (server/) with hot-reload.
# Requires pnpm and Node.js >=18.

set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Pre-flight: Node.js >=18
if ! command -v node &>/dev/null; then
  echo "✗ Node.js 18+ is required to run Plugin Studio."
  echo "  Install via: https://nodejs.org"
  echo "  Or with fnm: fnm install 22 && fnm use 22"
  echo "  Or with nvm: nvm install 22 && nvm use 22"
  exit 1
fi

node_details=$(node -e "console.log(process.versions.node.split('.')[0] + '|' + process.version)")
node_major="${node_details%|*}"
node_version="${node_details#*|}"
if [ "${node_major}" -lt 18 ]; then
  echo "✗ Node.js 18+ is required (found ${node_version})."
  exit 1
fi

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

# Fixed port for dev mode so Vite proxy can target it reliably
export PLUGIN_STUDIO_SERVER_PORT="${PLUGIN_STUDIO_SERVER_PORT:-3847}"

echo "✓ Starting Plugin Studio in development mode"
echo "  API server : tsx watch on port ${PLUGIN_STUDIO_SERVER_PORT} (hot-reload)"
echo "  Vite app   : http://localhost:5173"
echo ""

# Run both concurrently; Ctrl-C kills both
trap 'kill 0' EXIT

pnpm --prefix "${PLUGIN_ROOT}/server" run dev &
SERVER_PID=$!

pnpm --prefix "${PLUGIN_ROOT}/app" run dev &
APP_PID=$!

wait "${SERVER_PID}" "${APP_PID}"
