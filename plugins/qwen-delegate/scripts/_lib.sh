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
QWEN_DELEGATE_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly QWEN_DELEGATE_LIB_DIR

# --- Logging (all to stderr) ---
log_info()  { echo "${QWEN_DELEGATE_LOG_PREFIX} INFO  $*" >&2; }
log_warn()  { echo "${QWEN_DELEGATE_LOG_PREFIX} WARN  $*" >&2; }
log_error() { echo "${QWEN_DELEGATE_LOG_PREFIX} ERROR $*" >&2; }
log_pass()  { echo "${QWEN_DELEGATE_LOG_PREFIX} PASS  $*" >&2; }
log_fail()  { echo "${QWEN_DELEGATE_LOG_PREFIX} FAIL  $*" >&2; }

# --- Pre-flight: auth check ---
qwen_preflight() {
  local auth_status
  if ! command -v qwen >/dev/null 2>&1; then
    log_error "Qwen CLI not installed. Install qwen and verify with: qwen --version"
    exit "${EXIT_PREFLIGHT_FAIL}"
  fi
  if ! command -v python3 >/dev/null 2>&1; then
    log_error "Python 3 is required for qwen-delegate validators and escalation payloads."
    exit "${EXIT_PREFLIGHT_FAIL}"
  fi
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
  case "$file" in
    .git|.git/*|*/.git|*/.git/*)
      log_error "DENIED: '$file' references the .git directory. Never delegate repository internals."
      return "${EXIT_PREFLIGHT_FAIL}"
      ;;
  esac

  local -a denied_patterns=(".env" ".env." "*.pem" "*.key" "*.p12" "*.pfx" "*.secret" "*password*" "*credential*" "*_secret*")
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
# max_retries=2 means one initial attempt plus up to 2 retries.
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
  local total_attempts=$((max_retries + 1))
  while (( attempt < total_attempts )); do
    attempt=$((attempt + 1))
    log_info "Qwen attempt $attempt/$total_attempts (turns=$turns)"
    exit_code=0
    local stderr_file
    stderr_file=$(mktemp "${TMPDIR:-/tmp}/qwen_stderr_XXXXXX")
    # shellcheck disable=SC2034
    QWEN_OUTPUT=$(qwen "$prompt" \
      --output-format text \
      --approval-mode yolo \
      --max-session-turns "$turns" \
      "${extra_flags[@]}" 2>"$stderr_file") || exit_code=$?

    if (( exit_code == EXIT_QWEN_TURNS )); then
      log_warn "Exit 53 — turns exhausted. Retrying with $((turns + 2)) turns."
      turns=$((turns + 2))
      rm -f "$stderr_file"
      continue
    fi

    if (( exit_code != 0 )); then
      log_error "qwen failed (exit=$exit_code): $(cat "$stderr_file" 2>/dev/null || true)"
      rm -f "$stderr_file"
      return "$exit_code"
    fi

    rm -f "$stderr_file"
    return 0
  done

  log_error "All $total_attempts attempts exhausted."
  return "${EXIT_VALIDATOR_FAIL}"
}

# --- Escalation ---
# Usage: qwen_escalate "category" "error_message" "validators_json"
# Outputs structured escalation JSON to stdout and exits EXIT_ESCALATE
qwen_escalate() {
  local category="$1"
  local error_msg="$2"
  local validators_json="${3:-{\}}"
  local script_status=0

  bash "${QWEN_DELEGATE_LIB_DIR}/escalate-review.sh" "$category" "$error_msg" "$validators_json" || script_status=$?
  if (( script_status != 0 )); then
    log_error "Failed to build escalation payload (exit=$script_status)."
  fi
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
