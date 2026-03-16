# Handover Reference — Waterfall Lifecycle

Formal handover standards for all 7 phase transitions in the predictive lifecycle.

## Purpose

In a predictive lifecycle, handovers must be explicit, evidenced, and formally accepted. This document defines the minimum requirements for each phase transition to prevent tribal knowledge loss, unclear accountability, and uncontrolled risk inheritance.

---

## Transition 1 — Opportunity and Feasibility → Requirements and Baseline

**Handover title:** Feasibility-to-Requirements Handover

**From role:** PM / Product Sponsor (Phase 1 owner)
**To role:** Business Analyst / PM (Phase 2 owner)

**Formal trigger:** Gate A (Initiation Approval) passed

**Mandatory artefacts transferred:**
- Problem Statement (`1.1-problem-statement`)
- Vision Statement (`1.2-vision-statement`)
- Stakeholder Map (`1.3-stakeholder-map`)
- Feasibility Assessment (`1.5-feasibility-assessment`)
- Project Charter (`1.18-project-charter`)
- Initial Plan and Milestone Map (`1.19-initial-plan-milestone-map`)
- Governance Model (`1.20-governance-model`)
- Initial Risk Register (`1.11-initial-risk-register`)
- Assumption Register — Initial (`1.16-assumption-register-initial`)
- Clarification / Open Decision Log (`1.17-clarification-log`)
- Evidence Index (updated through Phase 1)

**Open items inherited:**
- All open entries in the Assumption Register
- All open entries in the Clarification / Open Decision Log
- All open items in the Initial Risk Register

**Sign-off requirements:**
- Outgoing owner (PM / Product Sponsor) signs transfer confirmation
- Incoming owner (BA / PM Phase 2) signs acceptance
- Sponsor confirms Gate A approval and handover adequacy

**Verification step:** Incoming owner confirms that problem statement, stakeholder map, and feasibility assessment are sufficient to begin elicitation; that open decision log is understood; that all critical dependencies identified in Phase 1 are visible.

**Failure mode:** If incoming owner rejects handover, Phase 1 owner must resolve the specific gap (missing artefact, inadequate content, or unresolved critical decision) before re-submission. Gate A approval does not lapse; a partial re-work cycle is opened.

---

## Transition 2 — Requirements and Baseline → Architecture and Solution Design

**Handover title:** Requirements-to-Design Handover

**From role:** Business Analyst / PM (Phase 2 owner)
**To role:** Solution Architect / PM (Phase 3 owner)

**Formal trigger:** Gate B (Requirements Baseline Approval) passed

**Mandatory artefacts transferred:**
- Requirements Baseline / SRS (`2.13-requirements-baseline`)
- Requirements Traceability Matrix (`2.14-requirements-traceability-matrix`)
- Acceptance Criteria Catalog (`2.15-acceptance-criteria-catalog`)
- Glossary (`2.16-glossary`)
- AI Requirements Specification (`2.6-ai-requirements-specification`)
- NFR Specification (`2.9-nfr-specification`)
- Security Requirements Set (`2.10-security-requirements-set`)
- Updated Risk Register
- Updated Assumption Register (`2.18-assumption-register-updated`)
- Updated Clarification / Open Decision Log (`2.19-clarification-log-updated`)
- Evidence Index (updated through Phase 2)

**Open items inherited:**
- Ambiguities formally accepted via waiver in the baseline
- Open items in the Assumption Register with owner and deadline
- Unresolved entries in the Clarification / Open Decision Log

**Sign-off requirements:**
- Outgoing owner (BA / PM) signs baseline handover
- Incoming owner (Architect) confirms design can proceed
- Governance Forum or Sponsor confirms Gate B approval

**Verification step:** Incoming owner confirms that requirements are testable and unambiguous for critical scope, that AI and NFR requirements are sufficiently detailed for architectural decisions, and that all open decision items have owners.

**Failure mode:** If incoming owner identifies requirements that are insufficient for design, a targeted clarification cycle is opened with the BA. Requirements Baseline Approval (Gate B) remains valid; only the specific gap is re-worked under change control.

---

## Transition 3 — Architecture and Solution Design → Build and Integration

**Handover title:** Design-to-Build Handover

**From role:** Solution Architect / PM (Phase 3 owner)
**To role:** Engineering Lead / PM (Phase 4 owner)

**Formal trigger:** Gate C (Design Approval) passed

