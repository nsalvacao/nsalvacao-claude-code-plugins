---
description: Generate a structured experiment plan for an idea or MVP with stop rules, proxy metrics, and minimum sample sizes. Targets the weakest or most uncertain dimensions from a prior scorecard. Usage: /idea-auditor:tests <path>
argument-hint: "<path>"
allowed-tools: Bash, Read, Write
---

Generate an experiment plan for the idea at `<path>`.

## Steps

1. Parse `<path>` argument (directory containing `IDEA.md` and optionally `REPORTS/scorecard-*.json`).
2. Read the most recent scorecard (if available) to identify weak or null dimensions.
3. Generate 2–5 experiments targeting the weakest/most uncertain dimensions.
4. Write outputs:
   - `EXPERIMENTS/plan-YYYYMMDD.md` — human-readable plan
   - `EXPERIMENTS/plan-YYYYMMDD.json` — structured, conforming to `experiments.schema.json`

## Experiment Requirements

Each experiment must include:
- **hypothesis** — falsifiable statement
- **proxy_metric** — `{name, formula, source}`, not a vanity metric
- **design** — one of: `smoke_test`, `fake_door`, `wizard_of_oz`, `ab_test`, `jtbd_interview`, `concierge`
- **stop_rules** — pre-committed kill/iterate/proceed thresholds (set before running, never after)
- **instrumentation_events** — what to track

## Anti-patterns to avoid

- Stop rules defined after seeing results (p-hacking)
- Vanity metrics (pageviews, likes) without conversion or commitment signal
- Missing sample size estimate
