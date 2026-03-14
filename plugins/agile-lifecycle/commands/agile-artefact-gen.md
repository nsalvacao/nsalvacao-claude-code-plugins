---
name: agile-artefact-gen
description: Generate a lifecycle artefact from template. Without args, lists available templates for current phase.
---

# /agile-artefact-gen [artefact-type]

## Overview

Generates a lifecycle artefact from the appropriate template, filling placeholders with project context. Without arguments, lists all templates available for the current phase.

Use this command whenever a phase activity requires producing a formal artefact. The agent will guide you through filling all mandatory fields and validate the output against the relevant schema.

## Usage

```
/agile-artefact-gen [artefact-type]
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `artefact-type` | Optional | Template identifier (e.g. `opportunity-brief`, `feasibility-note`, `sprint-backlog`). If omitted, lists available templates for the current phase. |

## Available Artefact Types (selection)

**Phase 1:** `opportunity-statement`, `value-hypothesis`, `stakeholder-map`, `early-feasibility-note`, `initial-risk-note`, `ai-data-feasibility-note`, `funding-recommendation`, `portfolio-decision-record`

**Phase 2:** `product-vision`, `product-goal-set`, `working-model`, `governance-model`, `role-responsibility-map`, `initial-architecture-pack`, `initial-adr`, `initial-roadmap`, `inception-closure-pack`

**Phase 3:** `discovery-findings`, `pain-point-map`, `user-journey-map`, `acceptance-criteria-catalog`, `ai-backlog-items`, `data-readiness-notes`, `readiness-notes`

**Phase 4:** `iteration-goal`, `committed-work-set`, `iteration-plan`, `experiment-log`, `evaluation-results`, `validation-evidence`, `review-outcomes`

**Phase 5–7:** `release-readiness-pack`, `deployment-record`, `rollout-log`, `retirement-decision-record`, and more.

**Transversal:** `risk-register-entry`, `assumption-register-entry`, `clarification-entry`, `gate-review-report`, `waiver-entry`, `significant-change-record`

Run `/agile-artefact-gen` without args to see the full list for the current phase.

## What It Does

1. If no argument: reads current phase from `lifecycle-state.json` and lists available templates.
2. If artefact-type provided:
   a. Loads the matching template from `templates/`.
   b. Reads project context from `lifecycle-state.json` to pre-fill known placeholders.
   c. Guides you through filling remaining mandatory fields.
   d. Renders the artefact using `scripts/render-template.sh`.
   e. Validates against the relevant schema using `scripts/validate-schema.sh` (if schema exists).
   f. Saves the artefact to `.agile-lifecycle/artefacts/phase-N/`.
   g. Updates the artefact manifest.

## Examples

```
# List templates for current phase
/agile-artefact-gen

# Generate an opportunity statement
/agile-artefact-gen opportunity-statement

# Generate a gate review report
/agile-artefact-gen gate-review-report

# Generate a risk register entry
/agile-artefact-gen risk-register-entry
```

## Related Commands

- `/agile-gate-review` — uses artefacts produced by this command
- `/agile-risk-update` — for risk/assumption register entries specifically
- `/agile-phase-start` — often triggers artefact generation as part of phase entry

## Related Agents

- `agents/transversal/artefact-generator` — fills templates with project context and validates output
