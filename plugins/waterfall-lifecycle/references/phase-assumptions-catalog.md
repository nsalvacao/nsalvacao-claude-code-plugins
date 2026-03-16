# Phase Assumptions Catalog — Waterfall Lifecycle

Typical assumptions for each of the 8 phases. Use this catalog to seed the Assumption Register at the start of each phase and to prompt assumption validation conversations during gate preparation.

## Purpose

Unvalidated assumptions are a primary source of phase failure. This catalog provides a reference set of typical assumptions per phase. For each project, the team should:
1. Review the relevant phase section before starting work
2. Confirm which assumptions apply
3. Add any project-specific assumptions
4. Assign an owner and validation deadline to each retained assumption

Assumptions that cannot be validated before the phase gate must either be resolved or formally accepted as risks.

## Assumption Types

| Type | Description |
|------|-------------|
| `technical` | Relates to system capabilities, integration, or platform behaviour |
| `business` | Relates to organisational decisions, priorities, or domain stability |
| `data` | Relates to data availability, quality, or access rights |
| `ai` | Relates to model behaviour, feasibility, or tooling |
| `legal` | Relates to compliance, regulatory obligations, or contractual constraints |
| `external` | Relates to third-party dependencies, vendors, or external stakeholders |

---

## Phase 1 — Opportunity and Feasibility

| ID | Description | Type | Typical Impact if Invalid | When to Validate |
|----|-------------|------|--------------------------|------------------|
| P1-A1 | The business problem is stable and not likely to change materially during the feasibility phase | business | Scope instability; rework on problem statement and feasibility artefacts | Before starting subfase 1.1 |
| P1-A2 | An AI/ML approach is technically viable for this problem class (pre-validated by prior research, prototype, or expert assessment) | ai | Feasibility outcome changes; project may need to pivot before gate | Before completing subfase 1.2 |
| P1-A3 | Required data sources exist, are accessible, and have sufficient quality to support the intended solution | data | Data feasibility note becomes invalid; project may not be viable | Before completing subfase 1.2 |
| P1-A4 | Legal and compliance constraints applicable to this solution are known and documented at the level needed for feasibility | legal | Hidden regulatory blockers discovered after gate; costly rework in later phases | Before Gate A |
| P1-A5 | The sponsor is committed, available for sign-off, and has authority to approve initiation | business | Gate A cannot be formally closed; project loses momentum or funding certainty | Before Gate A |
| P1-A6 | Key stakeholders needed for requirements elicitation in Phase 2 are identifiable and available | external | Phase 2 delayed or incomplete due to missing domain knowledge | Before Gate A |
| P1-A7 | The project has sufficient budget certainty to proceed to Phase 2 without re-approval | business | Phase 2 planning proceeds on uncertain footing; risk of mid-phase funding freeze | Before Gate A |

---

## Phase 2 — Requirements and Baseline

| ID | Description | Type | Typical Impact if Invalid | When to Validate |
|----|-------------|------|--------------------------|------------------|
| P2-A1 | The stakeholders participating in elicitation represent all critical user and business perspectives | business | Missing requirements discovered in later phases; costly baseline change requests | Before starting subfase 2.1 |
| P2-A2 | The operational context is sufficiently stable for requirements to be baselined without immediate obsolescence | business | Baseline requires significant change control before design can proceed | Before Gate B |
| P2-A3 | Language used in requirements is testable and unambiguous for critical scope items | technical | Verification in Phase 5 cannot confirm compliance; acceptance disputes arise | During subfase 2.4 review |
| P2-A4 | AI acceptance criteria can be defined in measurable terms for the intended use cases | ai | AI evaluation in Phase 5 has no clear pass/fail definition; release decision is contested | Before completing subfase 2.2 |
| P2-A5 | Datasets and data pipelines required for AI training or inference are available under the legal basis needed | data | AI requirements specification is incomplete; project may need legal/privacy clearance before proceeding | Before Gate B |
| P2-A6 | The regulatory classification of the AI component (if applicable) is known and reflected in requirements | legal | Missing regulatory requirements discovered post-baseline; significant rework | Before Gate B |
| P2-A7 | Third-party models, APIs, or services that requirements depend on are contractually available for the intended purpose | external | Requirements for a third-party capability cannot be baselined; design decisions deferred | Before Gate B |