**Mandatory artefacts transferred:**
- HLD (`3.1-hld`)
- LLD (`3.6-lld`)
- Interface Specifications (`3.7-interface-specifications`)
- Architecture Decision Records — ADR Set (`3.5-adr-set`)
- Control Matrix (`3.12-control-matrix`)
- Test Design Package (`3.10-test-design-package`)
- Operational Design Package (`3.11-operational-design-package`)
- AI/ML Design Package (`3.9-ai-ml-design-package`)
- Security Architecture Decisions (`3.4-security-architecture-decisions`)
- Updated Risk Register
- Updated Assumption Register (`3.17-assumption-register-updated`)
- Updated Clarification / Open Decision Log (`3.18-clarification-log-updated`)
- Evidence Index (updated through Phase 3)

**Open items inherited:**
- Open design issues with owner, impact, and resolution target
- ADRs with deferred decisions and their constraints
- Open items in the Clarification / Open Decision Log

**Sign-off requirements:**
- Outgoing owner (Architect) signs design completeness
- Incoming owner (Engineering Lead) confirms build can proceed
- Design Authority / Governance Forum confirms Gate C approval

**Verification step:** Incoming owner confirms that HLD and LLD provide sufficient detail for implementation, that environments are or will be available per environment strategy, and that the test design package is buildable within the available tooling and timeline.

**Failure mode:** If incoming owner identifies a design gap that blocks build, a targeted design iteration is opened. Gate C approval is retained; the specific gap is resolved via a controlled design update before build progresses on the affected component.

---

## Transition 4 — Build and Integration → Verification and Validation

**Handover title:** Build-to-Verification Handover

**From role:** Engineering Lead / PM (Phase 4 owner)
**To role:** QA Lead / PM (Phase 5 owner)

**Formal trigger:** Gate D (Build Complete / Integration Ready) passed

**Mandatory artefacts transferred:**
- Build Packages (`4.5-build-packages`)
- Integration Evidence (`4.8-integration-evidence`)
- Model Package or Integration Package (`4.12-model-package`)
- Model Card (`4.14-model-card`)
- Readiness Checklist Draft (`4.17-readiness-checklist-draft`)
- Runbooks (`4.18-runbooks`)
- Support Procedures (`4.19-support-procedures`)
- Defect Log (`4.9-defect-log`)
- Updated Risk Register (`4.20-risk-register-updated`)
- Updated Assumption Register (`4.21-assumption-register-updated`)
- Updated Clarification / Open Decision Log (`4.22-clarification-log-updated`)
- Evidence Index (updated through Phase 4)

**Open items inherited:**
- All open defects with severity classification
- Open items in Risk Register
- Constraints or known issues that affect test coverage

**Sign-off requirements:**
- Outgoing owner (Engineering Lead) signs build completeness declaration
- Incoming owner (QA Lead) signs verification readiness acceptance
- Delivery Authority confirms Gate D approval

**Verification step:** Incoming owner confirms that build packages are deployable to test environments, that test environments are available and configured per environment strategy, that defect log is complete and triaged, and that the test design package from Phase 3 remains aligned with the delivered build.

**Failure mode:** If incoming owner rejects build readiness (e.g., environments not ready, critical integration gaps), Phase 4 owner opens a targeted remediation cycle. Gate D approval is re-assessed if the gap is material.

---

## Transition 5 — Verification and Validation → Release and Transition to Operations

**Handover title:** Validation-to-Release Handover

**From role:** QA Lead / PM (Phase 5 owner)
**To role:** PM / Release Manager (Phase 6 owner)

**Formal trigger:** Gate E (Validation Complete / Release Readiness) passed

**Mandatory artefacts transferred:**
- Functional Test Report (`5.1-functional-test-report`)
- NFR Test Report (`5.4-nfr-test-report`)
- AI Evaluation Report (`5.8-ai-evaluation-report`)
- Operational Readiness Review (`5.14-operational-readiness-review`)
- UAT Report (`5.13-uat-report`)
- Residual Risk Note (`5.17-residual-risk-note`)
- Acceptance Sign-Off or Waiver Log (`5.16-acceptance-sign-off`)
- Model Card — Updated (`5.11-model-card-updated`)
- Validation and Release Readiness Pack (`5.18-validation-release-readiness-pack`)
- Updated Assumption Register (`5.19-assumption-register-updated`)
- Updated Clarification / Open Decision Log (`5.20-clarification-log-updated`)
- Evidence Index (updated through Phase 5)

**Open items inherited:**
- Accepted waivers and their conditions
- Open defects formally accepted for production entry
- Residual risks with owner and monitoring commitment

**Sign-off requirements:**
- Outgoing owner (QA Lead) signs validation completeness
- Incoming owner (Release Manager) confirms release package is adequate
- Governance Forum / Release Authority confirms Gate E approval
- Sponsor endorses residual risk acceptance where applicable

