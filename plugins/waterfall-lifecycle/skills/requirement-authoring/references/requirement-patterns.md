# Requirement Patterns Reference

Reference material for the `requirement-authoring` skill. Covers ID format, category classification, SMART criteria, acceptance criteria templates, AI requirement templates, NFR templates, and anti-patterns.

---

## 1. Requirement ID Format

Format: `REQ-YYYY-NNN`

| Field | Rule | Example |
|-------|------|---------|
| `REQ` | Fixed prefix | `REQ` |
| `YYYY` | Calendar year of creation | `2026` |
| `NNN` | 3-digit sequential number, zero-padded | `001`, `042`, `100` |

### Examples

| ID | Year | Sequence |
|----|------|----------|
| `REQ-2026-001` | 2026 | First requirement |
| `REQ-2026-042` | 2026 | 42nd requirement |
| `REQ-2026-100` | 2026 | 100th requirement |
| `REQ-2027-001` | 2027 | First requirement of new year |

IDs are permanent. A deferred or rejected requirement retains its ID with `status: deferred`. The ID is never reused or reassigned.

---

## 2. Category Classification Guide

| Category | Typical Trigger | Example Requirement |
|----------|-----------------|---------------------|
| `functional` | User story, use case, business process step | "The system shall allow a registered user to export their transaction history as a CSV file." |
| `ai` | Model accuracy target, ML pipeline step, AI-generated decision | "The classification model shall achieve F1 ≥ 0.88 on the held-out validation set." |
| `nfr` | Performance SLA, security policy, availability target, compliance mandate | "The API shall respond within 200ms at p95 under 1000 concurrent users." |
| `constraint` | Fixed technology mandate, budget cap, regulatory limit | "The solution shall be deployed exclusively on AWS eu-west-1 per the enterprise cloud policy." |
| `assumption` | Condition accepted as true for planning, not yet validated | "It is assumed that the source database schema will not change before Phase 3 completion." |

**Category drives traceability:**
- `functional` → system design artefacts
- `ai` → model design and ML pipeline artefacts
- `nfr` → architecture and infrastructure artefacts
- `constraint` → governance and decision log artefacts
- `assumption` → risk register (assumption register)

---

## 3. SMART Criteria Checklist

| Criterion | Bad Example | Good Example |
|-----------|-------------|--------------|
| **Specific** | "The system should be fast." | "The system shall process payment authorisations within 500ms." |
| **Measurable** | "The model should be accurate." | "The model shall achieve precision ≥ 0.85 on the test dataset." |
| **Achievable** | "The system shall handle unlimited concurrent users." | "The system shall handle up to 5000 concurrent users per the Phase 1 capacity plan." |
| **Relevant** | "The UI shall use the colour blue." | "The UI shall comply with the corporate brand guidelines (ref: BRD-001)." |
| **Time-bound** | "The feature will be delivered eventually." | "The feature shall be available by the end of Phase 3 (target: 2026-09-30)." |

Vague language that must be replaced:
- "fast" → specify latency target (ms, s)
- "robust" → specify availability target (% uptime) or MTTR
- "user-friendly" → specify usability metric or user research validation method
- "good" → specify the metric and threshold
- "scalable" → specify the target load and timeframe

---

## 4. Acceptance Criteria Templates

### 4.1 Functional Requirement

```
Given [user context or system precondition],
when [the user performs an action or an event occurs],
then [the expected outcome with a measurable or verifiable result].
```

**Example:**
```
Given a registered user with an active account,
when the user requests a CSV export of their transaction history,
then the system shall generate and return a valid CSV file containing all transactions
within 3 seconds for datasets up to 10,000 rows.
```

### 4.2 AI Requirement

```
Given [test dataset description including size and source],
when [the model is evaluated against the test dataset],
then [metric name] shall be ≥ [threshold value].
```

**Example:**
```
Given the held-out validation set of 5,000 labelled records (ref: REQ-2026-010-testset.csv),
when the classification model is evaluated at inference time,
then precision shall be ≥ 0.85 and recall shall be ≥ 0.80.
```

### 4.3 NFR — Performance

```
Given [load conditions: concurrent users, request rate, data volume],
when [operation is performed],
then [response time metric] shall be ≤ [target] at [percentile].
```

**Example:**
```
Given 1000 concurrent users submitting search queries simultaneously,
when the search endpoint is called,
then p95 response time shall be ≤ 200ms and p99 shall be ≤ 500ms.
```

### 4.4 NFR — Security

```
Given [attack scenario or security test condition],
when [the system is tested using defined methodology],
then [protection measure or absence of vulnerability] shall be verified.
```

**Example:**
```
Given a penetration test conducted by an external security firm using OWASP Top 10 methodology,
when the API endpoints are tested,
then no critical or high severity vulnerabilities shall be found as defined in the CVSS v3.1 scoring rubric.
```

### 4.5 NFR — Availability

```
Given [production environment and monitoring period],
when [availability is measured over the defined period],
then uptime shall be ≥ [target percentage] excluding scheduled maintenance windows.
```

---

## 5. AI Requirement Template

