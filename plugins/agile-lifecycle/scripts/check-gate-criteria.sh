#!/usr/bin/env bash
# check-gate-criteria.sh — Checks if gate criteria are met for a given gate.
# Usage: ./check-gate-criteria.sh <gate> <evidence-dir>
# Returns: 0 if all criteria met, 1 if not met
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <gate> <evidence-dir>" >&2
  echo "Gates: A B C D E F G H I J" >&2
  exit 1
fi

GATE="${1^^}"
EVIDENCE_DIR="$2"

VALID_GATES="A B C D E F G H I J"
if ! echo "$VALID_GATES" | grep -qw "$GATE"; then
  echo "ERROR: Invalid gate '$GATE'. Valid gates: $VALID_GATES" >&2
  exit 1
fi

if [[ ! -d "$EVIDENCE_DIR" ]]; then
  echo "ERROR: Evidence directory not found: $EVIDENCE_DIR" >&2
  exit 1
fi

fail_count=0
pass_count=0

echo "=== Gate $GATE Criteria Check ==="
echo "Evidence directory: $EVIDENCE_DIR"
echo ""

check_artefact() {
  local label="$1"
  local pattern="$2"
  local found=0
  for f in "${EVIDENCE_DIR}"/${pattern}; do
    if [[ -f "$f" ]]; then
      found=1
      break
    fi
  done
  if [[ $found -eq 1 ]]; then
    echo "  OK:   $label"
    pass_count=$((pass_count + 1))
  else
    echo "  FAIL: $label — no matching file (pattern: ${pattern})"
    fail_count=$((fail_count + 1))
  fi
}

case "$GATE" in
  A)
    echo "Gate A — Opportunity Validated (end of Phase 1)"
    check_artefact "Opportunity statement" "phase-1/*opportunity*"
    check_artefact "Early feasibility note" "phase-1/*feasibility*"
    check_artefact "Risk note" "phase-1/*risk*"
    check_artefact "Portfolio decision record" "phase-1/*portfolio-decision*"
    ;;
  B)
    echo "Gate B — Inception Complete (end of Phase 2)"
    check_artefact "Product vision" "phase-2/*product-vision*"
    check_artefact "Working model" "phase-2/*working-model*"
    check_artefact "Initial roadmap" "phase-2/*roadmap*"
    check_artefact "Initial architecture" "phase-2/*architecture*"
    ;;
  C)
    echo "Gate C — Backlog Readiness (end of Phase 3)"
    check_artefact "Discovery findings" "phase-3/*discovery-findings*"
    check_artefact "Acceptance criteria catalog" "phase-3/*acceptance-criteria*"
    check_artefact "Readiness notes" "phase-3/*readiness*"
    ;;
  D)
    echo "Gate D — AI Readiness / Delivery Health (mid Phase 4)"
    check_artefact "Experiment log" "phase-4/*experiment*"
    check_artefact "Validation evidence" "phase-4/*validation*"
    ;;
  E)
    echo "Gate E — Iteration Review (end of Phase 4 sprint)"
    check_artefact "Review outcomes" "phase-4/*review-outcomes*"
    ;;
  F)
    echo "Gate F — Delivery Complete / Release Candidate (end of Phase 4)"
    check_artefact "Release readiness pack" "*release-readiness*"
    check_artefact "Validation evidence" "phase-4/*validation*"
    ;;
  G)
    echo "Gate G — Release Approved (end of Phase 5)"
    check_artefact "Deployment record" "phase-5/*deployment*"
    check_artefact "Operational transition pack" "phase-5/*transition*"
    check_artefact "Support acceptance" "phase-5/*support*"
    ;;
  H)
    echo "Gate H — Operational Health Review (mid Phase 6)"
    check_artefact "Service report" "phase-6/*service-report*"
    check_artefact "AI monitoring report" "phase-6/*ai-monitoring*"
    ;;
  I)
    echo "Gate I — Improvement Cycle Review (end of Phase 6)"
    check_artefact "Product analytics report" "phase-6/*analytics*"
    check_artefact "Improvement backlog" "phase-6/*improvement-backlog*"
    ;;
  J)
    echo "Gate J — Retirement Decision (Phase 7)"
    check_artefact "Retirement decision record" "phase-7/*retirement-decision*"
    check_artefact "Impact assessment" "phase-7/*impact-assessment*"
    ;;
esac

echo ""
echo "Passed: $pass_count | Failed: $fail_count"

if [[ $fail_count -gt 0 ]]; then
  echo "Gate $GATE: NOT MET — $fail_count criterion/criteria missing"
  exit 1
else
  echo "Gate $GATE: CRITERIA MET"
fi
