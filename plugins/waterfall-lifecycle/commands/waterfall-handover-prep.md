---
name: waterfall-handover-prep
description: Prepare inter-phase handover package by validating Gate C artefacts, generating handover summary, and assessing phase transition readiness.
---

# /waterfall-handover-prep

## Overview

Prepares the inter-phase handover package for a waterfall phase transition. For the default Phase 3 to Phase 4 transition, validates all 12 mandatory Gate C artefacts, scans for unfilled placeholder tokens, reports open items from the design approval pack, and invokes the `control-design` agent for a final readiness assessment.

This command is the pre-flight check before submitting to `/waterfall-gate-review`. A `READY` verdict means all artefacts are present, all placeholders are resolved, and Phase 4 can receive the handover package.

## Usage

```
/waterfall-handover-prep [--gate <label>] [--from <phase>] [--to <phase>]
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `--gate` | Optional | Gate label to validate against (default: `C`). |
| `--from` | Optional | Phase to hand over from (default: `3`). |
| `--to`   | Optional | Phase to hand over to (default: `4`). |

## What It Does

The following steps describe the behaviour for `--gate C` (Phase 3 → Phase 4). Other gate/phase combinations follow the same pattern with the corresponding artefact set.

1. Reads `.waterfall-lifecycle/lifecycle-state.json` — verifies that Phase 3 has status `in_progress`. If the phase is not active, the command blocks with a clear error and suggests running `/waterfall-lifecycle-status` to diagnose the state.

2. Checks all 12 mandatory Gate C artefacts under `.waterfall-lifecycle/artefacts/phase-3/`:
   - `hld.md`
   - `lld.md`
   - `interface-specifications.md`
   - `adr-set/` (directory containing at least 1 ADR file)
   - `control-matrix.md`
   - `test-design-package.md`
   - `operational-design-package.md`
   - `security-design-review.md`
   - `ai-control-design-note.md`
   - `design-approval-pack.md`
   - `assumption-register.md` (updated with Phase 3 assumptions)
   - `clarification-log.md` (updated, all blocking design items resolved or tracked)

3. Scans each present artefact for unfilled `{{variable}}` placeholder tokens — reports total count across all artefacts. Any placeholder count > 0 is a blocker.

4. Reads the open items section from `design-approval-pack.md` — reports the count of unresolved items. CRITICAL open items block the handover.

5. Invokes the `control-design` agent for a Gate C readiness assessment, passing the artefact inventory and open items summary.

6. Outputs:
   - Gate C artefact checklist (PASS/FAIL per artefact)
   - Total unfilled placeholder count
   - Open items count (by severity if available)
   - Overall readiness verdict: `READY` or `NOT READY`
   - Transition summary for Phase 4 (artefacts to receive, open items to inherit)

## Examples

```
# Default: validate Gate C, Phase 3 → Phase 4
/waterfall-handover-prep
```

```
# All 12 artefacts present, 0 placeholders, gate ready
Handover Prep — Gate C (Phase 3 → Phase 4)
  Reading lifecycle-state.json...
  Phase 3 status: in_progress [OK]

  Artefact Check:
    PASS  hld.md
    PASS  lld.md
    PASS  interface-specifications.md
    PASS  adr-set/ (3 ADR files found)
    PASS  control-matrix.md
    PASS  test-design-package.md
    PASS  operational-design-package.md
    PASS  security-design-review.md
    PASS  ai-control-design-note.md
    PASS  design-approval-pack.md
    PASS  assumption-register.md
    PASS  clarification-log.md

  Placeholder scan: 0 unfilled tokens
  Open items (design-approval-pack.md): 0 CRITICAL, 2 LOW
  Invoking control-design agent for readiness assessment...
  Gate C readiness: confirmed

  Verdict: READY
  Handover package ready for Phase 4.
  Next step: /waterfall-gate-review C 3
```

```
# 2 artefacts missing, placeholders found — NOT READY
/waterfall-handover-prep --gate C --from 3 --to 4
```

```
Handover Prep — Gate C (Phase 3 → Phase 4)
  Reading lifecycle-state.json...
  Phase 3 status: in_progress [OK]

  Artefact Check:
    PASS  hld.md
    PASS  lld.md
    FAIL  interface-specifications.md [missing]
    PASS  adr-set/ (1 ADR file found)
    FAIL  control-matrix.md [missing]
    PASS  test-design-package.md
    PASS  operational-design-package.md
    PASS  security-design-review.md
    PASS  ai-control-design-note.md
    PASS  design-approval-pack.md
    PASS  assumption-register.md
    PASS  clarification-log.md

  Placeholder scan: 7 unfilled tokens found
    - hld.md: 3 tokens ({{owner}}, {{version}}, {{review_date}})
    - test-design-package.md: 4 tokens ({{test_lead}}, {{coverage_target}}, ...)

  Open items (design-approval-pack.md): 1 CRITICAL, 3 MEDIUM

  Verdict: NOT READY

  Blockers:
    - interface-specifications.md is missing
      Fix: /waterfall-artefact-gen interface-specifications 3
    - control-matrix.md is missing
      Fix: /waterfall-artefact-gen control-matrix 3
    - 7 unfilled placeholder tokens must be resolved before gate submission
    - 1 CRITICAL open item in design-approval-pack.md must be resolved or explicitly signed off
```

## Related Commands

- `/waterfall-baseline-check` — equivalent pre-flight check for Gate B (Phase 2)
- `/waterfall-gate-review` — submit for formal gate review once handover-prep passes
- `/waterfall-lifecycle-status` — verify current phase and gate status
- `/waterfall-artefact-gen` — generate missing artefacts identified during the check

## Related Agents

- `agents/phase-3/control-design` — Gate C readiness assessment and final artefact consistency review
