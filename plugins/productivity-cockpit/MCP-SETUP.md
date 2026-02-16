# MCP Server Setup

This plugin works best with external tools connected via MCP. Commands include
graceful fallbacks for when no tools are connected — you can always provide context
manually.

## Setup

Copy relevant entries from `mcp-template.json` to your project root `.mcp.json`.
Then add authentication for each service.

> **Note:** The included `mcp-template.json` uses `"type": "http"` with the original
> vendor endpoints. If a vendor supports SSE OAuth, you can switch to `"type": "sse"`
> with the vendor's SSE endpoint URL. Check each vendor's MCP documentation for the
> correct transport type and URL.

### OAuth Services (SSE — browser-based login)

```json
{
  "mcpServers": {
    "slack": { "type": "sse", "url": "https://mcp.slack.com/sse" },
    "linear": { "type": "sse", "url": "https://mcp.linear.app/sse" },
    "notion": { "type": "sse", "url": "https://mcp.notion.com/sse" }
  }
}
```

Run `/mcp` in Claude Code to verify connections.

### Token Services (HTTP — add Bearer token)

```json
{
  "mcpServers": {
    "custom-api": {
      "type": "http",
      "url": "https://api.example.com/mcp",
      "headers": { "Authorization": "Bearer ${MY_API_TOKEN}" }
    }
  }
}
```

Set `MY_API_TOKEN` as an environment variable — never hardcode tokens.

## Available Integrations

| Category | Examples | What it enables |
|----------|----------|----------------|
| Project tracker | Linear, Asana, Jira, ClickUp, monday.com | Task syncing, ticket context |
| Knowledge base | Notion, Confluence | Reference documents, meeting notes |
| Chat | Slack, Teams | Team context, message scanning |
| Email + Calendar | Microsoft 365 | Action item discovery, scheduling |
| Office suite | Microsoft 365 | Document access |

## Without MCP

All commands work without any connected tools. Manage tasks and memory manually —
provide context via paste, upload, or conversation.
