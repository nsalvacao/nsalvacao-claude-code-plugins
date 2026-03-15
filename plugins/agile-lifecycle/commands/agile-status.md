---
name: agile-status
description: Show current lifecycle status — active phase, gate status, open risks, pending artefacts, and metrics summary.
---

# /agile-status

## Overview

Displays a comprehensive status dashboard of the current project's agile lifecycle. Reads `lifecycle-state.json` and aggregates data from registers and gate reports to produce a structured summary.

Use this command to get a quick situational awareness at any point — before a gate review, at sprint start, or during stakeholder check-ins.

## Usage

```
/agile-status
```

## Arguments

None.

## What It Does

1. Reads `.agile-lifecycle/lifecycle-state.json` — validates it exists and is not corrupted.
2. Shows phase summary table:
   - Phase number and name
   - Status: `not_started | in_progress | blocked | ready_for_gate | approved | closed`
   - Active subfase (if in progress)
3. Shows gate summary:
   - Gate label (A–J)
   - Outcome: `pending | PASS | FAIL | WAIVED`
   - Date (if completed)
4. Shows open items count:
   - Open risks (probability `high` or `critical`)
   - Unresolved assumptions (past due date or no owner)
   - Open clarifications
   - Pending artefacts for current phase
5. Shows metrics snapshot for active phase:
   - Delivery metrics (velocity, commitment ratio)
   - Quality metrics (defect rate, test coverage)
   - Any AI-specific metrics if product type is `ai-ml` or `data-product`
6. Suggests next action based on current state.

## Examples

```
/agile-status
```

```
# Example output
=== Agile Lifecycle Status — my-ai-product ===

Phases
  Phase 1 (Opportunity)   ● in_progress  — subfase 1.2
  Phase 2 (Inception)     ○ not_started
  ...

Gates
  Gate A (Opportunity OK) — pending
  Gate B (Inception OK)   — pending

Open Items
  Risks (high/critical):    2
  Unresolved assumptions:   1
  Open clarifications:      3
  Pending artefacts (Ph1):  4

Next: complete subfase 1.2, then /agile-gate-review A
```

## Related Commands

- `/agile-phase-start <N>` — start or resume a phase
- `/agile-gate-review <gate>` — run a gate review
- `/agile-risk-update` — update the risk register
- `/agile-artefact-gen` — generate a pending artefact

## Related Agents

- `agents/transversal/lifecycle-orchestrator` — reads state and computes phase/gate status
- `agents/transversal/metrics-analyst` — provides metrics snapshot
