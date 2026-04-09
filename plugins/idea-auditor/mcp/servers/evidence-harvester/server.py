#!/usr/bin/env python3
"""evidence-harvester MCP server — idea-auditor v0.5.0

Fetches external evidence signals and normalizes them to evidence.schema.json format.

Tools:
  github_repo_stats   — GitHub star/fork/contributor velocity, security posture
  registry_downloads  — npm/pypi/homebrew weekly download counts
  trend_snapshot      — GitHub trending & Google Trends signals (stub — v0.6.0)
  competitor_scan     — competitor metric list normalized to same proxies (stub — v0.6.0)

Environment:
  GITHUB_TOKEN — optional; absent → rate-limited to 60 req/h

Cache:
  STATE/.cache/evidence-harvester/<key>-<date>.json — TTL daily (auto-created)
"""

import asyncio
import json
import os
import re
from datetime import date, datetime, timezone
from pathlib import Path

import httpx
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
        pass  # cache write failure is non-fatal — MCP server continues without caching


async def _github_get(client: "httpx.AsyncClient", path: str) -> dict | list | None:
    """Async GitHub API GET via injected httpx.AsyncClient (non-blocking)."""
    url = f"{GITHUB_API}{path}"
    try:
        resp = await client.get(url, timeout=15)
        resp.raise_for_status()
        return resp.json()
    except httpx.HTTPStatusError as e:
        return {"error": f"HTTP {e.response.status_code}: {e.response.reason_phrase}", "url": str(e.request.url)}
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
        "confidence_components": {},
    }


# ---------------------------------------------------------------------------
# Tool: github_repo_stats
# ---------------------------------------------------------------------------

async def _fetch_github_repo_stats(client: httpx.AsyncClient, repo: str, state_dir: str | None) -> dict:
    cache_key = f"github_repo_{repo}"
    cached = _cache_load(cache_key, state_dir)
    if cached:
        return {**cached, "cache_hit": True}

    repo_data = await _github_get(client, f"/repos/{repo}")
    if not repo_data or "error" in repo_data:
        return {"error": repo_data.get("error") if repo_data else "no data", "repo": repo}

    # Contributors (last 90 days via stats/contributors — can be slow)
    contrib_data = await _github_get(client, f"/repos/{repo}/stats/contributors")
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
    contents = await _github_get(client, f"/repos/{repo}/contents/SECURITY.md")
    if isinstance(contents, dict) and "name" in contents:
        has_security_md = True

    # Latest release
    latest_release = await _github_get(client, f"/repos/{repo}/releases/latest")
    last_release_date = None
    last_release_days = None
    if isinstance(latest_release, dict) and "published_at" in latest_release:
        last_release_date = latest_release["published_at"][:10]
        try:
            rel_date = date.fromisoformat(last_release_date)
            last_release_days = (date.today() - rel_date).days
        except ValueError:
            pass  # published_at format unexpected — leave last_release_days as None

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

async def _fetch_registry_downloads(client: httpx.AsyncClient, package: str, registry: str, state_dir: str | None) -> dict:
    """Fetch weekly download counts from npm, pypi, or homebrew. Results cached daily."""
    cache_key = f"registry_{registry}_{package}"
    cached = _cache_load(cache_key, state_dir)
    if cached:
        return {**cached, "cache_hit": True}

    result: dict = {
        "package": package,
        "registry": registry,
        "fetched_at": TODAY,
        "weekly_downloads": None,
        "monthly_downloads": None,
    }

    try:
        if registry == "npm":
            resp = await client.get(
                f"https://api.npmjs.org/downloads/point/last-week/{package}", timeout=15
            )
            resp.raise_for_status()
            data = resp.json()
            result["weekly_downloads"] = data.get("downloads")

        elif registry == "pypi":
            resp = await client.get(
                f"https://pypistats.org/api/packages/{package}/recent", timeout=15
            )
            resp.raise_for_status()
            data = resp.json()
            pkg_data = data.get("data") or {}
            result["weekly_downloads"] = pkg_data.get("last_week")
            result["monthly_downloads"] = pkg_data.get("last_month")

        elif registry == "homebrew":
            resp = await client.get(
                f"https://formulae.brew.sh/api/formula/{package}.json", timeout=15
            )
            resp.raise_for_status()
            data = resp.json()
            install_30d = (data.get("analytics") or {}).get("install", {}).get("30d", {})
            monthly = sum(install_30d.values()) if install_30d else None
            result["monthly_downloads"] = monthly
            result["weekly_downloads"] = round(monthly / 4) if monthly else None

        else:
            return {"error": f"Unknown registry: {registry}", "package": package, "registry": registry}

    except httpx.HTTPStatusError as e:
        return {"error": f"HTTP {e.response.status_code}: {e.response.reason_phrase}", "package": package, "registry": registry}
    except Exception as e:
        return {"error": str(e), "package": package, "registry": registry}

    _cache_save(cache_key, result, state_dir)
    return result


