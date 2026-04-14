#!/usr/bin/env bash
# Emit a structured escalation payload for Claude to act on.
# Usage: escalate-review.sh <category> <error_message> [validators_json]
# Stdout: <gemini_escalation>JSON</gemini_escalation>
# This script is a standalone helper; _lib.sh::gemini_escalate() is the runtime code path.
set -euo pipefail

CATEGORY="${1:-unknown}"
ERROR_MSG="${2:-Persistent validation failure}"
VALIDATORS_JSON="${3:-}"
[[ -z "$VALIDATORS_JSON" ]] && VALIDATORS_JSON="{}"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

printf '%s\n' '<gemini_escalation>'
jq -n \
  --arg status "escalate" \
  --arg ts "$TIMESTAMP" \
  --arg cat "$CATEGORY" \
  --arg err "$ERROR_MSG" \
  --argjson val "$VALIDATORS_JSON" \
  --arg instr "Gemini output failed deterministic validation after retries. (1) Fix the issue directly with minimal tokens, OR (2) inform the user with the exact error and offer alternatives. Do NOT re-read the raw Gemini output." \
  '{status: $status, timestamp: $ts, category: $cat, error: $err, validators: $val, instruction: $instr}'
printf '%s\n' '</gemini_escalation>'
