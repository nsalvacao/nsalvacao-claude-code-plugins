# Artefact Catalog

## Overview

This catalog lists all artefacts produced by the agile-lifecycle framework, organized by phase. Each entry includes the artefact type, producing subfase, owner, template path, schema path (if applicable), and gate closure obligation.

**Closure obligation** defines the gate at which an artefact must be formally closed (reviewed or approved). An artefact with a closure obligation must be present at the referenced gate at the specified evidence threshold.

---

## Phase 1 — Opportunity and Portfolio Framing

| Artefact | Type | Subfase | Owner | Template | Schema | Closure Gate | Evidence Level |
|----------|------|---------|-------|----------|--------|-------------|----------------|
| Opportunity Statement | document | 1.1 | Product Owner / Sponsor | `templates/phase-1/opportunity-statement.md.template` | — | A | reviewed |
| Value Hypothesis | document | 1.1 | Product Owner | `templates/phase-1/value-hypothesis.md.template` | — | A | reviewed |
| Stakeholder Map | document | 1.1 | PM | `templates/phase-1/stakeholder-map.md.template` | — | A | exists |
| Early Feasibility Note | document | 1.2 | Engineering Lead | `templates/phase-1/early-feasibility-note.md.template` | — | A | reviewed |
| Initial Risk Note | record | 1.2 | PM | `templates/phase-1/initial-risk-note.md.template` | `schemas/risk-register.schema.json` | A | exists |
| AI/Data Feasibility Note | document | 1.2 | Data Lead / ML Lead | `templates/phase-1/ai-data-feasibility-note.md.template` | — | A | reviewed |
| Funding Recommendation | document | 1.3 | PM / Sponsor | `templates/phase-1/funding-recommendation.md.template` | — | A | reviewed |
| Portfolio Decision Record | record | 1.3 | Governance Board | `templates/phase-1/portfolio-decision-record.md.template` | — | A | exists |

---

## Phase 2 — Inception and Product Framing

| Artefact | Type | Subfase | Owner | Template | Schema | Closure Gate | Evidence Level |
|----------|------|---------|-------|----------|--------|-------------|----------------|
| Product Vision | document | 2.1 | Product Owner | `templates/phase-2/product-vision.md.template` | — | B | reviewed |
| Product Goal Set | document | 2.1 | Product Owner | `templates/phase-2/product-goal-set.md.template` | — | B | reviewed |
| Working Model | document | 2.2 | PM | `templates/phase-2/working-model.md.template` | — | B | approved |
| Governance Model | document | 2.2 | PM / Steering | `templates/phase-2/governance-model.md.template` | — | B | approved |
| Role-Responsibility Map | document | 2.2 | PM | `templates/phase-2/role-responsibility-map.md.template` | — | B | reviewed |
| Initial Architecture Pack | document | 2.3 | Engineering Lead | `templates/phase-2/initial-architecture-pack.md.template` | — | B | reviewed |
| Initial ADR | record | 2.3 | Engineering Lead | `templates/phase-2/initial-adr.md.template` | — | B | exists |
| Initial Roadmap | document | 2.4 | PM + PO | `templates/phase-2/initial-roadmap.md.template` | — | B | reviewed |
| Inception Closure Pack | record | 2.4 | PM | `templates/phase-2/inception-closure-pack.md.template` | — | B | reviewed |

---

## Phase 3 — Discovery and Backlog Readiness

| Artefact | Type | Subfase | Owner | Template | Schema | Closure Gate | Evidence Level |
|----------|------|---------|-------|----------|--------|-------------|----------------|
| Discovery Findings | document | 3.1 | UX / PM | `templates/phase-3/discovery-findings.md.template` | — | C | reviewed |
| Pain Point Map | document | 3.1 | UX | `templates/phase-3/pain-point-map.md.template` | — | C | exists |
| User Journey Map | document | 3.1 | UX | `templates/phase-3/user-journey-map.md.template` | — | C | exists |
| Acceptance Criteria Catalog | document | 3.2 | PO | `templates/phase-3/acceptance-criteria-catalog.md.template` | — | C | reviewed |
| AI Backlog Items | record | 3.3 | ML Lead / PO | `templates/phase-3/ai-backlog-items.md.template` | — | C | reviewed |
| Data Readiness Notes | document | 3.3 | Data Lead | `templates/phase-3/data-readiness-notes.md.template` | — | C | reviewed |
| Readiness Notes | record | 3.4 | PO + Delivery Lead | `templates/phase-3/readiness-notes.md.template` | — | C | approved |

