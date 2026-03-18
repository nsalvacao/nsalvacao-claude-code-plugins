---
name: status
description: Report orchestration status for audit-fleet lanes, barrier readiness, and validation health.
argument-hint: "[--mode strict|balanced] [--db .audit-fleet/audit-fleet.sqlite3] [--reports-dir .audit-fleet/reports] [--out .audit-fleet/status.json]"
allowed-tools:
  - Bash
  - Read
  - Glob
---

# Audit Fleet Status

Generate deterministic status for fan-out completion, fan-in readiness, and contract health.

## Mode Semantics

- `balanced` (default): returns status even when warnings are present.
- `strict`: fails when status is unhealthy, validation is failing, or barrier is incomplete.

## Deterministic Output

- `.audit-fleet/status.json`

## Behavior

1. Ensure report inventory snapshot is current:
   - `reports-check.py --reports-dir <reports-dir> --mode <mode> --output .audit-fleet/reports-check.json`
2. Refresh lifecycle status from SQLite:
   - `sqlite-update.py status --db <db> --mode <mode> --reports-check .audit-fleet/reports-check.json --bundle .audit-fleet/audit-bundle.json --validation .audit-fleet/validation-result.json --output .audit-fleet/status.json`
3. Status must include:
   - lane todo counts by `pending|in_progress|done|blocked`
   - specialist barrier (`01`..`13`) completion
   - consolidator (`00`) state
   - report inventory completeness
   - validation gate state
   - global `healthy` boolean

## Usage

```bash
/audit-fleet:status
/audit-fleet:status --mode strict
/audit-fleet:status --db .audit-fleet/audit-fleet.sqlite3 --reports-dir .audit-fleet/reports
```
