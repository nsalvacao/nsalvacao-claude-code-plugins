#!/usr/bin/env bash
# extract_repo_signals.sh — Extracts signals from a local git repo for the timing/loop/trust dimensions.
#
# Usage:
#   bash extract_repo_signals.sh <repo_path> [--out <output.json>]
#
# Output: A signals document for STATE/ (not a validated evidence.schema.json item).
#   Dimension agents convert these signals into evidence items with claims before scoring.
#
# Signals extracted:
#   - Recent commits (last 30 days): count, authors, top changed paths
#   - Tags/releases: count, cadence (days between last 2 tags)
#   - Sensitive path changes: pricing, auth, README, CHANGELOG, SECURITY
#   - Contributors (30d): unique author count
#
# Design:
#   - Pure git commands, no network access
#   - Exits 0 on success, non-zero on error
#   - Does not expose secrets (skips .env, *.key paths in analysis)

set -euo pipefail

REPO_PATH="${1:-}"
OUT_PATH=""

if [[ -z "$REPO_PATH" ]]; then
    echo "Usage: extract_repo_signals.sh <repo_path> [--out <output.json>]" >&2
    exit 1
fi

shift
while [[ $# -gt 0 ]]; do
    case "$1" in
        --out) OUT_PATH="$2"; shift 2 ;;
        *) echo "Unknown argument: $1" >&2; exit 1 ;;
    esac
done

if [[ ! -d "$REPO_PATH/.git" ]]; then
    echo "ERROR: $REPO_PATH is not a git repository" >&2
    exit 1
fi

cd "$REPO_PATH"

# Commits in last 30 days
SINCE="30 days ago"
COMMIT_COUNT=$(git log --since="$SINCE" --oneline 2>/dev/null | wc -l | tr -d ' ')
CONTRIBUTOR_COUNT=$(git log --since="$SINCE" --format="%ae" 2>/dev/null | sort -u | wc -l | tr -d ' ')

# Tags
TAG_COUNT=$(git tag 2>/dev/null | wc -l | tr -d ' ')
TAG_CADENCE_DAYS="null"
LAST_TWO_TAGS=$(git tag --sort=-creatordate 2>/dev/null | head -2)
if [[ $(echo "$LAST_TWO_TAGS" | wc -l) -ge 2 ]]; then
    TAG1=$(echo "$LAST_TWO_TAGS" | head -1)
    TAG2=$(echo "$LAST_TWO_TAGS" | tail -1)
    DATE1=$(git log -1 --format="%ct" "$TAG1" 2>/dev/null || echo "0")
    DATE2=$(git log -1 --format="%ct" "$TAG2" 2>/dev/null || echo "0")
    if [[ "$DATE1" -gt 0 && "$DATE2" -gt 0 ]]; then
        DIFF=$(( (DATE1 - DATE2) / 86400 ))
        TAG_CADENCE_DAYS="$DIFF"
    fi
fi

# Sensitive path changes (last 90 days) — no secrets exposed
SENSITIVE_PATHS=("pricing" "auth" "README" "CHANGELOG" "SECURITY" "LICENSE")
SENSITIVE_CHANGES="[]"
SENSITIVE_JSON=""
for path_pattern in "${SENSITIVE_PATHS[@]}"; do
    CHANGED=$(git log --since="90 days ago" --oneline -- "*${path_pattern}*" 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$CHANGED" -gt 0 ]]; then
        SENSITIVE_JSON="${SENSITIVE_JSON}{\"path_pattern\":\"${path_pattern}\",\"commit_count\":${CHANGED}},"
    fi
done
if [[ -n "$SENSITIVE_JSON" ]]; then
    SENSITIVE_CHANGES="[${SENSITIVE_JSON%,}]"
fi

# Top changed paths (last 30 days).
# Uses Python for JSON-safe encoding to handle spaces, quotes, and backslashes in paths.
# Excludes: .env files, *.key, *.pem, and secrets in any directory.
TOP_PATHS=$(git log --since="$SINCE" --name-only --format="" 2>/dev/null \
    | python3 -c '
import collections, json, re, sys
counts = collections.Counter()
exclude = re.compile(r"(^|/)\.(env|secret)(\.|$)|(^|/)[^/]+\.(key|pem)$")
for line in sys.stdin:
    path = line.rstrip("\n")
    if path and not exclude.search(path):
        counts[path] += 1
top = [{"path": p, "change_count": c} for p, c in counts.most_common(5)]
print(json.dumps(top))
')

# Build output JSON
COLLECTED_AT=$(date +%Y-%m-%d)

OUTPUT=$(cat <<JSON
{
  "dimension": null,
  "source": "extract_repo_signals.sh",
  "method": "observation",
  "collected_at": "${COLLECTED_AT}",
  "signals": {
    "commits_last_30d": ${COMMIT_COUNT},
    "contributors_last_30d": ${CONTRIBUTOR_COUNT},
    "tag_count_total": ${TAG_COUNT},
    "tag_cadence_days": ${TAG_CADENCE_DAYS},
    "sensitive_path_changes_90d": ${SENSITIVE_CHANGES},
    "top_changed_paths_30d": ${TOP_PATHS}
  },
  "quality_tier": "behavioral",
  "notes": "Dimension must be assigned per-item by caller. Signals map to: loop (contributors/commits), timing (tag cadence, sensitive changes), trust (SECURITY/auth changes)."
}
JSON
)

if [[ -n "$OUT_PATH" ]]; then
    echo "$OUTPUT" > "$OUT_PATH"
    echo "OK: signals written to $OUT_PATH" >&2
else
    echo "$OUTPUT"
fi
