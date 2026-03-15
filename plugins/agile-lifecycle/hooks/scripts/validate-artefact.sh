#!/usr/bin/env bash
# validate-artefact.sh — PreToolUse hook: validates artefact structure before writing.
# Called by Claude Code before Write/Edit tool invocations.
# Non-blocking: warns but does not fail if validation cannot complete.
# Input: TOOL_INPUT env var or stdin contains the tool invocation JSON.
set -euo pipefail

# Extract file path from TOOL_INPUT (Claude Code provides this as JSON)
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

# If no file path found, skip silently (non-artefact write)
if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# Only validate files in .agile-lifecycle/ directories
if [[ "$FILE_PATH" != *".agile-lifecycle"* ]]; then
  exit 0
fi

# Determine file type and apply appropriate validation
case "$FILE_PATH" in
  *.json)
    # JSON files: validate syntax
    if [[ -s "$FILE_PATH" ]]; then
      if ! python3 -c "import json, sys; json.load(open(sys.argv[1]))" "$FILE_PATH" 2>/dev/null; then
        echo "WARN [validate-artefact]: $FILE_PATH may have invalid JSON syntax" >&2
        # Non-blocking: exit 0 to not prevent the write
        exit 0
      fi
    fi
    ;;
  *.md)
    # Markdown artefacts: check for placeholder markers (unfilled templates)
    if [[ -s "$FILE_PATH" ]]; then
      unfilled=$(grep -cE '\{\{[a-zA-Z_][a-zA-Z0-9_]*\}\}' "$FILE_PATH" 2>/dev/null || true)
      if [[ "$unfilled" -gt 0 ]]; then
        echo "WARN [validate-artefact]: $FILE_PATH has $unfilled unfilled placeholder(s) ({{variable}})" >&2
        exit 0
      fi
    fi
    ;;
esac

exit 0
