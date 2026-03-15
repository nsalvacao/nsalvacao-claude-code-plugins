---
name: agile-gate-review
description: Execute a formal gate review. Checks gate criteria, validates artefacts, produces gate-review-report with PASS/FAIL/WAIVED outcome.
---

# /agile-gate-review <gate>

## Overview

Executes a formal lifecycle gate review. Checks whether all gate criteria are satisfied, verifies required artefacts are present and complete, and produces a `gate-review-report` with a formal PASS, FAIL, or WAIVED outcome.

Gates are the governance checkpoints in the hybrid gated-iterative framework. Each gate must be executed before transitioning to the next phase or major work stream.

## Usage

```
/agile-gate-review <gate>
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `gate` | Required | Gate identifier: `A` through `J` (or review name: `backlog-readiness`, `sprint-review`) |

## Gates Reference

| Gate | Name | Timing | Purpose |
|------|------|--------|---------|
| A | Portfolio Entry | End of Phase 1 | Opportunity validated — fund and pursue? |
| B | Inception Closure | End of Phase 2 | Architecture and plan approved — ready to build? |
| C | Backlog Readiness | End of Phase 3 | Backlog ready, DoD agreed — ready to deliver? |
| D | Release Authorization | End of Phase 4 | Build complete and quality confirmed — safe to release? |
| E | Operations Handover | End of Phase 5 | Product stable in production — handover to ops? |
| F | Governance Review | Periodic in Phase 6 | Continue, pivot, or retire? |

Authoritative criteria for each gate: `references/gate-criteria-reference.md`.

## What It Does

1. Reads gate criteria from `references/gate-criteria-reference.md` for the specified gate.
2. Checks the gate I/O matrix — verifies all required inputs are present.
3. Validates required artefacts:
   - Checks each mandatory artefact exists in `.agile-lifecycle/artefacts/`.
   - Verifies evidence threshold (exists | reviewed | approved) per artefact.
4. Checks sign-off authority requirements for the gate.
5. Runs `scripts/check-gate-criteria.sh` to validate programmatic criteria.
6. Presents a structured review report:
   - Criteria checklist (met / not met / waived)
   - Missing artefacts list
   - Evidence gaps
   - Recommendation: PASS | FAIL | WAIVE with conditions
7. Prompts for formal outcome decision.
8. Generates `gate-review-report` using `templates/transversal/gate-review-report.md.template`.
9. Updates `lifecycle-state.json` with gate outcome.
10. If PASS: unlocks the next phase for `/agile-phase-start`.

## Examples

```
# Run Gate A (end of Phase 1)
/agile-gate-review A

# Run Gate C (backlog readiness)
/agile-gate-review C

# Run Gate F (release candidate)
/agile-gate-review F
```

## Related Commands

- `/agile-phase-start <N+1>` — start the next phase after a gate passes
- `/agile-artefact-gen` — generate missing artefacts before re-running a gate
- `/agile-status` — check overall lifecycle status

## Related Agents

- `agents/transversal/gate-reviewer` — executes the gate review logic and produces the report
