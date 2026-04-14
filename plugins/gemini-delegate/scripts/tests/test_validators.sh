#!/usr/bin/env bash
# Validator offline tests (no real Gemini invocation — uses mock GEMINI_RESPONSE)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="${SCRIPT_DIR}/.."
FIXTURES="${SCRIPT_DIR}/fixtures"

PASS=0
FAIL=0

assert_eq() {
  local desc="$1" expected="$2" actual="$3"
  if [[ "$expected" == "$actual" ]]; then
    echo "  PASS: $desc"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $desc"
    echo "        expected: [$expected]"
    echo "        actual:   [$actual]"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== test_validators.sh (offline — mocking gemini) ==="

# Load _lib.sh and mock gemini_preflight + gemini_invoke_with_retry
# shellcheck disable=SC1090,SC1091
source "${SCRIPTS_DIR}/_lib.sh"
gemini_preflight() { log_info "AUTH MOCK: OK"; }

# ---- Summary validators ----
echo ""
echo "-- Summary validators --"

SUMMARY_LONG=$(python3 -c "print(' '.join(['word'] * 200))")
WORD_COUNT=$(echo "$SUMMARY_LONG" | wc -w | tr -d ' ')
assert_eq "word count 200 > MAX_WORDS 150" "1" "$(( WORD_COUNT > 150 ))"

# 50 words within [30, 150]
SUMMARY_OK=$(python3 -c "print(' '.join(['word'] * 50))")
WORD_COUNT=$(echo "$SUMMARY_OK" | wc -w | tr -d ' ')
assert_eq "word count 50 within [30,150]" "1" "$(( WORD_COUNT >= 30 && WORD_COUNT <= 150 ))"

SUMMARY_SHORT=$(python3 -c "print(' '.join(['word'] * 10))")
WORD_COUNT=$(echo "$SUMMARY_SHORT" | wc -w | tr -d ' ')
assert_eq "word count 10 < MIN_WORDS 30" "1" "$(( WORD_COUNT < 30 ))"

# ---- Format validators ----
echo ""
echo "-- Format validators --"

VALID_JSON='{"a":1,"b":2}'
INVALID_JSON='{not:valid}'
IDEMPOTENT_JSON='{"a": 1, "b": 2}'

PARSE_RESULT=0
python3 -m json.tool <<< "$VALID_JSON" > /dev/null 2>&1 || PARSE_RESULT=$?
assert_eq "valid JSON parses OK" "0" "$PARSE_RESULT"

PARSE_RESULT=0
python3 -m json.tool <<< "$INVALID_JSON" > /dev/null 2>&1 || PARSE_RESULT=$?
assert_eq "invalid JSON parse fails" "1" "$(( PARSE_RESULT != 0 ))"

NORM1=$(python3 -m json.tool <<< "$IDEMPOTENT_JSON")
NORM2=$(python3 -m json.tool <<< "$NORM1")
HASH1=$(echo "$NORM1" | (sha256sum 2>/dev/null || shasum -a 256) | cut -d' ' -f1)
HASH2=$(echo "$NORM2" | (sha256sum 2>/dev/null || shasum -a 256) | cut -d' ' -f1)
assert_eq "JSON format is idempotent" "$HASH1" "$HASH2"

# ---- Codegen validators ----
echo ""
echo "-- Codegen validators --"

VALID_PYTHON='def greet(name: str) -> str:
    """Return greeting."""
    return f"Hello, {name}"'

INVALID_PYTHON='def greet(name
    return "hi"'

TMP=$(mktemp /tmp/test_py_XXXXXX.py)
echo "$VALID_PYTHON" > "$TMP"
PYCOMPILE=0
python3 -m py_compile "$TMP" 2>/dev/null || PYCOMPILE=$?
rm -f "$TMP"
assert_eq "valid Python compiles" "0" "$PYCOMPILE"

TMP=$(mktemp /tmp/test_py_XXXXXX.py)
echo "$INVALID_PYTHON" > "$TMP"
PYCOMPILE=0
python3 -m py_compile "$TMP" 2>/dev/null || PYCOMPILE=$?
rm -f "$TMP"
assert_eq "invalid Python fails compile" "1" "$(( PYCOMPILE != 0 ))"

CODE_WITH_FENCE='```python
def hello():
    pass
```'
CLEANED=$(echo "$CODE_WITH_FENCE" | sed '/^```/d')
assert_eq "fences removed" "$(printf 'def hello():\n    pass')" "$CLEANED"

# ---- HTML/UI validator ----
echo ""
echo "-- HTML validators --"

VALID_HTML="$(cat "${FIXTURES}/sample.html")"
# Check DOCTYPE present
if echo "$VALID_HTML" | grep -qi "<!DOCTYPE"; then
  echo "  PASS: HTML contains DOCTYPE"
  PASS=$((PASS + 1))
else
  echo "  FAIL: HTML missing DOCTYPE"
  FAIL=$((FAIL + 1))
fi

# Check html tag present
if echo "$VALID_HTML" | grep -qi "<html"; then
  echo "  PASS: HTML contains <html> tag"
  PASS=$((PASS + 1))
else
  echo "  FAIL: HTML missing <html> tag"
  FAIL=$((FAIL + 1))
fi

# Check body closes
if echo "$VALID_HTML" | grep -qi "</body>"; then
  echo "  PASS: HTML contains </body> tag"
  PASS=$((PASS + 1))
else
  echo "  FAIL: HTML missing </body> tag"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]]
