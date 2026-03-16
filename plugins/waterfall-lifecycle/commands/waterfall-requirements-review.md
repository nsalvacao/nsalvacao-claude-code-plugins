---
name: waterfall-requirements-review
description: Review the requirements set for completeness, testability, and AI/NFR coverage against Phase 2 exit criteria.
---

# /waterfall-requirements-review [--strict] [--phase <n>]

## Overview

Reviews all requirements artefacts produced during Phase 2 against completeness, testability, and AI/NFR coverage criteria. The command validates REQ-ID format, checks that every requirement has acceptance criteria defined, and computes per-artefact completeness percentages.

On completion, it invokes the `requirements-articulation` agent for business requirements review and the `ai-requirements-engineer` agent for AI-specific requirements review, then surfaces a structured report with actionable recommendations.

## Usage

```
/waterfall-requirements-review [--strict] [--phase <n>]
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `--strict` | Optional | Fail if any requirement lacks acceptance criteria (default: warn only). |
| `--phase` | Optional | Phase number to review (default: current phase from `lifecycle-state.json`). |

## What It Does

1. Reads `.waterfall-lifecycle/lifecycle-state.json` — verifies that Phase 2 has status `in_progress`. Blocks with an error if the phase is not active.
2. Scans `.waterfall-lifecycle/artefacts/phase-2/` for the three core artefacts:
   - `business-requirements-set.md`
   - `ai-requirements-specification.md`
   - `nfr-specification.md`
3. For each artefact present: validates that all REQ-IDs follow the format `REQ-YYYY-NNN`; checks that every requirement entry contains an explicit acceptance criteria section; computes and reports completeness percentage per artefact.
4. Invokes the `requirements-articulation` agent to perform a qualitative review of business requirements (clarity, unambiguity, scope alignment).
5. Invokes the `ai-requirements-engineer` agent to review AI-specific requirements (model constraints, data quality gates, bias/fairness criteria).
6. Outputs a structured report: artefacts found/missing, coverage summary table, testability issues list, agent review highlights, and prioritised recommendations.

## Examples

```
# Review with warnings only (default)
/waterfall-requirements-review
```

```
# Expected output (all artefacts present)
Requirements Review — Phase 2
  ✓ lifecycle-state.json: Phase 2 in_progress
  ✓ business-requirements-set.md found
  ✓ ai-requirements-specification.md found
  ✓ nfr-specification.md found

Artefact Coverage:
  business-requirements-set.md   : 18/20 requirements — 90% complete
    ⚠ REQ-2026-004: acceptance criteria missing
    ⚠ REQ-2026-017: acceptance criteria missing
  ai-requirements-specification.md: 8/8 requirements  — 100% complete
  nfr-specification.md            : 5/6 requirements  — 83% complete
    ⚠ REQ-2026-003: acceptance criteria missing

Agent Reviews:
  requirements-articulation : 2 clarity issues flagged (REQ-2026-007, REQ-2026-012)
  ai-requirements-engineer  : bias criteria missing for REQ-2026-005

Recommendations:
  1. Add acceptance criteria to REQ-2026-004, REQ-2026-017, REQ-2026-003
  2. Clarify scope boundary in REQ-2026-007
  3. Define fairness metric for REQ-2026-005 before baseline
```

```
# Strict mode — fails on any gap
/waterfall-requirements-review --strict
```

```
# Expected output (strict, gap found)
Requirements Review — Phase 2 (STRICT MODE)
  ✓ lifecycle-state.json: Phase 2 in_progress
  ✓ All 3 artefacts found

FAIL: 3 requirements lack acceptance criteria.
  REQ-2026-004 (business-requirements-set.md)
  REQ-2026-017 (business-requirements-set.md)
  REQ-2026-NFR-003 (nfr-specification.md)

Review blocked. Resolve all gaps before running /waterfall-baseline-check.
```

```
# Explicit phase override
/waterfall-requirements-review --phase 2
```

## Related Commands

- `/waterfall-lifecycle-status` — verify current phase and gate status
- `/waterfall-baseline-check` — validate Gate B artefact completeness after requirements review passes
- `/waterfall-phase-start` — start or restart a lifecycle phase

## Related Agents

- `agents/phase-2/requirements-articulation` — qualitative review of business requirements
- `agents/phase-2/ai-requirements-engineer` — AI/ML requirements review and bias criteria validation