**Verification step:** Incoming owner confirms that release plan, rollback plan, and cutover plan can be built from the available evidence; that operations and support teams have adequate readiness; and that accepted waivers are understood and tracked.

**Failure mode:** If incoming owner identifies critical gaps in release readiness evidence, a targeted re-validation cycle is opened. Gate E approval is re-assessed if the gap relates to an unresolved critical acceptance criterion.

---

## Transition 6 — Release and Transition to Operations → Operate, Monitor and Improve

**Handover title:** Release-to-Operations Handover

**From role:** PM / Release Manager (Phase 6 owner)
**To role:** Operations / Product Owner — Operational (Phase 7 owner)

**Formal trigger:** Gate G (Hypercare Exit / Service Acceptance) passed

**Mandatory artefacts transferred:**
- Handover Pack (`6.10-handover-pack`)
- Operations Acceptance (`6.11-operations-acceptance`)
- Support Readiness Confirmation (`6.12-support-readiness-confirmation`)
- AI Ops Handover Note (`6.13-ai-ops-handover-note`)
- Hypercare Report (`6.14-hypercare-report`)
- Stabilization Closure Note (`6.16-stabilization-closure-note`)
- Runbooks (from Phase 4, updated in Phase 6)
- Deployment Record (`6.6-deployment-record`)
- Issue and Incident Log (`6.9-issue-incident-log`)
- Updated Assumption Register (`6.17-assumption-register-updated`)
- Updated Clarification / Open Decision Log (`6.18-clarification-log-updated`)
- Evidence Index (updated through Phase 6)

**Open items inherited:**
- Open incident records from early-life period
- Known limitations and their monitoring commitments
- Any accepted waivers that remain relevant in production

**Sign-off requirements:**
- Outgoing owner (Release Manager) signs operational transfer
- Incoming owner (Operations) signs service acceptance
- Operations Authority confirms Gate G approval

**Verification step:** Incoming owner confirms that dashboards, alerting, and runbooks are operational; that support escalation paths are active; that AI monitoring is configured; and that the operations team has adequate context to manage independently.

**Failure mode:** If Operations rejects service acceptance (e.g., dashboards not functional, runbooks incomplete, unresolved P1 defects), hypercare is extended and specific gaps are resolved before re-submission. Gate G approval is re-assessed.

---

## Transition 7 — Operate, Monitor and Improve → Retire or Replace

**Handover title:** Operations-to-Retirement Handover

**From role:** Operations / Product Owner — Operational (Phase 7 owner)
**To role:** PM / Operations / Product Sponsor (Phase 8 owner, context-dependent)

**Formal trigger:** Retirement trigger decision formally approved (precursor to Gate H)

**Mandatory artefacts transferred:**
- Retirement Decision Record (`8.1-retirement-decision-record`)
- Impact Assessment (`8.2-impact-assessment`)
- Service Reports (full history from Phase 7)
- AI Monitoring Reports (full history from Phase 7)
- Risk Register (current state)
- Change Log (full lifecycle history)
- Evidence Index (full lifecycle history)
- Dependency Log (current state — all active dependencies)
- Handover Log (full lifecycle history)

**Open items inherited:**
- Active user obligations and contracts requiring formal closure
- Data retention obligations with specific deadlines
- Open incidents that must be resolved or formally closed
- Compliance obligations that outlive the service

**Sign-off requirements:**
- Outgoing owner (Operations) signs operational closure readiness
- Incoming owner (Phase 8 owner) accepts retirement scope and responsibilities
- Sponsor / Governance Forum authorises retirement initiation

**Verification step:** Incoming owner confirms that impact assessment covers all known dependencies, that data and access closure obligations are understood, that the sunset plan is feasible, and that communication plan is in place for affected users.

**Failure mode:** If Phase 8 owner identifies undiscovered dependencies or compliance obligations that invalidate the retirement plan, the impact assessment is revised and retirement initiation is deferred until the gap is resolved. Gate H cannot be passed until the scope is fully understood.

---

## Handover Log

All handovers must be recorded in the **Handover Log** (transversal object `T.8-handover-log`).

Minimum fields per handover log entry:

| Field | Description |
|-------|-------------|
| `handover_id` | Unique reference (e.g., `H-001`) |
| `transition` | Phase transition (e.g., `Phase 1 → Phase 2`) |
| `gate` | Gate that triggered the handover |
| `date` | Date of formal handover |
| `from_owner` | Name and role of outgoing owner |
| `to_owner` | Name and role of incoming owner |
| `status` | `accepted` / `rejected` / `conditional` |
| `conditions` | If conditional: outstanding items and deadline |
| `artefacts_transferred` | Reference list of artefacts transferred |
| `notes` | Any context relevant to the transition |
