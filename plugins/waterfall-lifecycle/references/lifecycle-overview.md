# Lifecycle Overview — Waterfall-Lifecycle Framework

## Framework Overview

The `waterfall-lifecycle` framework is a **formal predictive waterfall lifecycle** for AI/ML and software products in regulated, enterprise, and high-accountability environments. Its design principle is:

> Sequential phases with formal gate reviews, explicit handovers, controlled baselines, and V&V as a dedicated phase.

Unlike iterative frameworks, phases do not overlap. Work in Phase N is completed and formally accepted before Phase N+1 begins. Requirements are baselined before design starts. Design is approved before build begins. This structure makes scope, accountability, and evidence explicit at every transition.

**Target contexts:**
- Regulated industries (finance, healthcare, government, critical infrastructure)
- Solutions requiring formal audit trails and traceability
- High-risk AI systems requiring dedicated validation
- Enterprise delivery with multi-team coordination and formal governance forums
- Contracts requiring documented sign-off at phase transitions

**Diff vs agile-lifecycle:** See the explicit comparison at the end of this document. The key distinction is sequential vs iterative delivery: this framework does not run sprints inside phases. It runs structured workstreams that produce formal artefacts, validated at gates.

---

## Framework Summary

| Phase | Name | Subfases | Closing Gate |
|-------|------|----------|--------------|
| 1 | Opportunity and Feasibility | 1.1, 1.2, 1.3, 1.4 | A |
| 2 | Requirements and Baseline | 2.1, 2.2, 2.3, 2.4 | B |
| 3 | Architecture and Solution Design | 3.1, 3.2, 3.3 | C |
| 4 | Build and Integration | 4.1, 4.2, 4.3, 4.4 | D |
| 5 | Verification and Validation | 5.1, 5.2, 5.3, 5.4 | E |
| 6 | Release and Transition | 6.1, 6.2, 6.3, 6.4 | F |
| 7 | Operate, Monitor and Improve | 7.1, 7.2, 7.3 | G (mid-phase, Operational Review) |
| 8 | Retire or Replace | 8.1, 8.2 | H |

---

## Phase Descriptions

### Phase 1 — Opportunity and Feasibility

**Purpose:** Confirm that a real problem exists, that the opportunity has sufficient value and minimum viability, and that context is sufficient to initiate formal requirements. This phase must close all critical questions about why AI is justified, what the outcome boundaries are, and whether the project should proceed.

**Key subfases:**
- **1.1 Problem, value and context definition** — Problem statement, vision, stakeholder map, initial scope outline
- **1.2 Feasibility assessment** — Technical, data, AI, vendor, dependency, and cost/risk assessment
- **1.3 Risk, trust and compliance screening** — Initial risk register, compliance screening, privacy and AI governance triggers
- **1.4 Delivery framing and initiation** — Project charter, milestone map, governance model, initiation gate pack

**Primary workstreams:** Business/Product, Stakeholders, PM/Governance, Architecture, Data/AI, Security/Privacy, Risk, Legal/Compliance

**Gate reference:** Gate A — Initiation Approval (closes Phase 1)

---

### Phase 2 — Requirements and Baseline

**Purpose:** Transform the approved opportunity into a controlled requirements baseline with acceptance criteria and traceability sufficient to authorize formal design. Requirements ambiguities must be resolved. All critical functional, AI, non-functional, and control requirements must be documented and testable.

**Key subfases:**
- **2.1 Business and user requirements** — Business requirements set, use cases, user journeys, business rules, scope boundaries
- **2.2 Data and AI requirements** — Data requirements, AI requirements specification, AI acceptance criteria, control requirements for AI behavior
- **2.3 Non-functional and control requirements** — NFR specification, security requirements, operational requirements, observability requirements
- **2.4 Requirements consolidation and traceability** — SRS/requirements baseline, traceability matrix, acceptance criteria catalog, glossary, baseline approval pack

**Primary workstreams:** Business Analysis, Product, Stakeholders, PM, Data, AI/ML, Security/Privacy, Compliance, Architecture, QA, Operations

**Gate reference:** Gate B — Requirements Baseline Approval (closes Phase 2)

