---
name: agile-risk-update
description: Add or update entries in risk register, assumption register, clarification log, or dependency log.
---

# /agile-risk-update [register-type]

## Overview

Manages the four transversal operational registers: risk register, assumption register, clarification log, and dependency log. Use this command to add new entries, update existing ones, or review the current state of any register.

These registers are maintained throughout the lifecycle and reviewed at every gate review.

## Usage

```
/agile-risk-update [register-type]
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `register-type` | Optional | One of: `risk`, `assumption`, `clarification`, `dependency`. If omitted, shows summary of all registers and prompts for register type. |

## Register Types

| Type | Description |
|------|-------------|
| `risk` | Risks with probability, impact, owner, mitigation, and status |
| `assumption` | Assumptions with owner, due date, validation method, and status |
| `clarification` | Open decisions or questions requiring resolution, with owner and target date |
| `dependency` | External dependencies with owner, blocker flag, and expected resolution |

## What It Does

1. Reads current register from `.agile-lifecycle/registers/<register-type>.json`.
2. Shows current entries (summary table).
3. Prompts for action: add new entry | update existing | close/resolve entry.
4. For new entries: uses the appropriate template (`templates/transversal/<type>-entry.md.template`).
5. Validates entry against the relevant schema:
   - `schemas/risk-register.schema.json`
   - `schemas/assumption-register.schema.json`
   - `schemas/clarification-log.schema.json`
   - `schemas/dependency-log.schema.json`
6. Saves updated register.
7. Runs `scripts/check-assumptions.sh` after assumption updates — warns on stale items.
8. Reports any high/critical risks that should be escalated.

## Examples

```
# Show all registers summary
/agile-risk-update

# Add or update risk register
/agile-risk-update risk

# Add a new assumption
/agile-risk-update assumption

# Log an open clarification
/agile-risk-update clarification

# Track a dependency
/agile-risk-update dependency
```

## Related Commands

- `/agile-status` — shows open risk/assumption counts
- `/agile-gate-review` — reviews all registers as part of gate criteria
- `/agile-change-request` — use when a resolved clarification triggers a change

## Related Agents

- `agents/transversal/risk-assumption-tracker` — manages all four registers and monitors health
