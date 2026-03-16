# Handover Reference — waterfall-lifecycle

Formal handover standards for all 7 phase transitions.

Each transition defines: gate prerequisite, roles, mandatory artefacts transferred, open items inherited, sign-off requirements, incoming owner verification, and rejection criteria.

---

## Phase 1→2 Handover: Opportunity and Feasibility to Requirements and Baseline

- **Gate Prerequisite**: Gate A (Initiation approval) must be PASSED or WAIVED
- **Outgoing Role**: PM / Product Sponsor (Phase 1 owner)
- **Incoming Role**: Business Analysis / PM (Phase 2 owner)
- **Mandatory Artefacts Transferred**:
  - Problem Statement
  - Vision Statement
  - Stakeholder Map
  - Feasibility Assessment
  - Initial Risk Register
  - Assumption Register
  - Clarification Log
  - Project Charter (baselined)
  - Initiation Gate Pack
- **Open Items Inherited**: Risk Register (all open risks), Assumption Register (unvalidated assumptions), Clarification Log (unresolved items), Dependency Log
- **Sign-off Requirements**: Outgoing PM + Incoming BA/PM + Sponsor or Governance Forum
- **Incoming Owner Verification**:
  - Gate A decision recorded and accessible
  - Problem Statement and Vision Statement are unambiguous and signed off
  - All mandatory artefacts present in the evidence index
  - Open risk and assumption items are traceable and have owners assigned
  - Stakeholder availability for requirements elicitation confirmed
- **Rejection Criteria**:
  - Gate A not passed and not formally waived
  - Problem Statement absent or insufficiently defined
  - Critical feasibility blockers unresolved without documented mitigation
  - No identified sponsor or approval authority for Phase 2

---

## Phase 2→3 Handover: Requirements and Baseline to Architecture and Solution Design

- **Gate Prerequisite**: Gate B (Requirements baseline approval) must be PASSED or WAIVED
- **Outgoing Role**: Business Analysis / PM (Phase 2 owner)
- **Incoming Role**: Solution Architecture / PM (Phase 3 owner)
- **Mandatory Artefacts Transferred**:
  - Business Requirements Set (baselined)
  - AI Requirements Specification (baselined)
  - Non-Functional Requirements Specification (baselined)
  - Acceptance Criteria Catalog (baselined)
  - Requirements Traceability Matrix
  - Glossary
  - Change Management Plan (baselined)
  - Requirements Baseline Approval Pack
  - Updated Risk Register
  - Updated Assumption Register
  - Updated Clarification Log
- **Open Items Inherited**: Risk Register, Assumption Register, Clarification Log, Dependency Log, Requirements Traceability Matrix
- **Sign-off Requirements**: Outgoing BA/PM + Incoming Architect/PM + Sponsor or designated Governance Forum
- **Incoming Owner Verification**:
  - Gate B decision recorded and accessible
  - All critical requirements baselined and traceable
  - NFRs and acceptance criteria are measurable and unambiguous
  - AI requirements and data requirements explicitly covered
  - Change management process active for post-baseline changes
  - Open items have owners, dates, and impact assessments
- **Rejection Criteria**:
  - Gate B not passed and not formally waived
  - Requirements baseline incomplete or not formally approved
  - Critical ambiguities unresolved and not formally accepted
  - No acceptance criteria defined for mandatory requirements
  - Traceability matrix absent or structurally incomplete

---

## Phase 3→4 Handover: Architecture and Solution Design to Build and Integration

- **Gate Prerequisite**: Gate C (Design approval) must be PASSED or WAIVED
- **Outgoing Role**: Solution Architecture / PM (Phase 3 owner)
- **Incoming Role**: Engineering Lead / PM (Phase 4 owner)
- **Mandatory Artefacts Transferred**:
  - High-Level Design (baselined)
  - Low-Level Design (baselined)
  - Architecture Decision Records
  - Tech Stack Decision Record
  - API Contracts (baselined)
  - Control Matrix (baselined)
  - Test Design Package
  - Design Approval Pack
  - Updated Risk Register
  - Updated Assumption Register
  - Updated Clarification Log
- **Open Items Inherited**: Risk Register, Assumption Register, Clarification Log, Dependency Log, Requirements Traceability Matrix, Change Log
- **Sign-off Requirements**: Outgoing Architect/PM + Incoming Engineering Lead/PM + Design Authority or Governance Forum
- **Incoming Owner Verification**:
  - Gate C decision recorded and accessible
  - HLD and LLD sufficient for build to commence without blocking design queries
  - API contracts and interface specifications complete and versioned
  - Control matrix mapped to requirements and risks
  - Test design package accepted by QA lead
  - Environment and tooling dependencies identified and tracked
  - Open architectural decisions documented with impact and owner
- **Rejection Criteria**:
  - Gate C not passed and not formally waived
  - HLD or LLD absent or insufficient for build planning
  - Critical open design decisions without owner or resolution path
  - API contracts or interface specifications absent where integration is required
  - Control matrix not linked to requirements or risks

---

## Phase 4→5 Handover: Build and Integration to Verification and Validation

- **Gate Prerequisite**: Gate D (Build complete / integration ready) must be PASSED or WAIVED
- **Outgoing Role**: Engineering Lead / PM (Phase 4 owner)
- **Incoming Role**: QA Lead / PM (Phase 5 owner)
- **Mandatory Artefacts Transferred**:
  - Environment Readiness Record
  - CI/CD Pipeline Baseline
  - Build Packages
  - Code Review Records
  - Integration Evidence
  - Model / Integration Package
  - Deployment Runbook (Draft)
  - Readiness Checklist (Draft)
  - Updated Defect Log
  - Updated Risk Register
  - Updated Assumption Register
  - Updated Clarification Log
