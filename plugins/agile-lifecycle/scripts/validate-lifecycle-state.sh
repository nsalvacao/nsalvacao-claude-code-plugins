#!/usr/bin/env bash
# validate-lifecycle-state.sh — Validates lifecycle state transitions and integrity.
# Usage: ./validate-lifecycle-state.sh <lifecycle-state-json>
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <lifecycle-state-json>" >&2
  exit 1
fi

STATE_FILE="$1"

if [[ ! -f "$STATE_FILE" ]]; then
  echo "ERROR: Lifecycle state file not found: $STATE_FILE" >&2
  exit 1
fi

if ! python3 -c "import json, sys; json.load(open(sys.argv[1]))" "$STATE_FILE" 2>/dev/null; then
  echo "ERROR: $STATE_FILE is not valid JSON" >&2
  exit 1
fi

echo "=== Lifecycle State Validation: $STATE_FILE ==="
echo ""

python3 - "$STATE_FILE" <<'PYEOF'
import json
import sys

state_file = sys.argv[1]
with open(state_file) as f:
    data = json.load(f)

VALID_PHASE_STATUSES = {
    "not_started", "in_progress", "blocked",
    "ready_for_review", "ready_for_gate", "approved", "rejected", "waived", "closed"
}

VALID_GATE_STATUSES = {"pending", "PASS", "FAIL", "WAIVED"}

GATE_TO_PHASE = {
    "A": 1, "B": 2, "C": 3, "D": 4,
    "E": 4, "F": 4, "G": 5, "H": 6, "I": 6, "J": 7
}

issues = []
warnings = []

# Check required top-level fields
for field in ("project_name", "phases", "gates"):
    if field not in data:
        issues.append(f"Missing required field: {field}")

phases = data.get("phases", {})
gates = data.get("gates", {})

# Validate phase statuses
for ph, info in phases.items():
    status = info.get("status", "")
    if status not in VALID_PHASE_STATUSES:
        issues.append(f"Phase {ph}: invalid status '{status}'")

# Validate gate statuses
for gate, info in gates.items():
    status = info.get("status", "")
    if status not in VALID_GATE_STATUSES:
        issues.append(f"Gate {gate}: invalid status '{status}'")

# State machine: a phase cannot be 'in_progress' or 'closed' if the gate for
# the PREVIOUS phase has not passed (unless phase is 1)
phase_order = [str(i) for i in range(1, 8)]
gate_sequence = list("ABCDEFGHIJ")

# Map gates to which phase they unlock
# Gate A unlocks Phase 2, B unlocks Phase 3, etc.
gate_unlock = {"A": "2", "B": "3", "C": "4", "F": "5", "G": "6", "J": "7"}

for gate_label, unlocks_phase in gate_unlock.items():
    gate_status = gates.get(gate_label, {}).get("status", "pending")
    phase_status = phases.get(unlocks_phase, {}).get("status", "not_started")

    if phase_status in ("in_progress", "approved", "closed") and gate_status == "pending":
        warnings.append(
            f"Phase {unlocks_phase} is '{phase_status}' but Gate {gate_label} is still 'pending'"
        )

# Count active phases (should be at most 1 at a time normally)
active_phases = [ph for ph, info in phases.items() if info.get("status") == "in_progress"]
if len(active_phases) > 2:
    warnings.append(f"Multiple phases in_progress simultaneously: {active_phases}")

# Report
if issues:
    print(f"ERRORS ({len(issues)}):")
    for issue in issues:
        print(f"  FAIL: {issue}")
else:
    print("No errors found.")

if warnings:
    print(f"\nWARNINGS ({len(warnings)}):")
    for w in warnings:
        print(f"  WARN: {w}")
else:
    print("No warnings.")

print(f"\nActive phases: {active_phases if active_phases else ['none']}")

if issues:
    print("\nResult: INVALID")
    sys.exit(1)
elif warnings:
    print("\nResult: VALID WITH WARNINGS")
else:
    print("\nResult: VALID")
PYEOF
