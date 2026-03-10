# solution-audit

Continuous meta-quality audit system for solutions under development. Evaluates coherence, architecture, documentation, onboarding, and UX across 8 dimensions with prioritized, actionable findings.

## What it does

This plugin acts as a methodical, skeptical reviewer that examines your solution from multiple angles while you build it. It doesn't just check if files exist — it checks if what you've built matches what you've promised, if your architecture holds, and if your users can actually use what you've made.

## Dimensions

| # | Dimension | What it catches |
|---|-----------|----------------|
| 1 | **Product Coherence** | Ghost features, invisible features, naming drift, promise inflation |
| 2 | **Architecture Coherence** | Boundary violations, coupling, dead code, abstraction issues |
| 3 | **Documentation Quality** | Stale docs, broken links, marketing README, wrong examples |
| 4 | **Onboarding Quality** | Broken setup, missing prerequisites, high time-to-first-success |
| 5 | **CLI UX** | Bad --help, inconsistent flags, unhelpful errors, poor defaults |
| 6 | **Textual UX** | Jargon leakage, tone inconsistency, bad error messages, verbosity |
| 7 | **Learnability & Workflow** | Friction points, cognitive overload, missing feedback, no escape hatches |
| 8 | **Spec Gap Analysis** | Ghost features, invisible features, spec drift, implementation gaps |

## Commands

| Command | Purpose |
|---------|---------|
| `/audit` | Full audit across all 8 dimensions |
| `/audit-coherence` | Product + architecture coherence only |
| `/audit-docs` | Documentation quality only |
| `/audit-onboarding` | Onboarding experience only |
| `/audit-ux` | CLI UX + textual UX + learnability |
| `/audit-report` | View, compare, and trend previous audits |
| `/blueprint-review` | Parallel multi-agent blueprint/spec review with output contracts |

## Agents

| Agent | Role |
|-------|------|
| `solution-auditor` | Orchestrates full multi-dimensional audits |
| `coherence-analyzer` | Deep docs-vs-code and architecture analysis |
| `ux-reviewer` | Deep UX analysis across CLI, text, and workflow |
| `spec-reviewer` | Compares spec/blueprint documents against actual implementation |

## Scripts

| Script | Purpose |
|--------|---------|
| `check-links.sh` | Validates internal and external links in markdown files |
| `check-examples.sh` | Validates code blocks (bash, Python, JSON) in markdown files |
| `mark-stale.sh` | Marks audit dimensions as stale when files are edited (PostToolUse hook) |
| `save-progress.sh` | Saves session-end marker to WIP audit file (Stop hook) |

## Quick Start

```bash
# Run a full audit
/audit

# Focus on specific areas
/audit-ux --focus=cli
/audit-coherence --focus=product
/audit-docs --check-links --check-examples

# Review a blueprint or spec document
/blueprint-review docs/blueprint.md
/blueprint-review --all  # scan docs/, blueprints/, specs/

# View previous results
/audit-report --latest
/audit-report --trend
/audit-report --compare YYYY-MM-DD
```

## Output

Every audit produces:
- **Scorecard** — 0-100 per dimension with grades
- **Findings** — classified as Critical, Warning, or Info with file references
- **Actionable Checklist** — prioritized fixes grouped by effort
- **Baseline Comparison** — delta vs previous audit (if available)

Reports are saved to `.solution-audit-YYYY-MM-DD.json` for trend tracking.

## Session Hook

On session start, if a previous audit exists, a brief reminder shows the top 3 pending findings. Zero impact if no audit has been run.

## Scoring

Each dimension starts at 100. Findings subtract points:
- Critical: -15 points
- Warning: -7 points
- Info: -2 points

| Score | Grade | Meaning |
|-------|-------|---------|
| 90-100 | Outstanding | Production-ready quality |
| 80-89 | Good | Minor improvements needed |
| 65-79 | Needs Attention | Several areas to address |
| 50-64 | Poor | Significant work required |
| 0-49 | Critical | Fundamental issues to resolve |

## License

MIT
