# Artefact Catalog — waterfall-lifecycle

Full catalogue of artefacts produced across all 8 phases and the transversal operational layer.

Each row: `artefact_id | name | phase | subfase | type | template | closure_obligation | gate_evidence`

**Types**: document, register, report, plan, schema, evidence
**Closure obligations**: baselined, archived, handed_over, updated, closed
**Evidence thresholds**: E = exists, R = reviewed, A = approved

---

## Phase 1 — Opportunity and Feasibility

| artefact_id | name | phase | subfase | type | template | closure_obligation | gate_evidence |
|---|---|---|---|---|---|---|---|
| 1.1-problem-statement | Problem Statement | 1 | 1.1 | document | problem-statement.md.template | handed_over | A |
| 1.1-vision-statement | Vision Statement | 1 | 1.1 | document | vision-statement.md.template | handed_over | A |
| 1.1-stakeholder-map | Stakeholder Map | 1 | 1.1 | document | stakeholder-map.md.template | handed_over | A |
| 1.2-feasibility-assessment | Feasibility Assessment | 1 | 1.2 | document | feasibility-assessment.md.template | handed_over | A |
| 1.2-data-feasibility-note | Data Feasibility Note | 1 | 1.2 | document | data-feasibility-note.md.template | archived | A |
| 1.2-ai-feasibility-note | AI Feasibility Note | 1 | 1.2 | document | ai-feasibility-note.md.template | archived | A |
| 1.3-initial-risk-register | Initial Risk Register | 1 | 1.3 | register | initial-risk-register.md.template | handed_over | A |
| 1.3-assumption-register | Assumption Register | 1 | 1.3 | register | assumption-register-entry.md.template | handed_over | A |
| 1.3-clarification-log | Clarification Log | 1 | 1.3 | register | clarification-entry.md.template | handed_over | A |
| 1.4-project-charter | Project Charter | 1 | 1.4 | document | project-charter.md.template | baselined | A |
| 1.4-initiation-gate-pack | Initiation Gate Pack | 1 | 1.4 | report | initiation-gate-pack.md.template | archived | A |

---

## Phase 2 — Requirements and Baseline

| artefact_id | name | phase | subfase | type | template | closure_obligation | gate_evidence |
|---|---|---|---|---|---|---|---|
| 2.1-business-requirements | Business Requirements Set | 2 | 2.1 | document | business-requirements.md.template | baselined | A |
| 2.1-ai-requirements-spec | AI Requirements Specification | 2 | 2.1 | document | ai-requirements-spec.md.template | baselined | A |
| 2.2-nfr-specification | Non-Functional Requirements Specification | 2 | 2.2 | document | nfr-specification.md.template | baselined | A |
| 2.2-acceptance-criteria-catalog | Acceptance Criteria Catalog | 2 | 2.2 | document | acceptance-criteria-catalog.md.template | baselined | A |
| 2.3-requirements-traceability-matrix | Requirements Traceability Matrix | 2 | 2.3 | schema | rtm.md.template | handed_over | A |
| 2.3-glossary | Glossary | 2 | 2.3 | document | glossary.md.template | archived | R |
| 2.4-change-management-plan | Change Management Plan | 2 | 2.4 | plan | change-management-plan.md.template | baselined | A |
| 2.4-requirements-baseline-pack | Requirements Baseline Approval Pack | 2 | 2.4 | report | requirements-baseline-pack.md.template | archived | A |

---

## Phase 3 — Architecture and Solution Design

| artefact_id | name | phase | subfase | type | template | closure_obligation | gate_evidence |
|---|---|---|---|---|---|---|---|
| 3.1-hld | High-Level Design | 3 | 3.1 | document | hld.md.template | baselined | A |
| 3.1-lld | Low-Level Design | 3 | 3.1 | document | lld.md.template | baselined | A |
| 3.2-adr-set | Architecture Decision Records | 3 | 3.2 | document | adr-entry.md.template | archived | R |
| 3.2-tech-stack-decision-record | Tech Stack Decision Record | 3 | 3.2 | document | tech-stack-decision.md.template | archived | R |
| 3.3-api-contracts | API Contracts | 3 | 3.3 | schema | api-contract.md.template | baselined | A |
| 3.3-control-matrix | Control Matrix | 3 | 3.3 | document | control-matrix.md.template | baselined | A |
| 3.4-test-design-package | Test Design Package | 3 | 3.4 | plan | test-design-package.md.template | handed_over | A |
| 3.4-design-approval-pack | Design Approval Pack | 3 | 3.4 | report | design-approval-pack.md.template | archived | A |

