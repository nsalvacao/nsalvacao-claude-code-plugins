# Role Accountability Model — waterfall-lifecycle

**IMPORTANT — This document is guidance, not enforcement.**

Roles defined here are recommendations. Actual authority, accountability, and team structure depend on organisation size, governance model, project criticality, and regulatory context. The gate-reviewer agent asks "who is the sign-off authority?" without enforcing a fixed role — the answer should come from your project governance, not from this document.

---

## 1. Role Definitions

| Role | Typical Responsibilities | Phase Presence |
|---|---|---|
| **Product Owner** | Owns the product vision, prioritises requirements, accepts the product on behalf of the business | Phases 1–7 |
| **Sponsor** | Provides funding authority, escalation path, and formal gate approvals | All phases |
| **Governance Forum** | Collective decision-making body for gate approvals and significant changes | All phases (as applicable) |
| **PM (Project Manager)** | Plans and tracks delivery, manages risks and issues, coordinates handovers | All phases |
| **Business Analyst** | Elicits, documents, and baselines requirements; maintains traceability | Phases 1–3, 5 |
| **Architect** | Owns solution architecture, key design decisions, and technical integrity | Phases 2–4 |
| **Technical Lead** | Leads engineering team, oversees build quality and integration | Phases 3–5 |
| **QA Lead** | Owns test strategy, validation execution, and V&V sign-off | Phases 3–6 |
| **Data Engineer** | Owns data pipelines, data quality, and data readiness for AI | Phases 1–5, 7 |
| **AI/ML Engineer** | Owns model design, training, evaluation, and AI integration | Phases 1–5, 7 |
| **Security Lead** | Reviews security controls, threat model, and compliance posture across phases | Phases 1–6 |
| **Operations Lead** | Owns operational readiness, runbooks, monitoring, and service acceptance | Phases 3, 6–8 |

---

## 2. Responsibility by Phase

`P = Primary` — accountable for phase output and gate readiness
`S = Support` — active contribution expected
`I = Informed` — kept up to date; consulted as needed

| Phase | Primary | Support | Informed |
|---|---|---|---|
| **1 — Opportunity and Feasibility** | PM, Product Owner | Business Analyst, Data Engineer, AI/ML Engineer, Security Lead | Architect, QA Lead, Operations Lead |
| **2 — Requirements and Baseline** | Business Analyst, PM | Product Owner, Data Engineer, AI/ML Engineer, Security Lead | Architect, QA Lead, Operations Lead |
| **3 — Architecture and Solution Design** | Architect, PM | Technical Lead, Security Lead, QA Lead, Data Engineer, AI/ML Engineer | Operations Lead, Product Owner |
| **4 — Build and Integration** | Technical Lead, PM | Architect, Data Engineer, AI/ML Engineer, Security Lead | QA Lead, Operations Lead, Product Owner |
| **5 — Verification and Validation** | QA Lead, PM | Technical Lead, Business Analyst, AI/ML Engineer, Data Engineer | Operations Lead, Product Owner, Sponsor |
| **6 — Release and Transition to Operations** | PM, Operations Lead | Technical Lead, QA Lead, Security Lead | Product Owner, Sponsor |
| **7 — Operate, Monitor and Improve** | Operations Lead, Product Owner | AI/ML Engineer, Data Engineer, Security Lead | PM, Sponsor |
| **8 — Retire or Replace** | PM, Operations Lead | Data Engineer, Security Lead, Technical Lead | Product Owner, Sponsor |

---

## 3. Gate Sign-off Authority (Guidance)

The following are minimum recommended sign-off roles per gate. Additional stakeholders may be included depending on project governance, regulatory requirements, or organisational policy.

| Gate | Recommended Minimum Sign-off | Optional Additional |
|---|---|---|
| **Gate A — Initiation approval** | Sponsor | Governance Forum |
| **Gate B — Requirements baseline approval** | Sponsor + Technical Lead | Governance Forum, Security Lead |
| **Gate C — Design approval** | Sponsor + Architect | Governance Forum, Security Lead |
| **Gate D — Build complete / integration ready** | Technical Lead + QA Lead | PM, Architect |
| **Gate E — Validation complete / release readiness** | QA Lead + Sponsor | Governance Forum, Security Lead, Operations Lead |
| **Gate F — Go-live approval** | Sponsor + Operations Lead | Governance Forum, Release Manager |
| **Gate G — Hypercare exit / service acceptance** | Operations Lead | Sponsor, PM |
| **Gate H — Retirement approval** | Sponsor | Governance Forum, Operations Lead |

---

## 4. Hybrid Model Note

This model is intentionally flexible. In practice:

- **Small teams**: one person may fill multiple roles (e.g., PM + Product Owner, Architect + Technical Lead). What matters is that each accountability is explicitly owned by a named person — not that separate individuals hold each role.

- **Enterprise contexts**: governance forums, change advisory boards, or release authority panels may replace or supplement individual sign-off roles. The model above provides a minimum baseline; organisations should layer their own governance on top.

- **AI-specific roles**: Data Engineer and AI/ML Engineer may be the same person on small teams, or may involve external vendors. Regardless of team structure, the accountability for data readiness and model evaluation must be explicitly owned.

- **The gate-reviewer agent**: when the agent asks "who is the sign-off authority?", the answer should come from your project governance model, not from this document. This document helps you think through that question — it does not answer it for you.

- **Role absence is a risk**: if a role listed as Primary or Support for a phase is not filled, that gap should be recorded in the risk register and explicitly mitigated (e.g., by assigning the accountability to a named person in a different role, or by escalating to the sponsor).
