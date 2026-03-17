---
name: summarize
description: Produce an executive-level summary from validated audit-fleet outputs with deterministic summary artifacts.
argument-hint: "[--mode strict|balanced] [--bundle .audit-fleet/audit-bundle.json] [--status .audit-fleet/status.json]"
allowed-tools:
  - Bash
  - Read
---

# Audit Fleet Summarize

Synthesize validated lane outputs into decision-ready summary artifacts.

## Mode Semantics

- `balanced` (default): include warnings and open risks in summary.
- `strict`: fail if validation gate is not green or required inputs are missing.

## Deterministic Outputs

- `.audit-fleet/summary.json`
- `.audit-fleet/summary.md`

## Behavior

1. Read validated inputs:
   - `.audit-fleet/audit-bundle.json`
   - `.audit-fleet/status.json`
   - `.audit-fleet/validation-result.json`
2. Summarize by blueprint+plan alignment:
   - critical/warning/info totals
   - top dimensions by impact
   - quick wins shortlist
   - high-impact expansions shortlist
   - blocked dependencies and owning lanes
3. Emit deterministic summaries:
   - machine format in `.audit-fleet/summary.json`
   - board-readable markdown in `.audit-fleet/summary.md`
4. In strict mode, fail if:
   - validation result is not `ok`
   - bundle is missing any required lane report
   - status `healthy` is false.

## Usage

```bash
/audit-fleet:summarize
/audit-fleet:summarize --mode strict
/audit-fleet:summarize --bundle .audit-fleet/audit-bundle.json --status .audit-fleet/status.json
```
