---
description: Assesses switching costs and migration feasibility for infrastructure forks and standards-adoption products (Infra_Fork_Standard mode). Decomposes switching costs using Klemperer taxonomy — technical, learning, transaction, lock-in — and measures diff surface as the primary quantitative proxy. Produces a migration report with rollback assessment and experiment recommendation.
argument-hint: "<path>  — path to the project directory (must contain IDEA.md or IDEA.json)"
allowed-tools: Bash, Read, Write
---

Assess migration feasibility and switching costs for the idea at `<path>`.

1. Resolve the project path. If no path is given, use the current directory. Look for `IDEA.md` or `IDEA.json`.
2. Read `IDEA.md` / `IDEA.json` and confirm the mode is `Infra_Fork_Standard`. If it is not, note that the migration dimension is not applicable to this mode, explain briefly, and stop.
3. Load migration evidence from `STATE/migration_*.json` if present.
4. Load `BLUEPRINT.md` if present — it may contain migration strategy or compatibility layer decisions.
5. Invoke `idea-auditor-migration-analyst` with all loaded evidence. Request:
   - `score_bruto` (0–5 or null if evidence insufficient)
   - `diff_surface_pct` measurement or estimate with source
   - `migration_time_hours` estimate
   - `rollback_feasible` boolean + `rollback_time_hours`
   - Switching cost decomposition (technical, learning, transaction, lock-in)
   - Evidence gaps
   - ≥1 experiment with stop rules to validate migration time
6. Write the migration report to `REPORTS/migration-<YYYYMMDD>.md` with the full assessment.
7. Show the user:
   - `score_bruto` and dominant switching cost type
   - Whether rollback is feasible within 1 day
   - The single highest-leverage action to reduce switching cost
   - Recommended experiment with kill and proceed thresholds
8. Remind the user: migration score feeds into the full scorecard via `/idea-auditor:score --mode Infra_Fork_Standard`.
