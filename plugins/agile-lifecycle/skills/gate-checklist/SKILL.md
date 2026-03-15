---
name: gate-checklist
description: "This skill should be used when conducting a formal gate review (Gates A-F), when validating gate criteria, or when deciding PASS/FAIL/WAIVED for a lifecycle gate."
---

# Gate Checklist

## Purpose
Gate reviews are formal decision points that control progression between lifecycle phases. Each gate has defined criteria that must be met (or formally waived) before the next phase begins. This skill ensures gate reviews are conducted consistently, criteria are checked against actual evidence, and outcomes are formally recorded in a gate review report.

## When to Use
- A phase is reaching completion and a gate review must be triggered
- Gate criteria need to be checked against available evidence
- A gate decision (PASS / FAIL / WAIVED criterion) needs to be made and recorded
- A gate review report needs to be produced
- Reviewing whether a prior gate's criteria remain valid after a significant change

## Instructions

### Step 1: Identify the Gate and Load Criteria
Determine which gate (A through F) is being reviewed. Load the gate criteria from `skills/gate-checklist/references/gate-criteria.md`. Each gate has:
- Objective: what the gate is testing
- Mandatory criteria: must all be met or waived to pass
- Evidence requirements: what proof must exist
- Pass/fail threshold

### Step 2: Assemble the Evidence Package
Before conducting the review, collect all evidence referenced in the gate criteria:
- Locate each required artefact in the project's artefact directory
- Check the evidence index for recorded entries
- Confirm each artefact exists AND has been reviewed/approved to the required threshold
- List any missing evidence as a blocker

### Step 3: Conduct Criterion-by-Criterion Review
For each criterion in the gate checklist:
1. State the criterion clearly
2. Locate the evidence that satisfies it
3. Assess: **PASS** (evidence exists and meets standard) / **FAIL** (evidence missing or inadequate) / **WAIVER REQUESTED** (criterion cannot be met; waiver justification provided)
4. Record the assessor's name and date

### Step 4: Handle Waivers
If any criterion cannot be met:
- The gate reviewer must formally evaluate whether a waiver is acceptable
- A waiver requires: written justification, risk assessment, compensating controls, approver sign-off
- Waivers are recorded in the waiver log using the waiver entry template
- Excessive waivers (more than 20% of criteria for a gate) indicate the phase was not ready

### Step 5: Make the Gate Decision
Based on the criterion-by-criterion review:
- **PASS**: All criteria met or formally waived. Phase can proceed.
- **CONDITIONAL PASS**: Minor items to address post-gate, with deadline and owner. Gate passes with conditions.
- **FAIL**: One or more mandatory criteria failed without acceptable waiver. Phase cannot proceed until remediated.

### Step 6: Produce the Gate Review Report
Fill the gate review report template (`templates/transversal/gate-review-report.md.template`) with:
- Gate ID (A–F)
- Review date and reviewer(s)
- Decision (PASS / CONDITIONAL PASS / FAIL)
- Criterion-by-criterion results
- Waivers issued (if any)
- Conditions (if conditional pass)
- Next phase authorization (if PASS)

### Step 7: Update Lifecycle State
After gate decision:
- Update the lifecycle state document with gate outcome
- If PASS: update phase status to `approved` and set next phase entry criteria as pending
- If FAIL: update phase status to `blocked` with remediation items
- Record the gate review report in the evidence index

## Key Principles
1. **Gates are decision points, not rubber stamps** — every criterion must be assessed against actual evidence.
2. **Evidence quality matters** — an artefact that exists but was not reviewed does not satisfy an "approved" threshold criterion.
3. **Waivers must be rare and deliberate** — waivers acknowledge known risk; they are not a way to skip governance.
4. **Gate reviewers must be independent** — the person(s) who produced the artefacts should not be the sole gate reviewer.
5. **Conditional passes have teeth** — conditions must have owners and deadlines; unclosed conditions become blockers for the next gate.

## Reference Materials
- `references/gate-criteria.md` — Gate criteria A–F, pass/fail thresholds, evidence requirements, waiver conditions
- `templates/transversal/gate-review-report.md.template` — Gate review report template
- Schema: `schemas/gate-review.schema.json`
- Schema: `schemas/waiver-log.schema.json`

## Quality Checks
- Every criterion has been explicitly assessed (no "assumed OK" without evidence reference)
- Waivers are documented with justification and approver signature
- Gate review report is produced and referenced in the evidence index
- Lifecycle state is updated after the gate decision
- Next phase cannot start until PASS is recorded
