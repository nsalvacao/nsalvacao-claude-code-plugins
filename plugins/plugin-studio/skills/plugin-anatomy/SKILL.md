---
name: plugin-anatomy
description: >
  Knowledge base for the complete anatomy of a Claude Code plugin. Use when
  creating, inspecting, scaffolding, or validating Claude Code plugins. Covers
  the plugin.json manifest, commands, skills, agents, hooks (PreToolUse,
  PostToolUse, SessionStart, Stop, and others), MCP integration, and the
  canonical directory layout. Referenced by Plugin Studio for component-type
  awareness and validation guidance.
version: 0.1.0
---

# Plugin Anatomy — Claude Code Plugin Structure

A Claude Code plugin is a directory installed via `--plugin-dir` that extends
Claude Code with commands, skills, agents, hooks, and MCP integrations.

## Canonical Directory Layout

```text
plugins/<plugin-name>/
├── .claude-plugin/
│   └── plugin.json          # Manifest (required)
├── commands/
│   └── <command-name>.md    # Slash commands (/plugin-name:command-name)
├── skills/
│   └── <skill-name>/
│       └── SKILL.md         # Skill definitions (triggered by Claude)
├── agents/
│   └── <agent-name>.md      # Autonomous subagents
├── hooks/
│   ├── hooks.json           # Hook event configuration
│   └── scripts/             # Bash scripts called by command hooks
├── mcp-template.json        # MCP server configuration template (optional)
├── scripts/                 # Plugin utility scripts (optional)
└── README.md                # Required for marketplace listing
```

## plugin.json — Manifest

Required fields: `name`, `version`, `description`, `author`.

```json
{
  "name": "plugin-name",
  "version": "0.1.0",
  "description": "What this plugin does",
  "author": {
    "name": "Author Name",
    "email": "author@example.com"
  }
}
```

Naming rules: `kebab-case`, lowercase only, no spaces.

## Commands (`commands/*.md`)

Slash commands invoked as `/plugin-name:command-name`.

Required frontmatter field: `description`.

Optional frontmatter fields:

- `argument-hint` — shown in autocomplete (e.g., `"[path]"`)
- `allowed-tools` — tools the command may invoke (e.g., `Bash`, `Read`)
- `model` — override model (`haiku`, `sonnet`, `opus`, or `inherit`)

```markdown
---
description: Short description shown in autocomplete
argument-hint: "[optional-arg]"
allowed-tools: Bash, Read
---

# Command Title

Command body in Markdown. This is the prompt/instructions for Claude.
```

## Skills (`skills/<name>/SKILL.md`)

Skills are passive knowledge loaded when Claude detects the trigger described
in `description`. They are NOT slash commands.

Required frontmatter fields: `name`, `description`.

```markdown
---
name: skill-name
description: >
  Trigger conditions — what user actions or keywords activate this skill.
  Be specific so Claude knows when to load it.
---

# Skill Content

The actual knowledge, guidelines, or instructions Claude should follow.
```

## Agents (`agents/*.md`)

Autonomous subagents spawned by Claude via the Agent tool. They receive a
focused context and available tools defined in their frontmatter.

Required frontmatter fields: `name`, `description`, `model`, `color`.

```markdown
---
name: agent-name
description: Purpose and when to spawn this agent
model: claude-haiku-4-5-20251001
color: blue
tools: Read, Grep, Glob
---

# Agent System Prompt

Instructions for the agent's behaviour and focus.
```

## Hooks (`hooks/hooks.json`)

Event-driven automation. Supported events:

| Event | When |
|-------|------|
| `SessionStart` | Claude Code session begins |
| `SessionEnd` | Session ends |
| `PreToolUse` | Before any tool executes |
| `PostToolUse` | After any tool executes |
| `UserPromptSubmit` | User submits a message |
| `Stop` | Claude finishes a response |
| `SubagentStop` | A subagent finishes |
| `Notification` | System notification |
| `PreCompact` | Before context compaction |

Hook types:

- **`command`** — runs a bash script; supports `$CLAUDE_PLUGIN_ROOT`
- **`prompt`** — LLM-driven decision; supported on Stop, SubagentStop,
  UserPromptSubmit, PreToolUse

```json
{
  "SessionStart": [
    {
      "matcher": ".*",
      "hooks": [
        {
          "type": "command",
          "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/on-start.sh",
          "timeout": 10,
          "description": "Run setup on session start"
        }
      ]
    }
  ]
}
```

## MCP Integration (`mcp-template.json`)

Template for connecting external MCP servers. Users copy and fill in credentials.

```json
{
  "mcpServers": {
    "server-name": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@scope/mcp-server"],
      "env": {
        "API_KEY": "${YOUR_API_KEY}"
      }
    }
  }
}
```

## Plugin Studio Component Types

Plugin Studio uses component-type awareness to provide contextual editing:

| Directory pattern | Component type | Frontmatter |
|-------------------|----------------|-------------|
| `commands/*.md` | Command | `description` (required), `argument-hint`, `allowed-tools`, `model` |
| `skills/*/SKILL.md` | Skill | `name`, `description` (both required) |
| `agents/*.md` | Agent | `name`, `description`, `model`, `color` (all required) |
| `hooks/hooks.json` | Hooks config | JSON (validated by plugin-dev) |
| `.claude-plugin/plugin.json` | Manifest | JSON (validated by plugin-dev) |
| `mcp-template.json` | MCP config | JSON |
