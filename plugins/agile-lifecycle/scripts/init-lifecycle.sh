#!/usr/bin/env bash
# init-lifecycle.sh — Bootstraps the agile-lifecycle directory structure in a project.
# Usage: ./init-lifecycle.sh [project-dir]
set -euo pipefail

PROJECT_DIR="${1:-.}"

if [[ ! -d "$PROJECT_DIR" ]]; then
  echo "ERROR: Directory does not exist: $PROJECT_DIR" >&2
  exit 1
fi

LIFECYCLE_DIR="${PROJECT_DIR}/.agile-lifecycle"

if [[ -d "$LIFECYCLE_DIR" ]]; then
  echo "INFO: .agile-lifecycle already exists at $LIFECYCLE_DIR — skipping init"
  echo "To view current status, run: /agile-status"
  exit 0
fi

echo "Initializing agile-lifecycle in: $PROJECT_DIR"

# Create directory structure
mkdir -p \
  "${LIFECYCLE_DIR}/artefacts/phase-1" \
  "${LIFECYCLE_DIR}/artefacts/phase-2" \
  "${LIFECYCLE_DIR}/artefacts/phase-3" \
  "${LIFECYCLE_DIR}/artefacts/phase-4" \
  "${LIFECYCLE_DIR}/artefacts/phase-5" \
  "${LIFECYCLE_DIR}/artefacts/phase-6" \
  "${LIFECYCLE_DIR}/artefacts/phase-7" \
  "${LIFECYCLE_DIR}/artefacts/transversal" \
  "${LIFECYCLE_DIR}/evidence" \
  "${LIFECYCLE_DIR}/registers" \
  "${LIFECYCLE_DIR}/gate-reports" \
  "${LIFECYCLE_DIR}/metrics"

# Initialize lifecycle-state.json
STATE_FILE="${LIFECYCLE_DIR}/lifecycle-state.json"
TODAY=$(date +%Y-%m-%d)

cat > "$STATE_FILE" <<STATEJSON
{
  "schema": "agile-lifecycle/lifecycle-state",
  "version": "0.1.0",
  "project_name": "",
  "product_type": "",
  "team": "",
  "sponsor": "",
  "created": "${TODAY}",
  "updated": "${TODAY}",
  "tailoring_profile": null,
  "phases": {
    "1": { "status": "in_progress", "name": "Opportunity and Portfolio Framing", "active_subfase": "1.1" },
    "2": { "status": "not_started", "name": "Inception and Product Framing" },
    "3": { "status": "not_started", "name": "Discovery and Backlog Readiness" },
    "4": { "status": "not_started", "name": "Iterative Delivery and Continuous Validation" },
    "5": { "status": "not_started", "name": "Release, Rollout and Transition" },
    "6": { "status": "not_started", "name": "Operate, Measure and Improve" },
    "7": { "status": "not_started", "name": "Retire or Replace" }
  },
  "gates": {
    "A": { "status": "pending" },
    "B": { "status": "pending" },
    "C": { "status": "pending" },
    "D": { "status": "pending" },
    "E": { "status": "pending" },
    "F": { "status": "pending" },
    "G": { "status": "pending" },
    "H": { "status": "pending" },
    "I": { "status": "pending" },
    "J": { "status": "pending" }
  },
  "open_risks": 0,
  "open_assumptions": 0,
  "open_clarifications": 0
}
STATEJSON

# Initialize empty registers
for reg in risk assumption clarification dependency; do
  echo "[]" > "${LIFECYCLE_DIR}/registers/${reg}.json"
done

echo "  Created: ${LIFECYCLE_DIR}/"
echo "  Created: ${STATE_FILE}"
echo "  Created: registers/ (risk, assumption, clarification, dependency)"
echo ""
echo "Next step: /agile-phase-start 1"