---

## Phase 4 — Build and Integration

| artefact_id | name | phase | subfase | type | template | closure_obligation | gate_evidence |
|---|---|---|---|---|---|---|---|
| 4.1-environment-readiness-record | Environment Readiness Record | 4 | 4.1 | evidence | environment-readiness.md.template | archived | R |
| 4.1-cicd-pipeline-baseline | CI/CD Pipeline Baseline | 4 | 4.1 | document | cicd-pipeline-baseline.md.template | baselined | R |
| 4.2-build-packages | Build Packages | 4 | 4.2 | evidence | build-package-record.md.template | archived | E |
| 4.2-code-review-records | Code Review Records | 4 | 4.2 | evidence | code-review-record.md.template | archived | R |
| 4.3-integration-evidence | Integration Evidence | 4 | 4.3 | evidence | integration-evidence.md.template | archived | R |
| 4.3-model-package | Model / Integration Package | 4 | 4.3 | document | model-package.md.template | handed_over | A |
| 4.4-deployment-runbook-draft | Deployment Runbook (Draft) | 4 | 4.4 | plan | deployment-runbook.md.template | handed_over | R |
| 4.4-readiness-checklist-draft | Readiness Checklist (Draft) | 4 | 4.4 | evidence | readiness-checklist.md.template | handed_over | R |

---

## Phase 5 — Verification and Validation

| artefact_id | name | phase | subfase | type | template | closure_obligation | gate_evidence |
|---|---|---|---|---|---|---|---|
| 5.1-vv-plan | Verification and Validation Plan | 5 | 5.1 | plan | vv-plan.md.template | baselined | A |
| 5.1-test-cases | Test Cases | 5 | 5.1 | document | test-case-entry.md.template | archived | R |
| 5.2-functional-test-report | Functional Test Report | 5 | 5.2 | report | functional-test-report.md.template | archived | A |
| 5.2-nfr-test-report | NFR Test Report | 5 | 5.2 | report | nfr-test-report.md.template | archived | A |
| 5.3-ai-evaluation-report | AI Evaluation Report | 5 | 5.3 | report | ai-evaluation-report.md.template | archived | A |
| 5.3-defect-log | Defect Log | 5 | 5.3 | register | defect-log-entry.md.template | closed | A |
| 5.4-uat-report | UAT Report | 5 | 5.4 | report | uat-report.md.template | archived | A |
| 5.4-residual-risk-note | Residual Risk Note | 5 | 5.4 | document | residual-risk-note.md.template | handed_over | A |
| 5.4-vv-release-readiness-pack | Validation and Release Readiness Pack | 5 | 5.4 | report | vv-release-readiness-pack.md.template | archived | A |

---

## Phase 6 — Release and Transition to Operations

| artefact_id | name | phase | subfase | type | template | closure_obligation | gate_evidence |
|---|---|---|---|---|---|---|---|
| 6.1-release-plan | Release Plan | 6 | 6.1 | plan | release-plan.md.template | baselined | A |
| 6.1-cutover-plan | Cutover Plan | 6 | 6.1 | plan | cutover-plan.md.template | baselined | A |
| 6.1-rollback-plan | Rollback Plan | 6 | 6.1 | plan | rollback-plan.md.template | baselined | A |
| 6.2-deployment-package | Deployment Package | 6 | 6.2 | evidence | deployment-package-record.md.template | archived | E |
| 6.2-deployment-record | Deployment Record | 6 | 6.2 | evidence | deployment-record.md.template | archived | A |
| 6.3-user-documentation | User Documentation | 6 | 6.3 | document | user-documentation.md.template | handed_over | R |
| 6.3-training-materials | Training Materials | 6 | 6.3 | document | training-materials.md.template | handed_over | R |
| 6.4-operations-acceptance | Operations Acceptance | 6 | 6.4 | evidence | operations-acceptance.md.template | handed_over | A |
| 6.4-hypercare-report | Hypercare Report | 6 | 6.4 | report | hypercare-report.md.template | archived | A |
| 6.4-stabilization-closure-note | Stabilization Closure Note | 6 | 6.4 | document | stabilization-closure-note.md.template | archived | A |

