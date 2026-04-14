#!/usr/bin/env bash
# Delegate code generation to Gemini with deterministic validation.
# Uses gemini-2.5-pro (complex code tasks).
# Usage: delegate-codegen.sh <lang> "<spec_prompt>"
#   lang: python | typescript | bash
# Stdout: <gemini_output category="codegen-LANG">...</gemini_output>
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

gemini_preflight

PROMPT="You are a ${LANG} code generator. Return ONLY valid ${LANG} code — no markdown fences, no prose, no commentary.

Write ${LANG} code for this specification:

${SPEC}

Include type hints and a docstring. Start directly with the code."

gemini_invoke_with_retry "$GEMINI_DELEGATE_MAX_RETRIES" "$PROMPT" \
  "$GEMINI_DELEGATE_PRO_MODEL" "plan"
CODE="$GEMINI_RESPONSE"

# Strip markdown fences if Gemini included them (first and last line only — avoids
# removing ``` that may appear inside docstrings or string literals)
CODE=$(echo "$CODE" | sed -e '1{/^```/d}' -e '${/^```$/d}')

TMP_FILE=$(mktemp "/tmp/gemini_codegen_XXXXXX")
PY_ERR_FILE=$(mktemp "/tmp/gemini_py_err_XXXXXX")
SC_ERR_FILE=$(mktemp "/tmp/gemini_sc_err_XXXXXX")
trap 'rm -f "$TMP_FILE" "$PY_ERR_FILE" "$SC_ERR_FILE"' EXIT
echo "$CODE" > "$TMP_FILE"

case "$LANG" in
  python)
    # Validator 1: syntax (up to 2 retries)
    COMPILE_RETRIES=0
    while ! python3 -m py_compile "$TMP_FILE" 2>"$PY_ERR_FILE"; do
      COMPILE_ERR=$(head -3 "$PY_ERR_FILE" || true)
      if (( COMPILE_RETRIES >= 2 )); then
        gemini_escalate "codegen-python" "syntax errors persist after 2 retries" '{"syntax":"fail"}'
      fi
      COMPILE_RETRIES=$((COMPILE_RETRIES + 1))
      log_warn "Syntax error (attempt $COMPILE_RETRIES/2): $COMPILE_ERR. Retrying."
      RETRY_PROMPT="Previous Python code had syntax errors: ${COMPILE_ERR}. Fix and return ONLY valid Python code, no fences."
      gemini_invoke_with_retry 2 "$RETRY_PROMPT" "$GEMINI_DELEGATE_PRO_MODEL" "plan"
      CODE="$GEMINI_RESPONSE"
      CODE=$(echo "$CODE" | sed -e '1{/^```/d}' -e '${/^```$/d}')
      echo "$CODE" > "$TMP_FILE"
    done
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
    TMP_TS="${TMP_FILE}.ts"
    cp "$TMP_FILE" "$TMP_TS"
    trap 'rm -f "$TMP_FILE" "$TMP_TS" "$PY_ERR_FILE" "$SC_ERR_FILE"' EXIT
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
      if ! shellcheck "$TMP_FILE" 2>"$SC_ERR_FILE"; then
        SC_ISSUES=$(head -5 "$SC_ERR_FILE" || true)
        log_warn "shellcheck: $SC_ISSUES"
      else
        log_pass "shellcheck: OK"
      fi
    else
      log_warn "shellcheck not installed — skipping."
    fi
    ;;

  *)
    log_warn "No validators for lang='$LANG'. Delivering as-is."
    ;;
esac

gemini_present_output "$CODE" "codegen-${LANG}"
