# Role Accountability Model — Waterfall Lifecycle

## Important: Guidance, Not Enforcement

This document provides a **recommended** accountability model for the predictive lifecycle. It is guidance, not a fixed constraint.

Actual authority, role names, and sign-off obligations depend on your organisation's structure, governance model, and contractual context. The gate-reviewer agent in this lifecycle asks "who is the sign-off authority?" at gate time without enforcing a specific role. This reference document helps teams answer that question consistently.

Adapt freely. The goal is that someone owns each activity, someone approves each gate, and nobody is surprised by accountability at handover time.

---

## 1. Role Definitions

Standard roles referenced in this model. Teams may use different titles; map to these by function.

| Role | Function | Typical Accountability |
|------|----------|----------------------|
| **Product Owner** | Represents business and user interests; owns the product vision and priorities | Problem statement, requirements sign-off, acceptance criteria, UAT |
| **Technical Lead** | Leads engineering delivery; owns technical quality and implementation decisions | Build completeness, code quality, integration readiness |
| **Architect** | Owns solution design; accountable for architectural decisions and their traceability | HLD, LLD, ADR set, control matrix, design approval |
| **QA Lead** | Owns verification and validation strategy and execution | Test design, test execution evidence, defect triage, validation reports |
| **Data Engineer** | Owns data pipelines, dataset preparation, and data quality | Data requirements, dataset documentation, data closure |
| **AI/ML Engineer** | Owns model development, training, evaluation, and integration | AI design package, experiment log, model card, AI evaluation |
| **Security Lead** | Owns security architecture, security review, and control design | Security requirements, security design review, security validation |
| **Operations Lead** | Owns operational readiness, runbooks, and service acceptance | Runbooks, operational readiness review, operations acceptance |
| **Sponsor** | Holds executive accountability; approves funding, gates, and risk acceptance | Gate approval, waiver acceptance, retirement decision |
| **Governance Forum** | Collective body for major decisions; composition depends on org context | Gate decisions for significant phases, significant change approval |

---

## 2. Responsibility Matrix

RACI-style guidance for key lifecycle activities. Use as a starting point; adjust for your team structure.

**Key:** R = Responsible (does the work), A = Accountable (owns the outcome), C = Consulted, I = Informed, `—` = not typically involved

### Phase 1 — Opportunity and Feasibility

| Activity | Product Owner | Technical Lead | Architect | QA Lead | Security Lead | Operations Lead | Sponsor | Governance Forum | Notes |
|----------|--------------|----------------|-----------|---------|---------------|-----------------|---------|-----------------|-------|
| Define problem statement | R/A | I | C | — | C | I | C | I | PM may hold R if Product Owner is not yet engaged |
| Conduct feasibility assessment | C | C | R/A | — | C | C | I | I | Architecture leads technical feasibility |
| Assess data feasibility | C | C | C | — | C | — | I | — | Data Engineer typically does the work |
| Screen for AI feasibility | C | C | R | — | C | — | I | — | AI/ML Engineer supports this activity |
| Identify initial risks | C | C | C | — | R | C | A | C | Risk / Compliance owner may hold A |
| Draft project charter | R | C | C | — | — | — | A | C | PM typically drafts |
| Approve Gate A | C | C | C | — | — | — | A | C | Sponsor is minimum sign-off authority |

### Phase 2 — Requirements and Baseline

| Activity | Product Owner | Technical Lead | Architect | QA Lead | Security Lead | Operations Lead | Sponsor | Governance Forum | Notes |
|----------|--------------|----------------|-----------|---------|---------------|-----------------|---------|-----------------|-------|
| Elicit business requirements | R/A | C | C | C | C | C | I | I | BA supports Product Owner |
| Define AI acceptance criteria | R | C | C | R | — | — | I | — | QA Lead and AI/ML Engineer co-own |
| Define NFRs | C | R | A | C | R | R | I | — | Operations and Security own their respective NFR sets |
| Baseline requirements | A | C | C | C | C | C | C | I | PM or BA typically owns the baseline pack |
| Define acceptance criteria | R | C | C | R/A | — | — | I | — | QA Lead owns testability review |
| Approve Gate B | A | C | C | — | — | — | A | C | Sponsor or delegated authority minimum |

