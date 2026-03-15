#!/usr/bin/env bash
# check-sprint-health.sh — Checks sprint health indicators.
# Usage: ./check-sprint-health.sh <sprint-health-json>
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <sprint-health-json>" >&2
  exit 1
fi

HEALTH_FILE="$1"

if [[ ! -f "$HEALTH_FILE" ]]; then
  echo "ERROR: Sprint health file not found: $HEALTH_FILE" >&2
  exit 1
fi

if ! python3 -c "import json, sys; json.load(open(sys.argv[1]))" "$HEALTH_FILE" 2>/dev/null; then
  echo "ERROR: $HEALTH_FILE is not valid JSON" >&2
  exit 1
fi

echo "=== Sprint Health Check: $HEALTH_FILE ==="
echo ""

python3 - "$HEALTH_FILE" <<'PYEOF'
import json
import sys

health_file = sys.argv[1]
with open(health_file) as f:
    data = json.load(f)

warnings = 0

def check_metric(label, value, warn_threshold, crit_threshold, higher_is_worse=True):
    global warnings
    if value is None:
        print(f"  SKIP: {label} — no data")
        return
    if higher_is_worse:
        if value >= crit_threshold:
            print(f"  CRIT: {label} = {value} (threshold: <{crit_threshold})")
            warnings += 1
        elif value >= warn_threshold:
            print(f"  WARN: {label} = {value} (threshold: <{warn_threshold})")
            warnings += 1
        else:
            print(f"  OK:   {label} = {value}")
    else:
        if value <= crit_threshold:
            print(f"  CRIT: {label} = {value} (threshold: >{crit_threshold})")
            warnings += 1
        elif value <= warn_threshold:
            print(f"  WARN: {label} = {value} (threshold: >{warn_threshold})")
            warnings += 1
        else:
            print(f"  OK:   {label} = {value}")

sprint_id = data.get("sprint_id", "unknown")
print(f"Sprint: {sprint_id}")
print("")

# Commitment ratio: read direct field (schema) or calculate from points (fallback)
commitment_ratio = data.get("commitment_ratio")
if commitment_ratio is None:
    committed = data.get("committed_points")
    completed = data.get("completed_points")
    if committed and committed > 0 and completed is not None:
        commitment_ratio = round(completed / committed, 2)
check_metric("Commitment ratio", commitment_ratio, 0.7, 0.5, higher_is_worse=False)

# Carry-over rate
carryover = data.get("carryover_items", 0)
check_metric("Carry-over items", carryover, 3, 5)

# Defects: read schema field name with fallback to legacy name
defects = data.get("defect_count", data.get("defects_found", 0))
check_metric("Defects found", defects, 5, 10)

# Velocity trend (3-sprint avg vs current)
velocity_avg = data.get("velocity_avg_3sprint")
velocity_current = data.get("velocity_current")
if velocity_avg and velocity_current is not None:
    drop = round((velocity_avg - velocity_current) / velocity_avg, 2) if velocity_avg > 0 else 0
    check_metric("Velocity drop vs 3-sprint avg", drop, 0.2, 0.4)

# Blocked items
blocked = data.get("blocked_items", 0)
check_metric("Blocked items", blocked, 2, 4)

print("")
print(f"Warnings/Issues: {warnings}")
if warnings > 0:
    print("Sprint health: DEGRADED — review with /agile-retrospective sprint")
    sys.exit(1)
else:
    print("Sprint health: GOOD")
PYEOF
