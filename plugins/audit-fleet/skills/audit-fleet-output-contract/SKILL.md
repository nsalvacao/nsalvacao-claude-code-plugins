---
name: Audit Fleet Output Contract
description: This skill should be used when an audit-fleet lane is producing or validating report format and must enforce deterministic sections plus exact finding keys.
version: 0.1.0
---

# Audit Fleet Output Contract

Use one canonical structure so lane outputs can be merged without manual rework.

## Canonical Contract Terms
All audit-fleet outputs must preserve this exact section order:
1. Executive Summary
2. Findings
3. Quick Wins
4. High-Impact Expansions

All Findings entries must include these keys exactly:
- finding_id
- severity
- dimension
- evidence
- impact
- recommendation
- effort
- owner
- dependencies
- confidence
- acceptance_criteria

Severity enum is strict: critical | warning | info.


## Findings Format
Use a markdown table with this exact column order:
| finding_id | severity | dimension | evidence | impact | recommendation | effort | owner | dependencies | confidence | acceptance_criteria |
|---|---|---|---|---|---|---|---|---|---|---|

## Validation Rules
- Do not rename keys or add aliases.
- If no material issue exists, include one info finding with clear evidence.
- Quick Wins must be actionable in one day or less.
- High-Impact Expansions must represent initiatives longer than one week.