---

### Phase 3 — Architecture and Solution Design

**Purpose:** Define architecture, detailed design, control mechanisms, and test strategy with sufficient detail to authorize controlled build. All major architectural decisions must be documented. The test design package must be approved before Phase 4 starts.

**Key subfases:**
- **3.1 Solution architecture** — HLD, context and integration diagrams, environment strategy, security architecture decisions, ADR set
- **3.2 Detailed design** — LLD, interface specifications, data flow design, AI/ML design package, test design package, operational design package
- **3.3 Control design** — Control matrix, security design review, privacy design review, AI control design note, design approval pack

**Primary workstreams:** Enterprise/Solution Architecture, Security, Data, Operations, Engineering, AI/ML, QA, Privacy, Compliance, AI Governance

**Gate reference:** Gate C — Design Approval (closes Phase 3)

---

### Phase 4 — Build and Integration

**Purpose:** Build, integrate, and stabilize the solution in a controlled manner, producing verifiable increments against the approved baseline. Evidence of build quality, integration completeness, and minimum readiness for formal testing must be produced continuously.

**Key subfases:**
- **4.1 Environment and foundation setup** — Environment readiness record, CI/CD pipeline baseline, platform configuration, access model record
- **4.2 Application and integration build** — Build packages, code review records, test execution evidence, integration evidence, defect log
- **4.3 Data and AI implementation** — Dataset preparation records, experiment log, model package, evaluation evidence, model card or equivalent
- **4.4 System integration and readiness buildup** — Integration test evidence, readiness checklist draft, runbooks, support procedures, updated defect and risk logs

**Primary workstreams:** DevOps/Platform, Security, Operations, Engineering, Integration, QA, Data Engineering, AI/ML/LLM Engineering

**Gate reference:** Gate D — Build Complete / Integration Ready (closes Phase 4)

---

### Phase 5 — Verification and Validation

**Purpose:** Demonstrate with formal evidence that the solution satisfies requirements, controls, acceptance criteria, and operational readiness before production entry. V&V is a dedicated phase — not a subset of build. Residual risks, defects, and waivers must be formally documented before Gate E.

**Key subfases:**
- **5.1 Functional verification** — Functional test report, traceability completion evidence, defect closure evidence
- **5.2 Non-functional verification** — NFR test report, security validation report, resilience/recoverability evidence, observability validation report
- **5.3 AI validation** — AI evaluation report, safety/trust validation note, acceptance evidence for AI behavior, updated model card, issue log for residual risks
- **5.4 User and operational acceptance** — UAT report, operational readiness review, training completion evidence, acceptance sign-off or waiver log

**Primary workstreams:** QA, Business, Engineering, Performance, Security, Operations, AI/ML, Data, Product, AI Governance, Support, PM

**Gate reference:** Gate E — Validation Complete / Release Readiness (closes Phase 5)

---

### Phase 6 — Release and Transition

**Purpose:** Execute a controlled release, complete operational transition, and formalize service acceptance. The phase ends only when hypercare is closed and operations has formally accepted the service. Two gates govern this phase: Gate F authorizes production entry; Gate G closes hypercare.

**Key subfases:**
- **6.1 Release planning** — Release plan, cutover plan, rollback plan, communications plan, go-live criteria pack
- **6.2 Deployment and cutover** — Deployment record, cutover execution log, smoke test evidence, issue and incident log
- **6.3 Handover to operations** — Handover pack, operations acceptance, support readiness confirmation, AI ops handover note
- **6.4 Hypercare** — Hypercare report, early-life incident report, stabilization closure note

**Primary workstreams:** PM, Release Management, Operations, Business, Engineering, Security, Support, AI Ops/MLOps, Product

**Gate reference:** Gate F — Go-live Approval; Gate G — Hypercare Exit / Service Acceptance (closes Phase 6)

---

### Phase 7 — Operate, Monitor and Improve

**Purpose:** Operate the service in normal mode, monitor technical and AI behavior, manage incidents and problems, and execute controlled improvement. This phase has no fixed exit — it continues until a significant change or retirement decision is made. Gate G (mid-Phase 6/7 boundary) transitions from early-life to steady-state.

