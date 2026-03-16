---
name: phase-contract-enforcement
description: This skill should be used when enforcing compliance with a signed waterfall phase contract — checking mandatory fields, verifying exit criteria completeness before a gate review, and blocking gate requests when contract gaps are found. Distinct from the phase-contract skill (which creates contracts); this skill enforces them.
---

# Phase Contract Enforcement

## Purpose
A signed phase contract is the governance baseline for a waterfall phase. This skill performs pre-gate enforcement: it reads a signed contract, checks every mandatory field, verifies that all exit criteria are met or formally waived, and confirms that required evidence exists before a gate review is requested. The output is an enforcement report with a definitive gate readiness verdict — READY or BLOCKED. Without enforcement, contracts are documentation artefacts, not governance instruments.

## When to Use
- Phase work is believed to be complete and a gate review is about to be requested
- A gate reviewer asks for a pre-gate compliance check
- There is uncertainty about whether exit criteria have been met
- A waiver has been granted for one or more exit criteria and its validity needs confirming
- Evidence artefacts need to be verified against the contract's required evidence list
- A CRITICAL clarification is outstanding and the team is considering requesting gate anyway

## Instructions

### Step 1: Load the Current Phase Contract
Retrieve the signed phase contract document for the phase under review. Validate it against `schemas/phase-contract.schema.json`. Confirm the contract status field is set — if it is `not_started`, phase work has not formally begun and enforcement is premature.

### Step 2: Check Mandatory Fields
Perform a hard check on all mandatory fields. FAIL immediately if any of the following are empty, null, or contain "TBD":

- `phase_id` — must be a non-empty identifier
- `phase_name` — must be a non-empty string
- `status` — must be a valid status value
- `owner` — must be a named individual, not a team or role alias
- `start_date` — must be a valid ISO date
- `target_end_date` — must be a valid ISO date
- `entry_criteria` — must contain at least one entry
- `exit_criteria` — must contain at least one entry
- `evidence_required` — must contain at least one specific artefact ID
- `sign_off_authority` — must be a named individual; "TBD" is an immediate FAIL

Record PASS or FAIL per field. Any single FAIL blocks the gate verdict.

### Step 3: Verify Entry Criteria Were Assessed
Review each entry criterion listed in the contract. The `status` of each entry criterion must not be `not_assessed`. If any entry criterion was never assessed before phase work started, log this as a process violation — it means the phase was started without meeting its own entry conditions.

This does not block the gate verdict on its own, but it must be recorded in the enforcement report as a finding.

### Step 4: Verify Exit Criteria Status
For each exit criterion listed in the contract, check its current status:
- `met` — acceptable; proceed
- `waived` — acceptable only if Step 5 waiver validation passes
- `not_started` — this is a **BLOCK**; phase has not addressed this criterion
- `in_progress` — this is a **BLOCK**; criterion is not complete at gate time

Record every non-`met` and non-`waived` criterion as an exit criterion gap. Any exit criterion gap blocks the gate verdict.

### Step 5: Validate Waivers
For every exit criterion with status `waived`, verify all three of the following are present and non-empty:
- `waiver_justification` — a written explanation of why the criterion is being waived
- `approver_name` — the name of the person who approved the waiver (must not be the phase owner self-approving; must be the `sign_off_authority` or their designated delegate)
- `risk_acceptance_statement` — a written statement acknowledging the risk of proceeding without this criterion being met

A waiver missing any of these three fields is treated as invalid — the criterion reverts to requiring resolution before gate.

### Step 6: Verify Evidence
For each artefact ID listed in `evidence_required`:
- Confirm the artefact exists in the evidence index
- Confirm it is referenced with a valid identifier, not a folder path or placeholder like "see artefact folder"
- Confirm it was produced during or before this phase (not from a previous phase without explicit carry-over note)

Any artefact in `evidence_required` that cannot be found in the evidence index is an evidence gap. Evidence gaps block the gate verdict.

### Step 7: Issue Enforcement Report
Produce a structured enforcement report with the following sections:

**Mandatory Fields Status**
| Field | Status | Notes |
|-------|--------|-------|
| phase_id | PASS / FAIL | ... |
| ... | ... | ... |

**Exit Criteria Gaps**
List each criterion with status `not_started` or `in_progress`, with criterion text and current status.

**Evidence Gaps**
List each artefact ID in `evidence_required` that is not found in the evidence index.

**Waiver Issues**
List each waiver missing `waiver_justification`, `approver_name`, or `risk_acceptance_statement`.

**Gate Readiness Verdict**
- `READY` — all mandatory fields pass, all exit criteria are met or validly waived, no evidence gaps
- `BLOCKED` — one or more blocking issues exist; list each blocking reason explicitly

Do not issue a READY verdict if any single blocking condition is present.

## Key Principles
1. **Hard FAIL on mandatory fields** — no partial credit; an empty or TBD field is a blocked gate, not a warning.
2. **Exit criteria are binary at gate time** — at the moment of gate review, a criterion is either met or formally waived; `in_progress` and `not_started` are not acceptable states.
3. **Evidence gaps block gates** — a required artefact that cannot be found in the evidence index is treated as non-existent; the promise to add it later is not accepted.
4. **Waivers require approver identity** — a waiver without a named approver (matching the sign-off authority or their delegate) is invalid; self-waiver by the phase owner is not permitted.
5. **Run enforcement just before gate** — this is the final check before requesting gate review; it protects the gate reviewer from receiving incomplete submissions and protects the team from failed gate attempts.

## Reference Materials
- Phase contract schema: `schemas/phase-contract.schema.json`
- `references/contract-enforcement-rules.md` — Mandatory field matrix, exit criteria rules, common failures checklist
- `references/gate-criteria-reference.md` — What gate reviewers check and how enforcement output maps to gate criteria
- `references/lifecycle-overview.md` — Phase boundaries, sign-off authority roles, and escalation paths

## Quality Checks
- Enforcement report covers all 10 mandatory fields with an explicit PASS or FAIL per field
- No exit criterion in the report has status `not_started` or `in_progress` without a corresponding BLOCK verdict
- Every waiver in the report has been validated for all 3 required fields
- Evidence gaps list is cross-referenced against the actual evidence index, not assumed from contract text
- Gate readiness verdict is READY only when zero blocking conditions exist
- Enforcement is run on the most recent version of the contract (version number confirmed)
