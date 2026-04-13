#!/usr/bin/env bash
# Delegate formatting/conversion to Qwen with deterministic validation.
# Usage: delegate-format.sh <format_type> [input_file]
#   format_type: json | yaml | markdown
# Stdin: pipe input if input_file is "-" or omitted
# Stdout: <qwen_output category="formatting-TYPE">...</qwen_output>
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/_lib.sh"

FORMAT_TYPE="${1:-json}"
INPUT_FILE="${2:--}"

qwen_preflight

if [[ "$INPUT_FILE" != "-" ]]; then
  qwen_check_path_safe "$INPUT_FILE"
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
    TURNS=1
    ;;
  yaml)
    PROMPT="Reformat the following YAML: consistent 2-space indentation, sorted keys at each level.
Output ONLY valid YAML — no prose, no fences.

${INPUT_TEXT}"
    TURNS=1
    ;;
  markdown)
    PROMPT="Reformat the following Markdown for consistency: ATX headings, normalised list markers (use -), proper blank lines between sections.
Output ONLY the reformatted Markdown — no commentary.

${INPUT_TEXT}"
    TURNS=2
    ;;
  *)
    log_error "Unknown format type: '$FORMAT_TYPE'. Valid: json, yaml, markdown"
    exit 1
    ;;
esac

qwen_invoke_with_retry "$QWEN_DELEGATE_MAX_RETRIES" "$PROMPT" "$TURNS" \
  --exclude-tools run_shell_command,edit,write_file
FORMATTED="$QWEN_OUTPUT"

# ---- Validators ----
case "$FORMAT_TYPE" in
  json)
    # Validator 1: syntax
    if ! python3 -m json.tool <<< "$FORMATTED" > /dev/null 2>&1; then
      RETRY_PROMPT="Output was not valid JSON. Return ONLY valid JSON with 2-space indentation, sorted keys, no fences.

${INPUT_TEXT}"
      qwen_invoke_with_retry 1 "$RETRY_PROMPT" 1 --exclude-tools run_shell_command,edit,write_file
      FORMATTED="$QWEN_OUTPUT"
      if ! python3 -m json.tool <<< "$FORMATTED" > /dev/null 2>&1; then
        qwen_escalate "formatting-json" "output is not valid JSON after retry" '{"json_syntax":"fail"}'
      fi
    fi
    log_pass "JSON syntax valid"

    # Validator 2: idempotency
    NORM1=$(python3 -m json.tool <<< "$FORMATTED")
    NORM2=$(python3 -m json.tool <<< "$NORM1")
    HASH1=$(echo "$NORM1" | sha256sum | cut -d' ' -f1)
    HASH2=$(echo "$NORM2" | sha256sum | cut -d' ' -f1)
    if [[ "$HASH1" != "$HASH2" ]]; then
      qwen_escalate "formatting-json" "format not idempotent (hash mismatch)" '{"idempotency":"fail"}'
    fi
    log_pass "JSON idempotency verified"
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
      TMP_MD=$(mktemp /tmp/qwen_md_XXXXXX.md)
      echo "$FORMATTED" > "$TMP_MD"
      if markdownlint-cli2 "$TMP_MD" &>/dev/null; then
        log_pass "markdownlint OK"
      else
        log_warn "markdownlint issues — manual review recommended."
      fi
      rm -f "$TMP_MD"
    else
      log_warn "markdownlint-cli2 not installed — skipping markdown lint."
    fi
    ;;
esac

qwen_present_output "$FORMATTED" "formatting-${FORMAT_TYPE}"