async def _fetch_trend_snapshot(client: httpx.AsyncClient, query: str, state_dir: str | None) -> dict:
    """Fetch GitHub Trending repos (weekly) matching the query. Google Trends not implemented.

    Google Trends has no stable public API without auth or fragile third-party libraries
    (pytrends regularly breaks due to Google blocking). Use trends.google.com manually.
    """
    cache_key = f"trend_{query.replace(' ', '_')}"
    cached = _cache_load(cache_key, state_dir)
    if cached:
        return {**cached, "cache_hit": True}

    trending_repos: list[dict] = []
    github_error: str | None = None

    try:
        resp = await client.get(
            "https://github.com/trending",
            params={"since": "weekly"},
            headers={"Accept": "text/html", "User-Agent": "idea-auditor/0.5.0"},
            timeout=20,
        )
        resp.raise_for_status()
        html = resp.text

        # Extract article blocks (each article = one trending repo)
        articles = re.findall(r'<article[^>]*Box-row[^>]*>(.*?)</article>', html, re.DOTALL)

        query_words = {w.lower() for w in query.split() if len(w) > 2}

        for article in articles[:25]:
            # Repo path: first href matching owner/name pattern inside the article
            repo_m = re.search(r'href="/([A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+)"', article)
            if not repo_m:
                continue
            repo_name = repo_m.group(1)

            # Stars this week
            stars_m = re.search(r'([\d,]+)\s+stars?\s+this\s+week', article, re.IGNORECASE)
            stars_week = int(stars_m.group(1).replace(",", "")) if stars_m else None

            # Description (first <p> tag content, stripped)
            desc_m = re.search(r'<p[^>]*>\s*(.*?)\s*</p>', article, re.DOTALL)
            description = re.sub(r'<[^>]+>', '', desc_m.group(1)).strip() if desc_m else None

            # Relevance: does the query match repo name or description?
            searchable = (repo_name + " " + (description or "")).lower()
            relevance = "match" if query_words and query_words.intersection(searchable.split()) else "trending"

            trending_repos.append({
                "repo": repo_name,
                "stars_this_week": stars_week,
                "description": description,
                "relevance": relevance,
            })

    except httpx.HTTPStatusError as e:
        github_error = f"HTTP {e.response.status_code}: {e.response.reason_phrase}"
    except Exception as e:
        github_error = str(e)

    result = {
        "query": query,
        "fetched_at": TODAY,
        "github_trending_weekly": trending_repos if not github_error else None,
        "github_error": github_error,
        "google_trends": None,
        "google_trends_note": (
            "Google Trends has no stable public API without auth. "
            "Check trends.google.com manually for keyword interest signals."
        ),
    }

    if not github_error:
        _cache_save(cache_key, result, state_dir)
    return result


