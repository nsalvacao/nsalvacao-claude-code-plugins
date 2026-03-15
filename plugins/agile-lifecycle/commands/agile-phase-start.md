---
name: agile-phase-start
description: Start or resume a lifecycle phase. Validates entry criteria, creates phase contract, invokes phase agents.
---

# /agile-phase-start <phase-number> [subfase]

## Overview

Starts or resumes a lifecycle phase. Validates that entry criteria are satisfied before proceeding, creates a phase contract from the appropriate template, and invokes the relevant phase agent(s).

This command is the primary entry point for phase work. It enforces the gated model — a phase cannot start unless the preceding gate has been passed (or explicitly waived).

## Usage

```
/agile-phase-start <phase-number> [subfase]
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `phase-number` | Required | Phase to start: `1` through `7` |
| `subfase` | Optional | Specific subfase to start (e.g. `1.1`, `1.2`, `4.3`). If omitted, starts from the first subfase of the phase. |

## What It Does

1. Reads `lifecycle-state.json` — checks current phase statuses.
2. Validates entry criteria for the requested phase:
   - Checks that the preceding gate has been passed or waived.
   - Checks that mandatory entry artefacts exist.
   - If criteria are not met, reports which are missing and suggests remediation.
3. Updates `lifecycle-state.json` — sets phase status to `in_progress`.
4. Creates or loads the phase contract:
   - If no contract exists, generates one from `templates/phase-N/` using `agile-artefact-gen`.
   - If a contract exists (resume case), loads it and shows current completion status.
5. Invokes the relevant phase agent(s):
   - If subfase is specified, invokes the matching subfase agent directly.
   - Otherwise, invokes the orchestrator to route to the correct starting subfase.
6. The agent then guides through the subfase activities, questions, assumptions, and artefact production.

## Examples

```
# Start Phase 1 from the beginning
/agile-phase-start 1

# Resume Phase 1 at subfase 1.2 (early feasibility)
/agile-phase-start 1 1.2

# Start Phase 4 (iterative delivery)
/agile-phase-start 4

# Jump to subfase 4.3 (AI delivery loop)
/agile-phase-start 4 4.3
```

## Related Commands

- `/agile-status` — check current state before starting
- `/agile-gate-review <gate>` — run the gate before starting the next phase
- `/agile-artefact-gen` — generate phase artefacts during the phase

## Related Agents

- `agents/transversal/lifecycle-orchestrator` — validates entry criteria and routes to subfase agent
- `agents/phase-N/*` — the specific subfase agent invoked for the requested phase
