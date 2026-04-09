#!/usr/bin/env python3
"""evidence-harvester MCP server — idea-auditor v0.4.0

Fetches external evidence signals and normalizes them to evidence.schema.json format.

Tools:
  github_repo_stats   — GitHub star/fork/contributor velocity, security posture
  registry_downloads  — npm/pypi/homebrew weekly download counts (stub — v0.5.0)
  trend_snapshot      — GitHub trending & Google Trends signals (stub — v0.5.0)
  competitor_scan     — competitor metric list normalized to same proxies (stub — v0.5.0)

Environment:
  GITHUB_TOKEN — optional; absent → rate-limited to 60 req/h

Cache:
  STATE/.cache/evidence-harvester/<key>-<date>.json — TTL daily (auto-created)
"""

import asyncio
import json
import os
import sys
import urllib.request
import urllib.error
from datetime import date, datetime, timezone
from pathlib import Path

import mcp.server.stdio
import mcp.types as types
from mcp.server import NotificationOptions, Server
from mcp.server.models import InitializationOptions

# ---------------------------------------------------------------------------
# MCP server instance
# ---------------------------------------------------------------------------
app = Server("idea-auditor-evidence-harvester")

# ---------------------------------------------------------------------------
# Shared helpers
# ---------------------------------------------------------------------------
GITHUB_API = "https://api.github.com"
TODAY = date.today().isoformat()


def _cache_path(key: str, state_dir: str | None = None) -> Path:
    base = Path(state_dir) if state_dir else Path("STATE")
    cache_dir = base / ".cache" / "evidence-harvester"
    cache_dir.mkdir(parents=True, exist_ok=True)
    safe_key = key.replace("/", "_").replace(":", "_")
    return cache_dir / f"{safe_key}-{TODAY}.json"


def _cache_load(key: str, state_dir: str | None = None) -> dict | None:
    path = _cache_path(key, state_dir)
    if path.exists():
        try:
            return json.loads(path.read_text())
        except Exception:
            return None
    return None


def _cache_save(key: str, data: dict, state_dir: str | None = None) -> None:
    try:
        _cache_path(key, state_dir).write_text(json.dumps(data, indent=2))
    except Exception:
        pass


def _github_get(path: str) -> dict | list | None:
    token = os.environ.get("GITHUB_TOKEN")
    url = f"{GITHUB_API}{path}"
    req = urllib.request.Request(url)
    req.add_header("Accept", "application/vnd.github+json")
    req.add_header("X-GitHub-Api-Version", "2022-11-28")
    if token:
        req.add_header("Authorization", f"Bearer {token}")
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            return json.loads(resp.read())
    except urllib.error.HTTPError as e:
        return {"error": f"HTTP {e.code}: {e.reason}", "url": url}
    except Exception as e:
        return {"error": str(e), "url": url}


def _to_evidence_item(
    claim: str,
    source: str,
    method: str,
    collected_at: str,
    quality_tier: str,
    dimension: str | None,
    raw: dict | None,
    normalized: str | None,
) -> dict:
    """Build an evidence.schema.json-conformant item."""
    return {
        "claim": claim,
        "source": source,
        "method": method,
        "collected_at": collected_at,
        "quality_tier": quality_tier,
        "dimension": dimension,
        "raw": json.dumps(raw) if raw else None,
        "normalized": normalized,
        "confidence_components": None,
    }


# ---------------------------------------------------------------------------
# Tool: github_repo_stats
# ---------------------------------------------------------------------------

