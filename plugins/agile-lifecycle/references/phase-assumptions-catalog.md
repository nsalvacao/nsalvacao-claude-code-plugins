# Phase Assumptions Catalog

Catalog of common assumptions and required clarifications per lifecycle phase. Use when creating phase contracts or risk registers. Each entry is a starting point — adapt to your specific context.

---

## Phase 1 — Opportunity and Portfolio Framing

### Common Assumptions
- Problem is real and significant enough to justify investment
- Target users are identifiable and accessible for validation
- Business case is achievable within the organisation's investment appetite
- Regulatory landscape is understood at a high level
- An AI/ML approach is justified (data exists; problem is learnable)

### Required Clarifications Before Phase 2
- [ ] Who is the named sponsor and business owner?
- [ ] What is the success metric and target value?
- [ ] Is there an existing AI/ML capability or is this greenfield?
- [ ] What data sources are assumed to be available?
- [ ] What is the investment ceiling for this initiative?

---

## Phase 2 — Inception and Product Framing

### Common Assumptions
- Solution approach selected is technically feasible at the required scale
- Data quality and volume is sufficient for the chosen ML approach
- Infrastructure costs are within budget envelope
- Team has the required skills for the chosen technology stack
- Working Model and Governance Model will be agreed without significant conflict

### Required Clarifications Before Phase 3
- [ ] Is the data pipeline infrastructure already in place or must it be built?
- [ ] What are the non-negotiable non-functional requirements (latency, availability)?
- [ ] Are there any technology constraints (approved vendors, cloud providers)?
- [ ] What is the model retraining strategy (online vs. batch)?
- [ ] Who has final approval on the architecture design?

---

## Phase 3 — Discovery and Backlog Readiness

### Common Assumptions
- Acceptance criteria are stable and will not change significantly during Phase 4
- Sprint velocity estimates are realistic based on team capacity
- Test data is available for all test layers
- Definition of Done is agreed and non-negotiable
- User research participants are accessible and representative

### Required Clarifications Before Phase 4
- [ ] Are all team members confirmed and available for the full delivery period?
- [ ] What is the UAT participant recruitment plan?
- [ ] Are there any external dependencies that could block sprint execution?
- [ ] What is the escalation path if acceptance criteria need to change mid-sprint?
- [ ] Is the staging environment representative of production?

---

## Phase 4 — Iterative Delivery and Continuous Validation

### Common Assumptions
- Features are buildable within the sprint capacity without scope reduction
- Third-party APIs and services are available and performant in staging
- Code review can happen within the same sprint as implementation
- Integration testing environment is stable
- AI experiment results will be available within the sprint cycle

### Required Clarifications During Phase 4
- [ ] If a sprint item cannot complete: scope reduction or carry-over policy?
- [ ] If an architectural decision proves infeasible: who approves the ADR update?
- [ ] If a critical defect is found late: gate delay or conditional pass policy?
- [ ] What is the minimum test coverage threshold (cannot be waived)?
- [ ] If model performance does not meet targets: return to Phase 3 or accept with conditions?

---

## Phase 5 — Release, Rollout and Transition

### Common Assumptions
- Production environment is provisioned and matches the staging configuration
- Rollback procedure can be executed within 15 minutes of decision
- Users have been notified of the release with sufficient lead time
- On-call team is trained and ready for hypercare
- SLO monitoring tooling is operational before go-live

### Required Clarifications Before Go-Live
- [ ] What are the go/no-go criteria — who has authority to call no-go?
- [ ] What is the hypercare duration and exit criteria?
- [ ] Who is on-call for P1 incidents in the first 72 hours?
- [ ] What triggers an immediate rollback vs. a monitored incident?
- [ ] What data migration or user communication steps are required before deployment?

---

## Phase 6 — Operations, Measurement and Improvement

### Common Assumptions
- Operations team has sufficient context to manage the system independently
- Model drift thresholds are calibrated and retraining pipeline is automated
- Operational metrics are sufficient to detect degradation before users notice
- Continuous improvement process has executive sponsorship
- Gate F governance reviews will occur at the agreed 6-month cadence

### Required Clarifications for Gate F
- [ ] What is the SLO review cadence and who owns SLO target changes?
- [ ] At what adoption threshold is a pivot or retirement decision triggered?
- [ ] Who owns the improvement backlog and what is the release frequency for improvements?
- [ ] Is there a budget cycle alignment for the Gate F governance review?
- [ ] If model retraining is triggered: what approval is required before deploying a retrained model?

---

## Phase 7 — Retire or Replace

### Common Assumptions
- Retirement decision has been formally approved by the Steering Committee
- Data migration or archival obligations are understood before decommissioning begins
- Users and downstream integrations have been notified with adequate lead time
- Decommissioning will not create a service gap without a replacement in place

### Required Clarifications for Lifecycle Close
- [ ] What is the planned lifecycle for this product (run for N years, replace by X)?
- [ ] Who owns the decision to retire the system?
- [ ] What data retention obligations apply when the system is eventually retired?
- [ ] What lessons from this lifecycle should be formally captured for future initiatives?
- [ ] Are there any contractual or SLA obligations that affect the decommissioning timeline?
