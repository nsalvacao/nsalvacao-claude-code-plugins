#!/usr/bin/env bash
# generate-metrics-report.sh — Generates a metrics summary report in markdown.
# Usage: ./generate-metrics-report.sh [phase] [output-file]
set -euo pipefail

PHASE="${1:-}"
OUTPUT_FILE="${2:-}"
TODAY=$(date +%Y-%m-%d)

# Locate .agile-lifecycle
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

METRICS_DIR="${LIFECYCLE_DIR}/metrics"

if [[ -z "$OUTPUT_FILE" ]]; then
  OUTPUT_FILE="${METRICS_DIR}/report-${TODAY}.md"
fi

# Detect active phase if not specified
if [[ -z "$PHASE" ]]; then
  STATE_FILE="${LIFECYCLE_DIR}/lifecycle-state.json"
  if [[ -f "$STATE_FILE" ]]; then
    PHASE=$(python3 -c "
import json
data = json.load(open('$STATE_FILE'))
for ph, info in data.get('phases', {}).items():
    if info.get('status') == 'in_progress':
        print(ph)
        break
" 2>/dev/null || echo "")
  fi
fi

PHASE_LABEL="${PHASE:-all}"

echo "Generating metrics report (scope: Phase ${PHASE_LABEL})..."

{
  echo "# Metrics Report — Phase ${PHASE_LABEL}"
  echo ""
  echo "| Field | Value |"
  echo "|-------|-------|"
  echo "| Generated | ${TODAY} |"
  echo "| Scope | Phase ${PHASE_LABEL} |"
  echo "| Source | ${METRICS_DIR} |"
  echo ""

  echo "## Delivery Metrics"
  echo ""
  if compgen -G "${METRICS_DIR}/delivery-*.json" >/dev/null 2>&1; then
    python3 - "${METRICS_DIR}" "$PHASE" <<'PYEOF'
import json, os, sys, glob

metrics_dir = sys.argv[1]
phase = sys.argv[2]

pattern = os.path.join(metrics_dir, f"delivery-phase{phase}-*.json" if phase else "delivery-*.json")
files = sorted(glob.glob(pattern))

if not files:
    print("_No delivery metrics found._")
else:
    print("| Metric | Value | Status |")
    print("|--------|-------|--------|")
    for f in files:
        try:
            data = json.load(open(f))
            for k, v in data.items():
                if k not in ("phase", "sprint", "date"):
                    print(f"| {k} | {v} | — |")
        except (json.JSONDecodeError, OSError):
            pass
PYEOF
  else
    echo "_No delivery metrics data found._"
  fi

  echo ""
  echo "## Quality Metrics"
  echo ""
  if compgen -G "${METRICS_DIR}/quality-*.json" >/dev/null 2>&1; then
    python3 - "${METRICS_DIR}" "$PHASE" <<'PYEOF'
import json, os, sys, glob

metrics_dir = sys.argv[1]
phase = sys.argv[2]

pattern = os.path.join(metrics_dir, f"quality-phase{phase}-*.json" if phase else "quality-*.json")
files = sorted(glob.glob(pattern))

if not files:
    print("_No quality metrics found._")
else:
    print("| Metric | Value | Status |")
    print("|--------|-------|--------|")
    for f in files:
        try:
            data = json.load(open(f))
            for k, v in data.items():
                if k not in ("phase", "sprint", "date"):
                    print(f"| {k} | {v} | — |")
        except (json.JSONDecodeError, OSError):
            pass
PYEOF
  else
    echo "_No quality metrics data found._"
  fi

  echo ""
  echo "## Notes"
  echo ""
  echo "- Populate metric files in \`.agile-lifecycle/metrics/\` to generate richer reports."
  echo "- Run \`/agile-metrics-report lifecycle\` for a cross-phase summary."

} > "$OUTPUT_FILE"

echo "Report saved to: $OUTPUT_FILE"
