---
name: idea-auditor-score
description: Runs the idea-auditor scoring pipeline on an IDEA.md or IDEA.json file. Validates inputs, grades evidence from STATE/, calculates confidence-weighted dimension scores using scientific frameworks (JTBD, TAM, Rogers, Mayer), and produces a scorecard with a PROCEED/ITERATE/KILL decision, top blockers, and next tests. Invoke when the user wants to evaluate an idea, MVP, or evolving project against evidence.
---

# idea-auditor: Score

Trigger this skill when the user asks to "score my idea", "evaluate this project", "run the idea scorecard", "assess my idea", or invokes `/idea-auditor:score`.

## Interface

```
/idea-auditor:score <path> [--mode OSS_CLI|B2B_SaaS|Consumer_Viral|Infra_Fork_Standard]
```

- `<path>`: directory containing `IDEA.md` (or `IDEA.json`), optional `STATE/`, optional `BLUEPRINT.md`
- `--mode`: scoring weight profile (default: `OSS_CLI`)

## Pipeline

Invoke the `orchestrator` agent, which executes:

1. **Validate** — `scripts/validate_inputs.py --idea <path>/IDEA.md`
2. **Grade evidence** — `scripts/grade_evidence.py --evidence <path>/STATE/ --out REPORTS/evidence-<DATE>.json`
3. **Score** — `scripts/calc_scorecard.py --idea <path>/IDEA.md --evidence REPORTS/evidence-<DATE>.json --mode <MODE> --out REPORTS/scorecard-<DATE>.json`
4. **Summarize** — present scorecard to user

## Output Written to Disk

- `REPORTS/scorecard-YYYYMMDD.json` — machine-readable scorecard
- `REPORTS/evidence-YYYYMMDD.json` — graded evidence with ConfDim values

## Summary Shown to User

```
## Idea Scorecard — <IDEA name> (<DATE>)

Mode: OSS_CLI | Score: 63/100 | Confidence: 0.55 | Decision: ITERATE

### Dimensions
| Dimension | Score (0-5) | Confidence | Effective |
|-----------|------------|-----------|---------|
| wedge     | 4.0        | 0.8       | 3.2     |
| friction  | null       | 0         | —       | ← needs experiment
| ...

### Top 3 Blockers
1. No evidence of friction/TTFV — run activation test
2. Loop signal weak — no referral events tracked
3. Trust unvalidated — no commitment-tier evidence

### Next Tests
- Fake-door signup to measure wedge pull (target: >15% SR)
- Time-to-first-value measurement in onboarding (target: <10 min)
```

## Anti-Patterns

- **Never calculate scores in prose.** All numbers come from `calc_scorecard.py`.
- **Never fill null scores with guesses.** Missing evidence → `needs_experiment=true`.
- **Never skip validation.** If `validate_inputs.py` fails, stop and fix inputs first.

## References

- `agents/orchestrator.md` — full pipeline
- `schemas/scorecard.schema.json` — output contract
- `references/rubric.md` — 0–5 anchors per dimension
- `references/thresholds.yml` — weights and gates by mode
