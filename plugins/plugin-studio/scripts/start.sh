#!/usr/bin/env bash
# start.sh — Production launcher for Plugin Studio
# Usage: start.sh [path|--settings]
# Serves app/dist/ via the Node.js server. No build step required.
#
# NOTE: Full implementation tracked in issue #10 (milestone v0.1).
# This is a scaffold placeholder — server is implemented in issue #2.

set -euo pipefail

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

echo "⚠ Plugin Studio server not yet implemented (milestone v0.1, issue #2)."
echo "  This placeholder confirms Node.js ${node_version} is available."
echo "  Re-run /plugin-studio:open after issue #2 is merged."
exit 0
