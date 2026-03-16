#!/usr/bin/env bash
# lf-check.sh — Post-write hook: warns on CRLF line endings in markdown files.
# Called by Claude Code after Write/Edit operations.
# Exits 0 always (warnings only).
set -euo pipefail

FILE_PATH="${CLAUDE_FILE_PATH:-${1:-}}"
if [[ -z "$FILE_PATH" ]]; then
  exit 0  # No file context available — skip gracefully
fi

# Only check markdown files
if [[ "$FILE_PATH" != *.md ]]; then
  exit 0
fi

if [[ ! -f "$FILE_PATH" ]]; then
  exit 0
fi

# Check for CRLF line endings
if file "$FILE_PATH" | grep -q "CRLF"; then
  echo "WARN: CRLF line endings detected in $FILE_PATH — run dos2unix to fix" >&2
fi

exit 0
