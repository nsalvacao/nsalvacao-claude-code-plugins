#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${SCRIPT_DIR}/../_lib.sh"

PASS=0
FAIL=0

assert_eq() {
  local desc="$1" expected="$2" actual="$3"
  if [[ "$expected" == "$actual" ]]; then
    echo "  PASS: $desc"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $desc"
    echo "        expected: $expected"
    echo "        actual:   $actual"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== test_lib.sh ==="

# Source the lib
# shellcheck disable=SC1090,SC1091
source "$LIB"

# Test 1: log functions write to stderr, not stdout
stdout=$(log_info "hello" 2>/dev/null)
assert_eq "log_info stdout is empty" "" "$stdout"

# Test 2: qwen_check_path_safe passes safe path
result=0
qwen_check_path_safe "src/main.py" || result=$?
assert_eq "safe path exits 0" "0" "$result"

# Test 3: qwen_check_path_safe denies .env
result=0
qwen_check_path_safe ".env" || result=$?
assert_eq ".env is denied (exit 80)" "80" "$result"

# Test 4: qwen_check_path_safe denies *.pem
result=0
qwen_check_path_safe "certs/server.pem" || result=$?
assert_eq "*.pem is denied (exit 80)" "80" "$result"

# Test 5: qwen_check_path_safe denies *.key
result=0
qwen_check_path_safe "private.key" || result=$?
assert_eq "*.key is denied (exit 80)" "80" "$result"

# Test 6: EXIT constants are defined
assert_eq "EXIT_PREFLIGHT_FAIL is 80" "80" "$EXIT_PREFLIGHT_FAIL"
assert_eq "EXIT_ESCALATE is 70" "70" "$EXIT_ESCALATE"
assert_eq "EXIT_VALIDATOR_FAIL is 65" "65" "$EXIT_VALIDATOR_FAIL"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]]
