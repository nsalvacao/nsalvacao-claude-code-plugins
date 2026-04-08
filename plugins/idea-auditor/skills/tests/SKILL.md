---
name: idea-auditor-tests
description: Generates a structured experiment plan for an idea or MVP with stop rules, proxy metrics, and minimum sample sizes. Uses Lean Startup, A/B testing, and JTBD interview patterns as anchors. Each experiment includes kill/iterate/proceed thresholds so decisions are pre-committed before running the test. Invoke when the user needs to validate assumptions or when a scorecard returns ITERATE or INSUFFICIENT_EVIDENCE.
---

# idea-auditor: Tests

Trigger this skill when the user runs `/idea-auditor:tests` or asks to "generate experiments", "what should I test", "design validation tests", "how do I validate this idea".

## Interface

```
/idea-auditor:tests <path>
```

- `<path>`: directory with `IDEA.md` and optional `REPORTS/scorecard-*.json` (to focus on weak dimensions)

## What to Generate

Produce 2–5 experiments targeting the weakest or most uncertain dimensions. For each experiment:

### Required Fields (every experiment)

1. **hypothesis** — falsifiable statement: "If [condition], then [metric] will be [value]"
2. **proxy_metric** — `{name, formula, source}` — measurable, not "engagement"
3. **design** — one of: `smoke_test`, `fake_door`, `wizard_of_oz`, `ab_test`, `jtbd_interview`, `concierge`
4. **stop_rules** — pre-committed decision thresholds (see below)
5. **instrumentation_events** — what to track to measure the metric

### Stop Rules (mandatory format)

Every experiment MUST include explicit thresholds before running it:

```
- Kill below: <value> — [what to do if below this]
- Iterate between: <low> and <high> — [what to do]
- Proceed above: <value> — [what to do]
```

Example:
```
- Kill below: 8% signup rate — revisit wedge / ICP
- Iterate between: 8–15% — refine framing and distribution
- Proceed above: 15% signup rate — build MVP with instrumentation
```

## Experiment Design Patterns

| Pattern | When to use | Time/cost |
|---------|------------|-----------|
| `smoke_test` | Test if demand exists at all | Low — landing page |
| `fake_door` | Test conversion before building | Low — button that leads to waitlist |
| `wizard_of_oz` | Simulate feature manually | Medium — real users, fake backend |
| `ab_test` | Compare two variants | Medium — needs traffic |
| `jtbd_interview` | Understand the job deeply | Low — 5–10 interviews |
| `concierge` | Deliver value manually to learn | Medium — white-glove |

## Output Written to Disk

`EXPERIMENTS/plan-YYYYMMDD.md` — human-readable plan
`EXPERIMENTS/plan-YYYYMMDD.json` — structured, conforming to `experiments.schema.json`

## Anti-Patterns

- **"Likes" are not stop rules.** Social approval ≠ demand signal.
- **Vanity metrics** (pageviews, follows) — use conversion, retention, or commitment signals.
- **No sample size** — always estimate minimum n for statistical validity.
- **p-hacking stop rules** — thresholds are set before the experiment, never after seeing results.

## References

- `schemas/experiments.schema.json` — output contract
- `references/experiment_playbook.md` — patterns with sample sizes and validity notes
- `references/metrics_dictionary.md` — metric definitions and pitfalls
