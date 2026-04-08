---
description: Deep-dive into a single scoring dimension using its specialist agent. Invokes the appropriate dimension agent (wedge-researcher, friction-analyst, loop-designer, timing-scout, or trust-auditor), grades available evidence, and produces a focused report with score_bruto, evidence gaps, and ≥3 experiments with stop rules.
argument-hint: "<dimension> [<path>]  — dimension: wedge|friction|loop|timing|trust"
allowed-tools: Bash, Read, Write, Agent
---

Run the idea-auditor drill pipeline for the specified dimension.

1. Parse the dimension from the argument (`wedge | friction | loop | timing | trust`). If missing or unrecognized, list valid dimensions and stop.
2. Identify the project path (default: current directory). Look for `IDEA.md` or `IDEA.json`.
3. Load evidence from `STATE/<dimension>_*.json` and any multi-dimensional files with matching `"dimension"` field.
4. Invoke the appropriate specialist agent:
   - `wedge` → `idea-auditor-wedge-researcher`
   - `friction` → `idea-auditor-friction-analyst`
   - `loop` → `idea-auditor-loop-designer`
   - `timing` → `idea-auditor-timing-scout`
   - `trust` → `idea-auditor-trust-auditor`
5. Produce `REPORTS/drill-<dimension>-YYYYMMDD.md` with score_bruto, evidence summary, gaps, and experiments.
6. Show the user: score_bruto, top 2 signals, top 2 gaps, and the 3 experiments with stop rules.
