---
name: phase-contract-enforcement
description: This skill should be used when tracking deviations from signed phase contracts, managing scope changes that affect contracts, or escalating contract violations. Triggers when a change request arrives, when a phase is running beyond its contract bounds, or when a gate review reveals contractual non-compliance.
---

# Phase Contract Enforcement

## Purpose
A phase contract becomes governance only when it is actively enforced. This skill complements `skills/phase-contract/SKILL.md` (which creates contracts) by monitoring adherence, detecting deviations, managing scope changes that affect contract boundaries, and producing a deviation log as evidence for gate reviews. Without enforcement, phase contracts are documentation artefacts, not governance instruments.

## When to Use
- A scope change arrives mid-phase that may violate contract boundaries
- Phase work is running beyond the contracted end date without a formal extension
- Exit criteria are being bypassed or redefined without a formal contract amendment
- A gate review reveals that the phase was delivered outside its contracted scope
- Sprint velocity data suggests the phase cannot complete within contract parameters
- A stakeholder requests a change that would alter contracted entry or exit criteria

## Instructions

### Step 1: Load the Active Phase Contract
Retrieve the signed phase contract for the current phase. Validate it against `schemas/phase-contract.schema.json`. Confirm the contract status is `in_progress` (not `blocked` or `ready_for_review`). Identify the sign-off authority and the contracted scope boundaries.

### Step 2: Detect the Deviation Type
Classify the deviation or potential deviation:
- **Scope expansion**: new work added beyond contracted scope
- **Scope reduction**: agreed deliverables removed without formal change
- **Timeline breach**: phase running beyond contracted end date
- **Exit criterion modification**: a criterion being redefined after contract sign-off
- **Evidence gap**: artefacts required by the contract are not being produced
- **Dependency breach**: an external dependency the contract assumed has failed

### Step 3: Log the Deviation
Create a deviation entry in the phase deviation log:
- `deviation_id`: unique identifier (e.g., `DEV-P3-001`)
- `phase_id`: which phase contract is affected
- `detected_date`: ISO date
- `deviation_type`: from the classification in Step 2
- `description`: what happened and how it differs from the contract
- `impact`: effect on timeline, scope, or gate readiness
- `status`: open | under-review | resolved | escalated

### Step 4: Assess Impact on Gate Readiness
For each logged deviation, assess whether it affects gate readiness:
- Does it invalidate any exit criterion?
- Does it create an evidence gap?
- Does it change the sign-off authority or scope?

If gate readiness is affected: update the phase contract status to `blocked` and notify the gate reviewer.

### Step 5: Manage Scope Changes Through Formal Amendment
For scope changes that fall within tolerable bounds:
- Create a contract amendment record referencing the original phase contract
- Document: what changes, why, impact on exit criteria, new timeline (if any)
- Obtain sign-off from the original contract authority
- Update the phase contract document and increment its version
- Reference the amendment in the evidence index

For changes that exceed contract bounds (major scope increase or reduction):
- Escalate to PM and sponsor
- Do not proceed with the change until escalation is resolved
- Document the escalation in the deviation log

### Step 6: Resolve or Escalate Open Deviations
At each sprint review, review all open deviation entries:
- If resolved: document resolution, close the entry, update the phase contract if needed
- If unresolved beyond 5 business days: escalate to PM
- If escalated and unresolved beyond 10 business days: flag as a gate blocker

Track resolution in the deviation log. The deviation log is a gate review artefact.

### Step 7: Include Deviation Log in Gate Evidence Pack
Before gate review, the deviation log must:
- List all deviations detected during the phase
- Show resolution status for each
- Reference any contract amendments produced
- Be added to the evidence index as a mandatory gate artefact

## Key Principles
1. **Contracts are enforced, not filed** — a signed contract that is never checked is not governance.
2. **Deviations are not failures** — they are information; detecting them early enables correction before gate.
3. **Scope changes need formal authority** — no change to contracted scope proceeds without the sign-off authority's approval.
4. **The deviation log is an audit trail** — it demonstrates that governance was active, not that the project was perfect.
5. **Enforcement protects the team** — undocumented scope creep harms the team; enforcement keeps the contract honest.

## Reference Materials
- Schema: `schemas/phase-contract.schema.json`
- `references/lifecycle-overview.md` — Phase boundaries and sign-off authority definitions
- `references/gate-criteria-reference.md` — Gate criteria that deviation may affect
- `references/artefact-catalog.md` — Mandatory artefacts that deviation log must reference

## Quality Checks
- Every scope change received during a phase has a deviation log entry
- Open deviations older than 5 business days have an escalation record
- Contract amendments are versioned and signed by the original authority
- Deviation log is included in the gate evidence pack
- Phase contract status accurately reflects the current state (not stale)
- No exit criterion is modified post-contract-sign-off without a formal amendment
