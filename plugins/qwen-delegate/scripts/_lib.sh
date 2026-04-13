#!/usr/bin/env bash
# qwen-delegate shared library
# Source this file: source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"
# Do NOT execute directly.

# --- Exit codes ---
readonly EXIT_QWEN_TURNS=53
readonly EXIT_VALIDATOR_FAIL=65
readonly EXIT_ESCALATE=70
readonly EXIT_PREFLIGHT_FAIL=80

# --- Config ---
QWEN_DELEGATE_MAX_RETRIES="${QWEN_DELEGATE_MAX_RETRIES:-2}"
readonly QWEN_DELEGATE_LOG_PREFIX="[qwen-delegate]"

# --- Logging (all to stderr) ---
log_info()  { echo "${QWEN_DELEGATE_LOG_PREFIX} INFO  $*" >&2; }
log_warn()  { echo "${QWEN_DELEGATE_LOG_PREFIX} WARN  $*" >&2; }
log_error() { echo "${QWEN_DELEGATE_LOG_PREFIX} ERROR $*" >&2; }
log_pass()  { echo "${QWEN_DELEGATE_LOG_PREFIX} PASS  $*" >&2; }
log_fail()  { echo "${QWEN_DELEGATE_LOG_PREFIX} FAIL  $*" >&2; }

# --- Pre-flight: auth check ---
qwen_preflight() {
  local auth_status
  auth_status=$(qwen auth status 2>&1 || true)
  if ! echo "$auth_status" | grep -qi "authenticated\|logged in\|qwen-oauth"; then
    log_error "Qwen not authenticated. Run: qwen auth"
    exit "${EXIT_PREFLIGHT_FAIL}"
  fi
  log_info "Auth: OK"
}

# --- Pre-flight: path safelist ---
# Usage: qwen_check_path_safe "path/to/file"
qwen_check_path_safe() {
  local file="$1"
  local -a denied_patterns=(".env" ".env." "*.pem" "*.key" "*.p12" "*.pfx" "*.secret" "*password*" "*credential*" "*_secret*" ".git" ".git/")
  for pattern in "${denied_patterns[@]}"; do
    # shellcheck disable=SC2254
    case "$file" in
      *$pattern*)
        log_error "DENIED: '$file' matches safelist pattern '$pattern'. Never delegate secrets."
        return "${EXIT_PREFLIGHT_FAIL}"
        ;;
    esac
  done
}

# --- Retry wrapper ---
# Usage: qwen_invoke_with_retry <max_retries> <prompt> <turns> [extra_flags...]
# On success: sets global QWEN_OUTPUT; returns 0
# On failure: returns non-zero exit code
# NOTE: retry budget is shared — exit-53 (turns exhausted) consumes the same slots as other errors.
# On exit-53, turns are incremented by 2 before the next attempt.
# shellcheck disable=SC2034
QWEN_OUTPUT=""
qwen_invoke_with_retry() {
  local max_retries="$1"
  local prompt="$2"
  local turns="$3"
  shift 3
  local extra_flags=("$@")

  local attempt=0
  local exit_code=0
  while (( attempt < max_retries )); do
    attempt=$((attempt + 1))
    log_info "Qwen attempt $attempt/$max_retries (turns=$turns)"
    exit_code=0
    # shellcheck disable=SC2034
    QWEN_OUTPUT=$(qwen "$prompt" \
      --output-format text \
      --approval-mode yolo \
      --max-session-turns "$turns" \
      "${extra_flags[@]}" 2>/tmp/qwen_stderr_$$.txt) || exit_code=$?

    if (( exit_code == EXIT_QWEN_TURNS )); then
      log_warn "Exit 53 — turns exhausted. Retrying with $((turns + 2)) turns."
      turns=$((turns + 2))
      continue
    fi

    if (( exit_code != 0 )); then
      log_error "qwen failed (exit=$exit_code): $(cat /tmp/qwen_stderr_$$.txt 2>/dev/null || true)"
      rm -f "/tmp/qwen_stderr_$$.txt"
      return "$exit_code"
    fi

    rm -f "/tmp/qwen_stderr_$$.txt"
    return 0
  done

  log_error "All $max_retries attempts exhausted."
  rm -f "/tmp/qwen_stderr_$$.txt"
  return "${EXIT_VALIDATOR_FAIL}"
}

# --- Escalation ---
# Usage: qwen_escalate "category" "error_message" "validators_json"
# Outputs structured escalation JSON to stdout and exits EXIT_ESCALATE
qwen_escalate() {
  local category="$1"
  local error_msg="$2"
  local validators_json="${3:-{\}}"
  local timestamp safe_category safe_error
  timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  safe_category=$(printf '%s' "$category" | sed 's/\\/\\\\/g; s/"/\\"/g')
  safe_error=$(printf '%s' "$error_msg" | sed 's/\\/\\\\/g; s/"/\\"/g')

  printf '<qwen_escalation>\n{"status":"escalate","timestamp":"%s","category":"%s","error":"%s","validators":%s,"instruction":"Fix directly or inform user — do not re-read Qwen output."}\n</qwen_escalation>\n' \
    "$timestamp" "$safe_category" "$safe_error" "$validators_json"
  exit "${EXIT_ESCALATE}"
}

# --- Present validated output ---
# Usage: qwen_present_output "$QWEN_OUTPUT" "category"
# Wraps output in <qwen_output> so Claude treats it as untrusted data, not instructions.
qwen_present_output() {
  local output="$1"
  local category="$2"
  printf '<qwen_output category="%s">\n%s\n</qwen_output>\n' "$category" "$output"
  log_info "Delivered. Category=$category. Drafted by Qwen CLI (coder-model), validated deterministically."
}
