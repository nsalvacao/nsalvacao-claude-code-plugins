---
name: waterfall-gate-review
description: Initiate a formal gate review by invoking the gate-reviewer agent with the evidence package for the specified gate.
---

# /waterfall-gate-review <gate> [phase]

## Overview

Initiates a formal waterfall gate review by invoking the `gate-reviewer` agent with the evidence package for the specified gate. Gates are the mandatory governance checkpoints between phases — a phase cannot advance until its gate is formally passed or waived.

The gate-reviewer agent validates artefact completeness, assesses evidence quality, and produces a `gate-review-report` with a PASS, FAIL, or WAIVED outcome that is recorded in `lifecycle-state.json`.

## Usage

```
/waterfall-gate-review <gate> [phase]
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `gate` | Required | Gate identifier: `A` through `H`. |
| `phase` | Optional | Phase number associated with the gate. Inferred from gate if omitted (A→1, B→2, … H→8). |

## Gates Reference

| Gate | Phase | Name | Purpose |
|------|-------|------|---------|
| A | 1 | Concept Approval | Problem validated, business case approved — proceed to requirements? |
| B | 2 | Requirements Baseline | Requirements signed off — proceed to design? |
| C | 3 | Design Review | Architecture and design approved — proceed to build? |
| D | 4 | Build Readiness | Build complete, unit tested — proceed to integration/system test? |
| E | 5 | System Test Entry | Test plans ready, environment stable — proceed to system test? |
| F | 6 | Acceptance Test Entry | System test passed — proceed to user acceptance test? |
| G | 7 | Deployment Authorization | UAT passed, deployment plan approved — release to production? |
| H | 8 | Operations Handover | Product stable in production — formally hand over to operations? |

Authoritative criteria for each gate: `references/gate-criteria-reference.md`.

## What It Does

1. Validates that the gate ID is one of A-H; rejects invalid values with a clear error.
2. Reads `lifecycle-state.json` to confirm the associated phase is in `in_progress` or `ready_for_gate` state. If not, prompts the user to update the phase status before proceeding.
3. Assembles the evidence package: gate ID, current phase number, and paths to artefacts stored in `.waterfall-lifecycle/artefacts/phase-N/`.
4. Invokes the `gate-reviewer` agent with the assembled evidence package.
5. The `gate-reviewer` agent produces a `gate-review-report` using `templates/transversal/gate-review-report.md.template` with criteria checklist, artefact status, evidence gaps, and formal recommendation.
6. Based on the gate outcome:
   - **PASS**: updates gate status to `passed`, phase status to `approved`, and sets the next phase to `not_started` (ready to start).
   - **FAIL**: updates gate status to `failed`, phase status to `blocked`; lists remediation actions required.
   - **WAIVER**: updates gate status to `waived`, records the waiver justification in `lifecycle-state.json` and the gate report.
7. Saves the gate report to `.waterfall-lifecycle/gate-reports/gate-<ID>-review-report.md`.

## Examples

```
# Run Gate A (end of Phase 1 — Concept Approval)
/waterfall-gate-review A
```

```
# Expected output (PASS)
Gate A Review — Concept Approval
  Invoking gate-reviewer agent...
  ✓ Project Charter: present (approved)
  ✓ Business Case (draft): present (reviewed)
  ✓ Stakeholder Register: present (reviewed)
  ✓ Sign-off authority: Sponsor confirmed

  Recommendation: PASS
  ✓ Gate A status set to: passed
  ✓ Phase 1 status set to: approved
  ✓ Phase 2 unlocked (not_started)
  ✓ Report saved: .waterfall-lifecycle/gate-reports/gate-A-review-report.md

Next step: /waterfall-phase-start 2
```

```
# Run Gate C with explicit phase
/waterfall-gate-review C 3
```

```
# Gate fails due to missing artefact
Gate C Review — Design Review
  Invoking gate-reviewer agent...
  ✗ Architecture Decision Record: missing
  ✓ System Design Document: present (draft — not reviewed)
  ✗ NFR Sign-off: missing

  Recommendation: FAIL
  ✗ Gate C status set to: failed
  ✗ Phase 3 status set to: blocked

  Remediation required:
    - Generate ADR: /waterfall-artefact-gen architecture-decision-record 3
    - Obtain NFR sign-off from system owner
```

```
# Waiver path
Gate B Review — Requirements Baseline
  Recommendation: WAIVED (formal waiver recorded)
  Waiver justification: [captured from user input]
  ✓ Gate B status set to: waived
  ✓ Phase 2 status set to: approved
```

## Related Commands

- `/waterfall-phase-start <N+1>` — start the next phase after a gate passes or is waived
- `/waterfall-artefact-gen` — generate missing artefacts before re-running a gate
- `/waterfall-lifecycle-status` — check overall phase and gate status

## Related Agents

- `agents/transversal/gate-reviewer` — executes gate review logic and produces the gate-review-report
