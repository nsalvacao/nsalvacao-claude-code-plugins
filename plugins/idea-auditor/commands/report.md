---
description: Generates a full consolidated Markdown report from the latest scorecard and evidence JSON. Covers all dimensions, final decision, top 3 blockers with improvement paths, and next steps. Requires a scorecard to exist in REPORTS/ (run /idea-auditor:score first).
argument-hint: "<path>  — path to project directory containing REPORTS/"
allowed-tools: Bash, Read, Write
---

Run the idea-auditor report pipeline.

1. Identify the project path from the argument (default: current directory).
2. Find the most recent `REPORTS/scorecard-*.json`. If absent, tell the user to run `/idea-auditor:score` first and stop.
3. Find the most recent `REPORTS/evidence-*.json` (optional).
4. Run `build_report.py`:
   ```bash
   python3 plugins/idea-auditor/scripts/build_report.py \
     --scorecard <latest-scorecard> \
     --evidence <latest-evidence> \
     --out <path>/REPORTS/report-<DATE>.md
   ```
5. Show the user the decision, ScoreTotal, top 3 blockers, and path to the written report.
