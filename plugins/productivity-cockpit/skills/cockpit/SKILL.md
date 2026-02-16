---
name: cockpit
description: Interactive web dashboard with task board, memory viewer, project pulse, and AI chatbot. Runs a local Python bridge server for file I/O and AI queries.
---

# Cockpit Skill

A browser-based dashboard that provides a visual interface for the productivity system.

## Components

| File | Purpose |
|------|---------|
| `index.html` | Main dashboard UI |
| `bridge.py` | Local Python HTTP server (file I/O + AI chatbot proxy) |
| `cockpit.sh` | Launcher for Linux/WSL |
| `cockpit.bat` | Launcher for Windows |
| `.cockpit.json` | Per-project configuration (paths, pulse rules, AI settings) |
| `assets/css/styles.css` | Dashboard styles |
| `assets/js/app.js` | Dashboard logic |

## Features

- **Task Board** — Kanban view of TASKS.md with drag-and-drop, inline editing
- **Memory Viewer** — Browse and edit memory files (glossary, people, projects)
- **Project Pulse** — Health check for expected files and directories
- **AI Chatbot** — Ask questions about your project using any AI CLI or API
- **Spotlight Search** — Ctrl+K to search across tasks, memory, and inventory
- **Focus Timer** — Built-in Pomodoro timer
- **Drift Watcher** — Auto-detects external file changes

## Launching

The cockpit is launched via `/productivity-cockpit:start`, which:

1. Copies `.cockpit.json` to the project root if it doesn't exist
2. Starts `bridge.py` in the background
3. Opens `http://localhost:8001` in the browser

## AI Chatbot Configuration

The chatbot is configured per-project in `.cockpit.json`:

```json
{
  "ai": {
    "mode": "cli",
    "cli": "claude",
    "args": []
  }
}
```

Supported modes:
- **CLI mode** — Calls any AI CLI binary as a subprocess (claude, gemini, copilot, codex, ollama)
- **API mode** — Direct HTTP calls to AI providers (set `"mode": "api"` with `"provider"` and env var for key)

## .cockpit.json Reference

```json
{
  "name": "My Project Cockpit",
  "version": "2.0.0",
  "paths": {
    "tasks": "TASKS.md",
    "memory": "memory",
    "output": "output"
  },
  "pulse_rules": {
    "essential_files": ["README.md"],
    "min_folders": []
  },
  "ai": {
    "mode": "cli",
    "cli": "claude",
    "args": []
  }
}
```

The `paths` section should match your project structure. The cockpit reads these paths relative to your project root.

## Notes

- Bridge server runs on port 8001 (auto-increments if busy)
- All file writes are sandboxed to the project root (path traversal is blocked)
- CORS headers are set for localhost development
- The chatbot sends project context (task state, inventory) with each query