---

## Phase 3 — Architecture and Solution Design

| ID | Description | Type | Typical Impact if Invalid | When to Validate |
|----|-------------|------|--------------------------|------------------|
| P3-A1 | The requirements baseline is sufficiently stable for architectural decisions to be made without immediate revision | business | Architecture decisions become invalid before build begins; significant rework | Before starting subfase 3.1 |
| P3-A2 | The major external components (APIs, cloud services, third-party models) are integrable under the technical and commercial conditions assumed | external | Key architectural decisions must be revisited; timeline and cost impact | Before completing subfase 3.1 |
| P3-A3 | Target deployment environments can be provisioned with the access and security controls required by the design | technical | Environment strategy fails; build cannot start as planned | Before Gate C |
| P3-A4 | The test strategy is executable within the available environments, data, and tooling constraints | technical | Test design package produces unrealisable plans; rework required before Phase 5 | Before Gate C |
| P3-A5 | Sufficient information is available to specify AI/ML design with a level of detail adequate for implementation | ai | AI/ML design package is incomplete; build team cannot implement the AI component without further R&D | Before completing subfase 3.2 |
| P3-A6 | Control design requirements (logging, audit, human oversight) do not conflict with performance or operational NFRs | technical | Control design must be revised in build, with potential NFR trade-offs | Before Gate C |
| P3-A7 | Privacy and security design review can be completed with the reviewers available and within the phase timeline | legal | Design approval is delayed; gate is blocked pending compliance review | During subfase 3.3 |
| P3-A8 | The cost of the chosen architecture is within the approved budget envelope | business | Architecture must be revised before Gate C; potential escalation to sponsor | Before Gate C |

---

## Phase 4 — Build and Integration

| ID | Description | Type | Typical Impact if Invalid | When to Validate |
|----|-------------|------|--------------------------|------------------|
| P4-A1 | Environments for development, testing, and staging remain available and stable throughout the build phase | technical | Build and integration are interrupted; timeline impact | Before starting subfase 4.1 |
| P4-A2 | Design artefacts (HLD, LLD, interface specifications) are sufficiently detailed for implementation without repeated design clarifications | technical | Build team is blocked; unplanned design iteration cycles during build | Before starting subfase 4.2 |
| P4-A3 | External dependencies (APIs, services, data sources) are accessible at the quality and rate needed for build and integration | external | Integration cannot be completed; build packages are incomplete for Gate D | During subfase 4.2 |
| P4-A4 | Datasets and model components required for AI implementation are available, versioned, and usable within the legal and technical constraints | data | AI implementation is delayed; experiment log is incomplete; Gate D is at risk | Before starting subfase 4.3 |
| P4-A5 | The engineering team has the skills, tooling, and access required to implement all components in scope | technical | Build velocity is lower than planned; skill gaps require mitigation | Before starting subfase 4.2 |
| P4-A6 | Test automation tooling and infrastructure are ready before the team requires them | technical | Manual testing replaces automation; coverage and evidence quality degrade | Before starting subfase 4.4 |
| P4-A7 | The build scope will not require material changes to the approved design | business | Change control activity in Phase 4 increases; potential gate re-assessment | Ongoing throughout Phase 4 |

---

## Phase 5 — Verification and Validation

| ID | Description | Type | Typical Impact if Invalid | When to Validate |
|----|-------------|------|--------------------------|------------------|
| P5-A1 | Validation environments adequately represent the production context for the critical test scenarios | technical | Test results are not representative; release decision is made on insufficient evidence | Before starting subfase 5.1 |
| P5-A2 | Test data covers the critical scenarios and edge cases required by the acceptance criteria | data | Test coverage gaps; critical failure modes not exercised before release | Before starting subfase 5.1 |
| P5-A3 | AI acceptance criteria defined in Phase 2 remain appropriate for the delivered implementation | ai | AI evaluation in subfase 5.3 produces inconclusive or contested results | Before starting subfase 5.3 |
| P5-A4 | All critical waivers required for Gate E will be obtainable from the relevant sign-off authorities within the phase timeline | business | Gate E is delayed by waiver approval process; release timeline slips | During subfase 5.4 |
| P5-A5 | Operations and support teams are available and prepared to participate in operational readiness validation | external | Operational Readiness Review cannot be completed; Gate E blocked | During subfase 5.4 |
| P5-A6 | Business users are available and willing to participate in UAT within the planned window | external | UAT cannot be completed within the phase; Gate E blocked | Before starting subfase 5.4 |
| P5-A7 | Defects found during verification will not require architectural changes that re-open Gate C | technical | Phase 5 triggers a design iteration loop; significant timeline impact | Ongoing throughout Phase 5 |

