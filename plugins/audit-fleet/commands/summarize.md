---
name: summarize
description: Produce an executive-level summary from validated audit-fleet outputs with deterministic summary artifacts.
argument-hint: "[--repo <path>] [--out <path>] [--mode strict|balanced] [--allow-partial-consolidation]"
allowed-tools:
  - Bash
  - Read
  - Task
---

# Audit Fleet Summarize

Synthesize validated lane outputs into a refreshed executive summary for any target repository.

## Mode Semantics

- `balanced` (default): include warnings and open risks in summary.
- `strict`: fail if validation gate is not green or required inputs are missing.

## Deterministic Outputs

- `<out>/summary.json`
- `<out>/summary.md`

## Behavior

1. Read validated inputs:
   - `<out>/audit-bundle.json`
   - `<out>/status.json`
   - `<out>/validation-result.json`
2. Summarize by artifact-to-implementation alignment:
   - critical/warning/info totals
   - top dimensions by impact
   - quick wins shortlist
   - high-impact expansions shortlist
   - blocked dependencies and owning lanes
   - coverage gaps and provisional conditions (if any)
3. Emit deterministic summaries:
   - machine format in `<out>/summary.json`
   - board-readable markdown in `<out>/summary.md`
4. In strict mode, fail if:
   - validation result is not `ok`
   - bundle is missing any required lane report
   - status `healthy` is false
   - coverage is provisional without explicit partial mode.

## Usage

```bash
/audit-fleet:summarize --repo . --out .dev/audit-2026-03-17
/audit-fleet:summarize --repo /workspace/repo --out /workspace/repo/.dev/audit-2026-03-17 --mode strict
/audit-fleet:summarize --repo /workspace/repo --out /workspace/repo/.dev/audit-2026-03-17 --allow-partial-consolidation
```
