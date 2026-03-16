# Artefact Catalog — Waterfall Lifecycle

Full catalogue of all artefacts across all 8 phases and transversal layer.

## Catalogue Format

Each entry includes:
- **artefact_id** — unique identifier in format `<phase>.<seq>-<slug>`
- **name** — artefact display name
- **phase** — lifecycle phase (1–8) or `transversal`
- **subfase** — subfase within the phase
- **type** — `document` / `register` / `report` / `plan` / `schema` / `evidence`
- **template** — template filename if one exists, else `none`
- **closure_obligation** — what must be done at phase closure: `baselined` / `archived` / `handed_over` / `updated` / `closed`
- **gate_evidence** — gate that uses this as evidence (A–H) or `—`

---

## Phase 1 — Opportunity and Feasibility

| artefact_id | name | subfase | type | template | closure_obligation | gate_evidence |
|-------------|------|---------|------|----------|--------------------|---------------|
| 1.1-problem-statement | Problem Statement | 1.1 | document | problem-statement.md.template | handed_over | A |
| 1.2-vision-statement | Vision Statement | 1.1 | document | vision-statement.md.template | handed_over | A |
| 1.3-stakeholder-map | Stakeholder Map | 1.1 | document | stakeholder-map.md.template | handed_over | A |
| 1.4-initial-scope-outline | Initial Scope Outline | 1.1 | document | none | handed_over | A |
| 1.5-feasibility-assessment | Feasibility Assessment | 1.2 | document | feasibility-assessment.md.template | handed_over | A |
| 1.6-initial-solution-options | Initial Solution Options | 1.2 | document | none | archived | A |
| 1.7-data-feasibility-note | Data Feasibility Note | 1.2 | document | data-feasibility-note.md.template | archived | A |
| 1.8-ai-feasibility-note | AI Feasibility Note | 1.2 | document | ai-feasibility-note.md.template | archived | A |
| 1.9-dependency-supplier-note | Dependency and Supplier Note | 1.2 | document | none | archived | A |
| 1.10-rough-order-estimate | Rough-Order Estimate | 1.2 | document | none | archived | A |
| 1.11-initial-risk-register | Initial Risk Register | 1.3 | register | initial-risk-register.md.template | handed_over | A |
| 1.12-compliance-screening-memo | Compliance Screening Memo | 1.3 | document | none | archived | A |
| 1.13-privacy-impact-trigger-note | Privacy Impact Trigger Note | 1.3 | document | none | archived | A |
| 1.14-ai-governance-trigger-note | AI Governance Trigger Note | 1.3 | document | none | archived | A |
| 1.15-preliminary-control-needs | Preliminary Control Needs | 1.3 | document | none | archived | A |
| 1.16-assumption-register-initial | Assumption Register (Initial) | 1.3 | register | assumption-register-entry.md.template | handed_over | A |
| 1.17-clarification-log | Clarification / Open Decision Log | 1.3 | register | clarification-entry.md.template | handed_over | A |
| 1.18-project-charter | Project Charter | 1.4 | document | project-charter.md.template | baselined | A |
| 1.19-initial-plan-milestone-map | Initial Plan and Milestone Map | 1.4 | plan | none | handed_over | A |
| 1.20-governance-model | Governance Model | 1.4 | document | none | handed_over | A |
| 1.21-reporting-model | Reporting Model | 1.4 | document | none | handed_over | A |
| 1.22-initiation-gate-pack | Initiation Gate Pack | 1.4 | document | initiation-gate-pack.md.template | archived | A |

---

## Phase 2 — Requirements and Baseline

| artefact_id | name | subfase | type | template | closure_obligation | gate_evidence |
|-------------|------|---------|------|----------|--------------------|---------------|
| 2.1-business-requirements-set | Business Requirements Set | 2.1 | document | none | baselined | B |
| 2.2-use-cases-user-journeys | Use Cases / User Journeys | 2.1 | document | none | baselined | B |
| 2.3-business-rules-log | Business Rules Log | 2.1 | register | none | baselined | B |
| 2.4-scope-boundaries | Scope Boundaries | 2.1 | document | none | baselined | B |
| 2.5-data-requirements-specification | Data Requirements Specification | 2.2 | document | none | baselined | B |
| 2.6-ai-requirements-specification | AI Requirements Specification | 2.2 | document | none | baselined | B |
| 2.7-ai-acceptance-criteria | AI Acceptance Criteria | 2.2 | document | none | baselined | B |
| 2.8-control-requirements-ai | Control Requirements for AI Behavior | 2.2 | document | none | baselined | B |
| 2.9-nfr-specification | NFR Specification | 2.3 | document | none | baselined | B |
| 2.10-security-requirements-set | Security Requirements Set | 2.3 | document | none | baselined | B |
| 2.11-operational-requirements-set | Operational Requirements Set | 2.3 | document | none | baselined | B |
| 2.12-observability-requirements-set | Observability Requirements Set | 2.3 | document | none | baselined | B |
| 2.13-requirements-baseline | SRS / Requirements Baseline | 2.4 | document | none | baselined | B |
| 2.14-requirements-traceability-matrix | Requirements Traceability Matrix | 2.4 | schema | none | baselined | B |
| 2.15-acceptance-criteria-catalog | Acceptance Criteria Catalog | 2.4 | document | none | baselined | B |
| 2.16-glossary | Glossary | 2.4 | document | none | baselined | B |
| 2.17-requirements-baseline-approval-pack | Requirements Baseline Approval Pack | 2.4 | document | none | archived | B |
| 2.18-assumption-register-updated | Assumption Register (Updated) | 2.4 | register | assumption-register-entry.md.template | handed_over | B |
| 2.19-clarification-log-updated | Clarification / Open Decision Log (Updated) | 2.4 | register | clarification-entry.md.template | handed_over | B |

