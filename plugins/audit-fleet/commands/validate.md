---
name: validate
description: Run the audit-fleet validation gate for fixed reports, section contract, and finding field schema.
argument-hint: "[--mode strict|balanced] [--reports-dir .audit-fleet/reports] [--json-dir .audit-fleet/reports-json] [--bundle .audit-fleet/audit-bundle.json]"
allowed-tools:
  - Bash
  - Read
  - Glob
---

# Audit Fleet Validate

Validate markdown and JSON artifacts against the audit-fleet contract.

## Fixed Contract Checks

- Required report files are exactly `00` through `13` lane files.
- Required markdown sections in each report (ordered):
  - `Executive Summary`
  - `Findings`
  - `Quick Wins`
  - `High-Impact Expansions`
- Every finding object must contain exact keys:
  - `finding_id`, `severity`, `dimension`, `evidence`, `impact`, `recommendation`,
    `effort`, `owner`, `dependencies`, `confidence`, `acceptance_criteria`
- Allowed values:
  - `severity`: `critical|warning|info`
  - `confidence`: `high|medium|low`
  - `effort`: `S|M|L`

## Mode Semantics

- `balanced` (default): warnings are emitted but do not fail the command.
- `strict`: any warning or error fails the command.

## Deterministic Output

- `.audit-fleet/validation-result.json`

## Behavior

1. Inventory gate:
   - `reports-check.py --reports-dir <reports-dir> --mode <mode> --output .audit-fleet/reports-check.json`
2. Contract gate:
   - `schema-validate.py --reports-dir <reports-dir> --json-dir <json-dir> --bundle <bundle> --mode <mode> --output .audit-fleet/validation-result.json`
3. Fail criteria:
   - missing fixed report files
   - missing or misordered required markdown sections
   - finding keys mismatch
   - enum violations for severity/confidence/effort
   - report parity mismatch between markdown, per-report JSON, and bundle.

## Usage

```bash
/audit-fleet:validate
/audit-fleet:validate --mode strict
/audit-fleet:validate --reports-dir .audit-fleet/reports --json-dir .audit-fleet/reports-json --bundle .audit-fleet/audit-bundle.json
```
