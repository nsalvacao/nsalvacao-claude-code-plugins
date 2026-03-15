# Command Reference

All 11 slash commands available in the agile-lifecycle plugin.

## Quick Reference

| Command | Purpose | Key Args |
|---------|---------|----------|
| `/agile-init` | Initialize lifecycle for project | — |
| `/agile-status` | Show current lifecycle status | — |
| `/agile-phase-start` | Start or resume a phase/subfase | `<phase-number> [subfase]` |
| `/agile-gate-review` | Execute a formal gate review | `<gate>` (A-F) |
| `/agile-artefact-gen` | Generate a lifecycle artefact | `[artefact-type]` |
| `/agile-risk-update` | Add/update risk register entries | `[register-type]` |
| `/agile-sprint-plan` | Plan or review current sprint | — |
| `/agile-retrospective` | Facilitate a retrospective | `[scope]` |
| `/agile-metrics-report` | Generate metrics report | `[scope]` |
| `/agile-change-request` | Evaluate and log a change request | — |
| `/agile-tailoring` | Configure lifecycle for product type | `[product-type]` |

## Detailed Reference

### /agile-init
Initialize the agile-lifecycle framework for a new project.

**Usage:** `/agile-init`

**What it does:**
1. Creates `.agile-lifecycle/` directory in project
2. Initializes `lifecycle-state.json` with default state
3. Prompts for project name, product type, team structure
4. Bootstraps Phase 1 context

### /agile-status
Show current lifecycle status.

**Usage:** `/agile-status`

**What it does:** Shows active phase, gate status, open risks count, pending artefacts, and metrics summary.

### /agile-phase-start `<phase>` `[subfase]`
Start or resume a lifecycle phase.

**Usage:** `/agile-phase-start 1` or `/agile-phase-start 1.2`

**What it does:** Validates entry criteria, creates phase contract, invokes the relevant phase agent.

### /agile-gate-review `<gate>`
Execute a formal gate review.

**Usage:** `/agile-gate-review A` or `/agile-gate-review E`

**What it does:** Checks gate criteria, verifies artefacts, produces gate-review-report with PASS/FAIL/WAIVED.

### /agile-artefact-gen `[type]`
Generate a lifecycle artefact from template.

**Usage:** `/agile-artefact-gen opportunity-brief` or `/agile-artefact-gen` (lists available templates)

### /agile-risk-update `[register]`
Add or update risk register entries.

**Usage:** `/agile-risk-update risk` or `/agile-risk-update assumption`

**Register types:** `risk | assumption | clarification | dependency`

### /agile-sprint-plan
Plan or review the current sprint.

**Usage:** `/agile-sprint-plan`

### /agile-retrospective `[scope]`
Facilitate a retrospective.

**Usage:** `/agile-retrospective sprint` or `/agile-retrospective phase`

**Scopes:** `sprint | phase | lifecycle`

### /agile-metrics-report `[scope]`
Generate a metrics report.

**Usage:** `/agile-metrics-report phase` or `/agile-metrics-report lifecycle`

**Scopes:** `phase | lifecycle | sprint`

### /agile-change-request
Evaluate and log a change request.

**Usage:** `/agile-change-request`

### /agile-tailoring `[product-type]`
Configure lifecycle tailoring.

**Usage:** `/agile-tailoring saas` or `/agile-tailoring ai-ml`

**Product types:** `saas | web | desktop | cli | ai-ml | data-product | internal | mvp`
