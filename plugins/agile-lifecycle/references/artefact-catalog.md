# Artefact Catalog

## Overview

This catalog lists all artefacts produced by the agile-lifecycle framework, organized by phase. Each entry includes the artefact type, producing subfase, owner, template path, schema path (if applicable), and gate closure obligation.

**Closure obligation** defines the gate at which an artefact must be formally closed (reviewed or approved). An artefact with a closure obligation must be present at the referenced gate at the specified evidence threshold.

---

## Phase 1 — Opportunity and Portfolio Framing

| Artefact | Type | Subfase | Owner | Template | Schema | Closure Gate | Evidence Level |
|----------|------|---------|-------|----------|--------|-------------|----------------|
| Opportunity Brief | document | 1.1 | Product Owner / Sponsor | `templates/phase-1/opportunity-brief.md.template` | — | A | reviewed |
| Hypothesis Canvas | document | 1.1 | Product Owner | `templates/phase-1/hypothesis-canvas.md.template` | — | A | reviewed |
| Stakeholder Map | document | 1.1 | PM | `templates/phase-1/stakeholder-map.md.template` | — | A | exists |
| Feasibility Note | document | 1.2 | Engineering Lead | `templates/phase-1/feasibility-note.md.template` | — | A | reviewed |
| Initial Risk Register | record | 1.2 | PM | `templates/phase-1/risk-register-init.md.template` | `schemas/risk-register.schema.json` | A | exists |
| AI/Data Feasibility Note | document | 1.2 | Data Lead / ML Lead | — | — | A | reviewed |
| Funding Recommendation | document | 1.3 | PM / Sponsor | — | — | A | reviewed |
| Portfolio Decision Record | record | 1.3 | Governance Board | — | — | A | exists |

---

## Phase 2 — Inception and Product Framing

| Artefact | Type | Subfase | Owner | Template | Schema | Closure Gate | Evidence Level |
|----------|------|---------|-------|----------|--------|-------------|----------------|
| Solution Brief | document | 2.1 | Product Owner | `templates/phase-2/solution-brief.md.template` | — | B | reviewed |
| Product Goal Set | document | 2.1 | Product Owner | — | — | B | reviewed |
| Working Model | document | 2.2 | PM | — | — | B | approved |
| Governance Model | document | 2.2 | PM / Steering | — | — | B | approved |
| Role-Responsibility Map | document | 2.2 | PM | — | — | B | reviewed |
| Architecture Decision | document | 2.3 | Engineering Lead | `templates/phase-2/architecture-decision.md.template` | — | B | reviewed |
| Iteration Plan | document | 2.4 | PM + PO | `templates/phase-2/iteration-plan.md.template` | — | B | reviewed |
| Gate B Pack | record | 2.4 | PM | `templates/phase-2/gate-b-pack.md.template` | — | B | reviewed |

---

## Phase 3 — Discovery and Backlog Readiness

| Artefact | Type | Subfase | Owner | Template | Schema | Closure Gate | Evidence Level |
|----------|------|---------|-------|----------|--------|-------------|----------------|
| Discovery Findings | document | 3.1 | UX / PM | — | — | C | reviewed |
| Pain Point Map | document | 3.1 | UX | — | — | C | exists |
| User Journey Map | document | 3.1 | UX | — | — | C | exists |
| Acceptance Criteria | document | 3.2 | PO | `templates/phase-3/acceptance-criteria.md.template` | — | C | reviewed |
| Sprint Backlog | record | 3.3 | ML Lead / PO | `templates/phase-3/sprint-backlog.md.template` | — | C | reviewed |
| Data Readiness Notes | document | 3.3 | Data Lead | — | — | C | reviewed |
| Readiness Notes | record | 3.4 | PO + Delivery Lead | — | — | C | approved |

---

## Phase 4 — Iterative Delivery and Continuous Validation

| Artefact | Type | Subfase | Owner | Template | Schema | Closure Gate | Evidence Level |
|----------|------|---------|-------|----------|--------|-------------|----------------|
| Iteration Goal | record | 4.1 | PO + Team | — | `schemas/sprint-contract.schema.json` | D | exists |
| Committed Work Set | record | 4.1 | Team | — | `schemas/sprint-contract.schema.json` | D | exists |
| Iteration Plan | document | 4.1 | Delivery Lead | — | — | D | exists |
| AI Experiment Log | record | 4.3 | ML Lead | `templates/phase-4/ai-experiment-log.md.template` | — | D | reviewed |
| Evaluation Results | document | 4.3 | ML Lead | — | — | D | reviewed |
| Validation Evidence | record | 4.4 | QA Lead | — | — | D | approved |
| Review Outcomes | record | 4.5 | PM | — | — | D | reviewed |
| Sprint Health Record | record | 4.5 | PM / Scrum Master | — | `schemas/sprint-health.schema.json` | D | exists |
| Retrospective Record | record | 4.5 | Facilitator | — | `schemas/retrospective.schema.json` | D | exists |
| Definition of Done (release) | record | 4.4 | Team | — | `schemas/definition-of-done.schema.json` | D | approved |

---

## Phase 5 — Release, Rollout and Transition

