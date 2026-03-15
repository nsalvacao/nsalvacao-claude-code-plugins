---
name: change-control
description: "This skill should be used when evaluating if a change is incremental or significant, when processing a change request, or when updating the change log. Triggers when scope, requirements, or architecture changes are proposed."
---

# Change Control

## Purpose
Change control ensures that scope changes, requirement changes, and architecture changes are assessed, classified, and approved before being implemented. The classification determines whether a change can be absorbed incrementally or requires a formal change request with impact assessment and re-gating. Unmanaged changes accumulate as technical debt, scope creep, or unacknowledged risk.

## When to Use
- A new requirement is proposed after Phase 3 (Discovery) is closed
- An architecture change is proposed during Phase 4 or later
- A stakeholder requests a change that affects scope, timeline, or budget
- A technical discovery reveals that the approach must change
- A regulatory or compliance update requires product changes
- Evaluating whether a proposed change should trigger a re-gate

## Instructions

### Step 1: Capture the Change Request
Document the proposed change using the significant change record template: `templates/transversal/significant-change-record.md.template`. At a minimum, record:
- Description of the change
- Requestor and date
- Justification or trigger
- Urgency (urgent / scheduled / advisory)

### Step 2: Classify the Change
Apply the classification criteria from `references/change-criteria.md`:
- **Significant change**: large scope, architecture impact, external dependency addition, regulatory impact, or budget/timeline change above thresholds
- **Incremental change**: bug fixes, small feature additions, content updates, performance improvements within bounds

If uncertain, default to "significant" — it is better to over-classify and scope down than to miss the impact of a change.

### Step 3: Impact Assessment (Significant Changes Only)
For significant changes, assess impact across six dimensions:
1. **Schedule**: will this delay any milestone or gate review?
2. **Cost**: does this require additional budget or resource?
3. **Risk**: does this introduce new risks or invalidate existing mitigations?
4. **Quality**: does this affect test coverage, technical debt, or quality thresholds?
5. **Scope**: how many existing requirements or backlog items are affected?
6. **Team**: does this require skills or capacity not currently available?

Rate each dimension: None / Low / Medium / High.

### Step 4: Determine Re-gate Requirement
Based on the impact assessment:
- If **any dimension is High**: significant change likely requires re-gate of the phase where the change originated
- If **multiple dimensions are Medium**: assess whether the cumulative impact crosses the re-gate threshold
- If **all dimensions are Low or None**: significant change can be absorbed without re-gate, but must be approved

Re-gate means: the affected phase returns to `in_progress` status, the changed artefacts are updated, and the gate review is re-run with the updated evidence.

### Step 5: Approval
- **Incremental change**: approved by product owner at sprint planning or backlog grooming
- **Significant change, no re-gate**: approved by PM and product owner; recorded in change log
- **Significant change with re-gate**: approved by PM, product owner, and sponsor; phase contract updated

### Step 6: Implement and Verify
After approval:
- Update affected artefacts (phase contract, risk register, backlog)
- If re-gate required: update phase status to `in_progress`, make the changes, re-assemble evidence, trigger gate review
- Record the change in the change log (`schemas/change-log.schema.json`)
- Notify affected stakeholders

### Step 7: Update Downstream Artefacts
After implementing the change:
- Update any artefacts that reference the changed scope, architecture, or requirements
- Verify acceptance criteria are still valid for affected stories
- Update risk register if new risks were introduced

## Key Principles
1. **Classify before you implement** — implementing first and classifying later leads to scope creep and unacknowledged technical debt.
2. **The default for uncertainty is "significant"** — it is easier to relax classification than to discover too late that a change was larger than assumed.
3. **Re-gating is not a punishment** — it is the mechanism that keeps the lifecycle honest when reality changes.
4. **Change log is cumulative** — every approved change is recorded; the cumulative view reveals drift from original scope.
5. **Approval must be documented** — verbal approvals are not sufficient for significant changes; email or written record required.

## Reference Materials
- `references/change-criteria.md` — Classification criteria, significant vs incremental thresholds, change request process, impact categories
- Schema: `schemas/change-log.schema.json`
- Template: `templates/transversal/significant-change-record.md.template`

## Quality Checks
- Every proposed change is classified before implementation begins
- Significant changes have an impact assessment covering all six dimensions
- Re-gate decisions are documented with rationale
- Change log is updated after each approved significant change
- Affected artefacts are updated after change implementation
- Stakeholders are notified of approved significant changes
