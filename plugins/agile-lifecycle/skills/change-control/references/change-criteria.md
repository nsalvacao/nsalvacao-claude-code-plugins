# Change Criteria

## Overview
This document defines the criteria for classifying changes as significant or incremental, the change request process, and the impact categories used for significant change assessment.

## Significant Change Triggers

A change is classified as **significant** if it meets any of the following criteria:

| Trigger | Threshold | Examples |
|---------|-----------|---------|
| Scope change | Net addition > 20% of original committed scope | Adding a new module, removing a core feature, redefining target user segment |
| Architecture change | Fundamental change to system design | Switching from monolith to microservices, changing the primary database, adding a message queue |
| New external dependency | Adding a new integration not in the original architecture | New third-party API, new SaaS vendor, new infrastructure component |
| Regulatory impact | Any change triggered by or affecting compliance requirements | GDPR data handling change, new security standard requirement, audit finding remediation |
| Budget change | Budget increase or reallocation > 15% of approved budget | Additional licensing costs, new infrastructure, additional headcount |
| Timeline change | Milestone slip > 20% of the sprint count between gates | Gate review pushed by > 2 sprints from original plan |
| Team composition change | Loss or addition of > 30% of core team | Key person departure, team scaling, outsourcing decision |
| AI model replacement | Replacing the AI model type, provider, or training approach | Switching from fine-tuned model to RAG, changing LLM provider |

**If uncertain:** classify as significant. The impact assessment may reveal it is lower than expected, but it is better to assess than to assume.

## Incremental Change Criteria

A change is classified as **incremental** if ALL of the following are true:

- Scope addition is < 5% of current sprint commitment (e.g., adding 1 story to a 20-story sprint)
- Does not change the architecture or introduce new external dependencies
- Does not affect regulatory or compliance posture
- Does not affect budget or timeline milestones
- Does not affect acceptance criteria of already-approved stories
- Does not affect the evidence required at the next gate

Incremental changes include:
- Bug fixes on committed features
- Small UX improvements (copy changes, style tweaks, micro-interactions)
- Content updates (labels, error messages, help text)
- Performance improvements within defined bounds (e.g., reducing page load time without architecture change)
- Test coverage improvements
- Documentation updates

## Change Request Process

### Step-by-Step

```
Request → Classify → Impact Assess (if significant) → Approve → Implement → Verify → Record
```

1. **Request**: Change requestor documents the change in the change request log with description, justification, requestor, date.
2. **Classify**: PM and/or tech lead classify as significant or incremental using criteria above.
3. **Impact assess** (significant only): PM assesses impact across six dimensions (schedule, cost, risk, quality, scope, team).
4. **Approve**:
   - Incremental: product owner approves at next backlog grooming or sprint planning
   - Significant (no re-gate): PM + product owner written approval
   - Significant (re-gate required): PM + product owner + sponsor written approval
5. **Implement**: implement the change in the codebase and artefacts.
6. **Verify**: confirm change is implemented correctly; re-run affected tests.
7. **Record**: update change log with classification, impact assessment, approval, and implementation status.

### Approval Authority

| Change Type | Approval Authority |
|-------------|-------------------|
| Incremental | Product Owner |
| Significant, no re-gate, Low impact | PM + Product Owner |
| Significant, no re-gate, Medium impact | PM + Product Owner + Tech Lead |
| Significant, re-gate required | PM + Product Owner + Sponsor |
| Significant, budget impact | PM + Sponsor + Finance approver |

## Impact Assessment Categories

For each significant change, rate impact in six dimensions:

### 1. Schedule Impact
- **None**: no milestone or gate date affected
- **Low**: individual story or sprint affected; milestone date unchanged
- **Medium**: upcoming gate review delayed 1 sprint
- **High**: gate review delayed 2+ sprints; delivery date at risk

### 2. Cost Impact
- **None**: no budget change
- **Low**: < 5% budget increase, within contingency
- **Medium**: 5–15% budget increase; requires PM sign-off
- **High**: > 15% budget increase; requires sponsor approval

### 3. Risk Impact
- **None**: no new risks introduced
- **Low**: 1–2 new low risks added to risk register
- **Medium**: new medium or high risk introduced
- **High**: new critical risk, or existing mitigations invalidated

### 4. Quality Impact
- **None**: no change to quality standards or test coverage
- **Low**: minor reduction in test coverage; no DoD changes
- **Medium**: DoD revision required; test plan update needed
- **High**: significant regression in quality metrics; re-testing required

### 5. Scope Impact
- **None**: no change to scope baseline
- **Low**: < 5% addition; absorbed in current sprint
- **Medium**: 5–20% addition; requires sprint planning adjustment
- **High**: > 20% addition; requires roadmap revision and sponsor approval

### 6. Team Impact
- **None**: no team changes required
- **Low**: 1–2 days of additional effort from existing team members
- **Medium**: requires temporary specialist or cross-team support
- **High**: requires permanent headcount addition or significant skills gap

## Gate Implications

A significant change **requires re-gate** when:
- Any impact dimension is rated **High**
- Three or more dimensions are rated **Medium**
- The change affects artefacts that have already been approved at a gate

**Re-gate process:**
1. Phase status reverts to `in_progress`
2. Affected artefacts updated with change
3. Change recorded in change log
4. Phase contract updated to reflect new exit criteria or evidence requirements
5. Gate review re-run with updated evidence package

**No re-gate required** when:
- All impact dimensions are Low or None
- Change does not affect gate-mandatory artefacts
- Change can be absorbed in the current sprint without milestone impact

## Change Log Entry Format

Each change log entry records:
- `change_id`: unique identifier (e.g., `CHG-001`)
- `description`: what changed
- `requestor`: who requested it
- `date_requested`: ISO date
- `classification`: significant | incremental
- `impact_assessment`: six dimensions with ratings
- `re_gate_required`: true | false
- `approved_by`: named approver(s)
- `date_approved`: ISO date
- `status`: proposed | approved | rejected | implemented
- `artefacts_affected`: list of artefact IDs updated
