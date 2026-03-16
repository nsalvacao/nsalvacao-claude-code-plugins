---
name: waterfall-phase-start
description: Start a waterfall lifecycle phase after confirming previous phase gate was passed or waived.
---

# /waterfall-phase-start <phase>

## Overview

Starts the specified waterfall lifecycle phase after validating that the previous phase's gate has been passed or formally waived. This command enforces the sequential gating contract that defines waterfall delivery — no phase may begin until its predecessor is closed.

On success, it updates `lifecycle-state.json`, loads the phase essentials card, routes to the appropriate phase agent, and creates the initial phase contract if one does not already exist.

## Usage

```
/waterfall-phase-start <phase>
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `phase` | Required | Phase number, integer 1–8. |

## What It Does

1. Reads `lifecycle-state.json` from `.waterfall-lifecycle/`.
2. **Validates previous phase gate**: For phase N > 1, checks that phase N-1 has status `approved` or `waived`. If not, blocks with error:
   ```
   ERROR: Phase N-1 must be approved or waived before starting Phase N.
          Current status: [status]
          Run /waterfall-gate-review <gate> to complete the gate for Phase N-1.
   ```
3. Validates that phase N is currently `not_started` or `blocked` (not already `in_progress` or `approved`).
4. Updates phase N status to `in_progress` in `lifecycle-state.json`.
5. Loads the phase essentials card from `docs/phase-essentials/phase-N.md` and surfaces key objectives, mandatory artefacts, and gate criteria for the phase.
6. Routes to the appropriate phase agent (e.g., `requirements-analyst` for Phase 2, `system-designer` for Phase 3).
7. Creates `.waterfall-lifecycle/artefacts/phase-N/phase-N-contract.md` from template if it does not already exist.

## Examples

```
# Start Phase 1 (no prior gate required)
/waterfall-phase-start 1
```

```
# Expected output (Phase 1)
Starting Phase 1 — Concept and Initiation...
  ✓ No prior gate required for Phase 1
  ✓ Phase 1 status set to: in_progress
  ✓ Phase contract created: .waterfall-lifecycle/artefacts/phase-1/phase-1-contract.md

Phase Essentials:
  Objectives: Define the problem, validate opportunity, obtain initiation approval
  Mandatory artefacts: Project Charter, Stakeholder Register, Business Case (draft)
  Gate: Gate A — Concept Approval

Routing to: lifecycle-orchestrator (Phase 1)
```

```
# Start Phase 3 after Phase 2 is approved
/waterfall-phase-start 3
```

```
# Expected output (Phase 3 — gate check passes)
Starting Phase 3 — System Design...
  ✓ Gate B (Phase 2) status: passed
  ✓ Phase 3 status set to: in_progress
  ✓ Phase contract created: .waterfall-lifecycle/artefacts/phase-3/phase-3-contract.md

Routing to: system-designer (Phase 3)
```

```
# Attempt Phase 3 when Phase 2 gate is still pending
/waterfall-phase-start 3
```

```
# Expected output (blocked)
ERROR: Phase 2 must be approved or waived before starting Phase 3.
       Current status: in_progress
       Run /waterfall-gate-review B to complete Gate B for Phase 2.
```

## Related Commands

- `/waterfall-lifecycle-status` — verify gate and phase statuses before starting
- `/waterfall-gate-review <gate>` — close the previous phase gate before proceeding
- `/waterfall-artefact-gen` — generate required phase artefacts

## Related Agents

- `agents/transversal/lifecycle-orchestrator` — phase routing and contract creation
- `agents/phase-*/` — phase-specific agents invoked after phase start
