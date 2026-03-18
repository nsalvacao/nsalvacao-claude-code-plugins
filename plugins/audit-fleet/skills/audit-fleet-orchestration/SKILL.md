---
name: Audit Fleet Orchestration
description: This skill should be used when the user asks to orchestrate multi-lane audit-fleet execution with deterministic report contracts, strict lane handoffs, and synchronized consolidation.
version: 0.1.0
---

# Audit Fleet Orchestration

Coordinate lane execution so every specialist report is contract-compliant before consolidation.

## Trigger Cues
Use when requests include:
- run audit fleet
- orchestrate audit lanes
- parallel audit board
- full cross-domain audit

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

## Execution Steps
1. Confirm target repository path and available project artifacts (docs, specs, roadmap/tasks, ADRs, CI config, and git history).
2. Assign one report file path per lane and dispatch lanes 01 to 13.
3. Validate each lane output against Executive Summary, Findings, Quick Wins, and High-Impact Expansions.
4. Accept lane completion only when finding_id, severity, dimension, evidence, impact, recommendation, effort, owner, dependencies, confidence, and acceptance_criteria are present.
5. Dispatch lane 00 after all required lane reports pass validation.

## Audit-Only Rule
All lanes are read-only on target source. Each lane can write only its assigned report file.
