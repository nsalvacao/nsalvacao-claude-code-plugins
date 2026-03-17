---
name: run
description: Orchestrate the full audit-fleet run with specialist fan-out, barrier synchronization, consolidator fan-in, and validation gates.
argument-hint: "[--repo <path>] [--out <path>] [--mode strict|balanced] [--include <agents>] [--exclude <agents>] [--max-parallel <n>] [--allow-partial-consolidation]"
allowed-tools:
  - Task
  - Bash
  - Read
  - Glob
  - AskUserQuestion
---

# Audit Fleet Run

Execute the canonical cross-repository audit-fleet orchestration flow.

## Defaults

- `repo`: current working directory
- `out`: `<repo>/.dev/audit-YYYY-MM-DD`
- `mode`: `balanced`
- `max-parallel`: `13`
- `allow-partial-consolidation`: `false`

If `repo` or `out` are missing, run a short wizard.

## Fixed Report Artifacts

The run is complete only when these report files exist in `<out>`:

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

## Agent Identifiers for `--include` and `--exclude`

- `solution-auditor-consolidator` (lane `00`)
- `solution-auditor`
- `coherence-analyzer`
- `architect-review`
- `security-auditor`
- `test-engineer`
- `devops`
- `deployment-engineer`
- `ux-reviewer`
- `business-analyst`
- `architect` (lane `10`)
- `explore` (lane `11`)
- `documentation-auditor`
- `cost-efficiency-auditor`

## Mode Semantics

- `balanced` (default): warnings are reported but the run can continue.
- `strict`: warnings fail validation gates.

## Deterministic Outputs

- `<out>/00-executive-summary.md` through `<out>/13-cost-efficiency-auditor.md`
- `<out>/reports-check.json`
- `<out>/reports-json/<report-id>.json` (one per fixed report)
- `<out>/audit-bundle.json`
- `<out>/validation-result.json`
- `<out>/sqlite-contract.json`
- `<out>/status.json`
- `<out>/audit-fleet.sqlite3`

## Orchestration Flow

1. **Pre-flight and state init**
   - Normalize `<repo>` and `<out>` with `path-normalize.py`.
   - Initialize DB: `sqlite-init.py --db <out>/audit-fleet.sqlite3 --seed-fleet`.
2. **Fan-out (parallel specialist stage)**
   - Dispatch lanes `01` to `13` in parallel.
   - Each lane audits the target repository (`--repo`) and writes one fixed markdown report in `<out>`.
   - Update lane todos to `in_progress`, then `done` or `blocked` via `sqlite-update.py set-status`.
3. **Barrier**
   - Run `reports-check.py --reports-dir <out>`.
   - Wait for all specialists to become terminal unless `--allow-partial-consolidation` is enabled.
4. **Fan-in (consolidator stage)**
   - Run lane `00-executive-summary` only after barrier conditions are met.
   - If partial consolidation is enabled, missing specialists must be listed as `coverage_gap`.
5. **Validation gate**
   - `schema-validate.py` validates markdown sections and JSON contracts with mode-aware strictness.
6. **JSON mirror generation**
   - `json-mirror.py --reports-dir <out> --out-dir <out>` emits per-report JSON and `audit-bundle.json`.
7. **State export**
   - `sqlite-update.py export-contract --db <out>/audit-fleet.sqlite3 --output <out>/sqlite-contract.json`.
   - `sqlite-update.py status --db <out>/audit-fleet.sqlite3 --mode <mode> --output <out>/status.json`.

## Usage

```bash
/audit-fleet:run --repo . --out .dev/audit-2026-03-17 --mode balanced
/audit-fleet:run --repo /workspace/my-app --out /workspace/my-app/.dev/audit-2026-03-17 --mode strict
/audit-fleet:run --repo /workspace/legacy-repo --out /workspace/legacy-repo/.dev/audit-2026-03-17 --allow-partial-consolidation
```
