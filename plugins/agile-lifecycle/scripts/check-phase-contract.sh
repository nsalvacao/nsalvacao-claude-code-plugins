#!/usr/bin/env bash
# check-phase-contract.sh — Validates phase contract completeness.
# Usage: ./check-phase-contract.sh <phase-contract-json>
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <phase-contract-json>" >&2
  exit 1
fi

CONTRACT_FILE="$1"

if [[ ! -f "$CONTRACT_FILE" ]]; then
  echo "ERROR: Phase contract file not found: $CONTRACT_FILE" >&2
  exit 1
fi

# Validate JSON syntax
if ! python3 -c "import json, sys; json.load(open(sys.argv[1]))" "$CONTRACT_FILE" 2>/dev/null; then
  echo "ERROR: $CONTRACT_FILE is not valid JSON" >&2
  exit 1
fi

REQUIRED_FIELDS=(
  "phase"
  "subfase"
  "status"
  "entry_criteria_met"
  "artefacts_produced"
  "owner"
  "created"
)

OPTIONAL_FIELDS=(
  "exit_criteria_met"
  "sign_off_authority"
  "assumptions"
  "clarifications"
  "evidence"
)

fail_count=0
warn_count=0

echo "=== Phase Contract Validation: $CONTRACT_FILE ==="

for field in "${REQUIRED_FIELDS[@]}"; do
  if ! python3 -c "
import json, sys
data = json.load(open(sys.argv[1]))
sys.exit(0 if sys.argv[2] in data else 1)
" "$CONTRACT_FILE" "$field" 2>/dev/null; then
    echo "  FAIL: required field missing: $field"
    fail_count=$((fail_count + 1))
  else
    echo "  OK:   $field"
  fi
done

for field in "${OPTIONAL_FIELDS[@]}"; do
  if ! python3 -c "
import json, sys
data = json.load(open(sys.argv[1]))
sys.exit(0 if sys.argv[2] in data else 1)
" "$CONTRACT_FILE" "$field" 2>/dev/null; then
    echo "  WARN: optional field absent: $field"
    warn_count=$((warn_count + 1))
  fi
done

echo ""
if [[ $fail_count -gt 0 ]]; then
  echo "Result: FAIL — $fail_count required field(s) missing, $warn_count warning(s)"
  exit 1
else
  echo "Result: PASS — all required fields present ($warn_count warning(s))"
fi
