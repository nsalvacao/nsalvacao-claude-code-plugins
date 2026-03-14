#!/usr/bin/env bash
# check-definition-of-done.sh — Verifies definition of done criteria are met for a phase.
# Usage: ./check-definition-of-done.sh <dod-json> [phase]
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <dod-json> [phase]" >&2
  exit 1
fi

DOD_FILE="$1"
PHASE="${2:-}"

if [[ ! -f "$DOD_FILE" ]]; then
  echo "ERROR: DoD file not found: $DOD_FILE" >&2
  exit 1
fi

if ! python3 -c "import json, sys; json.load(open(sys.argv[1]))" "$DOD_FILE" 2>/dev/null; then
  echo "ERROR: $DOD_FILE is not valid JSON" >&2
  exit 1
fi

echo "=== Definition of Done Check: $DOD_FILE ==="
if [[ -n "$PHASE" ]]; then
  echo "Scope: Phase $PHASE"
fi
echo ""

python3 - "$DOD_FILE" "$PHASE" <<'PYEOF'
import json
import sys

dod_file = sys.argv[1]
phase = sys.argv[2] if len(sys.argv) > 2 else ""

with open(dod_file) as f:
    data = json.load(f)

# Support both flat list and phase-keyed dict
if isinstance(data, list):
    items = data
elif isinstance(data, dict):
    if phase and phase in data:
        items = data[phase]
    elif "items" in data:
        items = data["items"]
    elif "global" in data:
        items = data.get("global", [])
        if phase and phase in data:
            items = items + data[phase]
    else:
        print("ERROR: Unexpected DoD JSON structure.", file=sys.stderr)
        sys.exit(1)
else:
    print("ERROR: DoD JSON must be an array or object.", file=sys.stderr)
    sys.exit(1)

total = len(items)
met = 0
unmet = []

for item in items:
    label = item.get("criterion", item.get("label", str(item)))
    done = item.get("met", item.get("done", item.get("status") == "met"))
    if done:
        met += 1
        print(f"  OK:   {label}")
    else:
        unmet.append(label)
        print(f"  FAIL: {label}")

print(f"\nMet: {met}/{total}")

if unmet:
    print(f"\nUnmet criteria ({len(unmet)}):")
    for u in unmet:
        print(f"  - {u}")
    print("\nDefinition of Done: NOT MET")
    sys.exit(1)
else:
    print("\nDefinition of Done: COMPLETE")
PYEOF
