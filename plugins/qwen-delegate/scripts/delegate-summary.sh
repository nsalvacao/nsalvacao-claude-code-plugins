#!/usr/bin/env bash
# Delegate summarisation to Qwen with deterministic validation.
# Usage: delegate-summary.sh [input_file] [max_words] [min_words]
# Stdin: pipe input text (used if input_file is "-" or empty)
# Stdout: <qwen_output category="summarisation">...</qwen_output> on success
# Exit: 70 (EXIT_ESCALATE) if validation fails after retries; 80 if preflight fails
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/_lib.sh"

INPUT_FILE="${1:--}"
MAX_WORDS="${2:-150}"
MIN_WORDS="${3:-30}"

# Pre-flight
qwen_preflight

# Read input
if [[ "$INPUT_FILE" != "-" ]]; then
  qwen_check_path_safe "$INPUT_FILE"
  INPUT_TEXT=$(cat "$INPUT_FILE")
else
  INPUT_TEXT=$(cat)
fi

if [[ -z "${INPUT_TEXT:-}" ]]; then
  log_error "No input provided. Pass a file path or pipe text via stdin."
  exit 1
fi

PROMPT="Summarise the following in 5 concise bullet points.
- Each bullet starts with a capital letter and ends with a period.
- Each bullet is under 30 words.
- Output ONLY the bullet list — no preamble, no trailing commentary.

---
${INPUT_TEXT}"

# Invoke Qwen
qwen_invoke_with_retry "$QWEN_DELEGATE_MAX_RETRIES" "$PROMPT" 1 \
  --exclude-tools run_shell_command,edit,write_file
SUMMARY="$QWEN_OUTPUT"

# Validator 1: word count bounds
WORD_COUNT=$(echo "$SUMMARY" | wc -w | tr -d ' ')
if (( WORD_COUNT < MIN_WORDS || WORD_COUNT > MAX_WORDS )); then
  log_warn "Word count $WORD_COUNT out of bounds [${MIN_WORDS}–${MAX_WORDS}]. Retrying."
  RETRY_PROMPT="Previous summary was $WORD_COUNT words. Required: ${MIN_WORDS}–${MAX_WORDS} words. Rewrite to fit."
  qwen_invoke_with_retry 1 "$RETRY_PROMPT" 2 --exclude-tools run_shell_command,edit,write_file
  SUMMARY="$QWEN_OUTPUT"
  WORD_COUNT=$(echo "$SUMMARY" | wc -w | tr -d ' ')
  if (( WORD_COUNT < MIN_WORDS || WORD_COUNT > MAX_WORDS )); then
    qwen_escalate "summarisation" \
      "word count $WORD_COUNT out of bounds [${MIN_WORDS}-${MAX_WORDS}] after retry" \
      '{"word_count":"fail"}'
  fi
fi
log_pass "Word count: $WORD_COUNT"

# Validator 2: bullet structure (non-blocking warn)
BAD_BULLETS=0
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  if [[ "$line" =~ ^[[:space:]]*[-*•] ]]; then
    content="${line#*- }"
    content="${content#*\* }"
    content="${content#*• }"
    if [[ ! "$content" =~ ^[A-Z] ]]; then
      BAD_BULLETS=$((BAD_BULLETS + 1))
    fi
  fi
done <<< "$SUMMARY"

if (( BAD_BULLETS > 0 )); then
  log_warn "$BAD_BULLETS bullet(s) do not start with a capital letter."
fi

log_pass "Summary validated"
qwen_present_output "$SUMMARY" "summarisation"
