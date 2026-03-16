#!/usr/bin/env bash
# check-phase-contract.sh — Verify a phase contract document for completeness.
# Usage: ./check-phase-contract.sh <contract-file>
# Returns exit 0 if all mandatory fields present, exit 1 if gaps found.
set -euo pipefail

usage() {
  echo "Usage: $(basename "$0") <contract-file>"
  echo ""
  echo "Verify a phase contract document for completeness."
  echo ""
  echo "Arguments:"
  echo "  contract-file   Path to the phase contract markdown file"
  echo ""
  echo "Checks mandatory fields:"
  echo "  phase_id, phase_name, owner, start_date, target_end_date,"
  echo "  entry_criteria, exit_criteria, evidence_required, sign_off_authority"
  echo ""
  echo "Exit codes:"
  echo "  0   All mandatory fields present and not TBD"
  echo "  1   One or more fields missing or set to TBD"
}

if [[ $# -eq 0 ]]; then
  usage
  exit 0
fi

CONTRACT_FILE="$1"

if [[ ! -f "$CONTRACT_FILE" ]]; then
  echo "ERROR: contract file not found: $CONTRACT_FILE" >&2
  exit 1
fi

pass_count=0
fail_count=0

check_field() {
  local field="$1"
  local file="$2"
  if grep -q "$field" "$file" && ! grep -q "$field.*TBD" "$file"; then
    echo "  ✓ $field"
    pass_count=$((pass_count + 1))
  else
    echo "  ✗ $field — missing or TBD"
    fail_count=$((fail_count + 1))
  fi
}

echo "Checking phase contract: $CONTRACT_FILE"
echo ""
echo "Field                      Status"
echo "─────────────────────────────────────────"

check_field "phase_id" "$CONTRACT_FILE"
check_field "phase_name" "$CONTRACT_FILE"
check_field "owner" "$CONTRACT_FILE"
check_field "start_date" "$CONTRACT_FILE"
check_field "target_end_date" "$CONTRACT_FILE"
check_field "entry_criteria" "$CONTRACT_FILE"
check_field "exit_criteria" "$CONTRACT_FILE"
check_field "evidence_required" "$CONTRACT_FILE"

# Special check for sign_off_authority — must exist and not be TBD or empty
if grep -q "sign_off_authority" "$CONTRACT_FILE"; then
  SAV=$(grep "sign_off_authority" "$CONTRACT_FILE" | head -1)
  if echo "$SAV" | grep -qiE "(TBD|^\s*sign_off_authority\s*:\s*$|sign_off_authority.*:\s*$)"; then
    echo "  ✗ sign_off_authority — missing or TBD"
    fail_count=$((fail_count + 1))
  else
    echo "  ✓ sign_off_authority"
    pass_count=$((pass_count + 1))
  fi
else
  echo "  ✗ sign_off_authority — missing or TBD"
  fail_count=$((fail_count + 1))
fi

echo "─────────────────────────────────────────"
echo ""

TOTAL=$((pass_count + fail_count))
echo "Results: $pass_count/$TOTAL fields OK"
echo ""

if [[ $fail_count -gt 0 ]]; then
  echo "FAIL: phase contract has $fail_count gap(s)"
  exit 1
else
  echo "OK: phase contract is complete"
  exit 0
fi
