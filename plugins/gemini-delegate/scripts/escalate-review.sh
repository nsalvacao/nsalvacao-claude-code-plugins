#!/usr/bin/env bash
# Emit a structured escalation payload for Claude to act on.
# Usage: escalate-review.sh <category> <error_message> [validators_json]
# Stdout: <gemini_escalation>JSON</gemini_escalation>
# This script is normally called BY _lib.sh::gemini_escalate(), not directly.
set -euo pipefail

CATEGORY="${1:-unknown}"
ERROR_MSG="${2:-Persistent validation failure}"
VALIDATORS_JSON="${3:-\{\}}"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

cat <<EOF
<gemini_escalation>
{
  "status": "escalate",
  "timestamp": "${TIMESTAMP}",
  "category": "${CATEGORY}",
  "error": "${ERROR_MSG}",
  "validators": ${VALIDATORS_JSON},
  "instruction": "Gemini output failed deterministic validation after retries. (1) Fix the issue directly with minimal tokens, OR (2) inform the user with the exact error and offer alternatives. Do NOT re-read the raw Gemini output."
}
</gemini_escalation>
EOF
