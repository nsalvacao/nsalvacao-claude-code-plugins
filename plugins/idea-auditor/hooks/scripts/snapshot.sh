#!/usr/bin/env bash
# snapshot.sh — PostToolUse hook for idea-auditor
# Reads JSON from stdin (Claude Code PostToolUse event), detects high-signal file writes,
# appends a snapshot entry to STATE/.snapshots/YYYYMMDD-HH.json.
#
# High-signal patterns: IDEA.*, BLUEPRINT.*, README.md, SECURITY.md, CHANGELOG.md
# Output: STATE/.snapshots/YYYYMMDD-HH.json (hourly, append-only, never overwrite)
# This script must never fail or block — all errors are silently absorbed.

set -uo pipefail

# Read stdin; exit silently on empty input
export _SNAP_INPUT
_SNAP_INPUT=$(cat 2>/dev/null) || exit 0
[ -z "$_SNAP_INPUT" ] && exit 0

# Extract the file path from PostToolUse JSON
# Expected shape: {"tool_name": "Write|Edit", "tool_input": {"file_path": "..."}, ...}
FILE_PATH=$(python3 - <<'EOF' 2>/dev/null
import json, os
try:
    data = json.loads(os.environ.get('_SNAP_INPUT', ''))
    ti = data.get('tool_input') or data.get('input') or {}
    path = ti.get('file_path') or ti.get('path') or ''
    print(path)
except Exception:
    pass
EOF
) || exit 0
[ -z "$FILE_PATH" ] && exit 0

# Check if this file matches a high-signal pattern (basename only)
BASENAME=$(basename "$FILE_PATH")
case "$BASENAME" in
    IDEA.*|BLUEPRINT.*|README.md|SECURITY.md|CHANGELOG.md) ;;
    *) exit 0 ;;
esac

# Detect project root: walk up from the file's directory looking for IDEA.md
detect_project_root() {
    local dir
    dir=$(dirname "$FILE_PATH")
    [[ "$dir" != /* ]] && dir="$(pwd)/$dir"
    while [ "$dir" != "/" ]; do
        [ -f "$dir/IDEA.md" ] && { echo "$dir"; return; }
        dir=$(dirname "$dir")
    done
    echo "$(pwd)"
}

PROJECT_ROOT=$(detect_project_root)
SNAPSHOT_DIR="$PROJECT_ROOT/STATE/.snapshots"
mkdir -p "$SNAPSHOT_DIR" 2>/dev/null || exit 0

# Hourly snapshot filename
TIMESTAMP=$(date -u +"%Y%m%d-%H")
SNAPSHOT_FILE="$SNAPSHOT_DIR/${TIMESTAMP}.json"

# Resolve absolute path to the written file
ABS_FILE="$FILE_PATH"
[[ "$ABS_FILE" != /* ]] && ABS_FILE="$(pwd)/$ABS_FILE"

# Build and append snapshot entry via Python
export _SNAP_FILE="$ABS_FILE"
export _SNAP_BASENAME="$BASENAME"
export _SNAP_OUTFILE="$SNAPSHOT_FILE"
export _SNAP_TS
_SNAP_TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

python3 - <<'EOF' 2>/dev/null || exit 0
import json, os

file_path = os.environ.get('_SNAP_FILE', '')
basename  = os.environ.get('_SNAP_BASENAME', '')
out_file  = os.environ.get('_SNAP_OUTFILE', '')
ts        = os.environ.get('_SNAP_TS', '')

entry = {'ts': ts, 'file': file_path, 'basename': basename}

try:
    size = os.path.getsize(file_path)
    if size <= 65536:
        with open(file_path, 'r', encoding='utf-8', errors='replace') as f:
            entry['content'] = f.read()
    else:
        entry['content_skipped'] = 'file_too_large'
        entry['size_bytes'] = size
except Exception as exc:
    entry['content_error'] = str(exc)

# Load existing array or start fresh
if os.path.exists(out_file):
    try:
        with open(out_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
        if not isinstance(data, list):
            data = [data]
    except Exception:
        data = []
else:
    data = []

data.append(entry)

with open(out_file, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
EOF
