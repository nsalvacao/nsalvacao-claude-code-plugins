---
name: phase-contract
description: This skill should be used when creating or validating a waterfall phase contract — the formal agreement that gates phase entry and exit. Phase contracts in waterfall are binding: no phase starts without approved entry criteria and no gate review without met exit criteria.
---

# Phase Contract

## Purpose
A waterfall phase contract is the binding formal agreement that governs phase entry and exit. It defines mandatory conditions that must be verified before work begins, the evidence required to prove phase completion, the sign-off authority responsible for approval, and the gate review trigger conditions. Unlike agile phase contracts (which are living operational guidelines), waterfall phase contracts are formal gate instruments — partial compliance blocks the phase.

## When to Use
- A new phase is about to start and a contract must be created or loaded
- Entry criteria must be validated before phase work begins
- A phase is blocked and the contract must record the blocker
- Exit criteria progress must be tracked during phase execution
- Phase completion evidence must be assembled before a gate review
- A gate review must be formally triggered

## Instructions

### Step 1: Identify the Phase and Load Context
Determine which phase (1–7) is being contracted. Load the phase essentials card from `docs/phase-essentials/phase-N.md`. Review `references/lifecycle-overview.md` for entry/exit criteria specific to the phase.

### Step 2: Load or Create the Phase Contract Document
Open the existing phase contract if one exists, or create a new contract using the mandatory fields:
- `phase_id`: integer 1–7
- `phase_name`: canonical phase name
- `status`: one of `not_started | in_progress | blocked | ready_for_gate | approved | rejected | waived | closed`
- `owner`: accountable role or person
- `start_date`: ISO date when phase was formally opened
- `target_end_date`: planned completion date
- `entry_criteria`: list of conditions verified before work starts
- `exit_criteria`: list of conditions verified before gate review
- `evidence_required`: list of artefact IDs proving completion
- `sign_off_authority`: role responsible for approving phase completion

### Step 3: Validate Entry Criteria
For each entry criterion, assess with binary evidence:
- Is it met? (`YES` / `NO` / `PARTIAL`)
- Each criterion must have evidence reference (document, sign-off, test result)
- If any criterion is `PARTIAL` or `NO`: phase is **BLOCKED** — do not proceed to Step 5

### Step 4: Handle Entry Blockers
If any entry criterion is not met:
- Document the specific blocker in the phase contract (`entry_blockers` section)
- Assign a responsible owner and resolution due date to each blocker
- Notify the sign-off authority of the blocked status
- Set phase `status` to `blocked` in `lifecycle-state.json`
- Do not begin phase work until all blockers are resolved and criteria re-validated

### Step 5: Track Exit Criteria Progress During Phase
During phase execution, maintain exit criteria status:
- Mark each criterion as: `not_started | in_progress | met | waived`
- If waived: create a formal waiver entry with justification text, approver name, and risk acceptance statement
- Update progress at regular checkpoints — do not wait until phase end for first assessment

### Step 6: Validate Phase Completeness Before Gate
Before triggering gate review, verify:
- All exit criteria are `met` or formally `waived`
- All mandatory artefacts produced (check `references/artefact-catalog.md`)
- All evidence recorded in `.waterfall-lifecycle/evidence/`
- All assumptions resolved or formally accepted with documented decision
- All clarifications closed or escalated with decision recorded
- Sign-off authority has reviewed the evidence package

### Step 7: Update State and Trigger Gate Review
When all exit criteria are satisfied:
- Update phase contract `status` to `ready_for_gate`
- Update `lifecycle-state.json` with current phase status
- Notify gate reviewer with evidence package reference
- Reference the phase contract in the gate review report

## Key Principles
1. **No phase starts without a contract** — entry criteria are non-negotiable gate guards; a missing or incomplete contract is a blocker.
2. **Contracts are living documents** — update as assumptions are resolved, blockers are cleared, and evidence is collected.
3. **Waivers must be formal** — require approver name and risk acceptance statement; informal waivers are invalid.
4. **Evidence is not optional** — exit criteria marked as met without evidence references fail at gate review.
5. **Sign-off authority is defined upfront** — "TBD" is not acceptable at gate time; resolve before phase start.

## Reference Materials
- `schemas/phase-contract.schema.json` — Validation schema for phase contract documents
- `references/lifecycle-overview.md` — Phase context, entry/exit criteria per phase
- `docs/phase-essentials/phase-N.md` — 1-pager per phase (start here)
- `skills/phase-contract/references/contract-structure.md` — Contract field formats and completeness indicators

## Quality Checks
- All mandatory contract fields are populated (no empty or "TBD" values)
- Each entry criterion has a binary status (`YES`/`NO`/`PARTIAL`) with evidence reference
- Each exit criterion maps directly to an evidence artefact in the evidence index
- Sign-off authority is a named role — not "TBD" or generic "Management"
- Phase contract status matches actual phase state in `lifecycle-state.json`
- No phase work was started while contract status was `blocked`