```
ID:                     REQ-YYYY-NNN
Title:                  [AI requirement title]
Category:               ai
Priority:               must | should | could | wont
Description:            [What the AI component must do — specific behaviour, not vague goal]
Acceptance Threshold:   [metric name] ≥ [value] on [test dataset name or reference]
Fallback Behaviour:     [What happens if the threshold is not met at evaluation time]
Explainability:         required | not required
                        [If required: specify format — SHAP values, LIME, decision rules, etc.]
Data Source:            [Description of training data — origin, format, collection method]
Data Volume:            [Minimum training examples required for the model to meet the threshold]
Model Constraints:
  - Latency:            [max inference time, e.g., ≤ 100ms per prediction]
  - Memory:             [max memory footprint, e.g., ≤ 2 GB at inference]
  - Interpretability:   [black-box acceptable | white-box required | reason: ...]
Acceptance Criteria:
  - Given [test dataset], when [model evaluated at inference], then [metric] ≥ [threshold]
  - Given [fallback trigger condition], when [threshold is not met], then [fallback behaviour is invoked]
Status:                 draft
Owner:                  [AI/ML lead name]
Traceability:
  upstream:             [Gate A artefact or business objective reference]
  test_ref:             TBD
```

---

## 6. NFR Templates by Sub-Category

### 6.1 Performance NFR

```
ID:               REQ-YYYY-NNN
Title:            [Performance requirement title]
Category:         nfr
Sub-category:     performance
Priority:         must | should | could | wont
Description:      [System shall meet [metric] ≤ [target] under [load conditions]]
Test Approach:    Load test using [tool] with [N] concurrent users; pass threshold: [metric = value]
SLA Reference:    [Contract SLA clause or internal SLA document reference]
Acceptance Criteria:
  - Given [load conditions], when [operation performed], then [metric] ≤ [target] at [percentile]
Status:           draft
Owner:            [Performance engineering lead]
```

### 6.2 Security NFR

```
ID:               REQ-YYYY-NNN
Title:            [Security requirement title]
Category:         nfr
Sub-category:     security
Priority:         must
Description:      [Security control required — what must be protected and from what threat]
Compliance Ref:   [GDPR Article N | ISO 27001 control A.x.x | OWASP Top 10 | NIS2 Article N]
Test Approach:    [Penetration test | SAST/DAST | compliance audit | threat model review]
Acceptance Criteria:
  - Given [threat scenario], when [system tested per methodology], then [control verified with no critical findings]
Status:           draft
Owner:            [Security lead / CISO]
```

### 6.3 Scalability NFR

```
ID:               REQ-YYYY-NNN
Title:            [Scalability requirement title]
Category:         nfr
Sub-category:     scalability
Priority:         must | should
Description:      [System shall support [N] units of [load dimension] by [date/milestone]]
Baseline Load:    [Current production load — users, records, transactions per second]
Target Load:      [Projected peak load at [horizon date]]
Test Approach:    [Capacity test | stress test | horizontal scaling verification]
Acceptance Criteria:
  - Given [target load conditions], when [load test executed], then system meets [metric] ≤ [target] with no errors
Status:           draft
Owner:            [Infrastructure / platform lead]
```

### 6.4 Availability NFR

```
ID:               REQ-YYYY-NNN
Title:            [Availability requirement title]
Category:         nfr
Sub-category:     availability
Priority:         must
Description:      [System shall maintain ≥ [uptime %] availability measured over [period]]
RTO:              [Recovery Time Objective — max downtime per incident]
RPO:              [Recovery Point Objective — max data loss per incident]
Maintenance:      [Scheduled maintenance window — excluded from SLA calculation]
Test Approach:    [Chaos engineering | DR drill | monitoring dashboard review]
Acceptance Criteria:
  - Given [monitoring period], when [availability measured], then uptime ≥ [target %] excluding maintenance windows
Status:           draft
Owner:            [SRE / operations lead]
```

### 6.5 Compliance NFR

```
ID:               REQ-YYYY-NNN
Title:            [Compliance requirement title]
Category:         nfr
Sub-category:     compliance
Priority:         must
Description:      [System shall comply with [regulation/standard] requirement [specific article/control]]
Regulation:       [GDPR | AI Act | ISO 27001 | SOC 2 | PCI-DSS | HIPAA | NIS2]
Specific Control: [Article N | Control A.x.x | Requirement section]
Test Approach:    [Compliance audit | DPO review | external certification]
Acceptance Criteria:
  - Given [compliance audit scope], when [audit conducted by qualified assessor], then [specific control] passes with no findings
Status:           draft
Owner:            [Compliance officer / DPO]
```

---

## 7. Common Vague Language Anti-Patterns

| Vague Phrase | Why It Fails | Replacement Guidance |
|--------------|--------------|----------------------|
| "fast" | No numeric target — untestable | Specify latency in ms/s at a percentile (e.g., p95 ≤ 200ms) |
| "robust" | No failure definition — untestable | Specify availability % (e.g., ≥ 99.9% uptime) or MTTR (e.g., ≤ 4h) |
| "user-friendly" | Subjective — no acceptance criterion | Specify usability metric (e.g., task completion rate ≥ 90% in usability test) |
| "good performance" | No baseline or target | Specify metric, target, and load conditions |
| "scalable" | No load target — relative, not absolute | Specify target load (e.g., 10x current volume by 2027-Q4) |
| "secure" | No threat model or control specified | Reference a specific control (e.g., OWASP A01:2021 — broken access control mitigated) |
| "accurate" | No metric or threshold | Specify metric and threshold (e.g., precision ≥ 0.85, F1 ≥ 0.80) |
| "reliable" | Ambiguous — could mean many things | Specify availability target, MTTR, or error rate threshold |
| "should be able to" | Conditional — not a firm requirement | Use "shall" for mandatory; "should" for desired but not gated |
| "as needed" | No volume, frequency, or trigger | Specify triggering condition, volume, and response time |
| "minimal latency" | No numeric target | Define target latency at a specific percentile |
| "handles large data" | No size definition | Specify data volume (e.g., datasets up to 10 GB, 50M rows) |
