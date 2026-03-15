# Gate Criteria Reference

## Overview
This document defines the criteria for each formal lifecycle gate (A through F). Each gate controls the transition between lifecycle phases. Gate reviews are conducted by the gate reviewer role, independent of the delivery team.

## Gate A — Opportunity and Hypothesis Validation

**Objective:** Confirm the opportunity is real, the hypothesis is testable, and investment in inception is justified.

**Timing:** End of Phase 1 (Opportunity and Portfolio Framing)

**Mandatory Criteria:**

| ID | Criterion | Evidence Required | Threshold |
|----|-----------|-------------------|-----------|
| A1 | Opportunity statement is clear and specific | `opportunity-statement.md` | Approved by sponsor |
| A2 | Business outcome is quantified or quantifiable | `opportunity-statement.md` | Reviewed |
| A3 | AI/technology justification documented (if AI component) | `opportunity-statement.md` or `ai-data-feasibility-note.md` | Reviewed |
| A4 | Feasibility assessed (technical, commercial, data) | `early-feasibility-note.md` | Approved |
| A5 | Initial risk note produced | `initial-risk-note.md` | Exists |
| A6 | Stakeholder map produced (sponsor, users, affected parties) | `stakeholder-map.md` | Reviewed |
| A7 | Hypothesis canvas or value hypothesis documented | `hypothesis-canvas.md` or `value-hypothesis.md` | Reviewed |
| A8 | Portfolio decision record approved by portfolio owner | `portfolio-decision-record.md` | Approved |

**Pass Threshold:** All A1–A8 criteria met or waived. A1, A4, A8 cannot be waived.

**Fail Conditions:** Missing opportunity statement, no feasibility assessment, no portfolio decision.

**Waiver Conditions:** A2 may be waived for exploratory research projects with documented rationale. A3 may be waived if no AI component. A5 and A6 may be waived for internal micro-projects.

---

## Gate B — Architecture and Planning Approval

**Objective:** Confirm the product vision, ways of working, and architecture are sound before committing to delivery.

**Timing:** End of Phase 2 (Inception and Product Framing)

**Mandatory Criteria:**

| ID | Criterion | Evidence Required | Threshold |
|----|-----------|-------------------|-----------|
| B1 | Product vision documented and approved | `product-vision.md` | Approved by product owner |
| B2 | Product goals are measurable | `product-goal-set.md` | Reviewed |
| B3 | Team working model documented (ceremonies, tools, governance) | `working-model.md` | Reviewed |
| B4 | Initial architecture decision recorded (at least 1 ADR) | `initial-architecture-pack.md` + `initial-adr.md` | Approved by tech lead |
| B5 | Initial roadmap and release plan drafted | `initial-roadmap.md` | Reviewed |
| B6 | Risk register seeded (at minimum technical and commercial risks) | risk register with ≥3 entries | Exists |
| B7 | Roles and responsibilities mapped | `role-responsibility-map.md` | Reviewed |
| B8 | Inception closure pack assembled | `inception-closure-pack.md` | Approved |

**Pass Threshold:** All B1–B8 criteria met or waived. B1, B4, B8 cannot be waived.

**Fail Conditions:** No product vision, no architecture decision, no working model.

**Waiver Conditions:** B5 may be waived to "draft" status for teams using rolling planning. B7 may be waived for solo projects with documented rationale.

---

## Gate C — Sprint Readiness Review

**Objective:** Confirm the backlog is ready, acceptance criteria are defined, and the team can begin delivery.

**Timing:** End of Phase 3 (Discovery and Backlog Readiness)

**Mandatory Criteria:**

| ID | Criterion | Evidence Required | Threshold |
|----|-----------|-------------------|-----------|
| C1 | Discovery findings documented | `discovery-findings.md` | Reviewed |
| C2 | Acceptance criteria catalog produced for P1 stories | `acceptance-criteria-catalog.md` | Approved by product owner |
| C3 | All P1 backlog items have acceptance criteria | Backlog inspection | Verified |
| C4 | Backlog readiness review completed | `backlog-readiness-review.md` | Approved |
| C5 | Definition of Done agreed for sprints | DoD document | Approved by team |
| C6 | AI backlog items created (if AI component) | `ai-backlog-items.md` | Reviewed |
| C7 | Data readiness assessment completed (if data-dependent) | `data-readiness-notes.md` | Reviewed |
| C8 | Test plan outline produced | `test-plan.md` or equivalent | Exists |

**Pass Threshold:** All C1–C8 criteria met or waived. C2, C3, C4 cannot be waived.

**Fail Conditions:** P1 stories without acceptance criteria, no backlog readiness review, no DoD.

**Waiver Conditions:** C6 and C7 may be waived if no AI or data-intensive components. C8 may be reduced to a summary for small internal projects.

---

## Gate D — Build Quality Gate

**Objective:** Confirm the built product meets quality standards and is ready for release validation.

**Timing:** End of Phase 4 (Iterative Delivery and Continuous Validation)

**Mandatory Criteria:**

| ID | Criterion | Evidence Required | Threshold |
|----|-----------|-------------------|-----------|
| D1 | All committed features built and sprint-reviewed | Sprint review records | Approved per sprint |
| D2 | No open P1 (critical) defects | `defect-log.md` | Verified |
| D3 | Code review records exist for all significant changes | `code-review-record.md` | Exists |
| D4 | Integration tests passing | `integration-test-record.md` | Approved |
| D5 | AI experiment log updated and experiments assessed (if AI) | `ai-experiment-log.md` | Reviewed |
| D6 | Model card produced (if ML model trained) | `model-card.md` | Approved |
| D7 | Red-team evidence produced (if LLM used) | Red-team report | Approved |
| D8 | Security review completed | Security review record | Reviewed |
| D9 | Technical debt log reviewed and accepted | Defect log / tech debt section | Reviewed by tech lead |

