---
name: idea-auditor-drill
description: Deep-dives into a single scoring dimension using the appropriate specialist agent. Produces a focused analysis with score_bruto, evidence gaps, and ≥3 targeted experiments with stop rules. Invoke when a specific dimension is weak in the scorecard or when the user asks to analyze wedge, friction, loop, timing, or trust in depth.
---

# idea-auditor: Drill

Trigger this skill when the user asks to "drill into wedge", "analyze friction", "assess timing", "deep-dive loop", "evaluate trust", or invokes `/idea-auditor:drill <dimension>`.

## What This Skill Does

Runs a focused analysis of a single dimension using its specialist agent. Unlike `/score`, which covers all dimensions, drill goes deep on one — extracting all available evidence, identifying gaps, and producing targeted experiments.

## Specialist Agent Per Dimension

| Dimension | Agent | Model | Focus |
|-----------|-------|-------|-------|
| `wedge` | `idea-auditor-wedge-researcher` | sonnet | JTBD, commitment signals, ICP |
| `friction` | `idea-auditor-friction-analyst` | haiku | TTFV, activation rate, journey map |
| `loop` | `idea-auditor-loop-designer` | haiku | K-factor, referral mechanics, OSS velocity |
| `timing` | `idea-auditor-timing-scout` | haiku | Demand slope, catalyst, competitive acceleration |
| `trust` | `idea-auditor-trust-auditor` | sonnet | Trust action rate, NIST CSF-lite, security posture |

## Execution Steps

### Step 1 — Identify dimension
Parse the dimension from the command argument: `wedge | friction | loop | timing | trust`.
If dimension is unrecognized, list valid options and stop.

### Step 2 — Load evidence
Read from the project directory:
- `IDEA.md` or `IDEA.json`
- `STATE/<dimension>_*.json` — dimension-prefixed files auto-mapped
- `STATE/interviews.json`, `STATE/analytics.json` — multi-dimensional files (filter by `"dimension"` field)
- `BLUEPRINT.md` — optional

### Step 3 — Invoke specialist agent
Dispatch to the specialist agent for the requested dimension with:
- Loaded evidence items
- IDEA.md context
- Request for score_bruto, evidence_refs, gaps, and ≥3 experiments

### Step 4 — Produce drill output

Write `REPORTS/drill-<dimension>-YYYYMMDD.md` with:

```markdown
# Drill — <dimension> — <date>

## Dimension Score
score_bruto: X/5 | score_rationale: ...

## Evidence Summary
<table: evidence items, quality tier, confidence>

## Top Signals
<bullet list>

## Evidence Gaps
<bullet list>

## Experiments (stop rules pre-committed)
### Experiment 1 — <hypothesis>
- Proxy metric: ...
- Kill threshold: ...
- Proceed threshold: ...
- Sample / duration: ...

### Experiment 2 — ...
### Experiment 3 — ...
```

### Step 5 — Return to user
Show the score_bruto, top signals, top gaps, and the 3 experiments. Tell the user which experiments to run before re-scoring.

## Anti-patterns

- **Never report score_bruto without citing evidence** — if evidence is absent, score_bruto = null.
- **Experiments must have stop rules** — "run interviews" is not an experiment. An experiment has a hypothesis, a proxy metric, and pre-committed kill/proceed thresholds.
- **Drill does not replace score** — after running experiments, use `/idea-auditor:score` to update the full scorecard.

## Output Files

```
<project>/
  REPORTS/
    drill-wedge-20260408.md
    drill-friction-20260408.md
```

## Example

```
/idea-auditor:drill wedge ./my-startup

→ score_bruto: 2/5
→ Top signal: 3 stated interviews confirming pain, no commitment-tier evidence
→ Top gap: No commitment signal (waitlist, deposit, LOI)
→ Experiment 1: Run 5 JTBD interviews with deposit ask — kill if <10% accept, proceed if >25% accept
```
