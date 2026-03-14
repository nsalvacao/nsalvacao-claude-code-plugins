#!/usr/bin/env bash
# validate-schema.sh — Validates a JSON file against a JSON Schema.
# Usage: ./validate-schema.sh <json-file> <schema-file>
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <json-file> <schema-file>" >&2
  exit 1
fi

JSON_FILE="$1"
SCHEMA_FILE="$2"

if [[ ! -f "$JSON_FILE" ]]; then
  echo "ERROR: JSON file not found: $JSON_FILE" >&2
  exit 1
fi

if [[ ! -f "$SCHEMA_FILE" ]]; then
  echo "ERROR: Schema file not found: $SCHEMA_FILE" >&2
  exit 1
fi

# Validate JSON is well-formed first
if ! python3 -c "import json, sys; json.load(open(sys.argv[1]))" "$JSON_FILE" 2>/dev/null; then
  echo "ERROR: $JSON_FILE is not valid JSON" >&2
  exit 1
fi

if ! python3 -c "import json, sys; json.load(open(sys.argv[1]))" "$SCHEMA_FILE" 2>/dev/null; then
  echo "ERROR: $SCHEMA_FILE is not valid JSON" >&2
  exit 1
fi

# Try jsonschema validation if available
if python3 -c "import jsonschema" 2>/dev/null; then
  python3 - "$JSON_FILE" "$SCHEMA_FILE" <<'PYEOF'
import json, sys
from jsonschema import validate, ValidationError, SchemaError

json_file = sys.argv[1]
schema_file = sys.argv[2]

with open(json_file) as f:
    instance = json.load(f)

with open(schema_file) as f:
    schema = json.load(f)

try:
    validate(instance=instance, schema=schema)
    print(f"OK: {json_file} is valid against {schema_file}")
    sys.exit(0)
except ValidationError as e:
    print(f"FAIL: {json_file} failed validation: {e.message}", file=sys.stderr)
    sys.exit(1)
except SchemaError as e:
    print(f"FAIL: Schema error in {schema_file}: {e.message}", file=sys.stderr)
    sys.exit(1)
PYEOF
else
  echo "WARNING: jsonschema not installed — only JSON syntax validated" >&2
  echo "Install with: pip install jsonschema" >&2
  echo "OK: $JSON_FILE is valid JSON (schema validation skipped)"
fi
