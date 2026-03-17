---
name: Audit Fleet Consolidation
description: This skill should be used when merging audit-fleet lane reports into a single executive output while preserving exact sections, keys, and severity terminology.
version: 0.1.0
---

# Audit Fleet Consolidation

Merge specialist reports into one coherent executive artifact without contract drift.

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


## Consolidation Process
1. Validate each lane report contains Executive Summary, Findings, Quick Wins, High-Impact Expansions.
2. Validate every finding row keeps finding_id, severity, dimension, evidence, impact, recommendation, effort, owner, dependencies, confidence, acceptance_criteria.
3. Cluster duplicate findings by shared evidence and impact.
4. Preserve strongest evidence chain while keeping original finding_id traceability.
5. Re-prioritize Quick Wins and High-Impact Expansions for final delivery sequence.

## Merge Gate
Reject any source report that breaks key names or severity enum critical | warning | info.