---

## Phase 3 — Architecture and Solution Design

| artefact_id | name | subfase | type | template | closure_obligation | gate_evidence |
|-------------|------|---------|------|----------|--------------------|---------------|
| 3.1-hld | High-Level Design (HLD) | 3.1 | document | none | baselined | C |
| 3.2-context-integration-diagrams | Context and Integration Diagrams | 3.1 | document | none | baselined | C |
| 3.3-environment-strategy | Environment Strategy | 3.1 | document | none | baselined | C |
| 3.4-security-architecture-decisions | Security Architecture Decisions | 3.1 | document | none | baselined | C |
| 3.5-adr-set | Architecture Decision Records (ADR Set) | 3.1 | register | none | baselined | C |
| 3.6-lld | Low-Level Design (LLD) | 3.2 | document | none | baselined | C |
| 3.7-interface-specifications | Interface Specifications | 3.2 | document | none | baselined | C |
| 3.8-data-flow-design | Data Flow Design | 3.2 | document | none | baselined | C |
| 3.9-ai-ml-design-package | AI/ML Design Package | 3.2 | document | none | baselined | C |
| 3.10-test-design-package | Test Design Package | 3.2 | plan | none | baselined | C |
| 3.11-operational-design-package | Operational Design Package | 3.2 | document | none | baselined | C |
| 3.12-control-matrix | Control Matrix | 3.3 | schema | none | baselined | C |
| 3.13-security-design-review | Security Design Review | 3.3 | document | none | archived | C |
| 3.14-privacy-design-review | Privacy Design Review | 3.3 | document | none | archived | C |
| 3.15-ai-control-design-note | AI Control Design Note | 3.3 | document | none | archived | C |
| 3.16-design-approval-pack | Design Approval Pack | 3.3 | document | none | archived | C |
| 3.17-assumption-register-updated | Assumption Register (Updated) | 3.3 | register | assumption-register-entry.md.template | handed_over | C |
| 3.18-clarification-log-updated | Clarification / Open Decision Log (Updated) | 3.3 | register | clarification-entry.md.template | handed_over | C |

---

## Phase 4 — Build and Integration

| artefact_id | name | subfase | type | template | closure_obligation | gate_evidence |
|-------------|------|---------|------|----------|--------------------|---------------|
| 4.1-environment-readiness-record | Environment Readiness Record | 4.1 | evidence | none | archived | D |
| 4.2-cicd-pipeline-baseline | CI/CD Pipeline Baseline | 4.1 | document | none | baselined | D |
| 4.3-platform-configuration-record | Platform Configuration Record | 4.1 | document | none | baselined | D |
| 4.4-access-model-record | Access Model Record | 4.1 | document | none | baselined | D |
| 4.5-build-packages | Build Packages | 4.2 | evidence | none | archived | D |
| 4.6-code-review-records | Code Review Records | 4.2 | evidence | none | archived | D |
| 4.7-test-execution-evidence | Test Execution Evidence | 4.2 | evidence | none | archived | D |
| 4.8-integration-evidence | Integration Evidence | 4.2 | evidence | none | archived | D |
| 4.9-defect-log | Defect Log | 4.2 | register | none | handed_over | D |
| 4.10-dataset-preparation-records | Dataset Preparation Records | 4.3 | evidence | none | archived | D |
| 4.11-experiment-log | Experiment Log | 4.3 | register | none | archived | D |
| 4.12-model-package | Model Package or Integration Package | 4.3 | evidence | none | handed_over | D |
| 4.13-evaluation-evidence | Evaluation Evidence | 4.3 | evidence | none | archived | D |
| 4.14-model-card | Model Card or Equivalent AI Documentation | 4.3 | document | none | handed_over | D |
| 4.15-dataset-documentation | Dataset Documentation | 4.3 | document | none | archived | D |
| 4.16-integration-test-evidence | Integration Test Evidence | 4.4 | evidence | none | archived | D |
| 4.17-readiness-checklist-draft | Readiness Checklist Draft | 4.4 | document | none | handed_over | D |
| 4.18-runbooks | Runbooks | 4.4 | document | none | handed_over | D |
| 4.19-support-procedures | Support Procedures | 4.4 | document | none | handed_over | D |
| 4.20-risk-register-updated | Risk Register (Updated) | 4.4 | register | none | handed_over | D |
| 4.21-assumption-register-updated | Assumption Register (Updated) | 4.4 | register | assumption-register-entry.md.template | handed_over | D |
| 4.22-clarification-log-updated | Clarification / Open Decision Log (Updated) | 4.4 | register | clarification-entry.md.template | handed_over | D |

