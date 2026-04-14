#!/usr/bin/env bash
# Delegate research tasks to Gemini using Google Search grounding.
# Uses --approval-mode yolo to allow Google Search tool invocation.
# Uses gemini-2.5-pro for quality research responses.
# Usage: delegate-research.sh "<research_question>" [min_words]
# Stdout: <gemini_output category="research">...</gemini_output>
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/_lib.sh"

QUESTION="${1:-}"
MIN_WORDS="${2:-50}"

if [[ -z "$QUESTION" ]]; then
  log_error "Usage: delegate-research.sh \"<research_question>\" [min_words]"
  exit 1
fi

gemini_preflight

PROMPT="Research the following question using Google Search. Provide a well-structured, factual answer with sources where available.
Include key findings, relevant context, and any important caveats.
Format: use bullet points or numbered lists where appropriate.

Question: ${QUESTION}"

# Research requires yolo mode so Gemini can invoke Google Search tool
gemini_invoke_with_retry "$GEMINI_DELEGATE_MAX_RETRIES" "$PROMPT" \
  "$GEMINI_DELEGATE_PRO_MODEL" "yolo"
RESULT="$GEMINI_RESPONSE"

# Validator 1: minimum word count (research must be substantive)
WORD_COUNT=$(echo "$RESULT" | wc -w | tr -d ' ')
if (( WORD_COUNT < MIN_WORDS )); then
  log_warn "Research response too short ($WORD_COUNT words, min $MIN_WORDS). Retrying."
  RETRY_PROMPT="Your previous research response was too short ($WORD_COUNT words). Provide a more comprehensive answer with at least $MIN_WORDS words for: ${QUESTION}"
  gemini_invoke_with_retry 1 "$RETRY_PROMPT" "$GEMINI_DELEGATE_PRO_MODEL" "yolo"
  RESULT="$GEMINI_RESPONSE"
  WORD_COUNT=$(echo "$RESULT" | wc -w | tr -d ' ')
  if (( WORD_COUNT < MIN_WORDS )); then
    gemini_escalate "research" \
      "response too short ($WORD_COUNT words, min $MIN_WORDS) after retry" \
      '{"word_count":"fail"}'
  fi
fi
log_pass "Research response: $WORD_COUNT words"

gemini_present_output "$RESULT" "research"
