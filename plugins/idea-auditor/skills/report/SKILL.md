---
name: idea-auditor-report
description: Generates a full consolidated report from an existing scorecard and evidence JSON. Covers all dimensions, final decision, top 3 blockers with improvement paths, and next tests. Invoke when the user asks for a full report, executive summary, or runs /idea-auditor:report.
---

# idea-auditor: Report

Trigger this skill when the user asks to "generate a full report", "give me an executive summary", "consolidated view of all dimensions", or invokes `/idea-auditor:report <path>`.

## What This Skill Does

Reads an existing scorecard JSON (from `/score`) and evidence JSON, then produces a human-readable consolidated report. Does not re-run scoring — reads the deterministic output from `calc_scorecard.py`.

## Prerequisites

A scorecard must exist in `REPORTS/scorecard-*.json` (run `/score` first if absent).

## Execution Steps

### Step 1 — Load scorecard and evidence
Read from `REPORTS/`:
- `scorecard-<latest-date>.json` — if multiple, use most recent
- `evidence-<latest-date>.json` — optional; used to enrich evidence detail

### Step 2 — Run build_report.py
```bash
python3 plugins/idea-auditor/scripts/build_report.py \
  --scorecard REPORTS/scorecard-<DATE>.json \
  --evidence REPORTS/evidence-<DATE>.json \
  --out REPORTS/report-<DATE>.md
```

### Step 3 — Interpret and supplement

From the scorecard, derive the top 3 blockers:
- Rank dimensions by `score_efetivo` (lowest first)
- For dimensions with `needs_experiment=true`, these are the priority blockers
- For each blocker: describe what evidence is missing and what improvement path looks like

### Step 4 — Produce consolidated report

`REPORTS/report-YYYYMMDD.md` structure:

```markdown
# idea-auditor Report — <idea name> — <date>

## Decision: PROCEED | ITERATE | KILL | INSUFFICIENT_EVIDENCE

**ScoreTotal:** XX/100 | **Confidence:** 0.XX

## Dimension Scores

| Dimension | score_bruto | confidence | score_efetivo | Status |
|-----------|------------|-----------|--------------|--------|
| wedge     | 3          | 0.72      | 2.16         | ✅     |
| friction  | null       | 0.0       | null         | ❌ needs evidence |
| ...       |            |           |              |        |

## Top 3 Blockers

### 1. [Dimension] — <gap description>
- **Why it matters:** <impact on score if resolved>
- **Missing evidence:** <what to collect>
- **Recommended experiment:** <specific test with stop rule>

## Next Tests
<ordered list from /tests output>

## Evidence Summary
<per-dimension evidence items with quality tier>
```

## Anti-patterns

- **Never re-compute scores in narrative** — read from scorecard JSON; scripts are the source of truth.
- **Blockers must reference the scorecard** — not derived from intuition.
- **Report does not change the decision** — it explains it.

## Output Files

```
<project>/
  REPORTS/
    report-20260408.md      ← human report (this skill)
    scorecard-20260408.json ← source of truth (from /score)
    evidence-20260408.json  ← evidence detail (from /score)
```

## Example

```
/idea-auditor:report ./my-startup

→ Decision: ITERATE (score 52/100, confidence 0.54)
→ Blocker 1: friction — TTFV unmeasured, activation rate unknown
→ Blocker 2: trust — no SECURITY.md, trust action rate not tracked
→ Blocker 3: loop — K-factor unknown, no referral mechanism
```
