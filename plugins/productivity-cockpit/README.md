# Productivity Cockpit Plugin

Task management, workplace memory, and an interactive cockpit dashboard with a built-in AI chatbot. Claude learns your people, projects, and terminology. Works in any project type.

This is an extended version of the **productivity** plugin that adds the cockpit — a browser-based dashboard with task board, memory viewer, project pulse, and an AI chatbot powered by any CLI or API backend you choose.

## Prerequisites

- **Python 3.8+** — Required by the cockpit bridge server (`bridge.py`)

## Installation

```
claude plugin add nsalvacao/nsalvacao-claude-code-plugins/plugins/productivity-cockpit
```

## What It Does

- **Task management** — A markdown task list (`TASKS.md`) with kanban board view
- **Workplace memory** — Two-tier memory system (CLAUDE.md + memory/ directory)
- **Cockpit dashboard** — Browser-based UI with task board, memory viewer, project pulse, focus timer, and spotlight search (Ctrl+K)
- **AI chatbot** — Ask questions about your project from the dashboard, powered by any AI backend (Claude, Gemini, Copilot, Codex, Ollama, or direct API)

## Commands

| Command | What it does |
|---------|--------------|
| `/productivity-cockpit:start` | Initialize tasks + memory, launch the cockpit dashboard |
| `/productivity-cockpit:update` | Triage stale items, check memory gaps, sync from external tools |
| `/productivity-cockpit:update --comprehensive` | Deep scan email, calendar, chat — flag missed todos and suggest new memories |

## Skills

| Skill | Description |
|-------|-------------|
| `cockpit` | Interactive web dashboard with Python bridge server and AI chatbot |
| `memory-management` | Two-tier memory system — CLAUDE.md for working memory, memory/ for deep storage |
| `task-management` | Markdown-based task tracking using TASKS.md |

## Cockpit Dashboard

The cockpit runs as a local web app:

1. **Python bridge** (`bridge.py`) serves the dashboard and handles file I/O + AI queries
2. **Browser UI** renders tasks as a kanban board, memory as browsable cards, and includes a project health pulse check

Launch with `/productivity-cockpit:start` — the bridge starts on port 8001.

## AI Chatbot Configuration

The chatbot backend is configured in `.cockpit.json` at your project root:

### CLI Mode (default)

Calls any AI CLI binary as a subprocess:

```json
{
  "ai": {
    "mode": "cli",
    "cli": "claude",
    "args": []
  }
}
```

Supported CLIs: `claude`, `gemini`, `copilot`, `codex`, `ollama`

### API Mode

Direct HTTP calls to AI providers:

```json
{
  "ai": {
    "mode": "api",
    "provider": "anthropic",
    "model": "claude-sonnet-4-5-20250929"
  }
}
```

Supported providers: `anthropic` (ANTHROPIC_API_KEY), `openai` (OPENAI_API_KEY), `google` (GOOGLE_API_KEY), `ollama` (no key needed)

## MCP Integration (Optional)

Connect external tools for richer context. See [MCP-SETUP.md](MCP-SETUP.md) for setup instructions.

## Configuration

Create `.claude/productivity-cockpit.local.md` in your project root for per-project plugin settings:

```yaml
---
ai_mode: cli
ai_cli: claude
default_scan: comprehensive
---
```

This file is gitignored by default — it stays local to your machine.

## Privacy

All data (tasks, memory, dashboard) is stored as local files in your project directory. The AI chatbot sends project context to whichever backend you configure — no data is sent anywhere unless you explicitly set up an AI provider.