---

## Phase 7 — Operate, Monitor and Improve

| artefact_id | name | phase | subfase | type | template | closure_obligation | gate_evidence |
|---|---|---|---|---|---|---|---|
| 7.1-operations-runbook | Operations Runbook | 7 | 7.1 | document | operations-runbook.md.template | baselined | R |
| 7.1-monitoring-dashboard-spec | Monitoring Dashboard Specification | 7 | 7.1 | document | monitoring-dashboard-spec.md.template | baselined | R |
| 7.2-incident-log | Incident Log | 7 | 7.2 | register | incident-log-entry.md.template | updated | E |
| 7.2-problem-records | Problem Records | 7 | 7.2 | register | problem-record.md.template | updated | E |
| 7.3-ai-monitoring-reports | AI Monitoring Reports | 7 | 7.3 | report | ai-monitoring-report.md.template | updated | R |
| 7.3-intervention-records | Intervention Records | 7 | 7.3 | evidence | intervention-record.md.template | archived | R |
| 7.4-improvement-backlog | Improvement Backlog | 7 | 7.4 | register | improvement-backlog-entry.md.template | updated | E |
| 7.4-operational-review-report | Operational Review Report | 7 | 7.4 | report | operational-review-report.md.template | archived | R |

---

## Phase 8 — Retire or Replace

| artefact_id | name | phase | subfase | type | template | closure_obligation | gate_evidence |
|---|---|---|---|---|---|---|---|
| 8.1-retirement-decision-record | Retirement Decision Record | 8 | 8.1 | document | retirement-decision-record.md.template | baselined | A |
| 8.1-impact-assessment | Impact Assessment | 8 | 8.1 | document | impact-assessment.md.template | archived | A |
| 8.2-sunset-plan | Sunset Plan | 8 | 8.2 | plan | sunset-plan.md.template | baselined | A |
| 8.2-stakeholder-notification | Stakeholder Notification | 8 | 8.2 | document | stakeholder-notification.md.template | archived | R |
| 8.3-decommission-evidence | Decommission Evidence | 8 | 8.3 | evidence | decommission-evidence.md.template | closed | A |
| 8.3-access-closure-evidence | Access Closure Evidence | 8 | 8.3 | evidence | access-closure-evidence.md.template | closed | A |
| 8.4-data-archive-disposal-record | Data Archive / Disposal Record | 8 | 8.4 | document | data-archive-disposal-record.md.template | closed | A |
| 8.4-final-retrospective | Final Retrospective | 8 | 8.4 | report | final-retrospective.md.template | archived | R |
| 8.4-final-closure-pack | Final Closure Pack | 8 | 8.4 | report | final-closure-pack.md.template | closed | A |

---

## Transversal Operational Objects

Maintained throughout the lifecycle. Updated at each phase transition; closure obligation applies at Phase 8 unless stated otherwise.

| artefact_id | name | created | maintained_through | closure_obligation | gate_evidence |
|---|---|---|---|---|---|
| tx-risk-register | Risk Register | Phase 1 | Phase 8 | closed | A |
| tx-assumption-register | Assumption Register | Phase 1 | Phase 8 | closed | R |
| tx-clarification-log | Clarification Log | Phase 1 | Phase 8 | closed | R |
| tx-dependency-log | Dependency Log | Phase 1 | Phase 8 | closed | R |
| tx-requirements-traceability-matrix | Requirements Traceability Matrix | Phase 2 | Phase 5 | handed_over | A |
| tx-change-log | Change Log | Phase 2 | Phase 8 | archived | R |
| tx-evidence-index | Evidence Index | Phase 1 | Phase 8 | archived | R |
| tx-handover-log | Handover Log | Phase 1 | Phase 8 | closed | A |