def _fetch_github_repo_stats(repo: str, state_dir: str | None) -> dict:
    cache_key = f"github_repo_{repo}"
    cached = _cache_load(cache_key, state_dir)
    if cached:
        return {**cached, "cache_hit": True}

    repo_data = _github_get(f"/repos/{repo}")
    if not repo_data or "error" in repo_data:
        return {"error": repo_data.get("error") if repo_data else "no data", "repo": repo}

    # Contributors (last 90 days via stats/contributors — can be slow)
    contrib_data = _github_get(f"/repos/{repo}/stats/contributors")
    active_contributors = 0
    if isinstance(contrib_data, list):
        cutoff = datetime.now(timezone.utc).timestamp() - 90 * 86400
        for c in contrib_data:
            weeks = c.get("weeks", [])
            recent = [w for w in weeks if w.get("w", 0) >= cutoff and w.get("c", 0) > 0]
            if recent:
                active_contributors += 1

    # Security signals
    has_security_md = False
    contents = _github_get(f"/repos/{repo}/contents/SECURITY.md")
    if isinstance(contents, dict) and "name" in contents:
        has_security_md = True

    # Latest release
    latest_release = _github_get(f"/repos/{repo}/releases/latest")
    last_release_date = None
    last_release_days = None
    if isinstance(latest_release, dict) and "published_at" in latest_release:
        last_release_date = latest_release["published_at"][:10]
        try:
            rel_date = date.fromisoformat(last_release_date)
            last_release_days = (date.today() - rel_date).days
        except ValueError:
            pass

    result = {
        "repo": repo,
        "fetched_at": TODAY,
        "stars": repo_data.get("stargazers_count"),
        "forks": repo_data.get("forks_count"),
        "open_issues": repo_data.get("open_issues_count"),
        "watchers": repo_data.get("watchers_count"),
        "language": repo_data.get("language"),
        "license": (repo_data.get("license") or {}).get("spdx_id"),
        "has_security_md": has_security_md,
        "active_contributors_90d": active_contributors,
        "last_push": repo_data.get("pushed_at", "")[:10] if repo_data.get("pushed_at") else None,
        "last_release_date": last_release_date,
        "last_release_days": last_release_days,
        "description": repo_data.get("description"),
        "topics": repo_data.get("topics", []),
    }

    _cache_save(cache_key, result, state_dir)
    return result


# ---------------------------------------------------------------------------
# Tool stubs (v0.5.0)
# ---------------------------------------------------------------------------

def _fetch_registry_downloads(package: str, registry: str, state_dir: str | None) -> dict:
    """Stub — npm/pypi/homebrew registry downloads. Full implementation in v0.5.0."""
    return {
        "status": "stub",
        "message": f"registry_downloads for {registry}/{package} is not yet implemented. "
                   "Full implementation planned for v0.5.0.",
        "package": package,
        "registry": registry,
    }


def _fetch_trend_snapshot(query: str, state_dir: str | None) -> dict:
    """Stub — GitHub trending + Google Trends. Full implementation in v0.5.0."""
    return {
        "status": "stub",
        "message": f"trend_snapshot for '{query}' is not yet implemented. "
                   "Full implementation planned for v0.5.0.",
        "query": query,
    }


def _fetch_competitor_scan(alternatives: list[str], state_dir: str | None) -> dict:
    """Stub — competitor metric scan normalized to same proxies. Full implementation in v0.5.0."""
    return {
        "status": "stub",
        "message": "competitor_scan is not yet implemented. Use competitor-mapper agent for now. "
                   "Full implementation planned for v0.5.0.",
        "alternatives": alternatives,
    }


# ---------------------------------------------------------------------------
# MCP tool definitions
# ---------------------------------------------------------------------------

@app.list_tools()
async def list_tools() -> list[types.Tool]:
    return [
        types.Tool(
            name="github_repo_stats",
            description=(
                "Fetch GitHub repository signals for idea-auditor evidence collection. "
                "Returns stars, forks, active contributors (90d), last release age, "
                "security posture (SECURITY.md), and license. "
                "Output is normalized to evidence.schema.json items. "
                "Results are cached daily in STATE/.cache/evidence-harvester/."
            ),
            inputSchema={
                "type": "object",
                "required": ["repo"],
                "properties": {
                    "repo": {
                        "type": "string",
                        "description": "GitHub repo in owner/name format (e.g. 'facebook/react')",
                    },
                    "state_dir": {
                        "type": "string",
                        "description": "Path to STATE/ directory for cache. Defaults to STATE/",
                    },
                    "dimension": {
                        "type": "string",
                        "enum": ["wedge", "friction", "loop", "timing", "trust", "migration"],
                        "description": "Scoring dimension this evidence supports. Omit for multi-dimensional.",
                    },
                    "as_evidence": {
                        "type": "boolean",
                        "description": "If true, wrap output as evidence.schema.json item list. Default: false (raw signals).",
                    },
                },
            },
        ),
        types.Tool(
            name="registry_downloads",
            description=(
                "[STUB — v0.5.0] Fetch weekly download counts from npm, pypi, or homebrew. "
                "Returns a stub response indicating planned implementation."
            ),
            inputSchema={
                "type": "object",
                "required": ["package", "registry"],
                "properties": {
                    "package": {"type": "string", "description": "Package name"},
                    "registry": {
                        "type": "string",
                        "enum": ["npm", "pypi", "homebrew"],
                        "description": "Package registry",
                    },
                    "state_dir": {"type": "string"},
                },
            },
        ),
        types.Tool(
            name="trend_snapshot",
            description=(
                "[STUB — v0.5.0] Snapshot GitHub trending and Google Trends signals for a query. "
                "Returns a stub response indicating planned implementation."
            ),
            inputSchema={
                "type": "object",
                "required": ["query"],
                "properties": {
                    "query": {"type": "string", "description": "Search query (e.g. 'AI code review')"},
                    "state_dir": {"type": "string"},
                },
            },
        ),
        types.Tool(
            name="competitor_scan",
            description=(
                "[STUB — v0.5.0] Scan a list of competitor repos/packages and return normalized "
                "proxy metrics for the competitor-mapper agent. "
                "Returns a stub response; use competitor-mapper agent for current analysis."
            ),
            inputSchema={
                "type": "object",
                "required": ["alternatives"],
                "properties": {
                    "alternatives": {
                        "type": "array",
                        "items": {"type": "string"},
                        "description": "List of GitHub repos (owner/name) or package names to scan",
                    },
                    "state_dir": {"type": "string"},
                },
            },
        ),
    ]


