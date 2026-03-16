# Phase Assumptions Catalog — waterfall-lifecycle

Typical assumptions for each of the 8 phases. These are starting points for the Assumption Register — not an exhaustive or prescriptive list.

**Types**: technical, business, data, ai, legal, external

---

## Phase 1 — Opportunity and Feasibility — Typical Assumptions

| ID | Description | Type | Typical Impact if Invalid | When to Validate |
|---|---|---|---|---|
| A1.1 | Business problem is stable and will not change materially during feasibility | business | Phase 1 rework required; scope reset | Before Phase 2 start |
| A1.2 | Required data sources exist and are accessible in principle | data | AI approach may be infeasible; Phase 1 conclusion invalidated | During Phase 1.2 |
| A1.3 | AI/ML approach is technically viable for the identified problem | ai | Solution redesign required; Phase 1 exit blocked | During Phase 1.2 |
| A1.4 | Legal and compliance constraints are fully known and documented | legal | Scope change, late-stage redesign, or project cancellation | Before Gate A |
| A1.5 | Sponsor is available, committed, and empowered to approve | business | Phase delays, scope drift, gate decision blocked | Throughout Phase 1 |
| A1.6 | No show-stopping regulatory obligation specific to this AI use case | legal | Governance reframing required before Phase 2 | During Phase 1.3 |
| A1.7 | Key stakeholders are identifiable and willing to participate in feasibility | business | Stakeholder map incomplete; critical requirements missed | During Phase 1.1 |

---

## Phase 2 — Requirements and Baseline — Typical Assumptions

| ID | Description | Type | Typical Impact if Invalid | When to Validate |
|---|---|---|---|---|
| A2.1 | The correct stakeholders are represented in requirements elicitation | business | Requirements incomplete or misaligned; rework post-baseline | Before elicitation begins |
| A2.2 | Business context is sufficiently stable for requirements baselining | business | Baseline invalidated; change management overhead increases | Before Gate B |
| A2.3 | Requirements can be expressed in testable, unambiguous language | technical | Acceptance criteria undefined; test coverage gaps | During Phase 2 elicitation |
| A2.4 | AI performance thresholds can be agreed and are measurable | ai | V&V criteria undefined; release decision blocked | During Phase 2.2 |
| A2.5 | Data required for AI training, inference, or evaluation is available and lawful | data | Requirements baseline incomplete; AI scope reduced | During Phase 2.1 |
| A2.6 | Third-party dependencies (APIs, models, datasets) have acceptable licence terms | legal | Integration scope changes; cost impact | Before Gate B |
| A2.7 | Change control will be respected post-baseline; no informal scope additions | business | Requirements drift; traceability broken | Throughout Phase 2 and beyond |
| A2.8 | Regulatory or compliance requirements are stable for the duration of design and build | legal | Rework in later phases; gate re-approval required | Before Gate B |

---

## Phase 3 — Architecture and Solution Design — Typical Assumptions

| ID | Description | Type | Typical Impact if Invalid | When to Validate |
|---|---|---|---|---|
| A3.1 | Requirements baseline is sufficiently stable to base architecture decisions on | business | Architecture invalidated; design rework required | Before Phase 3 begins |
| A3.2 | Principal external components (cloud services, APIs, models) are integrable under expected conditions | technical | Solution redesign; vendor negotiations required | During Phase 3.2 |
| A3.3 | Performance and scalability targets can be met with the selected architecture | technical | NFRs unmet; architectural pivot required in later phases | During Phase 3.1 |
| A3.4 | Security and privacy controls can be implemented within the proposed architecture | technical | Architectural rework; compliance gap | During Phase 3.3 |
| A3.5 | The test strategy is executable within available environments, data, and timeline | technical | Test coverage gaps; validation delays | During Phase 3.4 |
| A3.6 | Human oversight mechanisms are technically feasible within the solution architecture | ai | AI governance requirements unmet; Gate C blocked | During Phase 3.1 |
| A3.7 | The rollback mechanism is technically viable for the chosen deployment model | technical | Release risk unacceptable; Phase 6 planning impacted | During Phase 3.4 |

---

## Phase 4 — Build and Integration — Typical Assumptions

| ID | Description | Type | Typical Impact if Invalid | When to Validate |
|---|---|---|---|---|
| A4.1 | Build environments are available and stable throughout the build phase | technical | Build delays; defects caused by environment instability | Before Phase 4 begins |
| A4.2 | Design artefacts are sufficiently detailed for implementation without major clarification cycles | technical | Build blocked; rework and design re-engagement required | Before Phase 4 begins |
| A4.3 | External data sources, APIs, and models are accessible and stable during integration | external | Integration failures; timeline slippage | During Phase 4.3 |
| A4.4 | The team has the skills and tooling required for build, integration, and quality verification | technical | Velocity below plan; quality gates missed | Before Phase 4 begins |
| A4.5 | Code review and quality checks are sufficient to detect issues before validation | technical | Defect leakage into V&V; validation delays | Throughout Phase 4 |
| A4.6 | AI model or integration behaves within expected parameters in the development environment | ai | Model rework required; integration re-testing needed | During Phase 4.3 |
| A4.7 | Defects identified during build can be resolved within Phase 4 timeline | technical | Validation scope reduced; waivers required in Phase 5 | Throughout Phase 4 |

