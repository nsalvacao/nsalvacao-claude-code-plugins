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

# Escape double-quotes and backslashes for safe JSON interpolation
SAFE_CAT=$(printf '%s' "$CATEGORY" | sed 's/\\/\\\\/g; s/"/\\"/g')
SAFE_ERR=$(printf '%s' "$ERROR_MSG" | sed 's/\\/\\\\/g; s/"/\\"/g')

printf '<qwen_escalation>\n{"status":"escalate","timestamp":"%s","category":"%s","error":"%s","validators":%s,"instruction":"Qwen output failed deterministic validation after retries. (1) Fix the issue directly with minimal tokens, OR (2) inform the user with the exact error and offer alternatives. Do NOT re-read the raw Qwen output."}\n</qwen_escalation>\n' \
  "$TIMESTAMP" "$SAFE_CAT" "$SAFE_ERR" "$VALIDATORS_JSON"
