---
name: evidence-management
description: This skill should be used when assembling gate evidence packs, tracking artefact completeness, or managing waivers before any gate review (A–F). Triggers when a phase is approaching its gate or when evidence index needs to be updated.
---

# Evidence Management

## Purpose
Gate reviews require a curated, traceable evidence pack that proves all exit criteria are met. This skill governs the assembly, indexing, completeness check, and waiver process for gate evidence across all lifecycle gates (A through F). Without structured evidence management, gate reviews stall, reviewers raise repeated clarifications, and phases are blocked. This is a transversal skill — it applies before every gate regardless of phase.

## When to Use
- A phase is approaching its gate review and evidence needs to be assembled
- The evidence index needs to be updated after a new artefact is produced
- An exit criterion cannot be met and a waiver is needed
- Gate review preparation needs a completeness check
- A previous gate evidence pack needs to be referenced for continuity
- Compliance requires an audit trail of artefacts and their approvals

## Instructions

### Step 1: Identify the Gate and Load Criteria
Determine which gate (A–F) is being prepared. Load `references/gate-criteria-reference.md` for the specific gate's mandatory evidence. Cross-reference with the phase contract exit criteria (`schemas/phase-contract.schema.json`) to confirm alignment.

### Step 2: Create or Update the Evidence Index
Open the evidence index for the current phase. Use `templates/transversal/evidence-entry.md.template` for each new entry. Required fields per entry:
- `id`: unique artefact identifier (e.g., `EV-P3-001`)
- `artefact_name`: human-readable name
- `artefact_type`: document | schema | test-result | sign-off | metric
- `location`: file path or URL to the artefact
- `status`: present | missing | waived
- `gate_criterion`: which exit criterion this evidence satisfies
- `last_updated`: ISO date

Validate each entry against `schemas/evidence-index.schema.json`.

### Step 3: Perform Completeness Check
For each mandatory exit criterion of the gate:
- Find at least one evidence entry that satisfies it
- Mark the criterion as: `covered | partial | missing`
- For `partial` or `missing` criteria: determine whether a waiver is needed or the artefact can be produced before the gate date

### Step 4: Assemble the Gate Evidence Pack
Use the gate pack template for the relevant gate:
- Phase 1 gate A: `templates/phase-1/gate-a-pack.md.template`
- Phase 2 gate B: `templates/phase-2/gate-b-pack.md.template`
- Phase 3 gate C: `templates/phase-3/gate-c-pack.md.template`
- Phase 4 gate D: `templates/phase-4/gate-d-pack.md.template`
- Phase 5 gate E: `templates/phase-5/gate-e-pack.md.template`
- Phase 6 gate F: `templates/phase-6/gate-f-pack.md.template`

The pack links to the evidence index and lists: summary of criteria met, criteria waived, criteria not met (blockers), reviewer sign-off fields.

### Step 5: Process Waivers
For any exit criterion that cannot be met:
- Use `templates/transversal/waiver-entry.md.template` to create a waiver record
- Required fields: criterion being waived, justification, risk accepted, approver, expiry (if applicable)
- Add waiver entry to `templates/phase-5/waiver-log.md.template`
- Update evidence index entry status to `waived`
- Waivers must be approved by the sign-off authority defined in the phase contract

### Step 6: Notify Gate Reviewers
Once the evidence pack is assembled and completeness check is clean:
- Update the phase contract status to `ready_for_gate`
- Send the evidence pack to the gate reviewer with a summary of: criteria met, waivers in place, any outstanding items
- Reference the evidence pack in the gate review report (`templates/transversal/gate-review-report.md.template`)

### Step 7: Archive Post-Gate
After the gate review is complete:
- Record the gate decision (pass | pass with conditions | fail)
- Archive the evidence pack with the gate outcome
- Carry forward any conditions as formal follow-up items into the next phase contract
- Update `schemas/gate-review.schema.json` with the decision record

## Key Principles
1. **Evidence is created during the phase, not at the gate** — assembling evidence at gate time means the phase was not tracked properly.
2. **Every criterion needs traceable evidence** — verbal assurances and memory are not evidence; artefacts are.
3. **Waivers are formal decisions** — a waiver is not a shortcut; it is a documented risk acceptance with an approver.
4. **The evidence index is a living document** — update it as artefacts are produced, not in a last-minute rush.
5. **Gate conditions must be tracked** — a gate passed with conditions is not fully passed until the conditions are closed.

## Reference Materials
- `references/gate-criteria-reference.md` — Mandatory evidence per gate (A–F)
- `templates/transversal/evidence-entry.md.template` — Evidence index entry structure
- `templates/transversal/gate-review-report.md.template` — Gate review report template
- `templates/transversal/waiver-entry.md.template` — Waiver record template
- Schema: `schemas/evidence-index.schema.json`
- Schema: `schemas/gate-review.schema.json`

## Quality Checks
- Evidence index exists and is schema-valid before gate review is requested
- Every mandatory exit criterion for the gate has at least one evidence entry
- All waivers have an explicit approver and rationale
- Gate pack is assembled from the correct phase-specific template
- No evidence entry has status `missing` without a corresponding waiver or action item
- Gate decision and conditions are recorded in the evidence index post-review