---

## Phase 5 — Verification and Validation

| artefact_id | name | subfase | type | template | closure_obligation | gate_evidence |
|-------------|------|---------|------|----------|--------------------|---------------|
| 5.1-functional-test-report | Functional Test Report | 5.1 | report | none | archived | E |
| 5.2-traceability-completion-evidence | Traceability Completion Evidence | 5.1 | evidence | none | archived | E |
| 5.3-defect-closure-evidence | Defect Closure Evidence | 5.1 | evidence | none | archived | E |
| 5.4-nfr-test-report | NFR Test Report | 5.2 | report | none | archived | E |
| 5.5-security-validation-report | Security Validation Report | 5.2 | report | none | archived | E |
| 5.6-resilience-recoverability-evidence | Resilience / Recoverability Evidence | 5.2 | evidence | none | archived | E |
| 5.7-observability-validation-report | Observability Validation Report | 5.2 | report | none | archived | E |
| 5.8-ai-evaluation-report | AI Evaluation Report | 5.3 | report | none | archived | E |
| 5.9-safety-trust-validation-note | Safety / Trust Validation Note | 5.3 | document | none | archived | E |
| 5.10-ai-acceptance-evidence | Acceptance Evidence for AI Behavior | 5.3 | evidence | none | archived | E |
| 5.11-model-card-updated | Model Card (Updated) | 5.3 | document | none | handed_over | E |
| 5.12-residual-risk-issue-log | Issue Log for Residual Risks | 5.3 | register | none | handed_over | E |
| 5.13-uat-report | UAT Report | 5.4 | report | none | archived | E |
| 5.14-operational-readiness-review | Operational Readiness Review | 5.4 | document | none | handed_over | E |
| 5.15-training-completion-evidence | Training Completion Evidence | 5.4 | evidence | none | archived | E |
| 5.16-acceptance-sign-off | Acceptance Sign-Off or Waiver Log | 5.4 | document | none | archived | E |
| 5.17-residual-risk-note | Residual Risk Note | 5.4 | document | none | handed_over | E |
| 5.18-validation-release-readiness-pack | Validation and Release Readiness Pack | 5.4 | document | none | handed_over | E |
| 5.19-assumption-register-updated | Assumption Register (Updated) | 5.4 | register | assumption-register-entry.md.template | handed_over | E |
| 5.20-clarification-log-updated | Clarification / Open Decision Log (Updated) | 5.4 | register | clarification-entry.md.template | handed_over | E |

---

## Phase 6 — Release and Transition to Operations

| artefact_id | name | subfase | type | template | closure_obligation | gate_evidence |
|-------------|------|---------|------|----------|--------------------|---------------|
| 6.1-release-plan | Release Plan | 6.1 | plan | none | archived | F |
| 6.2-cutover-plan | Cutover Plan | 6.1 | plan | none | archived | F |
| 6.3-rollback-plan | Rollback Plan | 6.1 | plan | none | archived | F |
| 6.4-communications-plan | Communications Plan | 6.1 | plan | none | archived | F |
| 6.5-go-live-criteria-pack | Go-Live Criteria Pack | 6.1 | document | none | archived | F |
| 6.6-deployment-record | Deployment Record | 6.2 | evidence | none | archived | F |
| 6.7-cutover-execution-log | Cutover Execution Log | 6.2 | evidence | none | archived | F |
| 6.8-smoke-test-evidence | Smoke Test Evidence | 6.2 | evidence | none | archived | F |
| 6.9-issue-incident-log | Issue and Incident Log | 6.2 | register | none | handed_over | G |
| 6.10-handover-pack | Handover Pack | 6.3 | document | none | handed_over | G |
| 6.11-operations-acceptance | Operations Acceptance | 6.3 | document | none | archived | G |
| 6.12-support-readiness-confirmation | Support Readiness Confirmation | 6.3 | document | none | archived | G |
| 6.13-ai-ops-handover-note | AI Ops Handover Note | 6.3 | document | none | handed_over | G |
| 6.14-hypercare-report | Hypercare Report | 6.4 | report | none | archived | G |
| 6.15-early-life-incident-report | Early-Life Incident Report | 6.4 | report | none | archived | G |
| 6.16-stabilization-closure-note | Stabilization Closure Note | 6.4 | document | none | archived | G |
| 6.17-assumption-register-updated | Assumption Register (Updated) | 6.4 | register | assumption-register-entry.md.template | handed_over | G |
| 6.18-clarification-log-updated | Clarification / Open Decision Log (Updated) | 6.4 | register | clarification-entry.md.template | handed_over | G |

