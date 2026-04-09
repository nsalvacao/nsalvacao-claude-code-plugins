---
name: idea-auditor-migrate
description: Assesses switching costs and migration feasibility for infrastructure forks, standards adoptions, and migration-heavy products. Decomposes switching costs into technical, learning, transaction, and lock-in components using the Klemperer taxonomy. Produces a migration scorecard with diff surface measurement, rollback feasibility, and migration time estimate. Active only in Infra_Fork_Standard mode.
---

# idea-auditor: Migrate

Trigger this skill when the user asks "how hard is migration", "what are the switching costs", "can users move to my product", "assess migration risk", or invokes `/idea-auditor:migrate <path>`.

## What This Skill Does

Evaluates whether potential adopters can realistically switch to this product — and whether they can leave if they need to. Migration analysis uses the Klemperer switching cost taxonomy and measures diff surface as the primary quantitative proxy.

**Mode requirement:** This skill is designed for `Infra_Fork_Standard` mode. If the idea is not an infrastructure fork, standards adoption, or migration-heavy product, note this and explain that the migration dimension is not applicable.

## When to Use

- Infrastructure forks (database engines, API gateways, message queues, auth providers)
- Standards adoption (new protocols, file formats, data schemas)
- Drop-in replacements for existing tools (CLI tools, libraries, SDKs)
- Products where the primary adoption barrier is migration effort

## Switching Cost Taxonomy (Klemperer)

| Cost Type | Definition | What to Measure |
|-----------|-----------|-----------------|
| **Technical** | Code, API, schema changes required | Diff surface (%), migration time (hours) |
| **Learning** | New concepts, documentation gaps, ramp-up | Time to independent operation (hours) |
| **Transaction** | Procurement, approval, contract renegotiation | Calendar time (weeks) |
| **Lock-in** | Proprietary formats, vendor-specific extensions | Exit path documented? Format openness? |

## Execution Steps

### Step 1 — Identify project and mode

Read `IDEA.md` or `IDEA.json`. Confirm mode is `Infra_Fork_Standard`. If mode is different, note that migration dimension is not scored but still provide context if useful.

### Step 2 — Load migration evidence

Read from the project directory:
- `IDEA.md` or `IDEA.json` — migration strategy and claims
- `STATE/migration_*.json` — migration-specific evidence (if present)
- `BLUEPRINT.md` — architecture decisions that affect migration
- Codebase — for direct diff surface measurement if accessible

### Step 3 — Invoke migration-analyst agent

Dispatch to `idea-auditor-migration-analyst` with loaded evidence. Request:
- `score_bruto` (0–5 or null)
- `score_rationale`
- `diff_surface_pct` measurement or estimate
- `migration_time_hours` estimate
- `rollback_feasible` boolean + `rollback_time_hours`
- Switching cost decomposition per Klemperer type
- Evidence gaps
- ≥1 experiment to validate migration time

### Step 4 — Produce migration report

Write `REPORTS/migration-YYYYMMDD.md` with:

```markdown
# Migration Assessment — <date>

## Decision
score_bruto: X/5
Rollback feasible: Yes/No | Rollback time: Xh

## Switching Cost Summary
| Type | Assessment | Measurement |
|------|-----------|-------------|
| Technical | low/moderate/high | diff_surface: X%, migration_time: Xh |
| Learning | ... | ramp-up: Xh |
| Transaction | ... | procurement cycle: X weeks |
| Lock-in | ... | exit path: documented/not documented |

## Diff Surface
<measurement or estimate with source>

## Rollback Path
<how a user would undo the migration>

## Evidence Gaps
<what is not yet measured>

## Recommended Experiment
<hypothesis, proxy metric, stop rules, duration>
```

### Step 5 — Return to user

Show:
- `score_bruto` and the dominant switching cost type
- Whether rollback is feasible within 1 day
- The single highest-leverage action to reduce switching cost
- The recommended experiment with stop rules

## Score Anchors

| Score | Meaning |
|-------|---------|
| 0 | Migration not documented; no rollback path; diff surface unknown |
| 1 | High diff surface (>20%); no compat layer; rollback > 1 day |
| 2 | Moderate diff surface; rollback feasible but complex; no migration guide |
| 3 | Low-moderate diff surface (<10%); rollback < 4h; migration guide exists |
| 4 | Low diff surface (<5%); compat layer available; codemod or wizard provided |
| 5 | Drop-in replacement; automated migration; rollback instant; exit path documented |

## Anti-patterns

- **Never claim "trivial migration" without measuring diff surface** — all migrations feel trivial to their authors.
- **Rollback must have a concrete path** — "theoretically reversible" is not the same as "documented, tested rollback".
- **Lock-in is binary per format** — a proprietary format with an export button is still lock-in unless the export is lossless and machine-readable.
- **This skill does not apply to non-migration products** — if mode is not `Infra_Fork_Standard`, do not score this dimension.

## Output Files

```
<project>/
  REPORTS/
    migration-YYYYMMDD.md
```

## Example

```
/idea-auditor:migrate ./my-infra-fork

→ score_bruto: 3/5
→ Diff surface: 8% of a typical integration
→ Rollback: feasible in <4h (documented path in BLUEPRINT.md)
→ Dominant cost: Technical — no codemod yet
→ Recommended experiment: Time 3 reference integrations to measure actual migration hours
  Kill threshold: >24h median → adoption will stall
  Proceed threshold: ≤8h median → migration is low-friction
```

## References

- `agents/migration-analyst.md` — specialist agent for this skill
- `references/rubric.md` — score anchors per dimension
- `schemas/scorecard.schema.json` — scorecard output contract
