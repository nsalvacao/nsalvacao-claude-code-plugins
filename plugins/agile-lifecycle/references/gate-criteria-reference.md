# Gate Criteria Reference

## Overview

This document is the authoritative reference for gate criteria in the agile-lifecycle framework. Gates A through F are formal governance checkpoints that authorize phase progression. A gate review is not a sprint ceremony — it is a structured assessment with defined pass/fail criteria, evidence thresholds, and waiver conditions.

---

## Table of Contents

1. [Gate A — Portfolio Entry](#gate-a--portfolio-entry)
2. [Gate B — Inception Closure](#gate-b--inception-closure)
3. [Gate C — Backlog Readiness](#gate-c--backlog-readiness)
4. [Gate D — Release Authorization](#gate-d--release-authorization)
5. [Gate E — Operations Handover](#gate-e--operations-handover)
6. [Gate F — Governance Review](#gate-f--governance-review)
7. [Artefact-to-Obligation Matrix](#artefact-to-obligation-matrix)
8. [Evidence Thresholds](#evidence-thresholds)
9. [Waiver Policy](#waiver-policy)

---

## Gate A — Portfolio Entry

**Objective:** Determine whether the opportunity is worth pursuing, whether AI is justified, and whether the project should enter the portfolio with committed funding.

**Timing:** End of Phase 1 (after subfases 1.1, 1.2, 1.3 are complete).

**Decision Authority:** Portfolio Governance Board or delegated authority (e.g. CTO, CPO).

### Input Artefacts Required

| Artefact | Evidence Threshold |
|----------|-------------------|
| Opportunity Statement | reviewed |
| Value Hypothesis | reviewed |
| Stakeholder Map | exists |
| Early Feasibility Note | reviewed |
| AI/Data Feasibility Note | reviewed |
| Initial Risk Note | exists |
| Funding Recommendation | reviewed |
| Portfolio Decision Record (draft) | exists |

### Output Artefacts Produced

| Artefact | Owner |
|----------|-------|
| Portfolio Decision Record (signed) | Governance Board |
| Gate A Review Record | Gate Reviewer |

### Pass Criteria (all must be met)

1. Opportunity Statement clearly identifies the problem, expected outcome, and AI justification.
2. Value Hypothesis articulates measurable expected value with business-agreed metrics.
3. Early Feasibility Note confirms no fundamental technical or data blockers.
4. AI/Data Feasibility Note confirms data availability and AI approach is plausible.
5. Funding Recommendation has been reviewed and endorsed by sponsor.
6. Stakeholder Map identifies all key stakeholders and their engagement status.
7. Initial risk register is populated with at least the top risks identified.
8. No open critical clarifications that would invalidate the opportunity.

### Fail Criteria (any triggers fail)

- Opportunity Statement has no quantifiable expected outcome.
- AI/Data Feasibility Note identifies a fundamental data blocker with no mitigation path.
- Funding Recommendation has not been reviewed by sponsor.
- Portfolio Decision Record is absent.
- Open critical clarifications that invalidate the core assumption of the opportunity.

### Waiver Conditions

- Early Feasibility Note: may be waived if a prior proof-of-concept already exists with documented results.
- Initial Risk Note: may be waived if risk register is embedded in the Feasibility Note.
- Waiver requires approval from Gate Decision Authority.

### State Transition

| Current State | Gate Outcome | New State |
|---------------|-------------|-----------|
| Phase 1: `ready_for_gate` | pass | Phase 1: `approved`, Phase 2: `not_started` → trigger start |
| Phase 1: `ready_for_gate` | fail | Phase 1: `rejected` → remediate and re-review |
| Phase 1: `ready_for_gate` | waived | Phase 1: `waived` → conditions documented |
| Phase 1: `ready_for_gate` | deferred | Phase 1: `ready_for_gate` → re-review by agreed date |

---

## Gate B — Inception Closure

**Objective:** Confirm the team has established vision, ways of working, initial architecture direction, and a viable roadmap before discovery spend begins.

**Timing:** End of Phase 2 (after subfases 2.1–2.4 complete).

**Decision Authority:** Product Owner and Engineering Lead (joint sign-off), with Steering Committee awareness.

### Input Artefacts Required

| Artefact | Evidence Threshold |
|----------|-------------------|
| Product Vision | reviewed |
| Product Goal Set | reviewed |
| Working Model | approved |
| Governance Model | approved |
| Role-Responsibility Map | reviewed |
| Initial Architecture Pack | reviewed |
| Initial ADR(s) | exists |
| Initial Roadmap | reviewed |
| Inception Closure Pack | reviewed |

### Output Artefacts Produced

| Artefact | Owner |
|----------|-------|
| Inception Closure Pack (signed) | PM + PO |
| Gate B Review Record | Gate Reviewer |

### Pass Criteria (all must be met)

1. Product Vision is documented and approved by product owner and sponsor.
2. Product Goal Set contains at least 3 measurable goals aligned to the value hypothesis.
3. Working Model and Governance Model are agreed by all team leads.
4. Role-Responsibility Map is complete and accepted by all named roles.
5. Initial Architecture Pack documents key architectural decisions and constraints.
6. At least one ADR has been produced covering the most critical architectural decision.
7. Initial Roadmap shows phase and release plan aligned to business goals and funding.
8. Risk register is updated with Phase 2 risks.
9. Assumption register is populated with Phase 2 assumptions, each with an owner and due date.

### Fail Criteria (any triggers fail)

- Product Vision has not been reviewed by sponsor or product owner.
- Working Model has not been agreed by team leads.
- No ADR produced for the highest-priority architectural decision.
- Roadmap is absent or has no milestone alignment to business goals.
- Risk register not updated since Phase 1.

### Waiver Conditions

- Initial ADR: may be waived if the architecture is entirely inherited from an existing system with documented evidence.
- Roadmap detail: may be reduced for MVP or prototype projects under lightweight tailoring.

### State Transition

| Current State | Gate Outcome | New State |
|---------------|-------------|-----------|
| Phase 2: `ready_for_gate` | pass | Phase 2: `approved`, Phase 3: enabled |
| Phase 2: `ready_for_gate` | fail | Phase 2: `rejected` → remediate |
| Phase 2: `ready_for_gate` | deferred | Phase 2: `ready_for_gate` |

---

## Gate C — Backlog Readiness

**Objective:** Confirm the team is ready to begin iterative delivery: backlog is shaped, acceptance criteria are defined, data and AI inputs are understood, and the environment is ready.

**Timing:** End of Phase 3 (after subfases 3.1–3.4, including Backlog Readiness Review).

**Decision Authority:** Product Owner and Delivery Lead.

### Input Artefacts Required

| Artefact | Evidence Threshold |
|----------|-------------------|
| Discovery Findings | reviewed |
| Pain Point Map | exists |
| User Journey Map | exists |
| Acceptance Criteria Catalog | reviewed |
| AI Backlog Items | reviewed |
| Data Readiness Notes | reviewed |
| Readiness Notes | approved |

### Output Artefacts Produced

| Artefact | Owner |
|----------|-------|
| Readiness Notes (signed) | PO + Delivery Lead |
| Gate C Review Record | Gate Reviewer |

### Pass Criteria (all must be met)

1. Product backlog has at least 2 sprints of ready items (acceptance criteria defined, estimated).
2. Acceptance Criteria Catalog is reviewed and approved by product owner.
3. Data Readiness Notes confirm all data sources for Phase 4 are accessible.
4. AI Backlog Items are defined with experiment hypotheses where applicable.
5. Development environment is provisioned and verified (CI/CD pipeline operational).
6. Team capacity is confirmed for Sprint 1.
7. Definition of Done is agreed at story and sprint levels.
8. All open critical clarifications from Phase 3 are resolved.

### Fail Criteria (any triggers fail)

- Fewer than one sprint of ready backlog items.
- Data Readiness Notes identifies a data blocker with no resolution path.
- Development environment not provisioned.
- Acceptance Criteria Catalog not reviewed by PO.

### Waiver Conditions

- User Journey Map: may be waived for internal tooling or data platform products.
- AI Backlog Items: may be waived if no AI features are in scope for Phase 4.

### State Transition

| Current State | Gate Outcome | New State |
|---------------|-------------|-----------|
| Phase 3: `ready_for_gate` | pass | Phase 3: `approved`, Phase 4: enabled |
| Phase 3: `ready_for_gate` | fail | Phase 3: `rejected` → remediate |
| Phase 3: `ready_for_gate` | waived | Phase 3: `waived` |

---

## Gate D — Release Authorization

**Objective:** Authorize the product for release to production. Confirm functional quality, security, performance, operational readiness, and AI safety (if applicable).

**Timing:** End of Phase 4 (after release criteria are met across all sprints).

**Decision Authority:** Steering Committee or delegated Release Authority (Product Owner + Engineering Lead + Ops Lead).

### Input Artefacts Required

| Artefact | Evidence Threshold |
|----------|-------------------|
| Validation Evidence (aggregate) | approved |
| Definition of Done (release level) | approved |
| Sprint Health Records | reviewed |
| Risk Register (current) | reviewed |
| Dependency Log (all resolved or accepted) | reviewed |
| Security Assessment | approved |
| Performance Test Results | reviewed |
| Release Readiness Pack (draft) | reviewed |
| Red-team evidence (if LLM used) | reviewed |

### Output Artefacts Produced

| Artefact | Owner |
|----------|-------|
| Release Readiness Pack (signed) | PM + PO |
| Gate D Review Record | Gate Reviewer |

### Pass Criteria (all must be met)

1. All committed release features are implemented and verified against acceptance criteria.
2. Release-level Definition of Done is complete with no unresolved exceptions.
3. Zero open critical or high defects with no accepted risk.
4. Security assessment passed or formal risk acceptance documented.
5. Performance meets SLO targets confirmed in test results.
6. All open critical risks are mitigated, accepted, or have contingency plans.
7. Operational runbook is reviewed and accepted by ops team.
8. Rollback plan documented and tested.
9. **If LLM used:** Red-team evidence exists and is reviewed; known failure modes documented.

### Fail Criteria (any triggers fail)

- Open critical defects with no accepted risk.
- Security assessment not conducted.
- Performance targets not met with no accepted deviation.
- Rollback plan absent.
- **If LLM used:** No red-team or adversarial testing evidence.

### Waiver Conditions

- Performance targets: may be waived with formal risk acceptance and a remediation plan in the next sprint.
- Minor security findings: may be waived with risk acceptance and a tracked remediation item.
- Red-team evidence: cannot be waived for public-facing LLM systems; may be waived for internal tools with limited exposure.

### State Transition

| Current State | Gate Outcome | New State |
|---------------|-------------|-----------|
| Phase 4: `ready_for_gate` | pass | Phase 4: `approved`, Phase 5: enabled |
| Phase 4: `ready_for_gate` | fail | Phase 4: `rejected` → remediate |
| Phase 4: `ready_for_gate` | deferred | Phase 4: `ready_for_gate` |

---

## Gate E — Operations Handover

**Objective:** Confirm the product has stabilized in production and operational ownership has been formally transferred from the delivery team to the operations team.

**Timing:** End of Phase 5 (after hypercare period closes).

**Decision Authority:** Operations Lead and Product Owner.

### Input Artefacts Required

| Artefact | Evidence Threshold |
|----------|-------------------|
| Deployment Record | approved |
| Rollout Log | reviewed |
| Operational Transition Pack | approved |
| Support Acceptance | approved |
| Hypercare Report | reviewed |
| SLO baseline data | exists |

### Output Artefacts Produced

| Artefact | Owner |
|----------|-------|
| Support Acceptance (signed) | Ops Lead |
| Gate E Review Record | Gate Reviewer |

### Pass Criteria (all must be met)

1. Product has been live for the agreed hypercare period with no critical production incidents unresolved.
2. Operational Transition Pack is complete: runbook, alerting, escalation paths documented.
3. Support Acceptance is formally signed by the ops team lead.
4. SLO baseline has been established and monitoring is operational.
5. All hypercare incidents are closed or have accepted mitigation.
6. Knowledge transfer to ops team is complete.

### Fail Criteria (any triggers fail)

- Unresolved critical production incident at gate review time.
- Support Acceptance not signed.
- SLO monitoring not operational.
- Runbook not reviewed by ops team.

### State Transition

| Current State | Gate Outcome | New State |
|---------------|-------------|-----------|
| Phase 5: `ready_for_gate` | pass | Phase 5: `approved`, Phase 6: enabled |
| Phase 5: `ready_for_gate` | fail | Phase 5: `rejected` → remediate |

---

## Gate F — Governance Review

**Objective:** Periodic governance checkpoint during Phase 6 to assess product health, alignment to business goals, and whether to continue, pivot, or retire.

**Timing:** Periodic during Phase 6 (recommended: every 6 months or on portfolio review cycle). Also triggered by a retirement decision initiation.

**Decision Authority:** Steering Committee or Portfolio Governance Board.

### Input Artefacts Required

| Artefact | Evidence Threshold |
|----------|-------------------|
| Service Reports (current period) | reviewed |
| Product Analytics Reports | reviewed |
| AI Monitoring Reports (if applicable) | reviewed |
| Improvement Backlog | reviewed |
| Risk Register (current) | reviewed |

### Output Artefacts Produced

| Artefact | Owner |
|----------|-------|
| Gate F Review Record | Gate Reviewer |
| Continue/Pivot/Retire Decision | Steering Committee |

### Pass Criteria (all must be met)

1. SLOs met in the reporting period (or deviations formally accepted).
2. Product analytics show continued user adoption above agreed threshold.
3. No unresolved critical risks or incidents from the reporting period.
4. Improvement backlog is being actively managed.
5. Budget and resource allocation are confirmed for the next period.

### Fail Criteria (any triggers fail)

- SLOs consistently missed without accepted deviation and remediation plan.
- Product adoption below agreed minimum threshold for two consecutive review periods.
- Critical risk open without mitigation or acceptance.

### State Transition

| Current State | Gate Outcome | New State |
|---------------|-------------|-----------|
| Phase 6: active | pass (continue) | Phase 6: continues |
| Phase 6: active | pivot decision | Phase 6: `blocked` → change request raised |
| Phase 6: active | retire decision | Phase 7: `not_started` → trigger start |

---

## Artefact-to-Obligation Matrix

This matrix maps each key artefact to its gate obligation — the gate at which it must be present and at what evidence threshold.

| Artefact | Gate A | Gate B | Gate C | Gate D | Gate E | Gate F |
|----------|--------|--------|--------|--------|--------|--------|
| Opportunity Statement | reviewed | — | — | — | — | — |
| Value Hypothesis | reviewed | — | — | — | — | — |
| Portfolio Decision Record | exists | — | — | — | — | — |
| Product Vision | — | reviewed | — | — | — | — |
| Working Model | — | approved | — | — | — | — |
| Initial Architecture Pack | — | reviewed | — | — | — | — |
| Initial Roadmap | — | reviewed | — | — | — | — |
| Discovery Findings | — | — | reviewed | — | — | — |
| Acceptance Criteria Catalog | — | — | reviewed | — | — | — |
| Data Readiness Notes | — | — | reviewed | — | — | — |
| Validation Evidence | — | — | — | approved | — | — |
| Security Assessment | — | — | — | approved | — | — |
| Release Readiness Pack | — | — | — | reviewed | — | — |
| Red-team Evidence (if LLM) | — | — | — | reviewed | — | — |
| Operational Transition Pack | — | — | — | — | approved | — |
| Support Acceptance | — | — | — | — | approved | — |
| Hypercare Report | — | — | — | — | reviewed | — |
| Service Reports | — | — | — | — | — | reviewed |
| Product Analytics Reports | — | — | — | — | — | reviewed |
| Risk Register | exists | updated | updated | reviewed | reviewed | reviewed |
| Assumption Register | updated | updated | updated | reviewed | — | — |

---

## Evidence Thresholds

Evidence thresholds define the minimum quality level required for a given artefact at a gate.

| Threshold | Meaning | Who sets it | Example |
|-----------|---------|-------------|---------|
| **exists** | The artefact has been produced in any state. Content may be incomplete. | Producer | Risk note with initial bullets |
| **reviewed** | The artefact has been read and quality-checked by at least one reviewer other than the author. Comments may exist but do not block. | Peer reviewer or PM | Opportunity Statement peer-reviewed |
| **approved** | The artefact has been formally accepted by the sign-off authority for this gate. It is complete, accurate, and endorsed. | Gate Decision Authority or named approver | Working Model approved by all team leads |

Gates escalate threshold requirements: early gates (A, B) accept `exists` for many artefacts; later gates (D, E) require `approved` for critical artefacts.

---

## Waiver Policy

### Who Can Grant Waivers

| Gate | Waiver Authority |
|------|-----------------|
| A | Portfolio Governance Board member |
| B | Product Owner + Engineering Lead (joint) |
| C | Delivery Lead |
| D | Release Authority (PO + EL + Ops Lead, joint agreement) |
| E | Operations Lead |
| F | Steering Committee |

### Waiver Conditions

1. **Documented justification:** The waiver request must state why the criterion cannot be met and why it is acceptable to proceed without it.
2. **Residual risk accepted:** The approver must explicitly accept the residual risk by recording it in the waiver log.
3. **Expiry date:** All waivers have an expiry date. If the criterion is not fulfilled before expiry, the waiver must be reviewed.
4. **Conditions:** Waivers may attach conditions — work that must be completed within an agreed timeframe.
5. **Waiver log entry required:** Every waiver is recorded in `waiver-log` with all required fields.

### Criteria That Cannot Be Waived

- Gate D: absence of security assessment for externally-facing systems.
- Gate D: red-team evidence for public-facing LLM features.
- Gate E: Support Acceptance (ops team must formally accept).
- Any gate: open critical defects or incidents without accepted risk documentation.

### Waiver Schema Reference

See `schemas/waiver-log.schema.json` for the formal waiver log data structure.
