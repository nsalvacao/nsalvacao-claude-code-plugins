# Phase Contract Structure Reference

This document defines the mandatory and optional fields of a waterfall phase contract, the format of entry/exit criteria entries, and the completeness indicators used during gate review.

---

## Mandatory Fields

| Field | Description | blank_means | Consequence |
|-------|-------------|-------------|-------------|
| `phase_id` | Integer 1–7 identifying the phase | Unknown phase | Contract invalid — cannot be processed |
| `phase_name` | Canonical phase name (e.g., "Concept & Feasibility") | Name not validated | Risk of misidentified phase work |
| `status` | Current phase status (see status enum below) | Untracked phase | Phase invisible to lifecycle-state.json |
| `owner` | Accountable role or person for phase delivery | No accountability | Escalation path undefined |
| `start_date` | ISO 8601 date of formal phase opening | Timeline undefined | Gate scheduling impossible |
| `target_end_date` | Planned completion date | No deadline | No basis for deviation assessment |
| `entry_criteria` | List of conditions verified before phase work starts | No gate guard | Phase may start prematurely |
| `exit_criteria` | List of conditions verified before gate review | No completion definition | Gate review cannot be triggered |
| `evidence_required` | List of artefact IDs required as proof of completion | Evidence undefined | Gate will fail — no proof package |
| `sign_off_authority` | Named role responsible for approving phase completion | Approval undefined | Gate review has no decision maker |

**Status enum:** `not_started | in_progress | blocked | ready_for_review | ready_for_gate | approved | closed`

---

## Entry Criteria Format

Each entry criterion is a structured object:

```yaml
entry_criteria:
  - criterion_id: EC-1
    description: "Approved project charter exists and is signed by sponsor"
    status: YES        # YES | NO | PARTIAL
    evidence: "docs/project-charter-v1.2-signed.pdf"
    responsible_role: Project Sponsor
  - criterion_id: EC-2
    description: "Feasibility study reviewed and accepted by steering committee"
    status: PARTIAL
    evidence: "Steering committee review scheduled — minutes pending"
    responsible_role: PMO Lead
```

**Status meanings:**
- `YES` — criterion is fully met; evidence is available and complete
- `NO` — criterion is not met; phase is BLOCKED
- `PARTIAL` — criterion is partially met; phase is BLOCKED until resolved to YES

If any criterion is `NO` or `PARTIAL`, the phase **must not start**. Document the blocker and set phase status to `blocked`.

---

## Exit Criteria Format

Each exit criterion is a structured object tracked throughout the phase:

```yaml
exit_criteria:
  - criterion_id: XC-1
    description: "SRS document approved by all stakeholders"
    status: met        # not_started | in_progress | met | waived
    evidence_artefact_ref: "evidence/phase-2/SRS-v2.0-approved.pdf"
  - criterion_id: XC-2
    description: "Traceability matrix links all requirements to business objectives"
    status: in_progress
    evidence_artefact_ref: ""
  - criterion_id: XC-3
    description: "Non-functional requirements reviewed by architect"
    status: waived
    evidence_artefact_ref: "evidence/phase-2/waivers/XC-3-waiver.md"
```

**Status meanings:**
- `not_started` — work on this criterion has not begun
- `in_progress` — work is ongoing; not yet verifiable
- `met` — criterion is satisfied with evidence; gate-ready
- `waived` — criterion formally waived with documented justification and approver

---

## Assumptions Section Format

```yaml
assumptions:
  - assumption_id: A-1
    description: "Client will provide test environment access by Week 3"
    impact_if_wrong: "Integration testing blocked; delivery delayed by 2+ weeks"
    resolution_date: "2026-04-15"
    resolution_owner: Client IT Lead
    status: open    # open | resolved | accepted_risk
    resolution_note: ""
```

---

## Clarifications Section Format

```yaml
clarifications:
  - clarification_id: CL-1
    question: "Is regulatory compliance scope limited to EU or global?"
    raised_by: Compliance Analyst
    raised_date: "2026-03-10"
    owner: Project Sponsor
    due_date: "2026-03-20"
    status: open    # open | resolved | escalated
    decision: ""
    decision_date: ""
```

---

## Sign-Off Authority Section

```yaml
sign_off_authority:
  - role: Project Sponsor
    name: "Jane Smith"
    date: "2026-03-15"
    signature: "Approved via email ref: PM-2026-031"
  - role: Technical Architect
    name: ""
    date: ""
    signature: ""
```

**Rules:**
- `name` must be a specific individual — not a team, department, or "TBD"
- `date` must be an ISO 8601 date — not "ASAP" or "pending"
- `signature` should reference a verifiable approval artifact (email, system approval, signed document)
- Blank sign-off entries block gate review

---

## Completeness Indicators

| Indicator | Condition | Meaning |
|-----------|-----------|---------|
| RED | Any mandatory field is empty or contains placeholder text | Contract is invalid; phase cannot proceed |
| AMBER | Optional field is empty (e.g., `clarifications`, `assumptions`) | Contract is valid but incomplete; monitor for risk |
| GREEN | All mandatory fields populated; all criteria have status and evidence | Contract is complete and gate-ready |

**Mandatory fields that trigger RED if empty:**
`phase_id`, `phase_name`, `status`, `owner`, `start_date`, `target_end_date`, `entry_criteria` (at least one), `exit_criteria` (at least one), `evidence_required` (at least one), `sign_off_authority.role`

---

## Waterfall vs Agile Phase Contract: Key Differences

| Dimension | Waterfall Phase Contract | Agile Phase Contract |
|-----------|--------------------------|----------------------|
| Nature | Binding formal gate instrument | Living operational guideline |
| Entry criteria | Non-negotiable — PARTIAL = BLOCKED | Advisory — tracked but flexible |
| Exit criteria failure | Blocks gate review entirely | Triggers retrospective, not blocker |
| Waivers | Require formal documentation and approver sign-off | Informal acknowledgement may suffice |
| Status tracking | Formal status in lifecycle-state.json | Board/backlog column |
| Sign-off authority | Named individual with date and evidence | Team agreement or PO acceptance |
| Amendment | Requires change control if phase has started | Updated in-place as a living document |
| Audit trail | Full history required for compliance | Nice-to-have |

The fundamental distinction: in waterfall, the phase contract is the governance artefact that authorises work. In agile, it is a coordination tool that guides work.