- **Open Items Inherited**: Risk Register, Assumption Register, Clarification Log, Dependency Log, Defect Log, Requirements Traceability Matrix, Change Log
- **Sign-off Requirements**: Outgoing Engineering Lead/PM + Incoming QA Lead/PM + Delivery Authority
- **Incoming Owner Verification**:
  - Gate D decision recorded and accessible
  - Build packages stable and versioned
  - All critical integrations verified and evidenced
  - Test environments available and representative
  - Defect log current with triage and severity classifications
  - No blocking defects without accepted mitigation or waiver
  - Readiness checklist and deployment runbook draft reviewed
- **Rejection Criteria**:
  - Gate D not passed and not formally waived
  - Build packages absent or unstable
  - Critical integrations not verified
  - Test environments unavailable or not representative
  - Blocking defects unresolved without formal acceptance

---

## Phase 5→6 Handover: Verification and Validation to Release and Transition to Operations

- **Gate Prerequisite**: Gate E (Validation complete / release readiness) must be PASSED or WAIVED
- **Outgoing Role**: QA Lead / PM (Phase 5 owner)
- **Incoming Role**: PM / Release Manager (Phase 6 owner)
- **Mandatory Artefacts Transferred**:
  - V&V Plan
  - Functional Test Report
  - NFR Test Report
  - AI Evaluation Report
  - UAT Report
  - Residual Risk Note
  - Waiver Log (if applicable)
  - Validation and Release Readiness Pack
  - Updated Defect Log
  - Updated Requirements Traceability Matrix
  - Updated Risk Register
  - Updated Assumption Register
  - Updated Clarification Log
- **Open Items Inherited**: Risk Register, Assumption Register, Clarification Log, Dependency Log, Defect Log, Change Log
- **Sign-off Requirements**: Outgoing QA Lead/PM + Incoming Release Manager/PM + Governance Forum or Release Authority
- **Incoming Owner Verification**:
  - Gate E decision recorded and accessible
  - All mandatory test reports present and formally signed
  - Residual risk note accepted by sponsor or delegated authority
  - All known waivers formally recorded and accepted
  - Rollback plan confirmed viable by engineering
  - Operations and support teams confirmed ready
- **Rejection Criteria**:
  - Gate E not passed and not formally waived
  - Critical validation failures unresolved without formal waiver
  - Residual risk not formally accepted
  - Operations or support readiness not confirmed
  - Rollback plan absent or not validated

---

## Phase 6→7 Handover: Release and Transition to Operations to Operate, Monitor and Improve

- **Gate Prerequisite**: Gate G (Hypercare exit / service acceptance) must be PASSED or WAIVED
- **Outgoing Role**: PM / Release Manager (Phase 6 owner)
- **Incoming Role**: Operations Lead / Product Owner (Phase 7 owner)
- **Mandatory Artefacts Transferred**:
  - Release Plan (as-executed)
  - Deployment Record
  - Operations Runbook
  - Monitoring Dashboard Specification
  - User Documentation
  - Training Materials
  - Operations Acceptance (signed)
  - Hypercare Report
  - Stabilization Closure Note
  - Updated Risk Register
  - Updated Assumption Register
  - Updated Clarification Log
- **Open Items Inherited**: Risk Register, Assumption Register, Clarification Log, Dependency Log, Defect Log (residual), Improvement Backlog (initial items), Change Log
- **Sign-off Requirements**: Outgoing Release Manager/PM + Incoming Operations Lead + Sponsor or Operations Authority
- **Incoming Owner Verification**:
  - Gate G decision recorded and accessible
  - Operations Acceptance formally signed by operations owner
  - Runbooks sufficient for day-to-day operations without delivery team involvement
  - Monitoring dashboards active and alerts configured
  - Support handover confirmed with support team
  - Escalation paths and incident process documented and communicated
  - Residual defects and risks documented with operations owner assigned
- **Rejection Criteria**:
  - Gate G not passed and not formally waived
  - Operations Acceptance not signed
  - Runbooks absent or insufficient for autonomous operations
  - Monitoring dashboards inactive or not configured
  - No escalation path or incident management process in place

---

## Phase 7→8 Handover: Operate, Monitor and Improve to Retire or Replace

- **Gate Prerequisite**: Formal retirement trigger review completed; Gate H (Retirement approval) must be PASSED or WAIVED
- **Outgoing Role**: Operations Lead / Product Owner (Phase 7 owner)
- **Incoming Role**: PM / Operations / Product Sponsor (Phase 8 owner — as applicable)
- **Mandatory Artefacts Transferred**:
  - Retirement Decision Record
  - Impact Assessment
  - Operational Review Report (most recent)
  - Updated Risk Register (final state)
  - Updated Incident Log
  - Updated Improvement Backlog (final state)
  - Data Archive / Disposal Record (draft or plan)
  - Updated Assumption Register
  - Updated Clarification Log
- **Open Items Inherited**: Risk Register (residual), Dependency Log, Change Log, Incident Log (open items), Compliance obligations register
- **Sign-off Requirements**: Outgoing Operations Lead/Product Owner + Incoming Retirement PM/Sponsor + Governance Forum or Sponsor
- **Incoming Owner Verification**:
  - Gate H decision recorded and accessible
  - Retirement decision formally approved by sponsor
  - All active users and dependent systems identified and notified
  - Data retention and disposal requirements identified and assigned to an owner
  - Decommission sequencing plan confirmed viable
  - Compliance, legal, and contractual obligations reviewed for residual requirements
- **Rejection Criteria**:
  - Gate H not passed and not formally waived
  - Retirement decision not formally approved
  - Active users or dependent systems not identified
  - Data retention obligations unresolved
  - No decommission plan or sequencing confirmed
