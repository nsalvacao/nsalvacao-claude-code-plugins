#!/usr/bin/env bash
# Emit a structured escalation payload for Claude to act on.
# Usage: escalate-review.sh <category> <error_message> [validators_json]
# Stdout: <qwen_escalation>JSON</qwen_escalation>
# This script is normally called BY _lib.sh::qwen_escalate(), not directly.
set -euo pipefail

CATEGORY="${1:-unknown}"
ERROR_MSG="${2:-Persistent validation failure}"
VALIDATORS_JSON="${3:-{\}}"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

PAYLOAD=$(
  python3 -c '
import json
import sys

timestamp, category, error_msg, validators_json = sys.argv[1:5]
try:
    validators = json.loads(validators_json)
except json.JSONDecodeError as exc:
    validators = {
        "_error": "invalid validators_json",
        "raw": validators_json,
        "message": str(exc),
    }

print(json.dumps({
    "status": "escalate",
    "timestamp": timestamp,
    "category": category,
    "error": error_msg,
    "validators": validators,
    "instruction": "Fix directly or inform user — do not re-read Qwen output.",
}, ensure_ascii=False))
' "$TIMESTAMP" "$CATEGORY" "$ERROR_MSG" "$VALIDATORS_JSON"
)

printf '<qwen_escalation>\n%s\n</qwen_escalation>\n' "$PAYLOAD"
