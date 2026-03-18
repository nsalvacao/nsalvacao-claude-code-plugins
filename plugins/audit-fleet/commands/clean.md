---
name: clean
description: Remove deterministic audit-fleet generated artifacts while preserving source configuration by default.
argument-hint: "[--mode strict|balanced] [--out-dir .audit-fleet] [--include-reports] [--all]"
allowed-tools:
  - Bash
  - Glob
---

# Audit Fleet Clean

Remove generated artifacts from previous audit-fleet runs.

## Mode Semantics

- `balanced` (default): missing targets are reported and skipped.
- `strict`: missing expected targets or failed removals cause failure.

## Deterministic Targets

Always clean these generated files when present:

- `.audit-fleet/reports-check.json`
- `.audit-fleet/validation-result.json`
- `.audit-fleet/audit-bundle.json`
- `.audit-fleet/sqlite-contract.json`
- `.audit-fleet/status.json`
- `.audit-fleet/summary.json`
- `.audit-fleet/summary.md`
- `.audit-fleet/reports-json/*.json`

Optional cleanup:

- `--include-reports`: also remove fixed markdown report files `00`..`13` in `<reports-dir>`
- `--all`: includes DB reset (`.audit-fleet/audit-fleet.sqlite3`) in addition to all generated artifacts

## Usage

```bash
/audit-fleet:clean
/audit-fleet:clean --mode strict
/audit-fleet:clean --include-reports
/audit-fleet:clean --all
```