| Artefact | Type | Subfase | Owner | Template | Schema | Closure Gate | Evidence Level |
|----------|------|---------|-------|----------|--------|-------------|----------------|
| Release Readiness Pack | document | 5.1 | PM + PO | — | — | D | reviewed |
| Deployment Record | record | 5.2 | Engineering Lead | `templates/phase-6/deployment-record.md.template` | — | E | approved |
| Release Plan | record | 5.2 | Engineering Lead / Ops | `templates/phase-6/release-plan.md.template` | — | E | reviewed |
| Operations Handover | document | 5.3 | Ops Lead + PM | `templates/phase-6/operations-handover.md.template` | — | E | approved |
| UAT Report | record | 5.3 | Ops Lead | `templates/phase-5/uat-report.md.template` | — | E | approved |
| Hypercare Report | document | 5.4 | PM + Ops Lead | `templates/phase-6/hypercare-report.md.template` | — | E | reviewed |

---

## Phase 6 — Operations, Measurement and Improvement

| Artefact | Type | Subfase | Owner | Template | Schema | Closure Gate | Evidence Level |
|----------|------|---------|-------|----------|--------|-------------|----------------|
| Service Report | report | 6.1 | Ops Lead | `templates/phase-7/service-report.md.template` | — | F | reviewed |
| Product Analytics Report | report | 6.2 | Product Lead | — | — | F | reviewed |
| AI Monitoring Report | report | 6.3 | ML Lead | `templates/phase-7/ai-monitoring-report.md.template` | — | F | reviewed |
| Improvement Backlog | record | 6.4 | PM + PO | `templates/phase-7/improvement-backlog.md.template` | — | F | reviewed |
| Change Recommendation | document | 6.4 | PM | — | `schemas/change-request.schema.json` | F | exists |

---

## Phase 7 — Retire or Replace

| Artefact | Type | Subfase | Owner | Template | Schema | Closure Gate | Evidence Level |
|----------|------|---------|-------|----------|--------|-------------|----------------|
| Retirement Decision Record | record | 7.1 | Steering Committee | — | — | F | approved |
| Impact Assessment | document | 7.1 | PM | — | — | F | reviewed |
| Sunset Plan | document | 7.1 | PM + Engineering | — | — | F | reviewed |
| Decommissioning Record | record | 7.2 | Engineering Lead | — | — | F | approved |
| Lifecycle Closure | record | 7.2 | PM | `templates/phase-7/lifecycle-closure.md.template` | — | lifecycle close | approved |

---

## Transversal Artefacts

Transversal artefacts are maintained throughout the lifecycle. They are not phase-specific but must be updated at each gate.

| Artefact | Type | Owner | Template | Schema | Gate Obligation |
|----------|------|-------|----------|--------|----------------|
| Risk Register | register | PM | `templates/transversal/risk-entry.md.template` | `schemas/risk-register.schema.json` | Updated and reviewed at every gate |
| Assumption Register | register | PM | `templates/transversal/assumption-entry.md.template` | `schemas/assumption-register.schema.json` | Updated at A, B, C; reviewed at D |
| Clarification Log | log | PM | `templates/transversal/clarification-entry.md.template` | `schemas/clarification-log.schema.json` | All critical items resolved by Gate C |
| Gate Review Reports | record | Gate Reviewer | `templates/transversal/gate-review-report.md.template` | `schemas/gate-review.schema.json` | Produced at each gate |
| Evidence Index | index | PM | `templates/transversal/evidence-entry.md.template` | `schemas/evidence-index.schema.json` | Updated at each gate |
| Handover Log | log | PM | `templates/transversal/handover-entry.md.template` | `schemas/handover-log.schema.json` | Produced at phase transitions |
| Waiver Log | log | Gate Reviewer | `templates/transversal/waiver-entry.md.template` | `schemas/waiver-log.schema.json` | Produced whenever waiver granted |
| Change Log | log | PM | — | `schemas/change-log.schema.json` | Maintained throughout; reviewed at D |
| Significant Change Records | record | PM | `templates/transversal/significant-change.md.template` | `schemas/change-request.schema.json` | Reviewed on creation |
| Artefact Manifest | manifest | PM | — | `schemas/artefact-manifest.schema.json` | Generated per phase |
| Lifecycle State | state | Lifecycle Orchestrator | — | `schemas/lifecycle-state.schema.json` | Maintained continuously |
| Definition of Done (by phase) | record | Team | — | `schemas/definition-of-done.schema.json` | Approved at phase closure |
| Backlog Readiness Review | record | PO + Delivery Lead | — | — | Required at Gate C |

---

## Closure Obligation Mapping Summary

An artefact with a closure obligation must be present at the referenced gate at the required evidence threshold. Failure to produce a mandatory artefact is a gate fail criterion.

| Gate | Mandatory Artefacts (must be at least at threshold) |
|------|---------------------------------------------------|
| A | Opportunity Brief (reviewed), Hypothesis Canvas (reviewed), Feasibility Note (reviewed) |
| B | Solution Brief (reviewed), Architecture Decision (reviewed), Iteration Plan (reviewed), Gate B Pack (reviewed) |
| C | Acceptance Criteria (reviewed), Readiness Notes (approved) |
| D | Definition of Done release level (approved), Security Assessment (approved), Risk Register (reviewed) |
| E | Deployment Record (approved), Operations Handover (approved), UAT Report (approved) |
| F | Service Reports (reviewed), Improvement Backlog (reviewed) |
