---
name: agile-retrospective
description: Facilitate a sprint or phase retrospective — what went well, what to improve, action items.
---

# /agile-retrospective [scope]

## Overview

Facilitates a structured retrospective for a sprint, phase, or iteration cycle. Guides the team through reflection on what went well, what could be improved, and captures concrete action items with owners and target dates.

Retrospective insights feed into the continuous improvement backlog and can trigger change recommendations.

## Usage

```
/agile-retrospective [scope]
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `scope` | Optional | `sprint` (default), `phase`, or `iteration`. Determines the retrospective format and timeframe. |

## What It Does

1. Prompts for retrospective scope and sprint/phase number.
2. Reads recent metrics and sprint health data to provide data-informed prompts.
3. Guides through structured retrospective format:
   - **What went well** — celebrate successes and effective practices
   - **What to improve** — identify friction, blockers, or process gaps
   - **Action items** — concrete improvements with owner and due date
   - **Experiments** — optional: propose an experiment for the next sprint
4. For `phase` scope: also reviews:
   - Gate outcomes and any waivers granted
   - Open risks that materialised
   - Artefact quality assessment
5. Records action items in the improvement backlog using `templates/phase-6/improvement-backlog.md.template`.
6. Checks if any improvement triggers a change recommendation — escalates to `/agile-change-request` if significant.
7. Updates metrics with retrospective completion marker.

## Examples

```
# Sprint retrospective (default)
/agile-retrospective

# Phase retrospective
/agile-retrospective phase

# Retrospective for a specific iteration
/agile-retrospective iteration
```

## Related Commands

- `/agile-sprint-plan` — plan next sprint using retrospective insights
- `/agile-change-request` — log significant changes identified in retrospective
- `/agile-metrics-report` — review metrics before the retrospective

## Related Agents

- `agents/phase-6/continuous-improvement` — facilitates retrospectives and captures improvement backlog
