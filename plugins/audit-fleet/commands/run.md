---
name: run
description: Orchestrate the full audit-fleet run with fan-out specialists, barrier sync, fan-in consolidation, and validation gates.
argument-hint: "[--mode strict|balanced] [--reports-dir .audit-fleet/reports] [--blueprint <path>] [--plan <path>] [--db .audit-fleet/audit-fleet.sqlite3]"
allowed-tools:
  - Task
  - Bash
  - Read
  - Glob
---

# Audit Fleet Run

Execute the canonical audit-fleet orchestration flow, aligned to blueprint plus implementation plan.

## Fixed Report Artifacts

The run is complete only when these report files exist in `<reports-dir>`:

- `00-executive-summary.md`
- `01-solution-auditor.md`
- `02-coherence-analyzer.md`
- `03-architect-review.md`
- `04-security-auditor.md`
- `05-test-engineer.md`
- `06-devops.md`
- `07-deployment-engineer.md`
- `08-ux-reviewer.md`
- `09-business-analyst.md`
- `10-architect-roadmap.md`
- `11-evolution-audit.md`
- `12-documentation-auditor.md`
- `13-cost-efficiency-auditor.md`

## Mode Semantics

- `balanced` (default): warnings are reported but the run can continue.
- `strict`: warnings are treated as failures at validation gates.

## Deterministic Outputs

- `<reports-dir>/00-executive-summary.md` through `<reports-dir>/13-cost-efficiency-auditor.md`
- `.audit-fleet/reports-check.json`
- `.audit-fleet/reports-json/<report-id>.json` (one per fixed report)
- `.audit-fleet/audit-bundle.json`
- `.audit-fleet/validation-result.json`
- `.audit-fleet/sqlite-contract.json`
- `.audit-fleet/status.json`

## Orchestration Flow

1. **Pre-flight and state init**
   - Normalize paths with `path-normalize.py`.
   - Initialize DB: `sqlite-init.py --db <db> --seed-fleet`.
2. **Fan-out (parallel barrier stage)**
   - Dispatch lanes `01`..`13` in parallel.
   - Each lane must audit against blueprint+plan and write exactly its fixed markdown file.
   - Update lane todos to `in_progress` then `done` via `sqlite-update.py set-status`.
3. **Barrier**
   - Run `reports-check.py` to confirm required report inventory.
   - Block fan-in until all specialist files are present and inventory checks pass.
4. **Fan-in (consolidator stage)**
   - Run lane `00-executive-summary` only after barrier pass.
   - Consolidator consumes `01`..`13`, deduplicates findings, and writes `00` report.
5. **Validation gate**
   - `schema-validate.py` validates markdown sections and JSON contracts with mode-aware strictness.
6. **JSON mirror generation**
   - `json-mirror.py` emits per-report JSON and `audit-bundle.json`.
7. **State export**
   - `sqlite-update.py export-contract --output .audit-fleet/sqlite-contract.json`.
   - `sqlite-update.py status --mode <mode> --output .audit-fleet/status.json`.

## Usage

```bash
/audit-fleet:run
/audit-fleet:run --mode strict --blueprint docs/blueprint.md --plan docs/plan.md
/audit-fleet:run --mode balanced --reports-dir .audit-fleet/reports --db .audit-fleet/audit-fleet.sqlite3
```