---

## Phase 6 — Release and Transition to Operations

| ID | Description | Type | Typical Impact if Invalid | When to Validate |
|----|-------------|------|--------------------------|------------------|
| P6-A1 | The release window planned for cutover is achievable given operational and business calendar constraints | external | Release must be rescheduled; hypercare window shifts | Before finalising release plan |
| P6-A2 | All critical personnel required during cutover are available and committed | external | Cutover execution is under-resourced; risk of incomplete or reversed deployment | Before Gate F |
| P6-A3 | Rollback remains technically executable after cutover, for the duration committed in the rollback plan | technical | Rollback plan is invalid; go-live risk is higher than accepted | Before Gate F |
| P6-A4 | Operations and support teams have sufficient context and access to operate the system independently after handover | technical | Extended hypercare; repeated escalations to the delivery team post-handover | Before Gate G |
| P6-A5 | Observability, dashboards, and alerting are fully functional in production before hypercare exit | technical | Operations operates blind during early-life period; incidents are detected late | Before Gate G |
| P6-A6 | The AI component behaves in production consistently with validation results | ai | Hypercare is extended; potential rollback or emergency re-tuning required | During subfase 6.4 |

---

## Phase 7 — Operate, Monitor and Improve

| ID | Description | Type | Typical Impact if Invalid | When to Validate |
|----|-------------|------|--------------------------|------------------|
| P7-A1 | Observability covers all critical paths and the AI component sufficiently to detect meaningful degradation | technical | Incidents or model drift are detected late or not at all | Before entering Phase 7 (verify at Gate G) |
| P7-A2 | Incident, problem, and change management processes are operational and staffed | external | Operational issues are not managed consistently; service quality degrades | Before entering Phase 7 |
| P7-A3 | The defined AI performance thresholds remain appropriate as usage patterns evolve | ai | Thresholds become misleading; teams intervene too early or too late | At scheduled AI monitoring reviews |
| P7-A4 | Feedback channels from users and operations are functional and regularly reviewed | business | Improvement signals are lost; product improvement is reactive rather than proactive | At each improvement review cycle |
| P7-A5 | Changes classified as maintenance do not cross into significant change territory without re-assessment | business | Uncontrolled accumulation of minor changes produces a material change without governance | At each change classification decision |
| P7-A6 | Compliance obligations remain stable or changes are detected and assessed before they become overdue | legal | Compliance gaps emerge in production; retroactive remediation is required | At each periodic compliance review |

---

## Phase 8 — Retire or Replace

| ID | Description | Type | Typical Impact if Invalid | When to Validate |
|----|-------------|------|--------------------------|------------------|
| P8-A1 | The retirement decision is legitimate, formally sponsored, and will not be reversed after decommissioning starts | business | Decommissioning is started and then reversed; costly and disruptive | Before starting Phase 8 |
| P8-A2 | All dependencies on the retiring system are identifiable from existing documentation and tooling | technical | Hidden dependencies discovered during decommissioning; service disruption | Before completing impact assessment |
| P8-A3 | Data retention and deletion obligations are known, scoped, and executable within the decommissioning timeline | legal | Legal or regulatory obligations breached; post-retirement audit findings | Before approving sunset plan |
| P8-A4 | Replacement systems or manual processes are in place and verified before the retiring system is taken offline | technical | Users or dependent systems are left without a working alternative | Before cutover in sunset plan |
| P8-A5 | Communication to affected users and teams can be completed within the planned notice period | external | Users are surprised by the retirement; reputational or contractual impact | Before finalising communications plan |
| P8-A6 | Access closure and credential revocation can be completed without disrupting other systems | technical | Shared credentials or access paths are disrupted unexpectedly | During decommissioning execution |
