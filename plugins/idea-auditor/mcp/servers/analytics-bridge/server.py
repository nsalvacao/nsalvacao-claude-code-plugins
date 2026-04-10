#!/usr/bin/env python3
"""analytics-bridge MCP server — idea-auditor v0.5.0

Bridges product analytics providers (PostHog, Mixpanel, Amplitude) to
evidence.schema.json items. Surfaces TTFV/activation/referral signals as
evidence for the friction and loop dimensions.

Tools:
  fetch_events    — fetch product events from analytics provider (stub — v0.6.0)
  fetch_funnels   — fetch activation funnel (TTFV proxy) from analytics provider (stub — v0.6.0)
  fetch_referrals — fetch referral loop metrics (K-factor inputs) (stub — v0.6.0)

Environment:
  ANALYTICS_PROVIDER  — posthog | mixpanel | amplitude (default: posthog)
  ANALYTICS_API_KEY   — provider API key
  ANALYTICS_PROJECT   — project ID / token

All tools are stubs in v0.5.0. Full implementation planned for v0.6.0.
"""

import asyncio
import json

import mcp.server.stdio
import mcp.types as types
from mcp.server import NotificationOptions, Server
from mcp.server.models import InitializationOptions

# ---------------------------------------------------------------------------
# MCP server instance
# ---------------------------------------------------------------------------
app = Server("idea-auditor-analytics-bridge")

# ---------------------------------------------------------------------------
# Tool stubs
# ---------------------------------------------------------------------------

_STUB_NOTE = (
    "Full implementation planned for v0.6.0. "
    "To use now: query your analytics provider directly and load results as "
    "evidence items in STATE/ (format: evidence.schema.json)."
)


def _stub_result(tool: str, extra: dict | None = None) -> dict:
    result = {
        "status": "stub",
        "tool": tool,
        "planned_version": "v0.6.0",
        "message": _STUB_NOTE,
    }
    if extra:
        result.update(extra)
    return result


# ---------------------------------------------------------------------------
# MCP tool definitions
# ---------------------------------------------------------------------------

@app.list_tools()
async def list_tools() -> list[types.Tool]:
    return [
        types.Tool(
            name="fetch_events",
            description=(
                "[STUB — v0.6.0] Fetch product events from PostHog, Mixpanel, or Amplitude. "
                "Will return event counts normalized to evidence.schema.json items "
                "(quality_tier: behavioral, dimension: friction or loop). "
                "Requires ANALYTICS_PROVIDER and ANALYTICS_API_KEY env vars."
            ),
            inputSchema={
                "type": "object",
                "required": ["event_name"],
                "properties": {
                    "event_name": {
                        "type": "string",
                        "description": "Event name to fetch (e.g. 'user_activated', 'feature_used')",
                    },
                    "days": {
                        "type": "integer",
                        "description": "Lookback window in days (default: 30)",
                        "default": 30,
                    },
                    "dimension": {
                        "type": "string",
                        "enum": ["wedge", "friction", "loop", "timing", "trust", "migration"],
                        "description": "Evidence dimension this event maps to",
                    },
                },
            },
        ),
        types.Tool(
            name="fetch_funnels",
            description=(
                "[STUB — v0.6.0] Fetch activation funnel steps from analytics provider. "
                "Will return TTFV (time-to-first-value) and activation rate as evidence items "
                "(quality_tier: behavioral, dimension: friction). "
                "Requires ANALYTICS_PROVIDER and ANALYTICS_API_KEY env vars."
            ),
            inputSchema={
                "type": "object",
                "required": ["funnel_id"],
                "properties": {
                    "funnel_id": {
                        "type": "string",
                        "description": "Funnel identifier in the analytics provider",
                    },
                    "days": {
                        "type": "integer",
                        "description": "Lookback window in days (default: 30)",
                        "default": 30,
                    },
                },
            },
        ),
        types.Tool(
            name="fetch_referrals",
            description=(
                "[STUB — v0.6.0] Fetch referral loop metrics (K-factor inputs) from analytics provider. "
                "Will return invites_per_user and referral_conversion_rate as evidence items "
                "(quality_tier: behavioral, dimension: loop). "
                "Requires ANALYTICS_PROVIDER and ANALYTICS_API_KEY env vars."
            ),
            inputSchema={
                "type": "object",
                "required": [],
                "properties": {
                    "days": {
                        "type": "integer",
                        "description": "Lookback window in days (default: 30)",
                        "default": 30,
                    },
                },
            },
        ),
    ]


@app.call_tool()
async def call_tool(
    name: str, arguments: dict
) -> list[types.TextContent | types.ImageContent | types.EmbeddedResource]:

    if name == "fetch_events":
        result = _stub_result("fetch_events", {"event_name": arguments.get("event_name")})
    elif name == "fetch_funnels":
        result = _stub_result("fetch_funnels", {"funnel_id": arguments.get("funnel_id")})
    elif name == "fetch_referrals":
        result = _stub_result("fetch_referrals")
    else:
        result = {"error": f"Unknown tool: {name}"}

    return [types.TextContent(type="text", text=json.dumps(result, indent=2))]


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

async def _main() -> None:
    async with mcp.server.stdio.stdio_server() as (read_stream, write_stream):
        await app.run(
            read_stream,
            write_stream,
            InitializationOptions(
                server_name="idea-auditor-analytics-bridge",
                server_version="0.5.0",
                capabilities=app.get_capabilities(
                    notification_options=NotificationOptions(),
                    experimental_capabilities={},
                ),
            ),
        )


def main() -> None:
    asyncio.run(_main())


if __name__ == "__main__":
    main()
