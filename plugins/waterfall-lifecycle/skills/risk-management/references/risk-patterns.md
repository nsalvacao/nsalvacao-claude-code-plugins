# Risk Patterns Reference

Reference material for the `risk-management` skill. Covers the likelihood-impact matrix, risk category patterns, mitigation language templates, and quick-entry format.

---

## 1. Likelihood-Impact Matrix (5×5)

Score = Likelihood × Impact. Assign both values on a 1–5 scale, then multiply.

| Likelihood \ Impact | 1 — Negligible | 2 — Minor | 3 — Moderate | 4 — Major | 5 — Critical |
|---------------------|---------------|-----------|--------------|-----------|--------------|
| **5 — Almost certain** | 5 MEDIUM | 10 HIGH | 15 HIGH | 20 CRITICAL | 25 CRITICAL |
| **4 — Likely**         | 4 LOW    | 8 MEDIUM | 12 HIGH | 16 HIGH    | 20 CRITICAL |
| **3 — Possible**       | 3 LOW    | 6 MEDIUM | 9 MEDIUM | 12 HIGH   | 15 HIGH     |
| **2 — Unlikely**       | 2 LOW    | 4 LOW    | 6 MEDIUM | 8 MEDIUM  | 10 HIGH     |
| **1 — Rare**           | 1 LOW    | 2 LOW    | 3 LOW    | 4 LOW     | 5 MEDIUM    |

### Severity Bands and Response

| Band | Score Range | Response |
|------|-------------|----------|
| LOW | 1–4 | Monitor quarterly; no immediate action required |
| MEDIUM | 5–9 | Mitigate or accept with documented justification |
| HIGH | 10–16 | Mitigate; flag in phase contract; report at every gate |
| CRITICAL | 17–25 | Immediate escalation to sign-off authority; can block gate |

---

## 2. Risk Categories with Typical Patterns

### Technical

| Pattern | Description |
|---------|-------------|
| Architecture complexity | Selected architecture exceeds team capability or introduces hidden coupling that increases delivery risk |
| Integration failure | External system or internal module does not behave as specified; interface contracts are ambiguous or undocumented |
| Performance degradation | Solution cannot meet non-functional performance requirements (latency, throughput, concurrency) under realistic load |
| Scalability limits | Design works at current data/user volume but fails to scale to projected production levels within the contract timeline |
| Tech debt accumulation | Shortcuts taken during earlier phases create compounding risk in later phases; no remediation plan exists |

### Business

| Pattern | Description |
|---------|-------------|
| Scope creep | Stakeholders introduce new requirements mid-phase without a formal contract amendment, inflating delivery scope |
| Stakeholder misalignment | Key stakeholders have divergent expectations on deliverables, priorities, or success criteria not captured in the contract |
| Budget overrun | Phase costs exceed contracted budget envelope; no contingency reserve exists or has already been consumed |
| Timeline slip | Cumulative delays cause the phase to miss its contracted end date, creating downstream phase dependency failures |
| ROI assumption failure | Business case assumptions (adoption rate, cost savings, revenue uplift) prove incorrect, undermining project justification |

### Data

| Pattern | Description |
|---------|-------------|
| Data quality degradation | Source data has higher-than-acceptable error rates, missing values, or inconsistencies that invalidate downstream processing |
| Data access revoked | Access rights to required datasets are removed or not granted by the contracted date, blocking development or testing |
| Privacy/GDPR violation | Data handling, storage, or transfer practices are found to be non-compliant with applicable privacy regulations |
| Data drift in production | Statistical properties of production data diverge from training or test data, causing model or rule-based logic to degrade |
| Insufficient data volume | Available data volume is too low to meet statistical confidence requirements for model training, testing, or reporting |

### AI/ML

| Pattern | Description |
|---------|-------------|
| Model accuracy below threshold | Trained model fails to meet the contracted minimum accuracy, F1, or business-defined performance metric |
| Training data bias | Training dataset contains systematic bias that causes the model to perform unequally across demographic or operational segments |
| Model drift post-deployment | Model performance degrades over time in production as real-world data distribution shifts from the training distribution |
| LLM hallucination (GenAI) | Large language model generates factually incorrect or fabricated outputs in a context where accuracy is contractually required |
| Explainability requirements unmet | Regulatory or stakeholder requirements for model explainability cannot be satisfied by the chosen model architecture |

### Legal

| Pattern | Description |
|---------|-------------|
| Regulatory non-compliance | Solution design or data handling violates applicable regulations (GDPR, AI Act, sector-specific rules) identified post-contract |
| IP ownership dispute | Ownership of generated artefacts, trained models, or derived data is contested between parties |
| AI liability gap | Contractual or regulatory liability for AI-generated decisions is undefined, creating legal exposure for the organisation |
| Export control violation | Data, models, or software components are subject to export control restrictions not identified during procurement |

