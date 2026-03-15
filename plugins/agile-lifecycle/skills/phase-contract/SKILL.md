---
name: phase-contract
description: Use when creating, reviewing, or enforcing phase contracts. Triggers when a new phase starts, when entry/exit criteria need validation, or when phase completeness needs assessment.
---

# Phase Contract

## Purpose
A phase contract is the operational agreement that governs a lifecycle phase. It defines the mandatory conditions for entering and exiting a phase, the evidence required to prove completion, and the sign-off authority responsible for approval. Without a valid phase contract, a phase cannot be formally started or closed.

## When to Use
- A new phase is about to start and a contract must be created
- An existing phase contract needs review or update
- Entry criteria must be validated before phase work begins
- Exit criteria must be assessed before a gate review is triggered
- Phase completeness needs formal assessment

## Instructions

### Step 1: Identify the Phase and Load Context
Determine which phase (1–7) is being contracted. Load the phase essentials card from `docs/phase-essentials/phase-N.md`. Review `references/lifecycle-overview.md` for entry/exit criteria specific to the phase.

### Step 2: Fill the Mandatory Contract Fields
Open the phase contract template (if available) or create the document with these mandatory fields:
- `phase_id`: integer 1–7
- `phase_name`: canonical phase name
- `status`: one of `not_started | in_progress | blocked | ready_for_review | ready_for_gate | approved | closed`
- `owner`: accountable role or person
- `start_date`: ISO date when phase was formally opened
- `target_end_date`: planned completion date
- `entry_criteria`: list of conditions that must be TRUE before work starts
- `exit_criteria`: list of conditions that must be TRUE before gate review
- `evidence_required`: list of artefact IDs or evidence entries proving completion
- `sign_off_authority`: role responsible for approving phase completion

### Step 3: Document Assumptions and Clarifications
Before proceeding with phase work, document:
- Assumptions being made that could invalidate the phase if wrong
- Open decisions or clarifications that must be resolved (with owner and due date)
- Dependencies on other teams, systems, or external parties

### Step 4: Validate Entry Criteria
For each entry criterion, assess:
- Is it met? (YES / NO / PARTIAL)
- If PARTIAL or NO: what is needed, who is responsible, by when?
- If all criteria are met: phase can formally start
- If criteria are not met: phase is BLOCKED — document the blocker and escalate

### Step 5: Track Progress Against Exit Criteria
During the phase, regularly assess exit criteria:
- Mark each criterion as: `not_started | in_progress | met | waived`
- If waived: create a waiver entry with justification and approver
- All criteria must reach `met` or `waived` before triggering the gate review

### Step 6: Validate Phase Completeness
Before requesting gate review:
- All mandatory artefacts produced (check `references/artefact-catalog.md`)
- All evidence recorded in the evidence index
- All open assumptions resolved or formally accepted
- All clarifications closed or escalated with decision recorded
- Sign-off authority has reviewed the evidence package

### Step 7: Trigger Gate Review
When all exit criteria are met:
- Update phase contract status to `ready_for_gate`
- Notify gate reviewer with evidence package
- Reference the phase contract in the gate review report

## Key Principles
1. **No phase starts without a contract** — entry criteria are not optional; they prevent premature starts.
2. **Contracts are living documents** — update them as assumptions are resolved and evidence is collected.
3. **Waivers must be formal** — any waived criterion requires an explicit waiver entry with rationale and approver.
4. **Evidence is not optional** — claiming exit criteria are met without evidence is insufficient for gate review.
5. **Sign-off authority is defined upfront** — ambiguity about who can approve a phase creates delays at gate time.

## Reference Materials
- `references/lifecycle-overview.md` — Phase context, entry/exit criteria per phase
- `docs/phase-essentials/phase-N.md` — 1-pager per phase (start here)
- Schema: `schemas/phase-contract.schema.json`

## Quality Checks
- All mandatory fields are populated (no empty or placeholder values)
- Entry criteria are specific and verifiable (not vague like "team is ready")
- Exit criteria map directly to evidence artefacts
- Sign-off authority is a named role, not "TBD"
- Phase contract status matches actual phase state in `lifecycle-state.json`