---

## Phase 4 — Iterative Delivery and Continuous Validation

| Artefact | Type | Subfase | Owner | Template | Schema | Closure Gate | Evidence Level |
|----------|------|---------|-------|----------|--------|-------------|----------------|
| Iteration Goal | record | 4.1 | PO + Team | `templates/phase-4/iteration-goal.md.template` | `schemas/sprint-contract.schema.json` | D | exists |
| Committed Work Set | record | 4.1 | Team | `templates/phase-4/committed-work-set.md.template` | `schemas/sprint-contract.schema.json` | D | exists |
| Iteration Plan | document | 4.1 | Delivery Lead | `templates/phase-4/iteration-plan.md.template` | — | D | exists |
| Experiment Log | record | 4.3 | ML Lead | `templates/phase-4/experiment-log.md.template` | — | D | reviewed |
| Evaluation Results | document | 4.3 | ML Lead | `templates/phase-4/evaluation-results.md.template` | — | D | reviewed |
| Validation Evidence | record | 4.4 | QA Lead | `templates/phase-4/validation-evidence.md.template` | — | D | approved |
| Review Outcomes | record | 4.5 | PM | `templates/phase-4/review-outcomes.md.template` | — | D | reviewed |
| Sprint Health Record | record | 4.5 | PM / Scrum Master | — | `schemas/sprint-health.schema.json` | D | exists |
| Retrospective Record | record | 4.5 | Facilitator | — | `schemas/retrospective.schema.json` | D | exists |
| Definition of Done (release) | record | 4.4 | Team | — | `schemas/definition-of-done.schema.json` | D | approved |

---

## Phase 5 — Release, Rollout and Transition

| Artefact | Type | Subfase | Owner | Template | Schema | Closure Gate | Evidence Level |
|----------|------|---------|-------|----------|--------|-------------|----------------|
| Release Readiness Pack | document | 5.1 | PM + PO | `templates/phase-5/release-readiness-pack.md.template` | — | D | reviewed |
| Deployment Record | record | 5.2 | Engineering Lead | `templates/phase-5/deployment-record.md.template` | — | E | approved |
| Rollout Log | record | 5.2 | Engineering Lead / Ops | `templates/phase-5/rollout-log.md.template` | — | E | reviewed |
| Operational Transition Pack | document | 5.3 | Ops Lead + PM | `templates/phase-5/operational-transition-pack.md.template` | — | E | approved |
| Support Acceptance | record | 5.3 | Ops Lead | `templates/phase-5/support-acceptance.md.template` | — | E | approved |
| Hypercare Report | document | 5.4 | PM + Ops Lead | `templates/phase-5/hypercare-report.md.template` | — | E | reviewed |

---

## Phase 6 — Operations, Measurement and Improvement

| Artefact | Type | Subfase | Owner | Template | Schema | Closure Gate | Evidence Level |
|----------|------|---------|-------|----------|--------|-------------|----------------|
| Service Report | report | 6.1 | Ops Lead | `templates/phase-6/service-report.md.template` | — | F | reviewed |
| Product Analytics Report | report | 6.2 | Product Lead | `templates/phase-6/product-analytics-report.md.template` | — | F | reviewed |
| AI Monitoring Report | report | 6.3 | ML Lead | `templates/phase-6/ai-monitoring-report.md.template` | — | F | reviewed |
| Improvement Backlog | record | 6.4 | PM + PO | `templates/phase-6/improvement-backlog.md.template` | — | F | reviewed |
| Change Recommendation | document | 6.4 | PM | `templates/phase-6/change-recommendation.md.template` | `schemas/change-request.schema.json` | F | exists |

---

## Phase 7 — Retire or Replace