**Pass Threshold:** All D1–D9 criteria met or waived. D1, D2, D4 cannot be waived.

**Fail Conditions:** Open P1 defects, integration tests failing, no code review records.

**Waiver Conditions:** D5, D6 waived if no AI/ML component. D7 waived if no LLM. D8 may be reduced for internal tools with documented rationale.

---

## Gate E — Release Readiness Gate

**Objective:** Confirm the product is ready for production deployment and operations.

**Timing:** End of Phase 5 (Release, Rollout and Transition)

**Mandatory Criteria:**

| ID | Criterion | Evidence Required | Threshold |
|----|-----------|-------------------|-----------|
| E1 | Functional test report produced and passed | `functional-test-report.md` | Approved |
| E2 | AI validation report produced (accuracy, bias, fairness) | `ai-validation-report.md` | Approved |
| E3 | UAT report signed off by business | `uat-report.md` | Approved by business owner |
| E4 | Residual risks documented and accepted | `residual-risk-note.md` | Approved |
| E5 | Rollback plan documented and tested | `rollback-plan.md` | Tested and approved |
| E6 | Release plan approved | `release-plan.md` | Approved |
| E7 | Operations handover document produced | `operations-handover.md` | Reviewed by ops |
| E8 | Monitoring and alerting configured and verified | Infrastructure evidence | Verified |
| E9 | Traceability evidence assembled (requirements → tests → results) | `traceability-evidence.md` | Reviewed |

**Pass Threshold:** All E1–E9 criteria met or waived. E1, E3, E5, E6 cannot be waived.

**Fail Conditions:** UAT not signed off, functional tests failing, no rollback plan.

**Waiver Conditions:** E2 waived if no AI component. E4 may be simplified for low-risk internal tools. E9 may be reduced for projects with lightweight traceability needs.

---

## Gate F — Operations and Hypercare Completion

**Objective:** Confirm the product is stable in production, operations team is self-sufficient, and the lifecycle can transition to steady-state operations.

**Timing:** End of Phase 6 (initial hypercare period, typically 4–8 weeks post-launch)

**Mandatory Criteria:**

| ID | Criterion | Evidence Required | Threshold |
|----|-----------|-------------------|-----------|
| F1 | Hypercare report produced (incident summary, stability assessment) | `hypercare-report.md` | Approved |
| F2 | Service SLOs being met | SLO metrics report | Verified |
| F3 | AI monitoring report active (drift, accuracy) | `ai-monitoring-report.md` | Reviewed |
| F4 | Operations team confirmed self-sufficient | `operations-handover.md` sign-off | Approved by ops lead |
| F5 | Improvement backlog seeded from hypercare learnings | `improvement-backlog.md` | Reviewed |
| F6 | Retrospective record produced | `retrospective-record.md` | Reviewed |
| F7 | Lifecycle closure record produced | `lifecycle-closure.md` | Approved |

**Pass Threshold:** All F1–F7 criteria met or waived. F1, F2, F4, F7 cannot be waived.

**Fail Conditions:** SLOs breached, ops team not self-sufficient, no lifecycle closure record.

**Waiver Conditions:** F3 waived if no AI component. F5 may be simplified for products with no active improvement pipeline.

---

## Evidence Quality Thresholds

| Threshold | Meaning |
|-----------|---------|
| **Exists** | Artefact file is present in the project artefact directory |
| **Reviewed** | Artefact was reviewed by at least one person other than the author; review record exists |
| **Approved** | Artefact was formally approved by the designated sign-off authority; approval record exists |

Gates A and B require mostly "Reviewed" evidence. Gates D, E, F require "Approved" for critical artefacts.

---

## Waiver Process

1. Gate reviewer identifies criterion that cannot be met
2. Requestor documents: criterion ID, justification, residual risk, compensating control, proposed approver
3. Gate reviewer assesses whether waiver is acceptable
4. If acceptable: waiver entry created in waiver log; gate proceeds with waiver noted
5. If not acceptable: gate FAILS on this criterion; remediation required before next review

**Waiver limit:** More than 20% of criteria waived for a single gate indicates the phase was not ready. Gate should be FAILED and phase re-entered.

---

## Gate State Transitions

| Gate | From Phase Status | Event | To Phase Status |
|------|------------------|-------|-----------------|
| A | Phase 1 `ready_for_gate` | Gate A PASS | Phase 1 `approved`, Phase 2 entry criteria unlocked |
| A | Phase 1 `ready_for_gate` | Gate A FAIL | Phase 1 `blocked` |
| B | Phase 2 `ready_for_gate` | Gate B PASS | Phase 2 `approved`, Phase 3 unlocked |
| C | Phase 3 `ready_for_gate` | Gate C PASS | Phase 3 `approved`, Phase 4 unlocked |
| D | Phase 4 `ready_for_gate` | Gate D PASS | Phase 4 `approved`, Phase 5 unlocked |
| E | Phase 5 `ready_for_gate` | Gate E PASS | Phase 5 `approved`, Phase 6 unlocked |
| F | Phase 6 `ready_for_gate` | Gate F PASS | Phase 6 `approved`, Phase 7 or steady-state |
