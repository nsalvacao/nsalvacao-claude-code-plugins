---
name: Audit Fleet Evidence Policy
description: This skill should be used when findings need evidence quality control, confidence grading, and strict mapping to audit-fleet finding keys and severity enum.
version: 0.1.0
---

# Audit Fleet Evidence Policy

Ensure every finding is verifiable, traceable, and decision-ready.

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


## Evidence Standard
- evidence must include file:line plus a short quote or command output.
- impact must describe concrete consequence for delivery, security, UX, reliability, or business value.
- recommendation must define a single actionable next step.
- owner and dependencies must make execution ownership explicit.
- acceptance_criteria must define objective completion signal.

## Confidence Guidance
- high: multiple corroborating evidence points.
- medium: one strong evidence point with limited ambiguity.
- low: weak or incomplete evidence.

## Rejection Criteria
Reject any Findings row that misses required keys or uses severity outside critical | warning | info.
