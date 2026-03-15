# Artefact Catalog

## Overview
This catalog lists all lifecycle artefacts produced by the agile-lifecycle framework. Each entry includes: artefact ID, name, owning phase, template path, applicable schema, primary owner role, and closure obligation (whether the artefact must be in evidence index at gate time).

## Catalog Format

| Field | Description |
|-------|-------------|
| `id` | Unique artefact identifier |
| `name` | Human-readable name |
| `phase` | Phase that produces this artefact |
| `template` | Path to the template file |
| `schema` | JSON schema for validation (if applicable) |
| `owner` | Primary responsible role |
| `closure_obligation` | Whether this artefact is mandatory at a gate (`gate-X` or `none`) |

---

## Phase 1 — Opportunity and Portfolio Framing

| ID | Name | Template | Schema | Owner | Closure |
|----|------|----------|--------|-------|---------|
| `opportunity-brief` | Opportunity Statement | `templates/phase-1/opportunity-statement.md.template` | — | PM / Sponsor | gate-A |
| `feasibility-note` | Early Feasibility Note | `templates/phase-1/early-feasibility-note.md.template` | — | Tech Lead / PM | gate-A |
| `hypothesis-canvas` | Value Hypothesis / Hypothesis Canvas | `templates/phase-1/value-hypothesis.md.template` | — | PM | gate-A |
| `stakeholder-map` | Stakeholder Map | `templates/phase-1/stakeholder-map.md.template` | — | PM | gate-A |
| `initial-risk-note` | Initial Risk Note | `templates/phase-1/initial-risk-note.md.template` | `risk-register` | PM / Tech Lead | gate-A |
| `ai-data-feasibility-note` | AI/Data Feasibility Note | `templates/phase-1/ai-data-feasibility-note.md.template` | — | Data/AI Lead | gate-A (if AI) |
| `funding-recommendation` | Funding Recommendation | `templates/phase-1/funding-recommendation.md.template` | — | PM / Sponsor | gate-A |
| `gate-a-pack` | Gate A Pack (assembly) | `templates/phase-1/portfolio-decision-record.md.template` | — | PM | gate-A |

---

## Phase 2 — Inception and Product Framing

| ID | Name | Template | Schema | Owner | Closure |
|----|------|----------|--------|-------|---------|
| `solution-brief` | Product Vision | `templates/phase-2/product-vision.md.template` | — | Product Owner | gate-B |
| `product-goal-set` | Product Goal Set | `templates/phase-2/product-goal-set.md.template` | — | Product Owner | gate-B |
| `working-model` | Working Model (ways of working) | `templates/phase-2/working-model.md.template` | — | PM / Team | gate-B |
| `governance-model` | Governance Model | `templates/phase-2/governance-model.md.template` | — | PM | gate-B |
| `role-responsibility-map` | Role Responsibility Map | `templates/phase-2/role-responsibility-map.md.template` | — | PM | gate-B |
| `architecture-decision` | Initial Architecture Pack + ADR | `templates/phase-2/initial-architecture-pack.md.template` | — | Tech Lead | gate-B |
| `initial-adr` | Initial Architecture Decision Record | `templates/phase-2/initial-adr.md.template` | — | Tech Lead | gate-B |
| `iteration-plan` | Initial Roadmap | `templates/phase-2/initial-roadmap.md.template` | — | PM | gate-B |
| `gate-b-pack` | Gate B Pack / Inception Closure Pack | `templates/phase-2/inception-closure-pack.md.template` | — | PM | gate-B |

---

## Phase 3 — Discovery and Backlog Readiness

