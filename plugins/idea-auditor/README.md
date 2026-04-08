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
| `ITERATE` | Score 40–69 OR confidence < 0.6 |
| `KILL` | Score < 40 |
| `INSUFFICIENT_EVIDENCE` | Any dimension has null score |

## Quick Start

1. Create `IDEA.md` in your project directory (see template in `assets/examples_min/IDEA.md`)
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
| `/idea-auditor:watch on\|off` | Toggle observation hooks *(v0.3.0)* |
| `/idea-auditor:calibrate` | Recalibrate weights with evidence *(v0.3.0)* |
| `/idea-auditor:migrate <path>` | Assess switching costs *(v0.4.0, Infra_Fork_Standard)* |

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

## Known Limitations (v0.1.0)

- **No external evidence collection** — MCP integration (GitHub stats, trends, competitors) is v0.4.0. In v0.1.0, evidence comes from local `STATE/` files only.
- **No watch mode** — Automated observation hooks are v0.3.0.
- **No drill or report commands** — Deep-dive per dimension and full reports are v0.2.0.
- **Scoring relies on human-provided score_bruto** — `calc_scorecard.py` computes deterministically but `score_bruto` (0–5, qualitative dimension assessment) must be supplied via `--scores`. Specialist agents that automate this arrive in v0.2.0.
- **Blockers and next_tests not auto-generated** — `scorecard.json` outputs `blockers: []` and `next_tests: []` in v0.1.0. The orchestrator agent derives these manually from scorecard output. Script-level population arrives in v0.2.0.
- **Calibration** — Weight/threshold recalibration is v0.3.0.

## License

MIT
