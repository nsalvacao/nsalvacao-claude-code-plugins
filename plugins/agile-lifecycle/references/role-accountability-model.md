# Role Accountability Model

Maps core roles to responsibilities per lifecycle phase and sign-off authority per gate. Use when creating phase contracts or resolving accountability ambiguities.

---

## Core Roles

| Role | Abbreviation | Primary Accountability |
|------|-------------|------------------------|
| Product Owner | PO | Product direction, acceptance criteria, scope decisions, stakeholder alignment |
| Product Manager | PM | Delivery governance, artefact ownership, gate preparation, risk tracking |
| Engineering Lead | EL | Architecture integrity, code quality, technical decision-making, deployment |
| Delivery Lead | DL | Sprint execution, capacity management, timeline, escalation management |
| Sponsor | SP | Investment decisions, strategic alignment, executive sign-off |
| UX Lead | UX | User research, discovery findings, user journey mapping |
| QA Lead | QA | Quality standards, test strategy, validation evidence, defect management |
| Operations Lead | OL | Production reliability, SLO management, incident response, ops transition |
| Data Lead | DT | Data quality, data pipeline, data readiness, data governance |
| ML Lead | ML | AI/ML model development, experiment tracking, model validation, AI monitoring |
| Steering Committee | SC | Portfolio governance, Gate F decisions, continue/pivot/retire authority |

---

## Accountability by Phase

### Phase 1 — Opportunity and Portfolio Framing
| Activity | Responsible | Accountable | Consulted | Informed |
|----------|-------------|-------------|-----------|---------|
| Opportunity framing | PO | SP | EL, DT | PM |
| Early feasibility assessment | EL | EL | DT, ML | PM, PO |
| AI/Data feasibility assessment | DT / ML | EL | — | PM, PO |
| Stakeholder mapping | PM | PM | PO | SP |
| Initial risk register | PM | PM | EL, DT | SP |
| Funding recommendation | PM | SP | PO | EL |
| Portfolio decision | SC | SP | PM, PO | EL |

### Phase 2 — Inception and Product Framing
| Activity | Responsible | Accountable | Consulted | Informed |
|----------|-------------|-------------|-----------|---------|
| Product vision and goal set | PO | PO | SP, EL | PM |
| Working model and governance | PM | PM | EL, DL, QA | SP, PO |
| Role-responsibility map | PM | PM | EL, DL | SP |
| Initial architecture and ADRs | EL | EL | DT, ML, QA | PM, PO |
| Initial roadmap | PM + PO | PO | EL | SP |
| Risk register update | PM | PM | EL | SP |
| Inception closure pack | PM | PM + PO | EL | SP |

### Phase 3 — Discovery and Backlog Readiness
| Activity | Responsible | Accountable | Consulted | Informed |
|----------|-------------|-------------|-----------|---------|
| User research and discovery | UX | PM | PO | EL |
| Pain point mapping and user journeys | UX | PM | PO | EL |
| Acceptance criteria catalog | PO | PO | QA, DL | EL, PM |
| AI backlog items | ML / PO | ML | EL, DT | PM |
| Data readiness assessment | DT | DT | ML, EL | PM, PO |
| Backlog readiness review | DL | PO | QA, EL | PM |
| Readiness notes | PO + DL | PO | EL, QA | PM |

### Phase 4 — Iterative Delivery and Continuous Validation
| Activity | Responsible | Accountable | Consulted | Informed |
|----------|-------------|-------------|-----------|---------|
| Sprint planning | DL | EL | PO, QA | PM |
| Feature implementation | EL (Dev Team) | EL | QA | PM, DL |
| AI delivery loop (experiments) | ML | ML | EL, DT | PM, QA |
| Continuous validation | QA | QA | EL | PM, DL |
| Sprint review and adaptation | PM | PO | EL, DL, QA | SP |
| Sprint health tracking | DL | PM | QA | SP |
| Release readiness evidence assembly | PM | PM | EL, QA | SP |

### Phase 5 — Release, Rollout and Transition
| Activity | Responsible | Accountable | Consulted | Informed |
|----------|-------------|-------------|-----------|---------|
| Release readiness assessment | PM | PO | EL, QA, OL | SP |
| Go/no-go decision | PM + OL | PO | EL, QA | SP |
| Deployment execution | EL | EL | OL | PM, DL |
| Rollout strategy execution | EL / OL | EL | PM | PO |
| Operational transition | OL + PM | OL | EL | SP |
| Hypercare monitoring | OL | PM | EL | SP, PO |

### Phase 6 — Operations, Measurement and Improvement
| Activity | Responsible | Accountable | Consulted | Informed |
|----------|-------------|-------------|-----------|---------|
| Service operations and SLO monitoring | OL | OL | EL | PM |
| Product analytics reporting | PM | PO | OL | SP |
| AI/ML monitoring and drift detection | ML | OL | EL, DT | PM |
| Improvement backlog management | DL | PM + PO | OL, QA | SP |
| Change recommendations | PM | PO | EL, OL | SP |
| Gate F governance preparation | PM | PM | OL, ML | SP, SC |

### Phase 7 — Retire or Replace
| Activity | Responsible | Accountable | Consulted | Informed |
|----------|-------------|-------------|-----------|---------|
| Retirement decision | PM | SP | EL, OL | SC, DL |
| Impact assessment | PM | PM | EL, OL, DT | SP |
| Sunset plan | PM + EL | PM | OL, DT | SP, SC |
| Decommissioning execution | EL | EL | OL, DT | PM |
| Final closure pack | PM | SP | EL, OL | SC |

---

## Gate Sign-off Authority

| Gate | Name | Description | Sign-off Authority | Quorum Required |
|------|------|-------------|-------------------|-----------------|
| A | Portfolio Entry | Phase 1 → Phase 2 | Governance Board / SP | SP + PO |
| B | Inception Closure | Phase 2 → Phase 3 | PO + EL (joint), SC aware | PO + EL |
| C | Backlog Readiness | Phase 3 → Phase 4 | PO + DL (joint) | PO + DL |
| D | Release Authorization | Phase 4 → Phase 5 | SC or delegated Release Authority | PO + EL + OL |
| E | Operations Handover | Phase 5 → Phase 6 | OL + PO (joint) | OL + PO |
| F | Governance Review | Periodic in Phase 6 | SC or Portfolio Governance Board | SC + PM |

---

## Escalation Path

| Issue Type | First Escalation | Second Escalation | Final Authority |
|-----------|-----------------|-------------------|-----------------|
| Scope change | PO | SP | SP |
| Architecture decision | EL | EL + SC if cross-system | EL |
| Quality gate waiver | QA | EL | EL + PO (joint) |
| Timeline slip | DL | PM | SP |
| Critical defect in production | OL | EL | EL + PM |
| Gate rejection | PM | SP | SP |
| Budget overrun | PM | SP | SP |
| AI model performance failure | ML | EL | EL + PO |
| Data blocker | DT | EL | EL + PM |
