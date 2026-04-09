---
description: Deliberately recalibrates one or more dimension scores after new evidence arrives. Enforces anti-p-hacking rules — every score adjustment must cite a specific new evidence item dated after the last scoring run. Produces a calibration log (REPORTS/calibration-log-YYYYMMDD.md) with before/after scores, evidence references, and written rationale. Use after interviews, experiments, or analytics data arrive; never to nudge scores toward a desired outcome.
argument-hint: "[<path>]  — defaults to current directory"
allowed-tools: Bash, Read, Write
---

Run the idea-auditor calibration pipeline for the given project.

1. Identify the project path (default: current directory). Read `STATE/scorecard.json` (latest) and existing evidence files.
2. Ask the user which new evidence items justify recalibration (file paths or inline description). If none provided, stop and explain the anti-p-hacking rule.
3. Validate that new evidence items are dated after the scorecard's `scored_at`. Reject pre-dated items.
4. For each dimension with new evidence, state: current score_bruto, proposed score_bruto, delta (max ±0.5 per item, ±1.0 total), and written rationale citing the evidence.
5. Run `python3 scripts/calc_scorecard.py` with adjusted `--scores` and updated evidence to produce a new scorecard.
6. Run `python3 scripts/diff_scorecards.py --before STATE/scorecard_<before>.json --after STATE/scorecard.json` to surface the delta.
7. Write `REPORTS/calibration-log-YYYYMMDD.md` with: evidence added table, score changes table, decision change, written rationale per dimension, and anti-p-hacking checklist.
8. Show the calibration log summary and diff to the user. Ask for confirmation before saving the new scorecard as the canonical `STATE/scorecard.json`.
