# Productivity Plugin

Task management, workplace memory, and a visual dashboard for Claude Code. Claude learns your people, projects, and terminology so it acts like a colleague, not a chatbot. Works in any project type.

## Installation

```
claude plugin add nsalvacao/nsalvacao-claude-code-plugins/plugins/productivity
```

## What It Does

- **Task management** — A markdown task list (`TASKS.md`) that Claude reads, writes, and executes against. Add tasks naturally, and Claude tracks status, triages stale items, and syncs with external tools.
- **Workplace memory** — A two-tier memory system that teaches Claude your shorthand, people, projects, and terminology. Say "ask todd to do the PSR for oracle" and Claude knows exactly who, what, and which deal.
- **Visual dashboard** — A local HTML file with a board view of your tasks and a live view of what Claude knows about your workplace.

## Commands

| Command | What it does |
|---------|--------------|
| `/productivity:start` | Initialize tasks + memory, open the dashboard |
| `/productivity:update` | Triage stale items, check memory for gaps, sync from external tools |
| `/productivity:update --comprehensive` | Deep scan email, calendar, chat — flag missed todos and suggest new memories |

## Skills

| Skill | Description |
|-------|-------------|
| `memory-management` | Two-tier memory system — CLAUDE.md for working memory, memory/ directory for deep storage |
| `task-management` | Markdown-based task tracking using a shared TASKS.md file |

## MCP Integration (Optional)

Connect external tools for richer context. Without them, manage tasks and memory manually.

| Category | Examples | What it enables |
|----------|----------|----------------|
| Project tracker | Linear, Asana, Jira, ClickUp | Task syncing, ticket context |
| Knowledge base | Notion, Confluence | Reference documents, meeting notes |
| Chat | Slack, Teams | Team context, message scanning |
| Email + Calendar | Microsoft 365 | Action item discovery, scheduling |

See [MCP-SETUP.md](MCP-SETUP.md) for setup instructions.

## Configuration

Create `.claude/productivity.local.md` in your project root for per-project settings:

```yaml
---
ai_mode: cli
ai_cli: claude
default_scan: comprehensive
---
```

This file is gitignored by default — it stays local to your machine.

## Example Workflows

### Getting Started

```
You: /productivity:start

Claude: [Creates TASKS.md, CLAUDE.md, memory/ directory, and dashboard.html]
        [Opens the dashboard in your browser]
        [Asks about your role, team, and current priorities to seed memory]
```

### Adding Tasks Naturally

```
You: I need to review the budget proposal for Sarah by Friday,
     draft the Q2 roadmap after syncing with Greg, and follow up
     on the API spec from the Platform team

Claude: [Adds all three tasks to TASKS.md with context]
        [Dashboard updates automatically]
```

### Workplace Shorthand

Once memory is populated, Claude decodes your shorthand instantly:

```
You: ask todd to do the PSR for oracle

Claude: "Ask Todd Martinez (Finance lead) to prepare the Pipeline
         Status Report for the Oracle Systems deal ($2.3M, closing Q2)"
```

## Privacy

All data (tasks, memory, dashboard) is stored as local files in your project directory. Nothing is sent to external services unless you explicitly connect MCP integrations.
