#!/usr/bin/env bash
# check-assumptions.sh — Finds assumptions past their due date or without an owner.
# Usage: ./check-assumptions.sh <assumption-register-json>
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <assumption-register-json>" >&2
  exit 1
fi

REGISTER_FILE="$1"

if [[ ! -f "$REGISTER_FILE" ]]; then
  echo "ERROR: Assumption register file not found: $REGISTER_FILE" >&2
  exit 1
fi

if ! python3 -c "import json, sys; json.load(open(sys.argv[1]))" "$REGISTER_FILE" 2>/dev/null; then
  echo "ERROR: $REGISTER_FILE is not valid JSON" >&2
  exit 1
fi

echo "=== Assumption Register Health Check: $REGISTER_FILE ==="
echo ""

python3 - "$REGISTER_FILE" <<'PYEOF'
import json
import sys
from datetime import date, datetime

register_file = sys.argv[1]
with open(register_file) as f:
    data = json.load(f)

if not isinstance(data, list):
    print("ERROR: Expected a JSON array of assumption entries.", file=sys.stderr)
    sys.exit(1)

today = date.today()
warn_count = 0
total = len(data)

if total == 0:
    print("No assumptions found.")
    sys.exit(0)

no_owner = []
past_due = []
no_due_date = []

for entry in data:
    entry_id = entry.get("id", "(no id)")
    owner = entry.get("owner", "")
    due_date_str = entry.get("due_date", "")
    status = entry.get("status", "open")

    if status in ("resolved", "closed", "validated"):
        continue

    if not owner or owner.strip() == "":
        no_owner.append(entry_id)

    if not due_date_str or due_date_str.strip() == "":
        no_due_date.append(entry_id)
    else:
        try:
            due_date = datetime.strptime(due_date_str, "%Y-%m-%d").date()
            if due_date < today:
                days_overdue = (today - due_date).days
                past_due.append((entry_id, due_date_str, days_overdue))
        except ValueError:
            print(f"  WARN: Cannot parse due_date for {entry_id}: {due_date_str}")

if no_owner:
    print(f"WARNING — {len(no_owner)} assumption(s) with no owner:")
    for eid in no_owner:
        print(f"  - {eid}")
    warn_count += len(no_owner)

if past_due:
    print(f"\nWARNING — {len(past_due)} assumption(s) past due date:")
    for eid, due, days in past_due:
        print(f"  - {eid}: due {due} ({days} days overdue)")
    warn_count += len(past_due)

if no_due_date:
    print(f"\nWARNING — {len(no_due_date)} assumption(s) with no due date:")
    for eid in no_due_date:
        print(f"  - {eid}")
    warn_count += len(no_due_date)

print(f"\nTotal: {total} entries | Warnings: {warn_count}")

if warn_count > 0:
    print("\nRecommendation: review stale assumptions with /agile-risk-update assumption")
    sys.exit(1)
else:
    print("All assumptions have owners and are within due dates.")
    sys.exit(0)
PYEOF
