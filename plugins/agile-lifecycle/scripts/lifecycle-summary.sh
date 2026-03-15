#!/usr/bin/env bash
# lifecycle-summary.sh — Generates overall lifecycle state summary.
# Usage: ./lifecycle-summary.sh
set -euo pipefail

find_lifecycle_dir() {
  local dir
  dir="$(pwd)"
  while [[ "$dir" != "/" ]]; do
    if [[ -d "${dir}/.agile-lifecycle" ]]; then
      echo "${dir}/.agile-lifecycle"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

LIFECYCLE_DIR=""
if ! LIFECYCLE_DIR="$(find_lifecycle_dir)"; then
  echo "ERROR: .agile-lifecycle not found. Run /agile-init first." >&2
  exit 1
fi

STATE_FILE="${LIFECYCLE_DIR}/lifecycle-state.json"

if [[ ! -f "$STATE_FILE" ]]; then
  echo "ERROR: lifecycle-state.json not found at $STATE_FILE" >&2
  exit 1
fi

python3 - "$STATE_FILE" "$LIFECYCLE_DIR" <<'PYEOF'
import json, os, sys, glob

state_file = sys.argv[1]
lifecycle_dir = sys.argv[2]

with open(state_file) as f:
    data = json.load(f)

project_name = data.get("project_name", "(unnamed)")
product_type = data.get("product_type", "(not set)")
phases = data.get("phases", {})
gates = data.get("gates", {})

STATUS_SYMBOLS = {
    "not_started": "○",
    "in_progress":  "●",
    "blocked":      "✗",
    "ready_for_gate": "▶",
    "approved":     "✓",
    "closed":       "✓",
    "rejected":     "✗",
    "waived":       "~",
}

GATE_SYMBOLS = {
    "pending": "○",
    "PASS":    "✓",
    "FAIL":    "✗",
    "WAIVED":  "~",
}

print(f"=== Lifecycle Summary: {project_name} ===")
print(f"Product type: {product_type}")
print("")

print("Phases:")
for ph in [str(i) for i in range(1, 8)]:
    info = phases.get(ph, {})
    status = info.get("status", "not_started")
    name = info.get("name", f"Phase {ph}")
    sym = STATUS_SYMBOLS.get(status, "?")
    subfase = info.get("active_subfase", "")
    subfase_str = f"  (subfase {subfase})" if subfase and status == "in_progress" else ""
    print(f"  {sym} Phase {ph}: {name} — {status}{subfase_str}")

print("")
print("Gates:")
gate_row = ""
for gate in "ABCDEFGHIJ":
    info = gates.get(gate, {})
    status = info.get("status", "pending")
    sym = GATE_SYMBOLS.get(status, "?")
    gate_row = f"  {sym} Gate {gate}: {status}"
    print(gate_row)

print("")

# Count open items from registers
registers_dir = os.path.join(lifecycle_dir, "registers")
open_risks = 0
open_assumptions = 0
open_clarifications = 0

for reg_file in glob.glob(os.path.join(registers_dir, "risk.json")):
    try:
        entries = json.load(open(reg_file))
        open_risks = sum(1 for e in entries if e.get("status", "open") == "open")
    except Exception:
        pass

for reg_file in glob.glob(os.path.join(registers_dir, "assumption.json")):
    try:
        entries = json.load(open(reg_file))
        open_assumptions = sum(1 for e in entries if e.get("status", "open") not in ("resolved", "closed", "validated"))
    except Exception:
        pass

for reg_file in glob.glob(os.path.join(registers_dir, "clarification.json")):
    try:
        entries = json.load(open(reg_file))
        open_clarifications = sum(1 for e in entries if e.get("status", "open") not in ("resolved", "closed"))
    except Exception:
        pass

print("Open Items:")
print(f"  Risks:          {open_risks}")
print(f"  Assumptions:    {open_assumptions}")
print(f"  Clarifications: {open_clarifications}")
print("")

# Suggestion
active = [ph for ph, info in phases.items() if info.get("status") == "in_progress"]
if active:
    print(f"Active phase: {active[0]} — use /agile-phase-start {active[0]} to continue")
elif all(info.get("status") == "closed" for info in phases.values()):
    print("All phases closed. Lifecycle complete.")
else:
    print("No phase in progress. Use /agile-phase-start <N> to begin.")
PYEOF
