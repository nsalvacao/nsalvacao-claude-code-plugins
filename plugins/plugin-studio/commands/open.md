---
description: >
  Launch the Plugin Studio visual dashboard. Starts the Node.js server and opens
  the browser UI for editing Claude Code plugins. Accepts an optional [path] argument
  to load a specific plugin directory directly on startup.
argument-hint: "[path]"
allowed-tools: Bash
---

# Plugin Studio: Open

Launch the Plugin Studio dashboard — a browser-based visual editor for Claude Code plugins.

## Usage

- `/plugin-studio:open` — opens dashboard with no plugin pre-loaded
- `/plugin-studio:open [path]` — loads the plugin at `[path]` directly on startup

## What this does

1. **Pre-flight check** — verifies Node.js ≥18 (hard requirement) and detects `plugin-dev` (optional)
2. **Server start** — launches `server/index.js` in the background if not already running
3. **Port detection** — auto-detects next available port from 3847 if default is occupied
4. **Browser open** — opens `http://localhost:{port}` cross-platform (WSL, macOS, Linux)
5. **Plugin load** — if `[path]` is provided, navigates directly to that plugin in the UI

## Pre-flight error messages

If Node.js ≥18 is absent:

```text
✗ Node.js 18+ is required to run Plugin Studio.
  Install via: https://nodejs.org
  Or with fnm: fnm install 22 && fnm use 22
  Or with nvm: nvm install 22 && nvm use 22
```

If `plugin-dev` is absent (non-blocking):

```text
⚠ plugin-dev is not installed. Validation and scaffolding features will be disabled.
  Install: /plugin install plugin-dev
  Plugin Studio will open with limited functionality.
```

## Implementation

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/start.sh" "$ARGUMENTS"
```