| ID | Name | Template | Schema | Owner | Closure |
|----|------|----------|--------|-------|---------|
| `discovery-findings` | Discovery Findings | `templates/phase-3/discovery-findings.md.template` | — | PM / UX Lead | gate-C |
| `pain-point-map` | Pain Point Map | `templates/phase-3/pain-point-map.md.template` | — | PM / UX Lead | none |
| `user-journey-map` | User Journey Map | `templates/phase-3/user-journey-map.md.template` | — | UX Lead | none |
| `acceptance-criteria` | Acceptance Criteria Catalog | `templates/phase-3/acceptance-criteria-catalog.md.template` | `acceptance-criteria` | Product Owner | gate-C |
| `sprint-backlog` | Backlog Readiness Review | `templates/transversal/backlog-readiness-review.md.template` | `product-backlog` | Product Owner | gate-C |
| `ai-backlog-items` | AI Backlog Items | `templates/phase-3/ai-backlog-items.md.template` | — | AI Lead | gate-C (if AI) |
| `data-readiness-notes` | Data Readiness Notes | `templates/phase-3/data-readiness-notes.md.template` | — | Data Lead | gate-C (if data) |
| `readiness-notes` | Readiness Notes | `templates/phase-3/readiness-notes.md.template` | — | PM | gate-C |
| `test-plan` | Test Plan | — | — | QA Lead | gate-C |
| `dod-checklist` | Definition of Done | `templates/transversal/definition-of-done-by-phase.md.template` | `definition-of-done` | Team | gate-C |
| `gate-c-pack` | Gate C Pack | — | — | PM | gate-C |

---

## Phase 4 — Iterative Delivery and Continuous Validation

| ID | Name | Template | Schema | Owner | Closure |
|----|------|----------|--------|-------|---------|
| `feature-spec` | Feature Spec / Iteration Goal | `templates/phase-4/iteration-goal.md.template` | — | Product Owner | none |
| `iteration-plan` | Iteration Plan | `templates/phase-4/iteration-plan.md.template` | — | PM / Team | none |
| `code-review-record` | Code Review Record | `templates/phase-4/review-outcomes.md.template` | — | Tech Lead | gate-D |
| `integration-test-record` | Integration Test Record | `templates/phase-4/validation-evidence.md.template` | — | QA Lead | gate-D |
| `ai-experiment-log` | AI Experiment Log | `templates/phase-4/experiment-log.md.template` | — | AI Lead | gate-D (if AI) |
| `model-card` | Model Card | — | — | AI Lead | gate-D (if ML) |
| `dataset-doc` | Dataset Documentation | — | — | Data Lead | gate-D (if data) |
| `defect-log` | Defect Log | — | — | QA Lead | gate-D |
| `sprint-risk-note` | Sprint Risk Note | `templates/phase-4/evaluation-results.md.template` | — | PM | none |
| `gate-d-pack` | Gate D Pack | — | — | PM | gate-D |

---

## Phase 5 — Release, Rollout and Transition

| ID | Name | Template | Schema | Owner | Closure |
|----|------|----------|--------|-------|---------|
| `functional-test-report` | Functional Test Report | `templates/phase-5/release-readiness-pack.md.template` | `release-readiness` | QA Lead | gate-E |
| `ai-validation-report` | AI Validation Report | — | — | AI Lead | gate-E (if AI) |
| `uat-report` | UAT Report | — | — | Business Owner | gate-E |
| `residual-risk-note` | Residual Risk Note | — | — | PM | gate-E |
| `waiver-log` | Waiver Log | `templates/transversal/waiver-entry.md.template` | `waiver-log` | PM | gate-E |
| `traceability-evidence` | Traceability Evidence | — | — | QA Lead | gate-E |
| `release-plan` | Release Plan | `templates/phase-5/release-readiness-pack.md.template` | — | Release Manager | gate-E |
| `deployment-record` | Deployment Record | `templates/phase-5/deployment-record.md.template` | — | DevOps Lead | gate-E |
| `rollback-plan` | Rollback Plan | `templates/phase-5/rollout-log.md.template` | — | DevOps Lead | gate-E |
| `hypercare-report` | Hypercare Report | `templates/phase-5/hypercare-report.md.template` | — | PM / Ops Lead | gate-F |
| `gate-e-pack` | Gate E Pack | — | — | PM | gate-E |

---

## Phase 6 — Operate, Measure and Improve

