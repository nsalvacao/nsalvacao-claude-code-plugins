---
name: Audit Fleet SQL Todos
description: This skill should be used when coordinating audit-fleet progress with SQL todo tracking and contract-aware completion gates across all audit lanes.
version: 0.1.0
---

# Audit Fleet SQL Todos

Track lane progress with SQL so audit runs remain resumable, dependency-aware, and contract-compliant.

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


## Trigger Cues
Use when requests mention:
- track lane status
- resume interrupted audit
- dependency-aware lane execution

## Workflow
1. Create one todo per lane plus one consolidation todo.
2. Move todo to in_progress before lane work starts.
3. Validate lane report has Executive Summary, Findings, Quick Wins, High-Impact Expansions.
4. Validate every Findings row includes finding_id, severity, dimension, evidence, impact, recommendation, effort, owner, dependencies, confidence, acceptance_criteria.
5. Mark lane done only after severity values are critical | warning | info and audit-only behavior is respected.

## Dependency Rule
Consolidation todo depends on all specialist lane todos.
