---
name: waterfall-lifecycle-status
description: Display current waterfall lifecycle state including active phase, gate statuses, and outstanding blockers.
---

# /waterfall-lifecycle-status

## Overview

Displays a structured summary of the current waterfall lifecycle state. Shows the active phase and subphase, all gate statuses (A-H), open risk register entries at medium impact or above, overdue clarifications, and the time since the last lifecycle state update.

This command is read-only and safe to run at any time. It does not modify `lifecycle-state.json`.

## Usage

```
/waterfall-lifecycle-status
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| *(none)* | — | No arguments. Reads state from `.waterfall-lifecycle/lifecycle-state.json`. |

## What It Does

1. Reads `lifecycle-state.json` from `.waterfall-lifecycle/`.
2. Shows the current phase number, phase name, and status (`in_progress` / `ready_for_gate` / `approved` / `blocked`).
3. Shows all 8 gates (A-H) with their current status (`pending` / `passed` / `failed` / `waived`), mapping each gate to its associated phase.
4. Lists all open risk register entries with impact level `medium` or higher from `.waterfall-lifecycle/registers/risk-register.md`.
5. Lists clarifications marked as `overdue` from `.waterfall-lifecycle/registers/clarification-log.md`.
6. Shows the elapsed time since `lifecycle-state.json` was last modified.

## Examples

```
/waterfall-lifecycle-status
```

```
# Expected output
Waterfall Lifecycle Status — enterprise-billing-platform
=========================================================

Active Phase: Phase 3 — System Design (in_progress)

Gates:
  Gate A — Concept Approval          [passed]
  Gate B — Requirements Baseline     [passed]
  Gate C — Design Review             [pending]
  Gate D — Build Readiness           [pending]
  Gate E — System Test Entry         [pending]
  Gate F — Acceptance Test Entry     [pending]
  Gate G — Deployment Authorization  [pending]
  Gate H — Operations Handover       [pending]

Open Risks (>= medium):
  R-003  HIGH  Vendor API availability for integration layer
  R-007  MED   Key architect on leave during design sprint

Overdue Clarifications:
  CL-002  Who owns NFR sign-off? (overdue 3 days)

Last updated: 2 hours ago
```

```
# No lifecycle state found
ERROR: .waterfall-lifecycle/lifecycle-state.json not found.
       Run /waterfall-lifecycle-init to initialize the framework.
```

## Related Commands

- `/waterfall-phase-start <N>` — start or resume a phase
- `/waterfall-gate-review <gate>` — run a gate review
- `/waterfall-artefact-gen` — generate missing artefacts before a gate review

## Related Agents

- `agents/transversal/lifecycle-orchestrator` — interprets state and provides lifecycle guidance
