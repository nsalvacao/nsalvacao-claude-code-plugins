---
name: idea-auditor-calibrate
description: Guides a deliberate, evidence-grounded recalibration of one or more dimension scores. Produces a calibration log (calibration-log-YYYYMMDD.md) with before/after scores, the evidence that changed, and the rationale. Enforces anti-p-hacking rules — score adjustments require new evidence, not score-shopping. Use after gathering new interviews, analytics, or experiment results, never to nudge scores toward a desired outcome.
---

# idea-auditor: Calibrate

Trigger this skill when the user says "calibrate scores", "update my scores", "I have new evidence", "recalibrate after experiments", or invokes `/idea-auditor:calibrate`.

## What Calibrate Does

Calibrate is a **deliberate, logged recalibration** of one or more dimension scores after new evidence arrives. It is NOT a way to tweak scores toward a desired outcome.

Every calibration produces a `REPORTS/calibration-log-YYYYMMDD.md` that records what changed, what evidence justified it, and the before/after scorecard comparison.

## Anti-P-Hacking Rules

> These rules are non-negotiable. Calibrate will refuse to proceed if they are violated.

1. **New evidence required**: Score adjustments must be linked to a specific new evidence item (interview, experiment result, analytics data, etc.) added since the last scoring run. Adjusting a score without new evidence is forbidden.
2. **One evidence item ≠ one point change**: A single data point may shift a score by at most 0.5. Evidence that significantly changes the picture (e.g., a full experiment with 30+ data points) may justify up to 1.0 shift.
3. **No retroactive evidence**: Evidence must be dated after the last scoring run (`scored_at` in scorecard). Pre-existing evidence that was previously considered cannot justify a recalibration.
4. **Both directions**: Calibrate applies equally to downward and upward adjustments. Cherry-picking only upward adjustments is a p-hacking signal.
5. **Rationale is required**: Each changed dimension must include a written rationale citing the specific evidence item(s).

## When to Use Calibrate

| Situation | Action |
|-----------|--------|
| Completed interviews since last score | Calibrate wedge and/or trust |
| Experiment results arrived | Calibrate the targeted dimension |
| New analytics data | Calibrate friction or loop |
| Market event (funding, competitor launch) | Calibrate timing |
| Changed assumptions with no new data | **Do not calibrate** — document the assumption change in IDEA.md instead |

## Execution Steps

### Step 1 — Load current state
Read:
- Latest scorecard: `STATE/scorecard.json` (or the most recent dated file)
- Existing evidence: `STATE/evidence_*.json`
- IDEA.md for context

### Step 2 — Identify new evidence
Ask the user (or read from argument) which new evidence items justify recalibration:
- File path(s) of new evidence JSON(s) added since `scored_at`
- Or inline description: dimension, method, finding, date

If no new evidence is provided, stop and explain the anti-p-hacking rule.

### Step 3 — Validate evidence dates
Confirm that new evidence items have a `collected_at` date after the scorecard's `scored_at`. Reject items that pre-date the last scoring run.

### Step 4 — Compute adjusted scores
For each dimension with new evidence:
- State the current `score_bruto`
- State the proposed new `score_bruto` and the delta (max ±0.5 per item, max ±1.0 total per calibration)
- Confirm the rationale cites specific evidence

### Step 5 — Run updated scorecard
Invoke `scripts/calc_scorecard.py` with the adjusted `--scores` and updated evidence to produce a new `scorecard.json`.

### Step 6 — Run diff
Run `scripts/diff_scorecards.py --before STATE/scorecard_<before>.json --after STATE/scorecard.json` to surface the delta and check for regression.

### Step 7 — Write calibration log

Write `REPORTS/calibration-log-YYYYMMDD.md`:

```markdown
# Calibration Log — YYYY-MM-DD

## Evidence Added
| Item | Method | Dimension | Date |
|------|--------|-----------|------|
| <description> | <method> | <dimension> | <date> |

## Score Changes
| Dimension | Before | After | Delta | Evidence Ref |
|-----------|--------|-------|-------|--------------|
| wedge | 2.5 | 3.0 | +0.5 | interviews_20260409.json #3 |

## Decision Change
Before: ITERATE → After: ITERATE (unchanged) / PROCEED / KILL

## Rationale
### wedge (+0.5)
<Written justification citing specific evidence items>

## Anti-P-Hacking Check
- [ ] All changes linked to evidence dated after last scoring run
- [ ] No dimension adjusted without evidence
- [ ] Max shift per item respected (≤0.5 per evidence item)
- [ ] Rationale written before score confirmed
```

### Step 8 — Confirm with user
Show the calibration log summary and the diff output. Ask the user to confirm before saving the new scorecard as the canonical `STATE/scorecard.json`.

## Output Files

```
<project>/
  STATE/
    scorecard_<before_date>.json   (renamed backup of previous canonical scorecard)
    scorecard.json                 (updated canonical scorecard)
  REPORTS/
    calibration-log-YYYYMMDD.md
```

## Example

```
/idea-auditor:calibrate ./my-startup

New evidence: STATE/interviews_20260409.json (5 JTBD interviews with deposit ask)
→ wedge: 2.5 → 3.0 (+0.5) — 2/5 participants accepted deposit request (40% > 25% proceed threshold)
→ trust: unchanged — no new trust-related evidence
→ Decision: ITERATE → ITERATE (score_total: 55 → 62)

Calibration log written: REPORTS/calibration-log-20260409.md
```