**Key subfases:**
- **7.1 Service operation** — Service reports, incident and problem records, change records, support metrics
- **7.2 AI operations and model monitoring** — AI monitoring reports, drift and degradation logs, model update decisions, AI incident records
- **7.3 Controlled improvement** — Improvement backlog, approved change requests, updated baselines, release recommendations

**Primary workstreams:** Operations, Support, Service Management, AI Ops/MLOps, Data, Product, Risk/Governance, PM, Engineering, Compliance

**Gate reference:** Gate G — Operational Review (mid-phase, triggers periodic governance); no recurring fixed gate. Significant changes must reopen formal governance. Retirement triggers transition to Phase 8.

---

### Phase 8 — Retire or Replace

**Purpose:** Formally close, replace, or consolidate the solution in a controlled manner. Preservation of evidence, data obligations, contract closure, access decommissioning, and formal sign-off are mandatory. No component of the solution should be decommissioned without a formal retirement decision and approved closure pack.

**Key subfases:**
- **8.1 Retirement decision** — Retirement decision record, impact assessment, sunset plan
- **8.2 Controlled decommissioning** — Decommissioning record, access closure evidence, data closure record, final closure pack

**Primary workstreams:** Product, Sponsors, PM, Operations, Risk/Compliance, Engineering, Security, Data

**Gate reference:** Gate H — Retirement Approval (closes Phase 8)

---

## Gate Summary

| Gate | Name | Timing | Phase Transition |
|------|------|--------|-----------------|
| A | Initiation Approval | End of Phase 1 | Phase 1 → Phase 2 |
| B | Requirements Baseline Approval | End of Phase 2 | Phase 2 → Phase 3 |
| C | Design Approval | End of Phase 3 | Phase 3 → Phase 4 |
| D | Build Complete / Integration Ready | End of Phase 4 | Phase 4 → Phase 5 |
| E | Validation Complete / Release Readiness | End of Phase 5 | Phase 5 → Phase 6 |
| F | Go-live Approval | Mid Phase 6 (pre-deployment) | Authorizes production entry |
| G | Hypercare Exit / Service Acceptance | End of Phase 6 / early Phase 7 | Early-life → Steady-state operations |
| H | Retirement Approval | End of Phase 8 | Lifecycle closure |

---

## State Machine — Phase-Level Transitions

The lifecycle state machine governs valid state transitions for each phase and subfase.

### Phase States

| Current State | Event | New State | Evidence Required | Who Triggers |
|---------------|-------|-----------|------------------|--------------|
| `not_started` | Phase entry criteria verified | `in_progress` | Entry criteria checklist signed off | Lifecycle Orchestrator / PM |
| `in_progress` | Blocker encountered | `blocked` | Blocker logged in dependency or risk register | Team / PM |
| `blocked` | Blocker resolved | `in_progress` | Dependency log closed with resolution evidence | Owner / PM |
| `in_progress` | All subfases complete, artefacts ready | `ready_for_gate` | Exit criteria met, artefact checklist complete | PM |
| `ready_for_gate` | Gate passes | `approved` | Gate Review Record (outcome: pass) | Gate Reviewer |
| `ready_for_gate` | Gate fails | `rejected` | Gate Review Record (outcome: fail) with remediation log | Gate Reviewer |
| `ready_for_gate` | Gate waived | `waived` | Waiver Log entry, Gate Review Record (outcome: waiver), risk acceptance signed | Gate Reviewer + Waiver Authority |
| `approved` | Next phase starts or lifecycle closes | `closed` | Next phase entry record or Final Closure Pack | PM / Steering |
| `rejected` | Remediation complete | `in_progress` | Remediation evidence, updated artefacts | PM |
| `waived` | Waiver conditions fulfilled | `closed` | Waiver conditions marked complete in Waiver Log | Gate Reviewer |

### Subfase States

