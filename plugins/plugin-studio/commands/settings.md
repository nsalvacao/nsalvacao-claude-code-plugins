---
description: >
  Open the Plugin Studio settings panel to configure AI providers, API keys,
  and dashboard preferences. Starts the server if not already running.
allowed-tools: Bash
---

# Plugin Studio: Settings

Open the settings panel in the Plugin Studio dashboard.

## What this does

1. Starts the Plugin Studio server if not already running
2. Opens (or focuses) the browser at `http://localhost:{port}/#settings`
3. The settings panel allows configuring:
   - **AI providers** — API keys, CLI OAuth detection, Ollama URL
   - **Default provider** — which AI backend to use for suggestions
   - **Dashboard preferences** — auto-save interval, editor theme

## Settings storage

Settings are stored in `.plugin-studio.config.json` outside the plugin directory.
API keys are **never** committed to version control — the config file is
automatically added to `.gitignore` on first run.

## Implementation

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/start.sh" "--settings"
```
