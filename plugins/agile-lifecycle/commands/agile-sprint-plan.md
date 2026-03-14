---
name: agile-sprint-plan
description: Plan or review the current sprint — sprint goal, committed backlog, capacity, acceptance criteria.
---

# /agile-sprint-plan [action]

## Overview

Facilitates sprint planning or review for the current iteration within Phase 4 (Iterative Delivery). Helps define the sprint goal, select and commit backlog items, assess team capacity, and verify acceptance criteria are defined for all committed stories.

Use this command at the start of each sprint (planning) or at the end (review/health check).

## Usage

```
/agile-sprint-plan [action]
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `action` | Optional | `plan` (default) to plan a new sprint, `review` to review the current sprint health, `backlog` to assess backlog readiness |

## What It Does

**For `plan` (default):**

1. Reads current backlog from `.agile-lifecycle/artefacts/phase-4/` or prompts to load from product-backlog JSON.
2. Prompts for sprint goal — a single sentence capturing the value this sprint delivers.
3. Helps select backlog items based on priority and capacity:
   - Estimates team capacity in story points or ideal days.
   - Suggests items within capacity using priority and dependency ordering.
4. Verifies each committed item has acceptance criteria defined.
5. Generates iteration plan using `templates/phase-4/iteration-plan.md.template`.
6. Generates committed work set using `templates/phase-4/committed-work-set.md.template`.
7. Checks definition of done coverage using `scripts/check-definition-of-done.sh`.

**For `review`:**

1. Reads sprint health data from `.agile-lifecycle/metrics/`.
2. Runs `scripts/check-sprint-health.sh`.
3. Shows: velocity, commitment ratio, defects found/closed, carry-over items.
4. Flags health concerns and suggests actions.

**For `backlog`:**

1. Assesses backlog readiness (input for Gate C review).
2. Checks: items estimated, acceptance criteria present, priorities set, dependencies flagged.
3. Produces backlog readiness assessment.

## Examples

```
# Plan the next sprint
/agile-sprint-plan

# Plan explicitly
/agile-sprint-plan plan

# Review sprint health
/agile-sprint-plan review

# Check backlog readiness
/agile-sprint-plan backlog
```

## Related Commands

- `/agile-gate-review C` — uses backlog readiness assessment
- `/agile-gate-review E` — iteration review gate
- `/agile-retrospective sprint` — run after sprint review

## Related Agents

- `agents/phase-4/iteration-planning` — drives sprint planning and backlog selection
- `agents/phase-4/continuous-validation` — provides acceptance criteria guidance
