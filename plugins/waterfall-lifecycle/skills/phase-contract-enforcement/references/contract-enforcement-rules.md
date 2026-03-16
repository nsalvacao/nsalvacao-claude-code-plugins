# Contract Enforcement Rules

Reference material for the `phase-contract-enforcement` skill. Covers the mandatory vs optional field matrix, exit criteria enforcement rules, and the common enforcement failures checklist.

---

## 1. Mandatory vs Optional Field Matrix

| Field | Mandatory? | Empty Value = | Action |
|-------|------------|---------------|--------|
| `phase_id` | Mandatory | FAIL | FAIL — blocks gate |
| `phase_name` | Mandatory | FAIL | FAIL — blocks gate |
| `status` | Mandatory | FAIL | FAIL — blocks gate |
| `owner` | Mandatory | FAIL | FAIL — blocks gate; must be a named individual, not a role or team |
| `start_date` | Mandatory | FAIL | FAIL — blocks gate; must be a valid ISO date |
| `target_end_date` | Mandatory | FAIL | FAIL — blocks gate; must be a valid ISO date |
| `entry_criteria` | Mandatory (≥1 item) | FAIL | FAIL — blocks gate; empty list is not acceptable |
| `exit_criteria` | Mandatory (≥1 item) | FAIL | FAIL — blocks gate; empty list is not acceptable |
| `evidence_required` | Mandatory (≥1 item) | FAIL | FAIL — blocks gate; must reference specific artefact IDs |
| `sign_off_authority` | Mandatory (not TBD) | FAIL | FAIL — blocks gate; "TBD" is treated as empty |
| `assumptions` | Optional | WARN | WARN — advisory only; absence is noted but does not block gate |
| `clarifications` | Optional | WARN | WARN — advisory only; absence is noted but does not block gate |
| `mandatory_questions` | Optional | WARN | WARN — advisory only; absence is noted but does not block gate |

**Note:** WARN items are included in the enforcement report as advisory findings. They do not affect the gate readiness verdict on their own, but they are highlighted because their absence may indicate incomplete due diligence.

---

## 2. Exit Criteria Enforcement Rules

### At Phase Start
- All exit criteria must be listed before phase work begins
- An empty `exit_criteria` list at phase start is a FAIL — the phase contract is incomplete and should not have been signed
- Each criterion must have a description sufficient to be objectively assessable at gate time

### During Phase
Exit criteria are tracked with the following status values:

| Status | Meaning |
|--------|---------|
| `not_started` | Work on this criterion has not begun |
| `in_progress` | Work has started but criterion is not yet met |
| `met` | Criterion has been demonstrably satisfied |
| `waived` | Criterion has been formally waived with authority approval |

### At Gate Time
- ALL exit criteria must be `met` or `waived`
- Any criterion in `not_started` or `in_progress` status is a **BLOCK** — gate review cannot proceed
- The enforcement report must list every non-`met`, non-`waived` criterion as a gate blocker

### Waiver Format
A valid waiver must include all three of the following fields. A waiver missing any one is invalid and the criterion is treated as unmet:

| Field | Requirement |
|-------|-------------|
| `waiver_justification` | Written explanation of why the criterion is being waived; must be substantive, not "not needed" |
| `approver_name` | Full name of the approving individual; must be the `sign_off_authority` or their designated delegate; self-waiver by the phase owner is not permitted |
| `risk_acceptance_statement` | Written acknowledgement of the risk of proceeding without this criterion being met; must name the risk explicitly |

---

## 3. Common Enforcement Failures

Use this checklist when reviewing a phase contract before gate. Each item that applies is a gate blocker or advisory finding.

**Mandatory Field Failures (FAIL — blocks gate)**
- [ ] `sign_off_authority` is "TBD" → FAIL
- [ ] `exit_criteria` list is empty → FAIL
- [ ] `entry_criteria` list is empty → FAIL
- [ ] `evidence_required` field is empty or says "see artefact folder" instead of specific artefact IDs → FAIL
- [ ] `owner` is a team name or role alias rather than a named individual → FAIL
- [ ] `start_date` or `target_end_date` is missing or not a valid ISO date → FAIL

**Exit Criteria Failures (BLOCK — blocks gate)**
- [ ] One or more exit criteria show `in_progress` at gate request time → BLOCK
- [ ] One or more exit criteria show `not_started` at gate request time → BLOCK
- [ ] A waiver exists but the `approver_name` field is empty or "TBD" → BLOCK (waiver is invalid)
- [ ] A waiver exists but `waiver_justification` is missing or is a single word / non-substantive text → BLOCK
- [ ] A waiver exists but `risk_acceptance_statement` is missing → BLOCK

**Evidence Failures (BLOCK — blocks gate)**
- [ ] One or more artefact IDs in `evidence_required` are not found in the evidence index → BLOCK
- [ ] Evidence index references a folder path rather than a specific artefact ID → BLOCK
- [ ] A required artefact exists but was produced in a prior phase without a carry-over note → BLOCK

**Process Violations (WARN — recorded but advisory)**
- [ ] Phase was started before entry criteria were assessed (`not_assessed` status at phase start) → WARN
- [ ] `assumptions` section is absent — no assumption register was maintained during the phase → WARN
- [ ] `clarifications` section is absent — no clarification log was maintained during the phase → WARN
- [ ] Phase end date has already passed without a gate being requested or an extension being documented → WARN
