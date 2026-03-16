#!/usr/bin/env bash
# validate-schema.sh — Validate a JSON file against its waterfall-lifecycle schema.
# Usage: ./validate-schema.sh <json-file> [schema-file]
# If schema-file omitted, infers from 'schema' or '$schema' field in json-file.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"

usage() {
  echo "Usage: $(basename "$0") <json-file> [schema-file]"
  echo ""
  echo "Validate a JSON file against its waterfall-lifecycle schema."
  echo ""
  echo "Arguments:"
  echo "  json-file     Path to the JSON file to validate"
  echo "  schema-file   Optional: path to JSON schema file"
  echo "                If omitted, infers from 'schema' or '\$schema' field in json-file"
  echo ""
  echo "Examples:"
  echo "  $(basename "$0") .waterfall-lifecycle/lifecycle-state.json"
  echo "  $(basename "$0") artefact.json schemas/artefact-schema.json"
}

if [[ $# -eq 0 ]]; then
  usage
  exit 0
fi

JSON_FILE="$1"
SCHEMA_FILE="${2:-}"

if [[ ! -f "$JSON_FILE" ]]; then
  echo "ERROR: JSON file not found: $JSON_FILE" >&2
  exit 1
fi

# Check python3 availability
if ! command -v python3 &>/dev/null; then
  echo "WARN: python3 not available — performing basic JSON syntax check only" >&2
  if command -v jq &>/dev/null; then
    if jq empty "$JSON_FILE" 2>/dev/null; then
      echo "OK: $JSON_FILE is valid JSON (checked with jq)"
      exit 0
    else
      echo "ERROR: $JSON_FILE contains invalid JSON" >&2
      exit 1
    fi
  else
    echo "WARN: neither python3 nor jq available — cannot validate JSON syntax" >&2
    exit 0
  fi
fi

# Validate JSON syntax
if ! python3 -c "import json; json.load(open('$JSON_FILE'))" 2>/dev/null; then
  echo "ERROR: $JSON_FILE contains invalid JSON" >&2
  exit 1
fi
echo "OK: $JSON_FILE is valid JSON"

# Resolve schema file if not provided
if [[ -z "$SCHEMA_FILE" ]]; then
  SCHEMA_ID=$(python3 -c "import json; d=json.load(open('$JSON_FILE')); print(d.get('\$schema', d.get('schema', '')))" 2>/dev/null || true)
  if [[ -n "$SCHEMA_ID" ]]; then
    # Try to resolve schema relative to plugin schemas/ directory
    SCHEMA_NAME=$(basename "$SCHEMA_ID")
    CANDIDATE="$PLUGIN_DIR/schemas/${SCHEMA_NAME}.schema.json"
    if [[ -f "$CANDIDATE" ]]; then
      SCHEMA_FILE="$CANDIDATE"
    else
      echo "INFO: schema file not found for id '$SCHEMA_ID' — skipping schema validation"
      exit 0
    fi
  else
    echo "INFO: no \$schema field found in $JSON_FILE — skipping schema validation"
    exit 0
  fi
fi

if [[ ! -f "$SCHEMA_FILE" ]]; then
  echo "ERROR: schema file not found: $SCHEMA_FILE" >&2
  exit 1
fi

# Validate against schema if jsonschema is available
if python3 -c "import jsonschema" 2>/dev/null; then
  if python3 -c "
import json, jsonschema, sys
schema = json.load(open('$SCHEMA_FILE'))
instance = json.load(open('$JSON_FILE'))
try:
    jsonschema.validate(instance, schema)
    print('OK: $JSON_FILE passes schema validation')
except jsonschema.ValidationError as e:
    print(f'ERROR: schema validation failed: {e.message}', file=sys.stderr)
    sys.exit(1)
"; then
    exit 0
  else
    exit 1
  fi
else
  echo "INFO: jsonschema module not available — skipping schema validation (JSON syntax OK)"
  exit 0
fi