---

## Phase 7 — Operate, Monitor and Improve

| artefact_id | name | subfase | type | template | closure_obligation | gate_evidence |
|-------------|------|---------|------|----------|--------------------|---------------|
| 7.1-service-reports | Service Reports | 7.1 | report | none | updated | — |
| 7.2-incident-problem-records | Incident and Problem Records | 7.1 | register | none | updated | — |
| 7.3-change-records | Change Records | 7.1 | register | none | updated | — |
| 7.4-support-metrics | Support Metrics | 7.1 | report | none | updated | — |
| 7.5-ai-monitoring-reports | AI Monitoring Reports | 7.2 | report | none | updated | — |
| 7.6-drift-degradation-logs | Drift and Degradation Logs | 7.2 | register | none | updated | — |
| 7.7-model-update-decisions | Model Update Decisions | 7.2 | document | none | updated | — |
| 7.8-ai-incident-records | AI Incident Records | 7.2 | register | none | updated | — |
| 7.9-improvement-backlog | Improvement Backlog | 7.3 | register | none | updated | — |
| 7.10-approved-change-requests | Approved Change Requests | 7.3 | document | none | updated | — |
| 7.11-updated-baselines | Updated Baselines | 7.3 | document | none | updated | — |
| 7.12-release-recommendations | Release Recommendations | 7.3 | document | none | updated | — |
| 7.13-risk-register-updated | Risk Register (Updated) | 7.3 | register | none | updated | — |
| 7.14-assumption-register-updated | Assumption Register (Updated) | 7.3 | register | assumption-register-entry.md.template | updated | — |
| 7.15-clarification-log-updated | Clarification / Open Decision Log (Updated) | 7.3 | register | clarification-entry.md.template | updated | — |

---

## Phase 8 — Retire or Replace

| artefact_id | name | subfase | type | template | closure_obligation | gate_evidence |
|-------------|------|---------|------|----------|--------------------|---------------|
| 8.1-retirement-decision-record | Retirement Decision Record | 8.1 | document | none | archived | H |
| 8.2-impact-assessment | Impact Assessment | 8.1 | document | none | archived | H |
| 8.3-sunset-plan | Sunset Plan | 8.1 | plan | none | archived | H |
| 8.4-decommissioning-record | Decommissioning Record | 8.2 | evidence | none | archived | H |
| 8.5-access-closure-evidence | Access Closure Evidence | 8.2 | evidence | none | archived | H |
| 8.6-data-closure-record | Data Closure Record | 8.2 | document | none | archived | H |
| 8.7-final-closure-pack | Final Closure Pack | 8.2 | document | none | closed | H |

---

## Transversal Objects

Objects that span the entire lifecycle and must be maintained continuously.

| artefact_id | name | phase | type | template | closure_obligation | gate_evidence |
|-------------|------|-------|------|----------|--------------------|---------------|
| T.1-risk-register | Risk Register | transversal | register | none | handed_over | A–H |
| T.2-assumption-register | Assumption Register | transversal | register | assumption-register-entry.md.template | handed_over | A–H |
| T.3-clarification-log | Clarification / Open Decision Log | transversal | register | clarification-entry.md.template | handed_over | A–H |
| T.4-dependency-log | Dependency Log | transversal | register | none | handed_over | A–H |
| T.5-requirements-traceability-matrix | Requirements Traceability Matrix | transversal | schema | none | baselined | B–E |
| T.6-change-log | Change Log | transversal | register | none | updated | B–H |
| T.7-evidence-index | Evidence Index | transversal | register | none | updated | A–H |
| T.8-handover-log | Handover Log | transversal | register | none | handed_over | A–H |

---

## Closure Obligation Definitions

| Value | Meaning |
|-------|---------|
| `baselined` | Artefact is frozen under change control at phase closure |
| `handed_over` | Artefact is formally transferred to the next phase owner |
| `archived` | Artefact is stored in the evidence archive for audit purposes |
| `updated` | Artefact is kept live and updated in place (Phase 7) |
| `closed` | Artefact is formally concluded with no further updates expected |
