#!/usr/bin/env bash
# generate-agents.sh — Generates agent stubs from the agent pattern and source document.
# Usage: ./generate-agents.sh [phase-number]
# If phase is omitted, generates stubs for all phases.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"
AGENTS_DIR="${PLUGIN_DIR}/agents"

PHASE="${1:-}"

# Agent definitions: phase, subfase, slug, description, color
AGENT_DEFS=(
  "transversal lifecycle-orchestrator lifecycle-orchestrator 'Lifecycle navigation, state management, and phase routing' cyan"
  "transversal gate-reviewer gate-reviewer 'Formal gate review execution for gates A through J' cyan"
  "transversal artefact-generator artefact-generator 'Generate lifecycle artefacts from templates' cyan"
  "transversal risk-assumption-tracker risk-assumption-tracker 'Manage risk, assumption, clarification, and dependency registers' cyan"
  "transversal metrics-analyst metrics-analyst 'Compile and analyse lifecycle metrics by category' cyan"
  "phase-1 problem-framing problem-framing 'Phase 1.1 — Opportunity and problem framing, stakeholder mapping' blue"
  "phase-1 early-feasibility early-feasibility 'Phase 1.2 — Early feasibility and AI data viability assessment' blue"
  "phase-1 portfolio-decision portfolio-decision 'Phase 1.3 — Portfolio decision and investment recommendation' blue"
  "phase-2 product-vision product-vision 'Phase 2.1 — Product vision, goals, and value proposition' cyan"
  "phase-2 ways-of-working ways-of-working 'Phase 2.2 — Working model, governance, and role responsibilities' cyan"
  "phase-2 initial-architecture initial-architecture 'Phase 2.3 — Initial architecture pack and ADRs' cyan"
  "phase-2 roadmap-release roadmap-release 'Phase 2.4 — Roadmap and release planning' cyan"
  "phase-3 problem-discovery problem-discovery 'Phase 3.1 — Problem discovery, user research, pain point mapping' green"
  "phase-3 requirements-shaping requirements-shaping 'Phase 3.2 — Requirements shaping, acceptance criteria, backlog' green"
  "phase-3 data-ai-control data-ai-control 'Phase 3.3 — Data readiness and AI control assessment' green"
  "phase-3 ready-for-delivery ready-for-delivery 'Phase 3.4 — Backlog readiness and delivery preparation' green"
  "phase-4 iteration-planning iteration-planning 'Phase 4.1 — Sprint planning, goal setting, capacity assessment' yellow"
  "phase-4 build-integration build-integration 'Phase 4.2 — Build, integrate, and unit test' yellow"
  "phase-4 ai-delivery-loop ai-delivery-loop 'Phase 4.3 — AI/ML model training, evaluation, experiment loop' yellow"
  "phase-4 continuous-validation continuous-validation 'Phase 4.4 — Continuous validation, acceptance criteria, DoD' yellow"
  "phase-4 review-adaptation review-adaptation 'Phase 4.5 — Iteration review, adaptation, stakeholder demo' yellow"
  "phase-5 release-readiness release-readiness 'Phase 5.1 — Release readiness assessment and sign-off' magenta"
  "phase-5 deployment-rollout deployment-rollout 'Phase 5.2 — Deployment execution and rollout management' magenta"
  "phase-5 ops-transition ops-transition 'Phase 5.3 — Operational transition, handover, support acceptance' magenta"
  "phase-5 hypercare hypercare 'Phase 5.4 — Hypercare period, issue triage, stabilisation' magenta"
  "phase-6 service-operations service-operations 'Phase 6.1 — Service operations, SLO monitoring, incident response' red"
  "phase-6 product-analytics product-analytics 'Phase 6.2 — Product analytics, usage telemetry, outcome tracking' red"
  "phase-6 ai-ops-monitoring ai-ops-monitoring 'Phase 6.3 — AI/ML operations monitoring, drift, retraining' red"
  "phase-6 continuous-improvement continuous-improvement 'Phase 6.4 — Continuous improvement, retrospectives, change recommendations' red"
  "phase-7 retirement-decision retirement-decision 'Phase 7.1 — Retirement decision, impact assessment, approval' blue"
  "phase-7 decommissioning decommissioning 'Phase 7.2 — Decommissioning planning and execution' blue"
)

created_count=0
skipped_count=0

for def in "${AGENT_DEFS[@]}"; do
  # Parse the definition
  read -r phase_dir slug name description color <<< "$def"

  # Filter by phase if specified
  if [[ -n "$PHASE" ]]; then
    if [[ "$phase_dir" != "phase-${PHASE}" && "$phase_dir" != "transversal" ]]; then
      continue
    fi
  fi

  target_dir="${AGENTS_DIR}/${phase_dir}"
  target_file="${target_dir}/${slug}.md"

  mkdir -p "$target_dir"

  if [[ -f "$target_file" ]]; then
    echo "SKIP: $target_file (already exists)"
    skipped_count=$((skipped_count + 1))
    continue
  fi

  # Remove surrounding quotes from description and color
  description="${description//\'/}"
  color="${color//\'/}"

  cat > "$target_file" <<AGENTMD
---
name: ${name}
description: ${description}
model: sonnet
color: ${color}
---

## Context

<!-- TODO: Add phase and subfase context from source document -->

## Workstreams

<!-- TODO: Add workstreams from source document -->

## Activities

<!-- TODO: Add detailed activities this agent performs -->

## Expected Outputs

<!-- TODO: List outputs and evidence produced -->

## Templates Available

<!-- TODO: List templates this agent uses -->

## Schemas

<!-- TODO: List schemas this agent validates against -->

## Responsibility Handover

### Receives From

<!-- TODO: What this subfase receives and from which preceding subfase/phase -->

### Delivers To

<!-- TODO: What this subfase delivers and to which subsequent subfase/phase -->

### Accountability

<!-- TODO: Who is accountable for the handover quality -->

## Phase Contract

This agent MUST read before producing any output:
- \`docs/phase-essentials/\` — 1-pager: what to do, who, evidence required
- \`references/lifecycle-overview.md\` — phase context, entry/exit criteria
- Relevant \`templates/\` — fill ALL mandatory fields
- Relevant \`schemas/*.schema.json\` — validate outputs (all \$id prefixed: \`agile-lifecycle/...\`)

### Mandatory Phase Questions

<!-- TODO: Phase-specific questions that MUST be answered -->

### Assumptions Required

<!-- TODO: Assumptions that MUST be documented before proceeding -->

### Clarifications Required

<!-- TODO: Open decisions that MUST be resolved -->

### Entry Criteria

<!-- TODO: What must be true before this subfase can start -->

### Exit Criteria

<!-- TODO: What must be true before this subfase is considered complete -->

### Evidence Required

<!-- TODO: Specific evidence artefacts that prove completion -->

### Sign-off Authority

<!-- TODO: Role responsible for sign-off + mechanism -->

## How to Use

Invoke this agent when working on ${description}.
Reference the phase essentials card and phase contract before starting.
AGENTMD

  echo "CREATED: $target_file"
  created_count=$((created_count + 1))
done

echo ""
echo "Done. Created: $created_count | Skipped (existing): $skipped_count"
