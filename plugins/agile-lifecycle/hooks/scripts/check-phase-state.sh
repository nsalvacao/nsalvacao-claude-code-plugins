#!/usr/bin/env bash
# check-phase-state.sh — PostToolUse hook: checks phase state consistency after writes.
# Called by Claude Code after Write/Edit tool invocations.
# Verifies lifecycle-state.json has not been corrupted.
# Non-blocking: outputs warning if inconsistency detected.
set -euo pipefail

# Extract file path from TOOL_INPUT
FILE_PATH=""
if [[ -n "${TOOL_INPUT:-}" ]]; then
  FILE_PATH=$(python3 -c "
import json, sys
try:
    data = json.loads(sys.argv[1])
    path = data.get('path') or data.get('file_path') or data.get('filename') or ''
    print(path)
except Exception:
    print('')
" "$TOOL_INPUT" 2>/dev/null || true)
fi

# Find the lifecycle state file by scanning from the written file's directory
find_lifecycle_state() {
  local start_dir="${1:-$(pwd)}"
  local dir="$start_dir"
  while [[ "$dir" != "/" ]]; do
    local state="${dir}/.agile-lifecycle/lifecycle-state.json"
    if [[ -f "$state" ]]; then
      echo "$state"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

START_DIR="$(pwd)"
if [[ -n "$FILE_PATH" ]]; then
  START_DIR="$(dirname "$FILE_PATH")"
fi

STATE_FILE=""
if ! STATE_FILE="$(find_lifecycle_state "$START_DIR")"; then
  # No lifecycle found — skip silently
  exit 0
fi

# Validate lifecycle-state.json is still valid JSON
if ! python3 -c "import json, sys; json.load(open(sys.argv[1]))" "$STATE_FILE" 2>/dev/null; then
  echo "WARN [check-phase-state]: lifecycle-state.json appears corrupted: $STATE_FILE" >&2
  echo "WARN [check-phase-state]: Run /agile-status to diagnose the issue." >&2
  exit 0
fi

# Check for basic state machine consistency
python3 - "$STATE_FILE" <<'PYEOF' 2>/dev/null || true
import json, sys

state_file = sys.argv[1]
with open(state_file) as f:
    data = json.load(f)

phases = data.get("phases", {})
gates = data.get("gates", {})

# Warn if Phase 2+ is in_progress but Gate A is still pending
gate_unlock = {"A": "2", "B": "3", "C": "4", "D": "5", "E": "6", "F": "7"}
for gate_label, unlocks_phase in gate_unlock.items():
    gate_status = gates.get(gate_label, {}).get("status", "pending")
    phase_status = phases.get(unlocks_phase, {}).get("status", "not_started")
    if phase_status in ("in_progress", "closed") and gate_status == "pending":
        print(
            f"WARN [check-phase-state]: Phase {unlocks_phase} is '{phase_status}' "
            f"but Gate {gate_label} is still 'pending' — verify state consistency",
            file=__import__("sys").stderr
        )
PYEOF

exit 0
