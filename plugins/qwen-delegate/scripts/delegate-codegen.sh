#!/usr/bin/env bash
# Delegate code generation to Qwen with deterministic validation.
# Usage: delegate-codegen.sh <lang> "<spec_prompt>"
#   lang: python | typescript | bash
# Stdout: <qwen_output category="codegen-LANG">...</qwen_output>
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/_lib.sh"

LANG="${1:-python}"
SPEC="${2:-}"

if [[ -z "$SPEC" ]]; then
  log_error "Usage: delegate-codegen.sh <lang> \"<spec_prompt>\""
  exit 1
fi

qwen_preflight

SYS_PROMPT="You are a ${LANG} code generator. Return ONLY valid ${LANG} code — no markdown fences, no prose, no commentary. Start directly with the code."

PROMPT="Write ${LANG} code for this specification:

${SPEC}

Include type hints and a docstring. Output ONLY the code."

qwen_invoke_with_retry "$QWEN_DELEGATE_MAX_RETRIES" "$PROMPT" 3 \
  --exclude-tools run_shell_command,edit,write_file \
  --system-prompt "$SYS_PROMPT"
CODE="$QWEN_OUTPUT"

# Strip markdown fences if Qwen included them despite instructions
CODE=$(echo "$CODE" | sed '/^```/d')

TMP_FILE=$(mktemp "/tmp/qwen_codegen_XXXXXX")
trap 'rm -f "$TMP_FILE"' EXIT
echo "$CODE" > "$TMP_FILE"

case "$LANG" in
  python)
    # Validator 1: syntax
    if ! python3 -m py_compile "$TMP_FILE" 2>/tmp/py_err_$$.txt; then
      COMPILE_ERR=$(head -3 "/tmp/py_err_$$.txt" || true)
      rm -f "/tmp/py_err_$$.txt"
      log_warn "Syntax error: $COMPILE_ERR. Retrying."
      RETRY_PROMPT="Previous Python code had syntax errors: ${COMPILE_ERR}. Fix and return ONLY valid Python code."
      qwen_invoke_with_retry 2 "$RETRY_PROMPT" 2 --exclude-tools run_shell_command,edit,write_file
      CODE="$QWEN_OUTPUT"
      CODE=$(echo "$CODE" | sed '/^```/d')
      echo "$CODE" > "$TMP_FILE"
      if ! python3 -m py_compile "$TMP_FILE" 2>/dev/null; then
        qwen_escalate "codegen-python" "syntax errors persist after retry" '{"syntax":"fail"}'
      fi
    fi
    rm -f "/tmp/py_err_$$.txt"
    log_pass "Python syntax valid"

    # Validator 2: mypy (non-blocking)
    if command -v mypy &> /dev/null; then
      MYPY_OUT=$(mypy "$TMP_FILE" --ignore-missing-imports --no-error-summary 2>&1 || true)
      if echo "$MYPY_OUT" | grep -q "error:"; then
        log_warn "mypy: $(echo "$MYPY_OUT" | grep 'error:' | head -3)"
      else
        log_pass "mypy: no errors"
      fi
    else
      log_warn "mypy not installed — skipping type check."
    fi
    ;;

  typescript)
    # Rename to .ts for tsc
    TMP_TS="${TMP_FILE}.ts"
    cp "$TMP_FILE" "$TMP_TS"
    trap 'rm -f "$TMP_FILE" "$TMP_TS"' EXIT
    if command -v tsc &> /dev/null; then
      TSC_OUT=$(tsc --noEmit --allowJs "$TMP_TS" 2>&1 || true)
      if echo "$TSC_OUT" | grep -q "error TS"; then
        log_warn "tsc: $(echo "$TSC_OUT" | grep 'error TS' | head -3)"
      else
        log_pass "tsc: no errors"
      fi
    else
      log_warn "tsc not installed — skipping type check."
    fi
    ;;

  bash)
    if command -v shellcheck &> /dev/null; then
      if ! shellcheck "$TMP_FILE" 2>/tmp/sc_$$.txt; then
        SC_ISSUES=$(head -5 "/tmp/sc_$$.txt" || true)
        log_warn "shellcheck: $SC_ISSUES"
      else
        log_pass "shellcheck: OK"
      fi
      rm -f "/tmp/sc_$$.txt"
    else
      log_warn "shellcheck not installed — skipping."
    fi
    ;;

  *)
    log_warn "No validators for lang='$LANG'. Delivering as-is."
    ;;
esac

qwen_present_output "$CODE" "codegen-${LANG}"
