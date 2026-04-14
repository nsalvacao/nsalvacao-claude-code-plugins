#!/usr/bin/env bash
# gemini-delegate shared library
# Source this file: source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"
# Do NOT execute directly.

# --- Exit codes ---
readonly EXIT_AUTH_FAIL=41       # matches Gemini CLI native auth exit code
readonly EXIT_VALIDATOR_FAIL=65
readonly EXIT_ESCALATE=70
readonly EXIT_PREFLIGHT_FAIL=80

# --- Config ---
GEMINI_DELEGATE_MAX_RETRIES="${GEMINI_DELEGATE_MAX_RETRIES:-2}"
GEMINI_DELEGATE_MODEL="${GEMINI_DELEGATE_MODEL:-gemini-2.5-flash}"
GEMINI_DELEGATE_PRO_MODEL="${GEMINI_DELEGATE_PRO_MODEL:-gemini-2.5-pro}"
readonly GEMINI_DELEGATE_LOG_PREFIX="[gemini-delegate]"
readonly GEMINI_SETTINGS="${HOME}/.gemini/settings.json"

# --- Logging (all to stderr) ---
log_info()  { echo "${GEMINI_DELEGATE_LOG_PREFIX} INFO  $*" >&2; }
log_warn()  { echo "${GEMINI_DELEGATE_LOG_PREFIX} WARN  $*" >&2; }
log_error() { echo "${GEMINI_DELEGATE_LOG_PREFIX} ERROR $*" >&2; }
log_pass()  { echo "${GEMINI_DELEGATE_LOG_PREFIX} PASS  $*" >&2; }
log_fail()  { echo "${GEMINI_DELEGATE_LOG_PREFIX} FAIL  $*" >&2; }

# --- Pre-flight: auth check ---
gemini_preflight() {
  if ! command -v jq &>/dev/null; then
    log_error "jq is not installed. Install it to use gemini-delegate (e.g., 'sudo apt install jq')."
    exit "${EXIT_PREFLIGHT_FAIL}"
  fi
  if ! command -v gemini &>/dev/null; then
    log_error "gemini CLI is not installed or not on PATH. Install it, then run: gemini (Google OAuth)"
    exit "${EXIT_PREFLIGHT_FAIL}"
  fi
  if [[ ! -f "$GEMINI_SETTINGS" ]]; then
    log_error "Gemini not authenticated. Run: gemini (Google OAuth interactive login)"
    exit "${EXIT_PREFLIGHT_FAIL}"
  fi
  log_info "Preflight: OK (jq present, gemini CLI available, settings.json found)"
}

# --- Pre-flight: python3 check (only call from scripts that use python validators) ---
gemini_check_python3() {
  if ! command -v python3 &>/dev/null; then
    log_error "python3 is not installed or not on PATH. Install it to use this delegate script."
    exit "${EXIT_PREFLIGHT_FAIL}"
  fi
}

