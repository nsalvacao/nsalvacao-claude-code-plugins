#!/usr/bin/env bash
# export-evidence-index.sh — Exports the evidence index to JSON or markdown.
# Usage: ./export-evidence-index.sh [phase] [format: json|md]
set -euo pipefail

PHASE="${1:-}"
FORMAT="${2:-json}"

if [[ "$FORMAT" != "json" && "$FORMAT" != "md" ]]; then
  echo "ERROR: Invalid format '$FORMAT'. Use 'json' or 'md'." >&2
  exit 1
fi

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

EVIDENCE_DIR="${LIFECYCLE_DIR}/evidence"
TODAY=$(date +%Y-%m-%d)

if [[ ! -d "$EVIDENCE_DIR" ]]; then
  echo "ERROR: Evidence directory not found: $EVIDENCE_DIR" >&2
  exit 1
fi

echo "=== Evidence Index Export ==="
echo "Scope: ${PHASE:-all phases} | Format: $FORMAT"
echo ""

if [[ "$FORMAT" == "json" ]]; then
  OUTPUT_FILE="${LIFECYCLE_DIR}/evidence-index-${TODAY}.json"
  python3 - "$EVIDENCE_DIR" "$PHASE" "$OUTPUT_FILE" <<'PYEOF'
import json, os, sys, glob

evidence_dir = sys.argv[1]
phase = sys.argv[2]
output_file = sys.argv[3]

pattern = os.path.join(evidence_dir, f"phase{phase}-*.json" if phase else "*.json")
files = sorted(glob.glob(pattern))

entries = []
for f in files:
    try:
        data = json.load(open(f))
        if isinstance(data, list):
            entries.extend(data)
        elif isinstance(data, dict):
            entries.append(data)
    except (json.JSONDecodeError, OSError) as e:
        print(f"WARNING: Could not read {f}: {e}", file=sys.stderr)

with open(output_file, "w") as out:
    json.dump({"exported": output_file, "count": len(entries), "entries": entries}, out, indent=2)

print(f"Exported {len(entries)} evidence entries to {output_file}")
PYEOF

else
  OUTPUT_FILE="${LIFECYCLE_DIR}/evidence-index-${TODAY}.md"
  {
    echo "# Evidence Index"
    echo ""
    echo "| Field | Value |"
    echo "|-------|-------|"
    echo "| Exported | ${TODAY} |"
    echo "| Scope | ${PHASE:-all} |"
    echo ""
    echo "## Entries"
    echo ""

    entry_count=0
    for f in "${EVIDENCE_DIR}"/phase"${PHASE}"-*.json "${EVIDENCE_DIR}"/*.json; do
      [[ -f "$f" ]] || continue
      fname="$(basename "$f")"
      echo "### $fname"
      python3 - "$f" <<'PYEOF'
import json, sys
try:
    data = json.load(open(sys.argv[1]))
    if isinstance(data, list):
        for e in data:
            for k, v in e.items():
                print(f"- **{k}**: {v}")
    elif isinstance(data, dict):
        for k, v in data.items():
            print(f"- **{k}**: {v}")
except Exception:
    print("_(could not parse entry)_")
PYEOF
      echo ""
      entry_count=$((entry_count + 1))
    done

    if [[ $entry_count -eq 0 ]]; then
      echo "_No evidence entries found._"
    fi
  } > "$OUTPUT_FILE"

  echo "Exported evidence index to $OUTPUT_FILE"
fi
