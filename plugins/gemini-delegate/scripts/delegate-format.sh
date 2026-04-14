#!/usr/bin/env bash
# Delegate formatting/conversion to Gemini with deterministic validation.
# Usage: delegate-format.sh <format_type> [input_file]
#   format_type: json | yaml | markdown
# Stdin: pipe input if input_file is "-" or omitted
# Stdout: <gemini_output category="formatting-TYPE">...</gemini_output>
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/_lib.sh"

FORMAT_TYPE="${1:-json}"
INPUT_FILE="${2:--}"

gemini_preflight

if [[ "$INPUT_FILE" != "-" ]]; then
  gemini_check_path_safe "$INPUT_FILE" || exit "${EXIT_PREFLIGHT_FAIL}"
  INPUT_TEXT=$(cat "$INPUT_FILE")
else
  INPUT_TEXT=$(cat)
fi

if [[ -z "${INPUT_TEXT:-}" ]]; then
  log_error "No input provided."
  exit 1
fi

case "$FORMAT_TYPE" in
  json)
    PROMPT="Format the following JSON with 2-space indentation and alphabetically sorted keys.
Output ONLY valid JSON — no markdown fences, no prose, no commentary.

${INPUT_TEXT}"
    TURNS_MODEL="$GEMINI_DELEGATE_MODEL"
    ;;
  yaml)
    PROMPT="Reformat the following YAML: consistent 2-space indentation, sorted keys at each level.
Output ONLY valid YAML — no prose, no fences.

${INPUT_TEXT}"
    TURNS_MODEL="$GEMINI_DELEGATE_MODEL"
    ;;
  markdown)
    PROMPT="Reformat the following Markdown for consistency: ATX headings, normalised list markers (use -), proper blank lines between sections.
Output ONLY the reformatted Markdown — no commentary.

${INPUT_TEXT}"
    TURNS_MODEL="$GEMINI_DELEGATE_MODEL"
    ;;
  *)
    log_error "Unknown format type: '$FORMAT_TYPE'. Valid: json, yaml, markdown"
    exit 1
    ;;
esac

gemini_invoke_with_retry "$GEMINI_DELEGATE_MAX_RETRIES" "$PROMPT" "$TURNS_MODEL" "plan"
FORMATTED="$GEMINI_RESPONSE"

# Strip markdown fences if Gemini included them (first and last line only — avoids
# removing ``` that may appear inside formatted markdown or code blocks)
FORMATTED=$(echo "$FORMATTED" | sed -e '1{/^```/d}' -e '${/^```$/d}')

# ---- Validators ----
case "$FORMAT_TYPE" in
  json)
    # Validator 1: syntax — jq exits non-zero on invalid JSON
    if ! echo "$FORMATTED" | jq . > /dev/null 2>&1; then
      RETRY_PROMPT="Output was not valid JSON. Return ONLY valid JSON with 2-space indentation, sorted keys, no fences.

${INPUT_TEXT}"
      gemini_invoke_with_retry "$GEMINI_DELEGATE_MAX_RETRIES" "$RETRY_PROMPT" "$TURNS_MODEL" "plan"
      FORMATTED="$GEMINI_RESPONSE"
      FORMATTED=$(echo "$FORMATTED" | sed -e '1{/^```/d}' -e '${/^```$/d}')
      if ! echo "$FORMATTED" | jq . > /dev/null 2>&1; then
        gemini_escalate "formatting-json" "output is not valid JSON after retry" '{"json_syntax":"fail"}'
      fi
    fi
    log_pass "JSON syntax valid"

    # Validator 2: normalize to 2-space + sorted keys (fulfils stated contract), then idempotency check.
    # jq is already a required dependency (pre-flight). python3 -m json.tool was 4-space and unsorted.
    NORM1=$(echo "$FORMATTED" | jq --indent 2 -S .)
    NORM2=$(echo "$NORM1" | jq --indent 2 -S .)
    HASH1=$(echo "$NORM1" | (sha256sum 2>/dev/null || shasum -a 256) | cut -d' ' -f1)
    HASH2=$(echo "$NORM2" | (sha256sum 2>/dev/null || shasum -a 256) | cut -d' ' -f1)
    if [[ "$HASH1" != "$HASH2" ]]; then
      gemini_escalate "formatting-json" "format not idempotent (hash mismatch)" '{"idempotency":"fail"}'
    fi
    log_pass "JSON idempotency verified (2-space, sorted keys)"
    FORMATTED="$NORM1"
    ;;

  yaml)
    if command -v yamllint &> /dev/null; then
      if yamllint -d "{extends: relaxed, rules: {line-length: {max: 120}}}" - <<< "$FORMATTED" &>/dev/null; then
        log_pass "yamllint OK"
      else
        log_warn "yamllint issues detected — manual review recommended."
      fi
    else
      log_warn "yamllint not installed — skipping YAML lint."
    fi
    ;;

  markdown)
    if command -v markdownlint-cli2 &> /dev/null; then
      TMP_MD=$(mktemp /tmp/gemini_md_XXXXXX.md)
      trap 'rm -f "$TMP_MD"' EXIT
      echo "$FORMATTED" > "$TMP_MD"
      if markdownlint-cli2 "$TMP_MD" &>/dev/null; then
        log_pass "markdownlint OK"
      else
        log_warn "markdownlint issues — manual review recommended."
      fi
    else
      log_warn "markdownlint-cli2 not installed — skipping markdown lint."
    fi
    ;;
esac

gemini_present_output "$FORMATTED" "formatting-${FORMAT_TYPE}"