async def _fetch_competitor_scan(client: httpx.AsyncClient, alternatives: list[str], state_dir: str | None) -> list[dict]:
    """Scan a list of GitHub repos or packages and return normalized competitor proxy matrix.

    For each alternative: fetches GitHub stats and maps to the 7 proxy fields used by
    the competitor-mapper agent. pricing_floor_usd and jtbd_match_score are left null —
    they require human research and cannot be inferred.
    """
    results = []
    for alt in alternatives:
        entry: dict = {
            "alternative": alt,
            "stars_or_installs": None,
            "weekly_downloads": None,
            "github_contributors": None,
            "last_release_days": None,
            "pricing_floor_usd": None,     # requires human research
            "integration_depth": None,     # requires human research
            "jtbd_match_score": None,      # requires human research
            "error": None,
        }

        # Treat as GitHub repo if it matches owner/name pattern
        if re.match(r'^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$', alt):
            data = await _fetch_github_repo_stats(client, alt, state_dir)
            if "error" in data:
                entry["error"] = data["error"]
            else:
                entry["stars_or_installs"] = data.get("stars")
                entry["github_contributors"] = data.get("active_contributors_90d")
                entry["last_release_days"] = data.get("last_release_days")
        else:
            entry["error"] = f"'{alt}' does not match owner/name format — package registry lookup not implemented here; use registry_downloads tool"

        results.append(entry)

    return results


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
                "Fetch weekly download counts from npm, pypi, or homebrew for idea-auditor evidence. "
                "Returns weekly_downloads (and monthly_downloads for pypi/homebrew). "
                "Results are cached daily in STATE/.cache/evidence-harvester/."
            ),
            inputSchema={
                "type": "object",
                "required": ["package", "registry"],
                "properties": {
                    "package": {"type": "string", "description": "Package name (e.g. 'httpx', 'react')"},
                    "registry": {
                        "type": "string",
                        "enum": ["npm", "pypi", "homebrew"],
                        "description": "Package registry",
                    },
                    "state_dir": {"type": "string", "description": "Path to STATE/ directory for cache. Defaults to STATE/"},
                },
            },
        ),
        types.Tool(
            name="trend_snapshot",
            description=(
                "Snapshot GitHub Trending repos (weekly) matching a query. "
                "Returns up to 25 trending repos with stars_this_week and relevance flag. "
                "Google Trends not implemented (no stable public API without auth). "
                "Results are cached daily in STATE/.cache/evidence-harvester/."
            ),
            inputSchema={
                "type": "object",
                "required": ["query"],
                "properties": {
                    "query": {"type": "string", "description": "Search query to match against trending repos (e.g. 'AI code review')"},
                    "state_dir": {"type": "string", "description": "Path to STATE/ directory for cache. Defaults to STATE/"},
                },
            },
        ),
        types.Tool(
            name="competitor_scan",
            description=(
                "Scan a list of GitHub repos and return a normalized competitor proxy matrix "
                "for the competitor-mapper agent. For each alternative: fetches GitHub stars, "
                "active contributors (90d), last release age. pricing_floor_usd, "
                "integration_depth, and jtbd_match_score are left null (require human research). "
                "Reuses github_repo_stats cache."
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

        token = os.environ.get("GITHUB_TOKEN")
        headers = {"Accept": "application/vnd.github+json", "X-GitHub-Api-Version": "2022-11-28"}
        if token:
            headers["Authorization"] = f"Bearer {token}"
        async with httpx.AsyncClient(headers=headers) as client:
            data = await _fetch_github_repo_stats(client, repo, state_dir)

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
        async with httpx.AsyncClient() as client:
            result = await _fetch_registry_downloads(client, arguments["package"], arguments["registry"], state_dir)
        return [types.TextContent(type="text", text=json.dumps(result, indent=2))]

    elif name == "trend_snapshot":
        async with httpx.AsyncClient() as client:
            result = await _fetch_trend_snapshot(client, arguments["query"], state_dir)
        return [types.TextContent(type="text", text=json.dumps(result, indent=2))]

    elif name == "competitor_scan":
        async with httpx.AsyncClient() as client:
            result = await _fetch_competitor_scan(client, arguments.get("alternatives", []), state_dir)
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