---

## Phase 5 — Verification and Validation — Typical Assumptions

| ID | Description | Type | Typical Impact if Invalid | When to Validate |
|---|---|---|---|---|
| A5.1 | Validation environments are representative of the intended production context | technical | Test results unreliable; release risk not accurately assessed | Before validation begins |
| A5.2 | Test data is adequate in scope, quality, and representativeness for all critical scenarios | data | Coverage gaps; AI evaluation results unreliable | Before validation begins |
| A5.3 | All critical acceptance criteria are defined, agreed, and measurable | business | Pass/fail decision contested; sign-off blocked | Before Phase 5 begins |
| A5.4 | Stakeholders required for UAT are available within the planned timeline | business | UAT delayed or incomplete; Gate E impacted | During Phase 5 planning |
| A5.5 | AI evaluation methodology is agreed and produces trusted evidence | ai | AI readiness cannot be formally established; waiver required | During Phase 5.1 |
| A5.6 | Residual defects that carry into release are known, bounded, and formally accepted | technical | Release decision delayed; governance risk | Before Gate E |
| A5.7 | Operations and support have visibility of the solution during validation to confirm readiness | external | Operational readiness not established; Gate E blocked | During Phase 5.4 |

---

## Phase 6 — Release and Transition to Operations — Typical Assumptions

| ID | Description | Type | Typical Impact if Invalid | When to Validate |
|---|---|---|---|---|
| A6.1 | The release window is available and will not be disrupted by external events | external | Go-live postponed; release plan rescheduled | Before Gate F |
| A6.2 | All stakeholders required for cutover are available and briefed | business | Cutover execution risk; decisions delayed | Before go-live |
| A6.3 | Rollback remains technically viable after cutover commences | technical | Irreversible state change if release fails; high residual risk | Before go-live execution |
| A6.4 | Operations and support teams have sufficient context and tooling to operate from day one | external | Incident risk in hypercare; escalation to delivery team required | Before Operations Acceptance |
| A6.5 | Hypercare criteria are agreed and the delivery team remains available for the hypercare period | business | Hypercare exit decision contested; support gap | Before Gate G |
| A6.6 | User training and documentation are adequate for initial adoption | business | User error rate elevated; support volume above plan | Before go-live |

---

## Phase 7 — Operate, Monitor and Improve — Typical Assumptions

| ID | Description | Type | Typical Impact if Invalid | When to Validate |
|---|---|---|---|---|
| A7.1 | Monitoring and observability cover all critical failure modes and AI performance indicators | technical | Incidents missed; AI drift undetected | At service acceptance and periodically |
| A7.2 | Incident and problem management processes are active and aligned to service agreements | external | Response SLAs missed; issues unresolved | At start of Phase 7 |
| A7.3 | AI model performance will remain within acceptable bounds without re-training for the planned period | ai | Re-training or rollback required earlier than planned | Periodically via AI monitoring reports |
| A7.4 | Change requests follow the agreed change management process | business | Uncontrolled changes; traceability broken; compliance risk | Throughout Phase 7 |
| A7.5 | The legal and regulatory environment does not change materially during operations | legal | Compliance gap; emergency rework required | Periodically and at major regulatory updates |
| A7.6 | Operational data can be used for monitoring, improvement, and re-training under the original legal basis | data | Monitoring or re-training approach changes required | Before using operational data for AI |
| A7.7 | The product owner has authority and budget to execute approved improvements | business | Improvement backlog stagnates; service quality degrades | At operational review cycles |

---

## Phase 8 — Retire or Replace — Typical Assumptions

| ID | Description | Type | Typical Impact if Invalid | When to Validate |
|---|---|---|---|---|
| A8.1 | The retirement decision is legitimate, formally approved, and will not be reversed | business | Decommission work wasted; operational risk if partially decommissioned | Before Gate H |
| A8.2 | All dependent systems, integrations, and users have been identified | technical | Unexpected failures at decommission; user impact unmanaged | During Phase 8.1 |
| A8.3 | Data retention and disposal requirements are fully known and achievable within timeline | legal | Compliance breach; legal liability if data deleted prematurely or retained too long | Before decommission begins |
| A8.4 | A replacement solution is ready (if applicable) before the current solution is decommissioned | external | Service gap; user disruption; rollback required | Before decommission begins |
| A8.5 | Sufficient technical capacity exists to execute decommissioning while maintaining any remaining services | technical | Decommission delayed; risk to ongoing operations | Before Phase 8 begins |
| A8.6 | Vendors and third parties will cooperate with contract termination and access revocation | external | Legal or contractual disputes; delayed closure | During Phase 8.2 |
| A8.7 | Evidence and audit records required post-retirement are identified and preserved before decommission | legal | Audit obligations unmet; regulatory risk post-closure | Before decommission begins |