### Phase 3 — Architecture and Solution Design

| Activity | Product Owner | Technical Lead | Architect | QA Lead | Security Lead | Operations Lead | Sponsor | Governance Forum | Notes |
|----------|--------------|----------------|-----------|---------|---------------|-----------------|---------|-----------------|-------|
| Define solution architecture | C | C | R/A | C | C | C | I | I | Enterprise Architect may hold A in large orgs |
| Define control matrix | C | C | R | C | R/A | C | I | — | Security Lead holds accountability for security controls |
| Define test design | C | C | C | R/A | — | C | — | — | QA Lead owns the test design package |
| Conduct security design review | C | C | C | — | R/A | — | — | I | Privacy Lead co-owns where applicable |
| Approve Gate C | C | C | A | C | C | — | A | C | Design Authority may substitute for Governance Forum |

### Phase 4 — Build and Integration

| Activity | Product Owner | Technical Lead | Architect | QA Lead | Security Lead | Operations Lead | Sponsor | Governance Forum | Notes |
|----------|--------------|----------------|-----------|---------|---------------|-----------------|---------|-----------------|-------|
| Set up environments | I | C | C | C | C | R/A | I | — | DevOps / Platform Engineer typically does the work |
| Build application components | I | R/A | C | C | C | C | — | — | Engineering team delivers |
| Implement AI components | C | C | C | C | C | — | — | — | AI/ML Engineer is R; Technical Lead is A |
| Manage defect log | C | A | — | R | — | — | — | — | QA Lead maintains the log |
| Approve Gate D | C | A | C | C | — | — | — | C | Delivery Authority defined per project |

### Phase 5 — Verification and Validation

| Activity | Product Owner | Technical Lead | Architect | QA Lead | Security Lead | Operations Lead | Sponsor | Governance Forum | Notes |
|----------|--------------|----------------|-----------|---------|---------------|-----------------|---------|-----------------|-------|
| Execute functional testing | C | C | — | R/A | — | — | — | — | QA team executes |
| Execute security testing | — | C | — | C | R/A | — | — | — | Security Lead owns security validation |
| Execute AI validation | C | C | C | R | — | — | — | — | AI/ML Engineer and QA Lead co-own |
| Conduct UAT | R/A | I | — | C | — | C | I | — | Product Owner leads UAT acceptance |
| Approve waivers | A | C | C | C | C | C | A | C | Sponsor must approve significant waivers |
| Approve Gate E | A | C | C | A | C | C | A | C | Governance Forum for high-risk releases |

### Phase 6 — Release and Transition to Operations

| Activity | Product Owner | Technical Lead | Architect | QA Lead | Security Lead | Operations Lead | Sponsor | Governance Forum | Notes |
|----------|--------------|----------------|-----------|---------|---------------|-----------------|---------|-----------------|-------|
| Plan release and cutover | C | C | — | C | C | R | A | I | Release Manager may hold A |
| Execute deployment | I | R | — | C | C | R | I | — | Operations and Engineering co-own execution |
| Accept service (handover) | I | C | — | — | — | R/A | I | — | Operations Lead must formally accept |
| Run hypercare | C | R | — | C | — | R/A | I | — | Operations owns hypercare; Engineering supports |
| Approve Gate F | C | C | — | — | — | C | A | C | Release Authority minimum |
| Approve Gate G | C | C | — | — | — | A | C | I | Operations Lead is minimum sign-off |

### Phase 7 — Operate, Monitor and Improve