| Artefact | Type | Subfase | Owner | Template | Schema | Closure Gate | Evidence Level |
|----------|------|---------|-------|----------|--------|-------------|----------------|
| Retirement Decision Record | record | 7.1 | Steering Committee | `templates/phase-7/retirement-decision-record.md.template` | — | F | approved |
| Impact Assessment | document | 7.1 | PM | `templates/phase-7/impact-assessment.md.template` | — | F | reviewed |
| Sunset Plan | document | 7.1 | PM + Engineering | `templates/phase-7/sunset-plan.md.template` | — | F | reviewed |
| Decommissioning Record | record | 7.2 | Engineering Lead | `templates/phase-7/decommissioning-record.md.template` | — | F | approved |
| Final Closure Pack | record | 7.2 | PM | `templates/phase-7/final-closure-pack.md.template` | — | lifecycle close | approved |

---

## Transversal Artefacts

Transversal artefacts are maintained throughout the lifecycle. They are not phase-specific but must be updated at each gate.

| Artefact | Type | Owner | Template | Schema | Gate Obligation |
|----------|------|-------|----------|--------|----------------|
| Risk Register | register | PM | `templates/transversal/risk-register-entry.md.template` | `schemas/risk-register.schema.json` | Updated and reviewed at every gate |
| Assumption Register | register | PM | `templates/transversal/assumption-register-entry.md.template` | `schemas/assumption-register.schema.json` | Updated at A, B, C; reviewed at D |
| Clarification Log | log | PM | `templates/transversal/clarification-entry.md.template` | `schemas/clarification-log.schema.json` | All critical items resolved by Gate C |
| Gate Review Reports | record | Gate Reviewer | `templates/transversal/gate-review-report.md.template` | `schemas/gate-review.schema.json` | Produced at each gate |
| Evidence Index | index | PM | `templates/transversal/evidence-index-entry.md.template` | `schemas/evidence-index.schema.json` | Updated at each gate |
| Handover Log | log | PM | `templates/transversal/handover-entry.md.template` | `schemas/handover-log.schema.json` | Produced at phase transitions |
| Waiver Log | log | Gate Reviewer | `templates/transversal/waiver-entry.md.template` | `schemas/waiver-log.schema.json` | Produced whenever waiver granted |
| Change Log | log | PM | — | `schemas/change-log.schema.json` | Maintained throughout; reviewed at D |
| Significant Change Records | record | PM | `templates/transversal/significant-change-record.md.template` | `schemas/change-request.schema.json` | Reviewed on creation |
| Artefact Manifest | manifest | PM | — | `schemas/artefact-manifest.schema.json` | Generated per phase |
| Lifecycle State | state | Lifecycle Orchestrator | — | `schemas/lifecycle-state.schema.json` | Maintained continuously |
| Definition of Done (by phase) | record | Team | `templates/transversal/definition-of-done-by-phase.md.template` | `schemas/definition-of-done.schema.json` | Approved at phase closure |
| Backlog Readiness Review | record | PO + Delivery Lead | `templates/transversal/backlog-readiness-review.md.template` | — | Required at Gate C |

---

## Closure Obligation Mapping Summary

An artefact with a closure obligation must be present at the referenced gate at the required evidence threshold. Failure to produce a mandatory artefact is a gate fail criterion.

| Gate | Mandatory Artefacts (must be at least at threshold) |
|------|---------------------------------------------------|
| A | Opportunity Statement (reviewed), Value Hypothesis (reviewed), Early Feasibility Note (reviewed), AI/Data Feasibility Note (reviewed), Funding Recommendation (reviewed) |
| B | Product Vision (reviewed), Working Model (approved), Governance Model (approved), Initial Architecture Pack (reviewed), Initial Roadmap (reviewed) |
| C | Acceptance Criteria Catalog (reviewed), Data Readiness Notes (reviewed), Readiness Notes (approved) |
| D | Validation Evidence (approved), Definition of Done release level (approved), Security Assessment (approved), Risk Register (reviewed) |
| E | Deployment Record (approved), Operational Transition Pack (approved), Support Acceptance (approved) |
| F | Service Reports (reviewed), Product Analytics Reports (reviewed), Improvement Backlog (reviewed) |
