---
name: waterfall-baseline-check
description: Validate requirements baseline completeness against all Gate B mandatory artefacts and RTM coverage before submitting for gate review.
---

# /waterfall-baseline-check [--gate <label>] [--strict]

## Overview

Validates that all mandatory Gate B artefacts are present and that the Requirements Traceability Matrix (RTM) provides full coverage before the baseline is submitted for gate review. This command acts as the final quality gate within Phase 2 — no gate review should be requested until this check passes.

The command invokes the `baseline-manager` agent for a Gate B readiness assessment and outputs a per-artefact PASS/FAIL checklist, RTM coverage percentage, a list of orphaned requirements, and an overall gate readiness verdict.

## Usage

```
/waterfall-baseline-check [--gate <label>] [--strict]
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `--gate` | Optional | Gate label to validate against (default: `B`). |
| `--strict` | Optional | Fail on any missing artefact instead of issuing a warning. |

## What It Does

1. Reads `.waterfall-lifecycle/lifecycle-state.json` — verifies that Phase 2 has status `in_progress`. Blocks with an error if the phase is not active.
2. Checks for all 10 mandatory Gate B artefacts in `.waterfall-lifecycle/artefacts/phase-2/`:
   - `requirements-baseline.md`
   - `business-requirements-set.md`
   - `ai-requirements-specification.md`
   - `nfr-specification.md`
   - `acceptance-criteria-catalog.md`
   - `requirements-traceability-matrix.md`
   - `glossary.md`
   - `assumption-register.md` (must show an update timestamp within the current phase)
   - `clarification-log.md` (must show an update timestamp within the current phase)
   - `requirements-baseline-approval-pack.md` (Gate B submission pack)
3. Validates RTM coverage: every REQ-ID present in the requirements set must have at least one entry in the RTM. Reports orphaned requirements (present in artefacts but absent from RTM).
4. Invokes the `baseline-manager` agent to perform a holistic Gate B readiness assessment, including consistency checks across linked artefacts.
5. Outputs: Gate B checklist with PASS/FAIL per artefact, RTM coverage percentage, orphaned requirements list, and an overall gate readiness verdict (`ready` / `not-ready`).

## Examples

```
# Check Gate B readiness (default)
/waterfall-baseline-check
```

```
# Expected output (all artefacts present, full RTM coverage)
Baseline Check — Gate B
  ✓ lifecycle-state.json: Phase 2 in_progress

Gate B Artefact Checklist:
  ✓ requirements-baseline.md
  ✓ business-requirements-set.md
  ✓ ai-requirements-specification.md
  ✓ nfr-specification.md
  ✓ acceptance-criteria-catalog.md
  ✓ requirements-traceability-matrix.md
  ✓ glossary.md
  ✓ assumption-register.md (updated 2026-03-14)
  ✓ clarification-log.md (updated 2026-03-15)
  ✓ requirements-baseline-approval-pack.md

RTM Coverage: 31/31 requirements — 100%
Orphaned requirements: none

baseline-manager assessment: Gate B artefacts consistent. No blocking issues.

Gate B Readiness: READY
  Run /waterfall-gate-review B to submit for formal gate review.
```

```
# Expected output (artefacts missing, RTM gaps)
Baseline Check — Gate B
  ✓ lifecycle-state.json: Phase 2 in_progress

Gate B Artefact Checklist:
  ✓ requirements-baseline.md
  ✓ business-requirements-set.md
  ✓ ai-requirements-specification.md
  ✓ nfr-specification.md
  ✗ acceptance-criteria-catalog.md — MISSING
  ✓ requirements-traceability-matrix.md
  ✓ glossary.md
  ⚠ assumption-register.md (last updated 2026-02-20 — stale)
  ✓ clarification-log.md (updated 2026-03-15)
  ✗ requirements-baseline-approval-pack.md — MISSING

RTM Coverage: 28/31 requirements — 90%
Orphaned requirements (not in RTM):
  REQ-2026-008, REQ-2026-019, REQ-2026-NFR-002

Gate B Readiness: NOT READY
  Resolve 2 missing artefacts and 3 RTM gaps before gate review.
```

```
# Strict mode — fails on any missing artefact
/waterfall-baseline-check --strict
```

## Related Commands

- `/waterfall-requirements-review` — review requirements completeness before running this check
- `/waterfall-gate-review` — submit for formal gate review once this check passes
- `/waterfall-lifecycle-status` — verify current phase and gate status

## Related Agents

- `agents/phase-2/baseline-manager` — Gate B readiness assessment and artefact consistency review
