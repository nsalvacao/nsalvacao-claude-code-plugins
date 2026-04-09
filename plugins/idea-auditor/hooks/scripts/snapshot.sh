#!/usr/bin/env bash
# snapshot.sh — PostToolUse hook for idea-auditor
# Reads JSON from stdin (Claude Code PostToolUse event), detects high-signal file writes,
# appends a snapshot entry to STATE/.snapshots/YYYYMMDD-HH.json.
#
# High-signal patterns: IDEA.*, BLUEPRINT.*, README.md, SECURITY.md, CHANGELOG.md
# Output: STATE/.snapshots/YYYYMMDD-HH.json (hourly, append-only, never overwrite)
# This script must never fail or block — all errors are silently absorbed.

set -uo pipefail

# Use a temp file to avoid E2BIG when tool input includes large file content
_TMP_INPUT=$(mktemp 2>/dev/null) || exit 0
cat > "$_TMP_INPUT" 2>/dev/null || { rm -f "$_TMP_INPUT"; exit 0; }
[ ! -s "$_TMP_INPUT" ] && { rm -f "$_TMP_INPUT"; exit 0; }

# Extract the file path from PostToolUse JSON via temp file
# Expected shape: {"tool_name": "Write|Edit", "tool_input": {"file_path": "..."}, ...}
FILE_PATH=$(python3 - "$_TMP_INPUT" <<'EOF' 2>/dev/null
import json, sys
try:
    with open(sys.argv[1], 'r', encoding='utf-8', errors='replace') as f:
        data = json.load(f)
    ti = data.get('tool_input') or data.get('input') or {}
    print(ti.get('file_path') or ti.get('path') or '')
except Exception:
    pass
EOF
)
rm -f "$_TMP_INPUT"
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
    pwd
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

# Build and append snapshot entry via Python.
# Uses flock on a lock file + atomic rename to prevent race conditions
# when multiple sessions write concurrently.
export _SNAP_FILE="$ABS_FILE"
export _SNAP_BASENAME="$BASENAME"
export _SNAP_OUTFILE="$SNAPSHOT_FILE"
export _SNAP_TS
_SNAP_TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

python3 - <<'EOF' 2>/dev/null || exit 0
import fcntl, json, os, tempfile

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

# Exclusive lock on a companion lock file; released when 'with' exits.
# Atomic write via temp file + os.replace to avoid partial reads.
lock_path = out_file + '.lock'
with open(lock_path, 'a') as lock_fh:
    fcntl.flock(lock_fh, fcntl.LOCK_EX)

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

    out_dir = os.path.dirname(out_file) or '.'
    tmp_fd, tmp_path = tempfile.mkstemp(dir=out_dir, suffix='.tmp')
    try:
        with os.fdopen(tmp_fd, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        os.replace(tmp_path, out_file)
    except Exception:
        try:
            os.unlink(tmp_path)
        except OSError:
            pass
        raise
EOF
