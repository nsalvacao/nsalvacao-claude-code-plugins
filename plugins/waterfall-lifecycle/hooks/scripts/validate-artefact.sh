#!/usr/bin/env bash
# validate-artefact.sh — Pre-write hook: validates JSON artefact against schema if applicable.
# Called by Claude Code before Write/Edit operations on .waterfall-lifecycle/ files.
# Exits 0 always (warnings only — does not block writes).
set -euo pipefail

FILE_PATH="${CLAUDE_FILE_PATH:-${1:-}}"
if [[ -z "$FILE_PATH" ]]; then
  exit 0  # No file context available — skip gracefully
fi

# Only process JSON files inside .waterfall-lifecycle/ directories
if [[ "$FILE_PATH" != *".waterfall-lifecycle/"* ]]; then
  exit 0
fi

if [[ "$FILE_PATH" != *.json ]]; then
  exit 0
fi

# Validate JSON syntax
if ! python3 -c "import json; json.load(open('${FILE_PATH}'))" 2>/dev/null; then
  echo "WARN: Invalid JSON syntax in ${FILE_PATH}" >&2
  exit 0
fi

# Try schema validation if \$id field is present
SCHEMA_ID=$(python3 -c "
import json, sys
try:
    d = json.load(open('${FILE_PATH}'))
    print(d.get('\$id', ''))
except Exception:
    print('')
" 2>/dev/null || true)

if [[ -n "$SCHEMA_ID" && -n "${CLAUDE_PLUGIN_ROOT:-}" ]]; then
  SCHEMA_NAME=$(basename "$SCHEMA_ID" .json)
  SCHEMA_FILE="${CLAUDE_PLUGIN_ROOT}/schemas/${SCHEMA_NAME}.json"
  if [[ -f "$SCHEMA_FILE" ]]; then
    if ! python3 -c "
import json, sys
try:
    import jsonschema
    schema = json.load(open('${SCHEMA_FILE}'))
    data = json.load(open('${FILE_PATH}'))
    jsonschema.validate(data, schema)
except ImportError:
    pass  # jsonschema not available — skip
except jsonschema.ValidationError as e:
    print(f'WARN: Schema validation failed: {e.message}', file=sys.stderr)
except Exception as e:
    print(f'WARN: Schema check error: {e}', file=sys.stderr)
" 2>&1; then
      echo "WARN: Schema validation encountered issues for ${FILE_PATH}" >&2
    fi
  fi
fi

echo "OK: ${FILE_PATH}"
exit 0
