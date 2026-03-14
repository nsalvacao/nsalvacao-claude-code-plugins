#!/usr/bin/env bash
# lf-check.sh — PostToolUse hook: checks written file for CRLF line endings.
# Called by Claude Code after Write/Edit tool invocations.
# Warns if CRLF found, suggests dos2unix.
# Non-blocking: always exits 0.
set -euo pipefail

# Extract file path from TOOL_INPUT
FILE_PATH=""
if [[ -n "${TOOL_INPUT:-}" ]]; then
  FILE_PATH=$(python3 -c "
import json, sys
try:
    data = json.loads(sys.argv[1])
    path = data.get('path') or data.get('file_path') or data.get('filename') or ''
    print(path)
except Exception:
    print('')
" "$TOOL_INPUT" 2>/dev/null || true)
fi

# Nothing to check
if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# File must exist and be a regular file
if [[ ! -f "$FILE_PATH" ]]; then
  exit 0
fi

# Check for CRLF using file command or grep
if command -v file >/dev/null 2>&1; then
  if file "$FILE_PATH" 2>/dev/null | grep -q "CRLF"; then
    echo "WARN [lf-check]: CRLF line endings detected in $FILE_PATH" >&2
    echo "WARN [lf-check]: Fix with: dos2unix \"$FILE_PATH\"" >&2
  fi
elif grep -qP "\r" "$FILE_PATH" 2>/dev/null; then
  echo "WARN [lf-check]: CRLF line endings detected in $FILE_PATH" >&2
  echo "WARN [lf-check]: Fix with: dos2unix \"$FILE_PATH\"" >&2
fi

exit 0