### Operational

| Pattern | Description |
|---------|-------------|
| Team capability gap | The team lacks skills required for a phase deliverable; no training or hiring plan is in place within the phase timeline |
| Critical vendor dependency | A single vendor supplies a critical component with no alternative; vendor delay or failure has no mitigation path |
| Runbook incompleteness | Operational runbooks for go-live are incomplete or untested, creating risk of production incidents post-deployment |
| Operational readiness failure | The receiving operational team is not prepared to support the solution at go-live (training, tooling, staffing gaps) |

### External

| Pattern | Description |
|---------|-------------|
| Third-party API breaking change | An external API used by the solution introduces a breaking change with insufficient notice or migration path |
| Regulatory change mid-project | A regulatory requirement changes during the project, requiring redesign of already-completed work |
| Market shift | External market conditions change significantly, undermining the business case assumptions underpinning the project |
| Dependency team delay | An internal team on whom this phase depends (data platform, security review, infrastructure) delays their deliverable |

---

## 3. Standard Mitigation Language Templates

Use these fill-in-the-blank templates to draft mitigation statements. Replace `[...]` with specifics.

### Technical

- "Conduct a [spike / proof of concept] on [architecture component] by [date] to validate feasibility before committing to [design decision]."
- "Establish a formal interface contract with [system/team] by [date]; validate with integration tests in [environment] before Phase [N] exit."
- "Run load testing using [tool] against a [X%] production-representative dataset by [date]; define pass/fail thresholds as [metric = value]."

### Business

- "Freeze scope for Phase [N] via signed contract amendment by [date]; all new requests to follow the change request process with sign-off from [authority]."
- "Schedule a stakeholder alignment session by [date] to document and sign off on agreed success criteria; output to be appended to the phase contract."
- "Review budget burn rate weekly from [date]; escalate to [authority] if projected overrun exceeds [X%] of contracted budget."

### Data

- "Complete a data quality assessment report for [dataset] by [date]; establish minimum quality thresholds and gate passage on meeting them."
- "Confirm data access rights with [data owner / DPO] by [date]; escalate to [authority] if access is not confirmed within [N] days."
- "Implement a data drift monitoring dashboard using [tool] before go-live; define drift thresholds and automated alerting by [date]."

### AI/ML

- "Define the minimum acceptable [accuracy / F1 / metric] threshold as [value] in the phase contract; gate model promotion on meeting this threshold."
- "Commission an independent bias audit of the training dataset by [date] using [method]; document findings and remediation actions."
- "Implement post-deployment model performance monitoring with [tool]; define a retraining trigger at [drift threshold] and assign ownership to [team]."

### Legal

- "Conduct a GDPR / AI Act compliance review with [legal team / DPO] before Phase [N] exit; document findings in a compliance assessment artefact."
- "Clarify IP ownership terms in the vendor contract by [date]; escalate to [legal authority] if not resolved before contract signature."

### Operational

- "Identify capability gaps via skills assessment by [date]; develop a training or hiring plan with [HR / training lead] and milestone dates."
- "Identify a secondary vendor for [component] by [date]; document the contingency activation criteria and handover process."
- "Complete and test operational runbooks in [staging environment] by [date]; gate go-live readiness on successful runbook execution."

### External

- "Pin [third-party API] to version [X] in all environments; establish a monitoring alert for upstream breaking change announcements by [date]."
- "Assign [role] to monitor [regulatory body] publications weekly; establish a change impact assessment process with sign-off from [authority]."

---

## 4. Register Entry Quick Format

Use this template for fast, consistent register entries:

```
ID:          R-YYYY-NNN
Category:    [technical | business | data | ai | legal | operational | external]
Phase:       [phase_id where identified]
Title:       [one-line summary]
Description: [what could happen and why it matters]
Likelihood:  [1-5]
Impact:      [1-5]
Score:       [L × I]
Severity:    [LOW | MEDIUM | HIGH | CRITICAL]
Owner:       [name]
Due date:    [YYYY-MM-DD]
Mitigation:  [action statement]
Status:      [open | in_progress | mitigated | accepted | closed]
Escalated:   [yes | no] — if yes: to whom and on what date
Notes:       [any additional context or links to evidence]
```

For **assumptions**, replace `Likelihood/Impact/Score` with:
```
Validation deadline: [YYYY-MM-DD]
Validation source:   [who can confirm this assumption]
Status:              [unvalidated | validated | invalidated | expired]
```

For **clarifications**, replace scoring fields with:
```
Severity:    [LOW | MEDIUM | HIGH | CRITICAL]
Raised by:   [name]
Directed to: [name / team]
Due date:    [YYYY-MM-DD]
Answer:      [text once resolved, or "OPEN"]
```
