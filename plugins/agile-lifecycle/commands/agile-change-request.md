---
name: agile-change-request
description: Evaluate and log a change request — determines if change is incremental or significant, triggers change control process if needed.
---

# /agile-change-request [description]

## Overview

Evaluates a proposed change and determines whether it is incremental (no formal gate required) or significant (triggers the change control process). Logs the change in the change log and, if significant, produces a formal significant-change-record and updates the lifecycle state.

Use this command whenever a change is proposed mid-phase — scope changes, technical direction shifts, team changes, or AI model substitutions.

## Usage

```
/agile-change-request [description]
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `description` | Optional | Brief description of the proposed change. If omitted, the agent will prompt for it. |

## Change Classification

| Type | Definition | Process |
|------|-----------|---------|
| **Incremental** | Stays within current phase scope, no gate impact, low risk | Log in change log, no gate needed |
| **Significant** | Affects scope, budget, timeline, architecture, or gate criteria | Formal change record + lifecycle-orchestrator review + possible gate re-run |

Significant change triggers include:
- Scope increase > 20% of remaining phase work
- New or changed AI/ML model (requires AI readiness re-check)
- Architecture decision reversal
- Sponsor or key stakeholder change
- Regulatory or compliance requirement change

## What It Does

1. Prompts for change description, rationale, and affected components.
2. Applies `skills/change-control` to classify the change.
3. Reads current lifecycle state to assess impact on remaining phases and gates.
4. For **incremental** changes:
   - Logs entry in change log (`schemas/change-log.schema.json`).
   - No gate re-run required.
5. For **significant** changes:
   - Generates `significant-change-record` from `templates/transversal/significant-change-record.md.template`.
   - Invokes lifecycle-orchestrator to assess gate impact.
   - Determines if a gate must be re-run or modified.
   - Prompts for sign-off authority confirmation.
   - Updates lifecycle state with change record reference.
6. Provides a summary of actions taken and next steps.

## Examples

```
# Evaluate a change with description
/agile-change-request "Switch from GPT-4 to Claude 3 as primary model"

# Interactive mode (prompts for description)
/agile-change-request

# Log a scope addition
/agile-change-request "Add multi-language support to Phase 3 scope"
```

## Related Commands

- `/agile-gate-review` — may be required after a significant change
- `/agile-risk-update` — update risk register if change introduces new risks
- `/agile-status` — check lifecycle state after logging the change

## Related Agents

- `agents/transversal/risk-assumption-tracker` — logs change and assesses register impact
- `agents/transversal/lifecycle-orchestrator` — evaluates gate and phase impact of significant changes