| ID | Name | Template | Schema | Owner | Closure |
|----|------|----------|--------|-------|---------|
| `service-report` | Service Report | `templates/phase-6/service-report.md.template` | — | Ops Lead | gate-F |
| `ai-monitoring-report` | AI Monitoring Report | `templates/phase-6/ai-monitoring-report.md.template` | — | AI Ops Lead | gate-F (if AI) |
| `retrospective-record` | Retrospective Record | — | — | PM / Scrum Master | gate-F |
| `improvement-backlog` | Improvement Backlog | `templates/phase-6/improvement-backlog.md.template` | — | Product Owner | gate-F |
| `lifecycle-closure` | Lifecycle Closure Record | — | — | PM / Sponsor | gate-F |
| `operations-handover` | Operations Handover | `templates/phase-5/operational-transition-pack.md.template` | `handover-log` | Ops Lead | gate-F |
| `gate-f-pack` | Gate F Pack | — | — | PM | gate-F |

---

## Phase 7 — Retire or Replace

| ID | Name | Template | Schema | Owner | Closure |
|----|------|----------|--------|-------|---------|
| `retirement-decision` | Retirement Decision Record | `templates/phase-7/retirement-decision-record.md.template` | — | Sponsor / PM | none |
| `sunset-plan` | Sunset Plan | `templates/phase-7/sunset-plan.md.template` | — | PM | none |
| `decommissioning-record` | Decommissioning Record | `templates/phase-7/decommissioning-record.md.template` | — | Tech Lead | none |
| `final-closure-pack` | Final Closure Pack | `templates/phase-7/final-closure-pack.md.template` | — | PM / Sponsor | none |

---

## Transversal Artefacts (All Phases)

| ID | Name | Template | Schema | Owner | Closure |
|----|------|----------|--------|-------|---------|
| `risk-entry` | Risk Register Entry | `templates/transversal/risk-register-entry.md.template` | `risk-register` | PM / Team | varies |
| `assumption-entry` | Assumption Register Entry | `templates/transversal/assumption-register-entry.md.template` | `assumption-register` | PM | varies |
| `clarification-entry` | Clarification Log Entry | `templates/transversal/clarification-entry.md.template` | `clarification-log` | PM | varies |
| `gate-review-report` | Gate Review Report | `templates/transversal/gate-review-report.md.template` | `gate-review` | Gate Reviewer | varies |
| `evidence-entry` | Evidence Index Entry | `templates/transversal/evidence-index-entry.md.template` | `evidence-index` | Artefact Owner | varies |
| `handover-entry` | Handover Entry | `templates/transversal/handover-entry.md.template` | `handover-log` | PM | varies |
| `change-request` | Significant Change Record | `templates/transversal/significant-change-record.md.template` | `change-log` | PM | none |
| `waiver-entry` | Waiver Entry | `templates/transversal/waiver-entry.md.template` | `waiver-log` | Gate Reviewer | varies |
| `significant-change` | Significant Change Record | `templates/transversal/significant-change-record.md.template` | `change-log` | PM | none |
| `dod-by-phase` | DoD by Phase | `templates/transversal/definition-of-done-by-phase.md.template` | `definition-of-done` | Team | varies |
| `backlog-readiness` | Backlog Readiness Review | `templates/transversal/backlog-readiness-review.md.template` | `product-backlog` | Product Owner | gate-C |

---

## Closure Obligation Mapping

An artefact's closure obligation defines whether it must appear in the evidence index at gate review time.

| Obligation Value | Meaning |
|-----------------|---------|
| `gate-A` | Must be in evidence index (at required threshold) before Gate A review |
| `gate-B` | Must be in evidence index before Gate B review |
| `gate-C` | Must be in evidence index before Gate C review |
| `gate-D` | Must be in evidence index before Gate D review |
| `gate-E` | Must be in evidence index before Gate E review |
| `gate-F` | Must be in evidence index before Gate F review |
| `gate-X (if AI)` | Required only if project has an AI/ML component |
| `none` | Supporting artefact; no mandatory gate closure, but may be referenced by gate artefacts |
