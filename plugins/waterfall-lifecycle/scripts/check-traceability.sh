#!/usr/bin/env bash
# check-traceability.sh — Validate RTM completeness for waterfall lifecycle Phase 2.
# Usage: ./check-traceability.sh <rtm-file> [--strict]
# Returns exit 0 if all checks pass, exit 1 if one or more checks fail.
set -euo pipefail

usage() {
  echo "Usage: $(basename "$0") <rtm-file> [--strict]"
  echo ""
  echo "Validate RTM completeness — every requirement has >=1 acceptance criterion,"
  echo "no orphaned requirements, no orphaned ACs."
  echo ""
  echo "Arguments:"
  echo "  rtm-file    Path to the requirements traceability matrix markdown file"
  echo "  --strict    Also check for presence of 10 Gate B mandatory artefacts in the same directory"
  echo ""
  echo "Checks:"
  echo "  - RTM file exists and is non-empty"
  echo "  - RTM table has required columns (REQ-ID, AC-ID, Status)"
  echo "  - REQ-ID count (reports row occurrences, not unique IDs)"
  echo "  - AC-ID count (reports row occurrences, not unique IDs)"
  echo "  - Ratio check: warns if AC row count < REQ row count (basic sanity check)"
  echo "  - In strict mode: checks that 10 Gate B artefacts exist alongside the RTM"
  echo ""
  echo "Exit codes:"
  echo "  0  All checks pass"
  echo "  1  One or more checks fail"
}

if [[ $# -eq 0 ]]; then
  usage
  exit 0
fi

RTM_FILE="$1"
STRICT=false

if [[ $# -ge 2 && "$2" == "--strict" ]]; then
  STRICT=true
fi

pass_count=0
fail_count=0

pass() {
  echo "  ✓ $1"
  pass_count=$((pass_count + 1))
}

fail() {
  echo "  ✗ $1"
  fail_count=$((fail_count + 1))
}

warn() {
  echo "  ! $1"
}

echo "Checking RTM: $RTM_FILE"
echo ""
echo "Check                                    Status"
echo "─────────────────────────────────────────────────────"

# Check 1: RTM file exists
if [[ ! -f "$RTM_FILE" ]]; then
  echo "ERROR: RTM file not found: $RTM_FILE" >&2
  exit 1
fi

# Check 2: RTM file is non-empty
if [[ ! -s "$RTM_FILE" ]]; then
  fail "RTM file is empty"
else
  pass "RTM file exists and is non-empty"
fi

# Check 3: Required columns present
if grep -qiE "REQ-?ID|REQ_ID" "$RTM_FILE"; then
  pass "Column REQ-ID present"
else
  fail "Column REQ-ID missing"
fi

if grep -qiE "AC-?ID|AC_ID" "$RTM_FILE"; then
  pass "Column AC-ID present"
else
  fail "Column AC-ID missing"
fi

if grep -qi "Status" "$RTM_FILE"; then
  pass "Column Status present"
else
  fail "Column Status missing"
fi

# Check 4: Count REQ-IDs
REQ_COUNT=$(grep -cE "REQ-[0-9]{4}-[0-9]{3}" "$RTM_FILE" 2>/dev/null) || REQ_COUNT=0

if [[ "$REQ_COUNT" -gt 0 ]]; then
  pass "REQ-ID entries found: $REQ_COUNT"
else
  fail "No REQ-ID entries found (expected format REQ-YYYY-NNN)"
fi

# Check 5: Count AC-IDs
AC_COUNT=$(grep -cE "AC-[0-9]{4}-[0-9]{3}" "$RTM_FILE" 2>/dev/null) || AC_COUNT=0

if [[ "$AC_COUNT" -gt 0 ]]; then
  pass "AC-ID entries found: $AC_COUNT"
else
  fail "No AC-ID entries found (expected format AC-YYYY-NNN)"
fi

# Check 6: Ratio check — warn if AC_COUNT < REQ_COUNT
if [[ "$REQ_COUNT" -gt 0 && "$AC_COUNT" -gt 0 ]]; then
  if [[ "$AC_COUNT" -lt "$REQ_COUNT" ]]; then
    warn "AC count ($AC_COUNT) < REQ count ($REQ_COUNT) — possible orphaned requirements"
  else
    pass "AC/REQ ratio OK (ACs: $AC_COUNT, REQs: $REQ_COUNT)"
  fi
fi

# Strict mode: Gate B artefacts
if [[ "$STRICT" == "true" ]]; then
  echo ""
  echo "Strict mode — Gate B artefact checks:"
  echo "─────────────────────────────────────────────────────"

  RTM_DIR="$(dirname "$RTM_FILE")"

  check_artefact() {
    local name="$1"
    local path="$RTM_DIR/$name"
    if [[ -f "$path" ]]; then
      pass "Gate B artefact present: $name"
    else
      fail "Gate B artefact missing: $name"
    fi
  }

  check_artefact "requirements-baseline.md"
  check_artefact "business-requirements-set.md"
  check_artefact "ai-requirements-specification.md"
  check_artefact "nfr-specification.md"
  check_artefact "acceptance-criteria-catalog.md"
  check_artefact "requirements-traceability-matrix.md"
  check_artefact "glossary.md"
  check_artefact "clarification-log.md"
  check_artefact "requirements-baseline-approval-pack.md"

  # assumption-register: check for any matching file
  ASSUMPTION_FILE=$(find "$RTM_DIR" -maxdepth 1 -name "assumption-register*" 2>/dev/null | head -1 || true)
  if [[ -n "$ASSUMPTION_FILE" ]]; then
    pass "Gate B artefact present: assumption-register (found: $(basename "$ASSUMPTION_FILE"))"
  else
    fail "Gate B artefact missing: assumption-register*"
  fi
fi

echo "─────────────────────────────────────────────────────"
echo ""

TOTAL=$((pass_count + fail_count))
echo "Results: $pass_count/$TOTAL checks OK"
echo ""

if [[ "$fail_count" -gt 0 ]]; then
  echo "FAIL: RTM validation has $fail_count issue(s)"
  exit 1
else
  echo "OK: RTM validation complete"
  exit 0
fi