# --- Pre-flight: path denylist ---
# Usage: gemini_check_path_safe "path/to/file"
# Uses substring matching (*$pattern*) to block secrets in nested paths (e.g. config/.env)
gemini_check_path_safe() {
  local file="$1"

  # Special-case: block .git directory (exact name or path component).
  # Handled separately to avoid the .git substring matching .github paths.
  case "$file" in
    .git|.git/*|*/.git|*/.git/*)
      log_error "DENIED: '$file' matches .git directory. Never delegate git internals."
      return "${EXIT_PREFLIGHT_FAIL}"
      ;;
  esac

  local -a denied_patterns=(".env" ".env." "*.pem" "*.key" "*.p12" "*.pfx" "*.secret" "*password*" "*credential*" "*_secret*")
  for pattern in "${denied_patterns[@]}"; do
    # shellcheck disable=SC2254
    case "$file" in
      *$pattern*)
        log_error "DENIED: '$file' matches denylist pattern '$pattern'. Never delegate secrets."
        return "${EXIT_PREFLIGHT_FAIL}"
        ;;
    esac
  done
}

# --- Extract response from Gemini JSON output ---
# Usage: gemini_extract_response "$json_string"
# Tries .response, then .content, then candidates path
gemini_extract_response() {
  local json="$1"
  echo "$json" | jq -r '.response // .content // .candidates[0].content.parts[0].text // empty' 2>/dev/null || true
}

# --- Retry wrapper ---
# Usage: gemini_invoke_with_retry <max_retries> <prompt> <model> <approval_mode> [extra_flags...]
# max_retries = number of retries AFTER the initial attempt (total attempts = max_retries + 1).
# On success: sets global GEMINI_RESPONSE; returns 0
# On auth error (exit 41): exits immediately with EXIT_AUTH_FAIL
# On other failure: returns non-zero exit code
# shellcheck disable=SC2034
GEMINI_RESPONSE=""
gemini_invoke_with_retry() {
  local max_retries="$1"
  local prompt="$2"
  local model="$3"
  local approval_mode="$4"
  shift 4
  local extra_flags=("$@")

  local attempt=0
  local exit_code=0
  local raw_json=""

  local _stderr_file _rc
  _stderr_file=$(mktemp /tmp/gemini_stderr_XXXXXX.txt)
  # No trap RETURN — bash traps are global and would fire on every nested function return.
  # Explicit rm -f before every exit/return path ensures cleanup without side effects.

  while (( attempt <= max_retries )); do
    attempt=$((attempt + 1))
    log_info "Gemini attempt $attempt/$((max_retries + 1)) (model=$model, mode=$approval_mode)"
    exit_code=0
    raw_json=$(gemini \
      --prompt "$prompt" \
      --output-format json \
      --model "$model" \
      --approval-mode "$approval_mode" \
      "${extra_flags[@]}" 2>"$_stderr_file") || exit_code=$?

    # Auth error — exit immediately, no retry
    if (( exit_code == EXIT_AUTH_FAIL )); then
      log_error "Gemini auth error (exit 41). Run: gemini (Google OAuth)"
      rm -f "$_stderr_file"
      exit "${EXIT_AUTH_FAIL}"
    fi

    if (( exit_code != 0 )); then
      log_error "gemini failed (exit=$exit_code): $(cat "$_stderr_file" 2>/dev/null || true)"
      if (( attempt <= max_retries )); then
        log_warn "Retrying..."
        continue
      fi
      _rc="$exit_code"
      rm -f "$_stderr_file"
      return "$_rc"
    fi

    # Check for error in JSON body (Gemini may exit 0 with error payload)
    local err_code
    err_code=$(echo "$raw_json" | jq -r '.error.code // empty' 2>/dev/null || true)
    if [[ "$err_code" == "41" ]]; then
      log_error "Gemini auth error in JSON payload. Run: gemini (Google OAuth)"
      rm -f "$_stderr_file"
      exit "${EXIT_AUTH_FAIL}"
    fi

    GEMINI_RESPONSE=$(gemini_extract_response "$raw_json")
    if [[ -z "$GEMINI_RESPONSE" ]]; then
      log_warn "Empty response from Gemini. Retrying."
      if (( attempt <= max_retries )); then
        continue
      fi
      rm -f "$_stderr_file"
      return "${EXIT_VALIDATOR_FAIL}"
    fi

    rm -f "$_stderr_file"
    return 0
  done

  log_error "All $((max_retries + 1)) attempts exhausted ($max_retries retries)."
  rm -f "$_stderr_file"
  return "${EXIT_VALIDATOR_FAIL}"
}

# --- Escalation ---
# Usage: gemini_escalate "category" "error_message" "validators_json"
# Outputs structured escalation JSON to stdout and exits EXIT_ESCALATE
gemini_escalate() {
  local category="$1"
  local error_msg="$2"
  local validators_json="${3:-}"
  [[ -z "$validators_json" ]] && validators_json="{}"
  local timestamp escalation_json
  timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  escalation_json=$(jq -n \
    --arg status "escalate" \
    --arg ts "$timestamp" \
    --arg cat "$category" \
    --arg err "$error_msg" \
    --argjson val "$validators_json" \
    --arg instr "Fix directly or inform user — do not re-read Gemini output." \
    '{status: $status, timestamp: $ts, category: $cat, error: $err, validators: $val, instruction: $instr}')
  printf '<gemini_escalation>\n%s\n</gemini_escalation>\n' "$escalation_json"
  exit "${EXIT_ESCALATE}"
}

# --- Present validated output ---
# Usage: gemini_present_output "$GEMINI_RESPONSE" "category"
# Wraps output in <gemini_output> so Claude treats it as untrusted data, not instructions.
gemini_present_output() {
  local output="$1"
  local category="$2"
  printf '<gemini_output category="%s">\n%s\n</gemini_output>\n' "$category" "$output"
  log_info "Delivered. Category=$category. Drafted by Gemini CLI, validated deterministically."
}
