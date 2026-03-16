---
name: gate-checklist
description: This skill should be used when preparing for or executing a gate review. Provides binary pass/fail/waived checklists for all 8 gates A-H of the waterfall-lifecycle framework. Use this skill as a pre-flight check before invoking the gate-reviewer agent.
---

# Gate Checklist

## Purpose
Gate reviews are binary decision points in the waterfall lifecycle. This skill provides the structured pre-flight checklist to verify gate readiness before a formal gate review is executed. It covers all 8 gates (A–H) and ensures artefact completeness, evidence thresholds, and waiver documentation are validated before the gate-reviewer agent is invoked.

## When to Use
- Phase exit criteria are met and gate review is approaching
- Stakeholders need to confirm gate readiness before scheduling a review
- A gate review has been blocked and the root cause needs to be identified
- A post-gate debrief requires a retrospective pass/fail analysis
- Waivers must be verified before a gate can proceed

## Instructions

### Step 1: Identify the Gate and Load Criteria
Determine which gate (A–H) is being reviewed. Load the relevant section from `skills/gate-checklist/references/gate-criteria.md`. Cross-reference with `references/gate-criteria-reference.md` for the full obligation matrix.

### Step 2: Verify Artefact Completeness
Check each mandatory artefact in the artefact-to-obligation matrix for this gate:
- Does the artefact exist in the designated location?
- Is it the correct version (not a draft unless draft is explicitly accepted for this gate)?
- Is it registered in the evidence index at `.waterfall-lifecycle/evidence/`?

Any missing mandatory artefact is an automatic gate FAIL — do not proceed without resolving.

### Step 3: Verify Evidence Thresholds
For each artefact, confirm it meets the evidence threshold required for this gate:
- `exists` — file is present and accessible
- `reviewed` — artefact has been reviewed by the designated reviewer role
- `approved` — artefact has formal sign-off from the designated approver

An artefact that exists but requires `approved` threshold and has not been signed off is a gate FAIL.

### Step 4: Assess Each Pass Criterion
For each pass criterion in the gate checklist:
- `met` — criterion is satisfied with evidence reference
- `not_met` — criterion is not satisfied; gate FAIL unless waived
- `waived` — criterion formally waived with documentation

Mark each criterion with its assessment and evidence or waiver reference.

### Step 5: Verify Waiver Documentation
For each criterion marked `waived`:
- Waiver has justification text explaining why criterion is not applicable or acceptable to skip
- Approver name is recorded (specific individual, not a role or "TBD")
- Risk acceptance statement is present confirming the approver accepts associated risks
- Undocumented waivers are treated as `not_met` — there is no implicit waiver

### Step 6: Determine Gate Decision
Apply the binary decision rule:
- **PASS** — all criteria are `met` or `waived` (with valid waiver documentation)
- **FAIL** — any criterion is `not_met`, or any waiver is undocumented
- No partial pass exists in waterfall gate reviews

Document the rationale for FAIL decisions including which specific criteria failed.

### Step 7: Document and Hand Off to Gate Reviewer
Document the gate decision in a gate review report using `templates/transversal/gate-review-report.md.template`:
- Record overall decision (PASS/FAIL)
- List all criteria with their assessment
- Reference evidence artefacts and waivers
- Hand off the completed checklist to the gate-reviewer agent for formal execution

## Key Principles
1. **Binary gate decision** — PASS, FAIL, or WAIVED per criterion; no partial pass at gate level.
2. **Artefact completeness first** — missing mandatory artefacts automatically fail the gate before criteria are assessed.
3. **Evidence thresholds are binding** — the distinction between `exists`, `reviewed`, and `approved` is a formal gate requirement, not a suggestion.
4. **Waivers require documentation** — an undocumented waiver is indistinguishable from a failure; treat it as `not_met`.
5. **Gate-reviewer agent is the executor** — this skill is the preparation checklist; the agent performs the formal review.

## Reference Materials
- `skills/gate-checklist/references/gate-criteria.md` — Summary checklists for all 8 gates A–H
- `references/gate-criteria-reference.md` — Full obligation matrix and evidence thresholds
- `references/lifecycle-overview.md` — Phase-to-gate mapping and lifecycle context
- `templates/transversal/gate-review-report.md.template` — Gate review report template

## Quality Checks
- Gate identifier (A–H) is clearly established before checklist is started
- Every mandatory artefact for this gate is verified (not assumed to exist)
- Every criterion has an assessment (`met` / `not_met` / `waived`) with evidence or waiver reference
- No undocumented waivers remain in the checklist
- Gate decision (PASS/FAIL) is recorded before handing off to gate-reviewer agent
- Evidence artefacts are registered in the evidence index, not just referenced locally