| Activity | Product Owner | Technical Lead | Architect | QA Lead | Security Lead | Operations Lead | Sponsor | Governance Forum | Notes |
|----------|--------------|----------------|-----------|---------|---------------|-----------------|---------|-----------------|-------|
| Operate and monitor service | C | I | — | — | C | R/A | I | — | Operations owns BAU |
| Monitor AI behaviour | R | C | — | C | — | R | I | — | AI/ML Engineer and Operations co-own |
| Classify and approve changes | R | C | C | C | C | C | C | A | Governance Forum approves significant changes |
| Update baselines | C | C | A | C | C | C | — | I | Architect owns design baseline updates |

### Phase 8 — Retire or Replace

| Activity | Product Owner | Technical Lead | Architect | QA Lead | Security Lead | Operations Lead | Sponsor | Governance Forum | Notes |
|----------|--------------|----------------|-----------|---------|---------------|-----------------|---------|-----------------|-------|
| Decide retirement | R | C | C | — | C | C | A | C | Sponsor holds final authority |
| Assess impact | C | C | R | — | C | R | I | I | Architecture and Operations co-own |
| Plan sunset | C | C | C | — | C | R/A | C | C | Operations owns execution planning |
| Execute decommissioning | C | R | — | — | R | R/A | I | — | Coordinated by Operations |
| Close data and access | — | C | — | — | R | R/A | I | — | Security and Operations co-own |
| Approve Gate H | A | C | — | — | C | C | A | C | Sponsor is minimum sign-off |

---

## 3. Sign-off Authority per Gate

Minimum required sign-off authority at each gate. Additional signatories are encouraged for high-risk or regulated contexts.

| Gate | Name | Minimum Sign-off Authority | Optional Additional Signatories | Notes |
|------|------|--------------------------|--------------------------------|-------|
| A | Initiation Approval | Sponsor | Governance Forum | For very small projects, a delegated product authority may suffice |
| B | Requirements Baseline Approval | Sponsor or delegated authority + Product Owner | Governance Forum, Security Lead | Architecture and QA should be consulted before sign-off |
| C | Design Approval | Architect + Sponsor | Design Authority, Security Lead, Governance Forum | Security Lead sign-off required if significant security architecture decisions were made |
| D | Build Complete / Integration Ready | Technical Lead (delivery authority) | Architect, QA Lead | Sponsor typically not required unless significant scope deviation occurred |
| E | Validation Complete / Release Readiness | QA Lead + Product Owner | Sponsor, Governance Forum, Security Lead | Sponsor endorsement required for significant waivers; Governance Forum for high-risk releases |
| F | Go-Live Approval | Sponsor (or delegated Release Authority) | Governance Forum, Operations Lead | Operations Lead must confirm readiness before Sponsor signs |
| G | Hypercare Exit / Service Acceptance | Operations Lead | Sponsor, Governance Forum | Operations Lead is the primary accountable party for service acceptance |
| H | Retirement Approval | Sponsor + Operations Lead | Governance Forum, Legal / Compliance | Legal / Compliance sign-off required where data retention or regulatory obligations are involved |

---

## 4. Hybrid Model Note

This accountability model is a guidance framework, not an enforcement mechanism. Organisations apply it differently:

**Smaller teams:** Roles collapse — the same person may be Product Owner, QA Lead, and PM. The model still applies: identify who holds each accountability, even if it is the same individual for multiple roles.

**Larger organisations:** Governance Forum may be mandatory for all gates. Design Authority may be separate from Sponsor. Security and Legal may be formal gate blockers.

**Regulated contexts:** Additional sign-off authorities may be required by regulation (e.g., Data Protection Officer for data-related gates, Responsible AI Officer for AI evaluation gates). Add these as mandatory additional signatories in your project context.

**Gate reviewer agent behaviour:** The gate-reviewer agent in this lifecycle does not enforce a specific sign-off authority. At each gate review, it asks: "Who is the sign-off authority for this gate?" and records the answer in the gate pack. The agent treats the response as the project's declared authority — it does not validate against this model. This is intentional: the model provides the reference; the project team owns the decision.

**When to deviate:** Deviations from this model are acceptable and expected. When deviating, record the rationale in the gate pack or project governance log. The key requirement is that accountability is explicit, not that it follows this specific model.
