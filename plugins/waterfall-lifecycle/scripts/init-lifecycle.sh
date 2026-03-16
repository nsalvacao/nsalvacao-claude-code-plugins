#!/usr/bin/env bash
# init-lifecycle.sh — Bootstrap the waterfall-lifecycle directory structure.
# Usage: ./init-lifecycle.sh [project-dir]
# Default: current directory
set -euo pipefail

usage() {
  echo "Usage: $(basename "$0") [project-dir]"
  echo ""
  echo "Bootstrap the waterfall-lifecycle directory structure in a project."
  echo ""
  echo "Arguments:"
  echo "  project-dir   Optional: path to project directory (default: current directory)"
  echo ""
  echo "Creates:"
  echo "  .waterfall-lifecycle/artefacts/phase-{1..8}/"
  echo "  .waterfall-lifecycle/artefacts/transversal/"
  echo "  .waterfall-lifecycle/evidence/"
  echo "  .waterfall-lifecycle/registers/"
  echo "  .waterfall-lifecycle/gate-reports/"
  echo "  .waterfall-lifecycle/metrics/"
  echo "  .waterfall-lifecycle/lifecycle-state.json"
  echo ""
  echo "This operation is idempotent — safe to run multiple times."
}

PROJECT_DIR="${1:-$(pwd)}"

if [[ "$PROJECT_DIR" == "--help" || "$PROJECT_DIR" == "-h" ]]; then
  usage
  exit 0
fi

if [[ ! -d "$PROJECT_DIR" ]]; then
  echo "ERROR: project directory not found: $PROJECT_DIR" >&2
  exit 1
fi

WF_DIR="$PROJECT_DIR/.waterfall-lifecycle"

if [[ -d "$WF_DIR" ]]; then
  echo "INFO: .waterfall-lifecycle/ already exists in $PROJECT_DIR — nothing to do"
  exit 0
fi

TODAY=$(date +%Y-%m-%d)

echo "Initialising waterfall-lifecycle in: $PROJECT_DIR"

# Create directory structure
mkdir -p "$WF_DIR/artefacts/phase-1"
mkdir -p "$WF_DIR/artefacts/phase-2"
mkdir -p "$WF_DIR/artefacts/phase-3"
mkdir -p "$WF_DIR/artefacts/phase-4"
mkdir -p "$WF_DIR/artefacts/phase-5"
mkdir -p "$WF_DIR/artefacts/phase-6"
mkdir -p "$WF_DIR/artefacts/phase-7"
mkdir -p "$WF_DIR/artefacts/phase-8"
mkdir -p "$WF_DIR/artefacts/transversal"
mkdir -p "$WF_DIR/evidence"
mkdir -p "$WF_DIR/registers"
mkdir -p "$WF_DIR/gate-reports"
mkdir -p "$WF_DIR/metrics"

# Create lifecycle-state.json
cat > "$WF_DIR/lifecycle-state.json" <<EOF
{
  "\$schema": "waterfall-lifecycle/lifecycle-state",
  "version": "0.1.0",
  "project_name": "",
  "created": "$TODAY",
  "phases": {
    "1": {
      "name": "Opportunity and Feasibility",
      "status": "in_progress"
    },
    "2": {
      "name": "Requirements and Baseline",
      "status": "not_started"
    },
    "3": {
      "name": "Architecture and Solution Design",
      "status": "not_started"
    },
    "4": {
      "name": "Build and Integration",
      "status": "not_started"
    },
    "5": {
      "name": "Verification and Validation",
      "status": "not_started"
    },
    "6": {
      "name": "Release and Transition",
      "status": "not_started"
    },
    "7": {
      "name": "Operate Monitor and Improve",
      "status": "not_started"
    },
    "8": {
      "name": "Retire or Replace",
      "status": "not_started"
    }
  },
  "gates": {
    "A": { "status": "pending" },
    "B": { "status": "pending" },
    "C": { "status": "pending" },
    "D": { "status": "pending" },
    "E": { "status": "pending" },
    "F": { "status": "pending" },
    "G": { "status": "pending" },
    "H": { "status": "pending" }
  }
}
EOF

echo ""
echo "Created:"
echo "  $WF_DIR/artefacts/phase-{1..8}/"
echo "  $WF_DIR/artefacts/transversal/"
echo "  $WF_DIR/evidence/"
echo "  $WF_DIR/registers/"
echo "  $WF_DIR/gate-reports/"
echo "  $WF_DIR/metrics/"
echo "  $WF_DIR/lifecycle-state.json"
echo ""
echo "Next step: /waterfall-phase-start 1"