| Current State | Event | New State | Evidence Required | Who Triggers |
|---------------|-------|-----------|------------------|--------------|
| `not_started` | Subfase started | `in_progress` | Phase entry criteria verified | Subfase Owner / PM |
| `in_progress` | Work blocked | `blocked` | Clarification or dependency log entry | Team |
| `blocked` | Unblocked | `in_progress` | Resolution documented in dependency log | Owner |
| `in_progress` | Exit criteria met, artefacts produced | `ready_for_gate` | Artefacts complete, exit criteria checked | PM / Owner |
| `ready_for_gate` | Review passed | `closed` | Sign-off from designated sign-off authority | Sign-off Authority |
| `ready_for_gate` | Review rejected | `in_progress` | Rejection documented, remediation planned | Reviewer |
| `closed` | — | — | No further transitions | — |

---

## Operational Objects

Eight mandatory registers must exist throughout the lifecycle, created in Phase 1 and updated continuously:

| Register | Description |
|----------|-------------|
| **Risk register** | Tracks identified risks, owners, likelihood, impact, mitigation status, and residual risk acceptance |
| **Assumption register** | Tracks all explicit assumptions with owner, origin phase, validation deadline, and impact if invalid |
| **Clarification / open decision log** | Tracks open questions, pending decisions, owners, deadlines, and blocking status |
| **Dependency log** | Tracks external and internal dependencies, owners, status, and blocking impact on the schedule |
| **Requirements traceability matrix** | Maps requirements → design decisions → build items → test cases → test results |
| **Change log** | Tracks change requests post-baseline: classification (minor / significant), impact assessment, decision, and baseline update |
| **Evidence index** | Indexes all artefacts by phase, gate, owner, location, and validity state |
| **Handover log** | Records all explicit handovers between phases: scope delivered, baseline applicable, known risks, open issues, and formal acceptance |

---

## Diff vs agile-lifecycle

| Dimension | waterfall-lifecycle | agile-lifecycle |
|-----------|--------------------|--------------------|
| **Phase structure** | 8 sequential phases; prior phase must close before next begins | 7 phases; phases can have overlapping work, with sprints inside phases |
| **Gates** | 8 gates (A–H); each gate is a formal go/no-go decision; no phase proceeds without gate approval | 6 gates (A–F); gates are governance checkpoints but teams iterate inside phases |
| **Handovers** | Explicit, documented, formally accepted at every phase boundary; no tribal handovers | Handovers exist but are lighter; team continuity across phases reduces formal handover weight |
| **Requirements** | Fully baselined and frozen before design begins (Phase 2 → Gate B); changes require formal change control | Requirements are shaped iteratively; backlog grooming occurs throughout; no single freeze point |
| **Verification & Validation** | Dedicated phase (Phase 5) with formal V&V test reports, AI validation, UAT, and operational readiness — not a subfase of build | Continuous validation inside Phase 4 sprints; no dedicated V&V phase; release readiness is a gate criterion |
| **Baselines** | Requirements baseline, design baseline, build baseline — all formal; changes trigger change control | Product vision and backlog are living artefacts; formal baselines exist only for release artefacts |
| **Phase states** | 8 states: `not_started`, `in_progress`, `blocked`, `ready_for_gate`, `approved`, `rejected`, `waived`, `closed` | Same 8 states; but `ready_for_gate` → `approved` cycle is more frequent and faster |
| **AI treatment** | AI requirements, design, implementation, and validation are separated into distinct workstreams per phase; Gate E requires formal AI validation evidence | AI activities distributed across phases (discovery, delivery, ops); no dedicated AI validation gate |
| **Target context** | Regulated environments, high-risk AI, formal audit requirements, multi-team structured delivery, contracts with phase sign-off obligations | Product-led organizations, iterative SaaS, teams that need velocity with governance rails, lower compliance overhead |

---

## Related References

- `references/gate-criteria-reference.md` — detailed gate criteria, pass/fail rules, evidence thresholds, waivers
- `references/artefact-catalog.md` — full artefact catalog with closure obligations
- `references/tailoring-guide.md` — product type tailoring profiles (SaaS, web, desktop, CLI)
- `references/genai-overlay.md` — GenAI/LLM-specific controls by phase
- `schemas/lifecycle-state.schema.json` — machine-readable lifecycle state schema
