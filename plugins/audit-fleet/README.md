# Audit Fleet Plugin

Audit Fleet is a cross-repository audit orchestration plugin designed for onboarding and diagnosing **any project or repository**, not just this marketplace.

## Problem Statement

When inheriting an unknown repository, teams lose time on ad-hoc audits: inconsistent specialist coverage, weak evidence traceability, and unclear prioritization.

## What This Plugin Solves

Audit Fleet turns repository audits into a repeatable system:

- fan-out/fan-in orchestration with 13 specialist lanes + 1 consolidator
- deterministic report contract and file names
- SQLite todo tracking (`pending`, `in_progress`, `done`, `blocked`)
- JSON mirror outputs for downstream automation
- strict/balanced validation gate before completion

## Included Components

- Commands (5): `run`, `status`, `validate`, `summarize`, `clean`
- Agents (14): `00-executive-summary` through `13-cost-efficiency-auditor`
- Skills (5): orchestration, output contract, evidence policy, SQL todos, consolidation
- Scripts (6): path normalization, report checks, json mirror, sqlite init/update, schema validation
- Schemas (3): report, bundle, sqlite contract

## Lane to Agent Mapping

Use these agent identifiers for `--include` / `--exclude` filters during `/audit-fleet:run`:

| Lane file | Agent identifier |
|---|---|
| `00-executive-summary.md` | `solution-auditor-consolidator` |
| `01-solution-auditor.md` | `solution-auditor` |
| `02-coherence-analyzer.md` | `coherence-analyzer` |
| `03-architect-review.md` | `architect-review` |
| `04-security-auditor.md` | `security-auditor` |
| `05-test-engineer.md` | `test-engineer` |
| `06-devops.md` | `devops` |
| `07-deployment-engineer.md` | `deployment-engineer` |
| `08-ux-reviewer.md` | `ux-reviewer` |
| `09-business-analyst.md` | `business-analyst` |
| `10-architect-roadmap.md` | `architect` |
| `11-evolution-audit.md` | `explore` |
| `12-documentation-auditor.md` | `documentation-auditor` |
| `13-cost-efficiency-auditor.md` | `cost-efficiency-auditor` |

## Installation

Use the official marketplace flow:

```text
/plugin marketplace add nsalvacao/nsalvacao-claude-code-plugins
/plugin install audit-fleet@nsalvacao-claude-code-plugins
```

## Usage Examples

Run a full audit in any repository:

```text
/audit-fleet:run --repo /path/to/repo --out /path/to/repo/.dev/audit-2026-03-17 --mode balanced
/audit-fleet:run --repo D:\Projects\my-app --out D:\Projects\my-app\.dev\audit-2026-03-17 --mode strict
```

Check progress/status:

```text
/audit-fleet:status --repo /path/to/repo --out /path/to/repo/.dev/audit-2026-03-17
```

Validate outputs:

```text
/audit-fleet:validate --repo /path/to/repo --out /path/to/repo/.dev/audit-2026-03-17 --mode strict
```

Rebuild executive summary:

```text
/audit-fleet:summarize --repo /path/to/repo --out /path/to/repo/.dev/audit-2026-03-17
```

Clean generated artifacts:

```text
/audit-fleet:clean --repo /path/to/repo --out /path/to/repo/.dev/audit-2026-03-17 --all
```

## Output Behavior and Side Effects

- Writes only to the selected output directory.
- Does not modify target repository source code.
- Creates or updates `<out>/audit-fleet.sqlite3`.
- Generates deterministic markdown + JSON artifacts and status files.

Expected output tree:

```text
<out>/
  00-executive-summary.md
  01-solution-auditor.md
  02-coherence-analyzer.md
  03-architect-review.md
  04-security-auditor.md
  05-test-engineer.md
  06-devops.md
  07-deployment-engineer.md
  08-ux-reviewer.md
  09-business-analyst.md
  10-architect-roadmap.md
  11-evolution-audit.md
  12-documentation-auditor.md
  13-cost-efficiency-auditor.md
  audit-fleet.sqlite3
  reports-check.json
  validation-result.json
  status.json
  sqlite-contract.json
  audit-bundle.json
  reports-json/
    00-executive-summary.json
    ...
    13-cost-efficiency-auditor.json
```

## Known Limitations

- Quality depends on specialist report quality and available evidence.
- Strict mode intentionally fails on warnings.
- No automatic remediation is performed (audit-only behavior).

## Version Information

- Plugin version: `0.1.0`
- Output contract schema version: `1.0.0`
