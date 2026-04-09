# idea-auditor

> Evidence-driven scorecard engine for ideas, MVPs, and evolving projects.

## Overview

`idea-auditor` applies scientific frameworks (JTBD, TAM, ISO, Rogers, Mayer) as anchors for each scoring dimension and uses mathematical proxies as instrumentation. The goal is disciplined evidence — not narrative conviction.

**What it is:** Scorecard Engine + Evidence Grader + Experiment Generator
**What it is not:** An oracle of success or a substitute for real fieldwork (interviews, usage, sales)

### Scoring Dimensions

| Dimension | Anchors | Key Proxy |
|-----------|---------|-----------|
| **wedge** | JTBD, Customer Dev, Kano | WedgeScore (severity × frequency × urgency × commitment) |
| **friction** | TAM, ISO 9241, Fogg | TTFV (median minutes), Activation Rate |
| **loop** | Network Effects, Bass, AARRR | K-factor = invites × conversion |
| **timing** | Rogers, Bass | Slope of demand (WoW/MoM), Catalyst flag |
| **trust** | Mayer, Privacy Calculus, NIST CSF | Trust action rate, Time-to-trust |
| **migration** *(optional)* | Klemperer, Katz-Shapiro | Migration time, Diff surface |

### Decision Gates

| Gate | Condition |
|------|-----------|
| `PROCEED` | Score ≥ 70 AND confidence ≥ 0.6 |
| `ITERATE` | Score 40–69, OR score ≥ 70 with confidence < 0.6 |
| `KILL` | Score < 40 |
| `INSUFFICIENT_EVIDENCE` | Any dimension has null score |

## Quick Start

1. Create `IDEA.md` in your project directory (template: `assets/examples_min/IDEA.md` — available in v0.2.0)
2. Run the scorecard:
   ```
   /idea-auditor:score ./my-project --mode OSS_CLI
   ```
3. Read the output: decision, top 3 blockers, next tests
4. If ITERATE or INSUFFICIENT_EVIDENCE:
   ```
   /idea-auditor:tests ./my-project
   ```
5. Run the experiments, record results in `STATE/`
6. Re-score to track progress over time

## Commands

| Command | Purpose |
|---------|---------|
| `/idea-auditor:score <path> [--mode]` | Score idea, produce scorecard |
| `/idea-auditor:tests <path>` | Generate experiment plan with stop rules |
| `/idea-auditor:drill <dimension>` | Deep-dive single dimension *(v0.2.0)* |
| `/idea-auditor:report <path>` | Full consolidated report *(v0.2.0)* |
| `/idea-auditor:watch [<path>]` | Show watch mode status and recent snapshots *(v0.3.0)* |
| `/idea-auditor:calibrate` | Recalibrate weights with evidence *(v0.3.0)* |
| `/idea-auditor:migrate <path>` | Assess switching costs *(v0.4.0, Infra_Fork_Standard only)* |

## Scoring Modes

```
OSS_CLI           # CLI tools, developer libraries, open-source projects
B2B_SaaS          # B2B products with sales cycle
Consumer_Viral    # Consumer apps with referral loops
Infra_Fork_Standard  # Infrastructure forks, standards, migrations (adds migration dimension)
```

## Output Files

```
<project>/
  IDEA.md                          # Input: idea definition
  STATE/                           # Input: accumulated evidence
    wedge_interviews.json          # dimension-prefixed → auto-mapped to "wedge"
    friction_analytics.json        # dimension-prefixed → auto-mapped to "friction"
    trust_oss_metrics.json         # dimension-prefixed → auto-mapped to "trust"
    interviews.json                # multi-dimensional → each item needs `"dimension"` field
    analytics.json                 # multi-dimensional → each item needs `"dimension"` field
  REPORTS/
    scorecard-YYYYMMDD.json        # Output: scorecard
    evidence-YYYYMMDD.json         # Output: graded evidence
    report-YYYYMMDD.md             # Output: human report (v0.2.0)
  EXPERIMENTS/
    plan-YYYYMMDD.md               # Output: experiment plan
    plan-YYYYMMDD.json             # Output: structured plan
```

> **STATE file naming:** `grade_evidence.py` infers dimension from filename prefix
> (e.g. `wedge_*.json → wedge`). Multi-dimensional files (e.g. `interviews.json`) require
> a `"dimension"` field in each evidence item. Items without a resolvable dimension
> aggregate under `"unknown"` and won't feed into the weighted score.

## Installation

```text
/plugin marketplace add nsalvacao/nsalvacao-claude-code-plugins
/plugin install idea-auditor@nsalvacao-claude-code-plugins
```

## Known Limitations (v0.4.0)

- **score_bruto is qualitative** — `calc_scorecard.py` computes deterministically but `score_bruto` (0–5) must be supplied via `--scores`. Specialist agents assist with dimension assessment but `score_bruto` still requires human judgment.
- **Blockers and next_tests not script-populated** — `scorecard.json` outputs `blockers: []` and `next_tests: []`. `build_report.py` derives blockers from lowest `score_efetivo` and `needs_experiment=True`.
- **Watch mode records writes only** — `hooks/scripts/snapshot.sh` snapshots file content after Write/Edit tool calls only. Deletions, git commits, and external edits are not captured.
- **MCP server tools are mostly stubs** — `evidence-harvester` has `github_repo_stats` functional; `registry_downloads`, `trend_snapshot`, and `competitor_scan` are stubs planned for v0.5.0.
- **competitor-mapper produces no score_bruto** — It feeds wedge/friction/timing agents; it does not produce a dimension score for `calc_scorecard.py` directly.

## License

MIT
