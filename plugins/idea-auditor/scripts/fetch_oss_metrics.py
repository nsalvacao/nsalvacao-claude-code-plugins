#!/usr/bin/env python3
"""fetch_oss_metrics.py — Fetches OSS signals via GitHub API for the loop/timing/trust dimensions.

Usage:
  python3 fetch_oss_metrics.py --repo owner/repo
  python3 fetch_oss_metrics.py --repo owner/repo --out STATE/oss_metrics.json

Environment:
  GITHUB_TOKEN — optional; if absent, rate-limited to 60 req/h (graceful fallback).

Output:
  JSON conforming to evidence.schema.json format, with dimension=null (multi-dimensional).
  Callers must assign dimension per item or use dimension-prefixed filenames.

Cache:
  STATE/.cache/<repo_slug>-<date>.json — TTL daily (no re-fetch within same day).
  Cache directory is auto-created if absent.

Design:
  - No required dependencies beyond stdlib (urllib, json, pathlib, datetime).
  - On rate limit or network error: returns partial data with error field; exits 0.
  - Never logs token values.
"""

import argparse
import json
import os
import sys
import urllib.request
import urllib.error
from datetime import date
from pathlib import Path


GITHUB_API = "https://api.github.com"


def _api_get(path: str, token: str | None) -> dict | list | None:
    """Make a GitHub API GET request. Returns parsed JSON or None on error."""
    url = f"{GITHUB_API}{path}"
    req = urllib.request.Request(url)
    req.add_header("Accept", "application/vnd.github+json")
    req.add_header("X-GitHub-Api-Version", "2022-11-28")
    if token:
        req.add_header("Authorization", f"Bearer {token}")

    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        if e.code == 403:
            print(f"WARN: GitHub rate limit hit for {path}. Results will be partial.", file=sys.stderr)
        elif e.code == 404:
            print(f"WARN: Repo not found: {path}", file=sys.stderr)
        else:
            print(f"WARN: HTTP {e.code} for {path}", file=sys.stderr)
        return None
    except Exception as e:  # noqa: BLE001
        print(f"WARN: network error for {path}: {e}", file=sys.stderr)
        return None


def fetch_metrics(repo: str, token: str | None) -> dict:
    """Fetch repo metadata and recent activity from GitHub API."""
    collected_at = date.today().isoformat()
    errors: list[str] = []

    # Core repo info
    raw = _api_get(f"/repos/{repo}", token)
    if not raw or not isinstance(raw, dict):
        errors.append("repo_info_unavailable")
        return {
            "dimension": None,
            "source": f"fetch_oss_metrics.py:{repo}",
            "method": "github_api",
            "collected_at": collected_at,
            "quality_tier": "proxy",
            "errors": errors,
            "signals": {},
        }
    repo_data: dict = raw

    stars = repo_data.get("stargazers_count", 0)
    forks = repo_data.get("forks_count", 0)
    open_issues = repo_data.get("open_issues_count", 0)
    watchers = repo_data.get("watchers_count", 0)
    pushed_at = repo_data.get("pushed_at", "")

    # Weekly commit activity (last 52 weeks)
    commit_activity = _api_get(f"/repos/{repo}/stats/commit_activity", token)
    recent_commits_4w = 0
    if isinstance(commit_activity, list):
        recent_commits_4w = sum(w.get("total", 0) for w in commit_activity[-4:])

    # Contributor count
    contributors = _api_get(f"/repos/{repo}/contributors?per_page=100&anon=false", token)
    contributor_count = len(contributors) if isinstance(contributors, list) else None
    if contributor_count is None:
        errors.append("contributors_unavailable")

    # Latest release
    releases = _api_get(f"/repos/{repo}/releases?per_page=2", token)
    latest_release = None
    release_count = None
    if isinstance(releases, list):
        release_count = len(releases)
        if releases:
            latest_release = releases[0].get("tag_name")

    # Star velocity proxy: recent commits as proxy for activity slope
    # (true star velocity requires Stargazers API with timestamps — pagination intensive)
    star_velocity_proxy = "unavailable_without_pagination"

    # SECURITY.md presence (trust signal)
    security_md = _api_get(f"/repos/{repo}/contents/SECURITY.md", token)
    has_security_md = security_md is not None and not isinstance(security_md, list) and "sha" in security_md

    signals = {
        "stars": stars,
        "forks": forks,
        "open_issues": open_issues,
        "watchers": watchers,
        "last_pushed_at": pushed_at,
        "commits_last_4_weeks": recent_commits_4w,
        "contributor_count": contributor_count,
        "release_count": release_count,
        "latest_release": latest_release,
        "star_velocity_proxy": star_velocity_proxy,
        "has_security_md": has_security_md,
        "star_fork_ratio": round(stars / forks, 2) if forks > 0 else None,
    }

    result = {
        "dimension": None,
        "source": f"fetch_oss_metrics.py:{repo}",
        "method": "github_api",
        "collected_at": collected_at,
        "quality_tier": "proxy",
        "signals": signals,
        "notes": (
            "dimension=null: signals are multi-dimensional. "
            "stars/forks/commits → loop; has_security_md → trust; last_pushed_at → timing."
        ),
    }
    if errors:
        result["errors"] = errors

    return result


def main() -> None:
    parser = argparse.ArgumentParser(description="Fetch OSS metrics from GitHub API.")
    parser.add_argument("--repo", required=True, help="GitHub repo in owner/repo format")
    parser.add_argument("--out", required=False, help="Output JSON path (default: stdout)")
    parser.add_argument("--cache-dir", required=False, default="STATE/.cache",
                        help="Cache directory (default: STATE/.cache)")
    args = parser.parse_args()

    token = os.environ.get("GITHUB_TOKEN")
    if not token:
        print("WARN: GITHUB_TOKEN not set — rate limited to 60 req/h", file=sys.stderr)

    repo = args.repo
    if "/" not in repo:
        print(f"ERROR: --repo must be in owner/repo format, got: {repo}", file=sys.stderr)
        sys.exit(1)

    # Check cache
    slug = repo.replace("/", "_")
    today = date.today().isoformat()
    cache_dir = Path(args.cache_dir)
    cache_file = cache_dir / f"{slug}-{today}.json"

    if cache_file.exists():
        print(f"INFO: using cached result from {cache_file}", file=sys.stderr)
        result_json = cache_file.read_text(encoding="utf-8")
    else:
        data = fetch_metrics(repo, token)
        result_json = json.dumps(data, indent=2, ensure_ascii=False)
        # Write cache
        try:
            cache_dir.mkdir(parents=True, exist_ok=True)
            cache_file.write_text(result_json, encoding="utf-8")
        except OSError as e:
            print(f"WARN: could not write cache: {e}", file=sys.stderr)

    if args.out:
        Path(args.out).write_text(result_json, encoding="utf-8")
        print(f"OK: metrics written to {args.out}")
    else:
        print(result_json)


if __name__ == "__main__":
    main()