@app.call_tool()
async def call_tool(
    name: str, arguments: dict
) -> list[types.TextContent | types.ImageContent | types.EmbeddedResource]:

    state_dir = arguments.get("state_dir")

    if name == "github_repo_stats":
        repo = arguments["repo"]
        dimension = arguments.get("dimension")
        as_evidence = arguments.get("as_evidence", False)

        data = _fetch_github_repo_stats(repo, state_dir)

        if "error" in data:
            return [types.TextContent(type="text", text=json.dumps(data, indent=2))]

        if as_evidence:
            items = []
            # Stars as loop/timing signal
            if data.get("stars") is not None:
                items.append(_to_evidence_item(
                    claim=f"{repo} has {data['stars']} GitHub stars",
                    source=f"github/{repo}",
                    method="oss_metrics",
                    collected_at=TODAY,
                    quality_tier="proxy",
                    dimension=dimension or "loop",
                    raw={"stars": data["stars"], "forks": data["forks"]},
                    normalized=f"stars={data['stars']}, forks={data['forks']}",
                ))
            # Security posture as trust signal
            if data.get("has_security_md") is not None:
                items.append(_to_evidence_item(
                    claim=f"{repo} {'has' if data['has_security_md'] else 'does not have'} SECURITY.md",
                    source=f"github/{repo}",
                    method="oss_metrics",
                    collected_at=TODAY,
                    quality_tier="behavioral",
                    dimension=dimension or "trust",
                    raw={"has_security_md": data["has_security_md"]},
                    normalized=f"has_security_md={data['has_security_md']}",
                ))
            # Release freshness as timing signal
            if data.get("last_release_days") is not None:
                items.append(_to_evidence_item(
                    claim=f"{repo} last released {data['last_release_days']} days ago",
                    source=f"github/{repo}",
                    method="oss_metrics",
                    collected_at=TODAY,
                    quality_tier="proxy",
                    dimension=dimension or "timing",
                    raw={"last_release_date": data["last_release_date"], "last_release_days": data["last_release_days"]},
                    normalized=f"last_release_days={data['last_release_days']}",
                ))
            return [types.TextContent(type="text", text=json.dumps(items, indent=2))]

        return [types.TextContent(type="text", text=json.dumps(data, indent=2))]

    elif name == "registry_downloads":
        result = _fetch_registry_downloads(arguments["package"], arguments["registry"], state_dir)
        return [types.TextContent(type="text", text=json.dumps(result, indent=2))]

    elif name == "trend_snapshot":
        result = _fetch_trend_snapshot(arguments["query"], state_dir)
        return [types.TextContent(type="text", text=json.dumps(result, indent=2))]

    elif name == "competitor_scan":
        result = _fetch_competitor_scan(arguments.get("alternatives", []), state_dir)
        return [types.TextContent(type="text", text=json.dumps(result, indent=2))]

    else:
        return [types.TextContent(type="text", text=json.dumps({"error": f"Unknown tool: {name}"}))]


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

async def _main() -> None:
    async with mcp.server.stdio.stdio_server() as (read_stream, write_stream):
        await app.run(
            read_stream,
            write_stream,
            InitializationOptions(
                server_name="idea-auditor-evidence-harvester",
                server_version="0.4.0",
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
