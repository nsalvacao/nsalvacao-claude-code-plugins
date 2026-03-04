---
name: audit
description: Run comprehensive solution audit across all quality dimensions
argument-hint: "[--dimensions=all|coherence|docs|onboarding|ux] [--severity=all|critical|warning] [--compare]"
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Skill
---

# Solution Audit — Full

Run a comprehensive multi-dimensional quality audit of the current project.

## Behavior

1. **Orient**: Read README.md, CLAUDE.md, package manifest (package.json, pyproject.toml, Cargo.toml, etc.), and any architecture docs to understand the project
2. **Baseline**: Check if `.solution-audit-latest.json` exists — if so, load it as the comparison baseline
3. **Execute dimensions**: Load and apply each audit skill in sequence:
   - `product-coherence` — docs vs implementation alignment
   - `architecture-coherence` — declared vs actual code structure
   - `documentation-quality` — doc accuracy, structure, and usefulness
   - `onboarding-quality` — setup clarity, time-to-first-success
   - `cli-ux` — CLI ergonomics and consistency (skip if no CLI)
   - `textual-ux` — user-facing text quality
   - `learnability-workflow` — learning curve and workflow friction
4. **Score**: Calculate per-dimension scores (start at 100, subtract per finding: critical -15, warning -7, info -2, min 0)
5. **Compare**: If baseline exists or --compare flag, show delta per dimension
6. **Report**: Present structured report (see Output Format below)
7. **Persist**: Save to `.solution-audit-YYYY-MM-DD.json` and update `.solution-audit-latest.json`

## Arguments

- `--dimensions`: Limit to specific dimensions (comma-separated). Default: all
- `--severity`: Filter findings by minimum severity. Default: all
- `--compare`: Force comparison with most recent previous audit

## Output Format

```
Solution Audit Report — [project-name]
Date: YYYY-MM-DD

Scorecard:
| Dimension              | Score | Grade | Critical | Warning | Info |
|------------------------|-------|-------|----------|---------|------|
| Product Coherence      | XX    | [G]   | N        | N       | N    |
| Architecture Coherence | XX    | [G]   | N        | N       | N    |
| Documentation Quality  | XX    | [G]   | N        | N       | N    |
| Onboarding Quality     | XX    | [G]   | N        | N       | N    |
| CLI UX                 | XX    | [G]   | N        | N       | N    |
| Textual UX             | XX    | [G]   | N        | N       | N    |
| Learnability & Workflow| XX    | [G]   | N        | N       | N    |
| OVERALL                | XX    | [G]   | N        | N       | N    |

Grade: 90-100 Outstanding | 80-89 Good | 65-79 Needs Attention | 50-64 Poor | 0-49 Critical

Top Findings:
[List critical and warning findings with file references and fix suggestions]

Actionable Checklist:
Quick wins (< 1h): [...]
Medium effort (1-4h): [...]
Significant work (> 4h): [...]

[If baseline comparison available:]
Delta vs previous ([date]):
| Dimension | Previous | Current | Delta |
|-----------|----------|---------|-------|
| ...       | ...      | ...     | +/-N  |
```

## Persistence

Save audit data as JSON to enable trend tracking:
- `.solution-audit-YYYY-MM-DD.json` — dated snapshot
- `.solution-audit-latest.json` — always the most recent run
- Suggest adding both patterns to `.gitignore` if not already present

## Tips

- For a quick check, use `--severity=critical` to see only blockers
- Use `--dimensions=coherence` to focus on docs-vs-code alignment
- Run `/audit-report --trend` after multiple audits to see score evolution
- If a dimension is not applicable (e.g., CLI UX for a library), score it as N/A
