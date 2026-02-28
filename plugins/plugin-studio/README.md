# Plugin Studio

> Visual dashboard for creating and managing Claude Code plugins.

**Status:** 🚧 In development — milestone v0.1 (Core Dashboard MVP)

Plugin Studio is a browser-based UI that runs locally alongside Claude Code.
It lets you browse plugin structure, edit components with syntax highlighting,
validate against `plugin-dev`, and scaffold new plugins via a guided wizard.

## What it does

- **Browse** — tree view of your plugin's anatomy (commands, skills, agents, hooks, MCP)
- **Edit** — Monaco editor with Markdown/JSON/YAML highlighting and auto-save
- **Validate** — live health score powered by `plugin-dev` validators
- **Scaffold** — create new plugins or components from canonical templates (v0.3)
- **AI assist** — Claude CLI integration for skill description suggestions (v0.2)

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed
- Node.js 18+
- `plugin-dev` plugin (optional — enables validation; dashboard works without it)

## Quick start

```bash
# Install Plugin Studio
claude --plugin-dir plugins/plugin-studio

# Launch dashboard
/plugin-studio:open

# Open a specific plugin directly
/plugin-studio:open path/to/your-plugin
```

The dashboard opens at `http://localhost:3847` (or next available port).

## Roadmap

| Milestone | Status | Scope |
|-----------|--------|-------|
| v0.1 — Core Dashboard MVP | 🚧 In progress | Plugin scaffold, Node.js server, filesystem API, 4-panel UI, validation |
| v0.2 — AI Chat | 📋 Planned | Claude CLI integration, chat sidebar, tree context menu |
| v0.3 — Scaffold & Create | 📋 Planned | New plugin wizard, scaffold routes, frontmatter form editor |
| v0.4 — Multi-Provider AI | 📋 Planned | Claude API, Ollama, OpenAI-compat, CLI OAuth providers |

## vs. ClaudeX

[ClaudeX](https://github.com/tct68/claudex) is an alternative with a similar
stack (React + Vite + Tailwind). Plugin Studio differentiates by:

- **Plugin-native** — built as a Claude Code plugin, installed via `--plugin-dir`
- **plugin-dev integration** — validation and scaffolding powered by `plugin-dev`
- **Component-type awareness** — editor adapts to the file type (command, skill, agent)
- **Frontmatter form editor** — visual UI for YAML frontmatter fields (v0.3)

## Contributing

See [CONTRIBUTING.md](../../CONTRIBUTING.md) for contribution guidelines.
Issues for this plugin: [#1–#20](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/issues)

## License

MIT — see [LICENSE](../../LICENSE)
