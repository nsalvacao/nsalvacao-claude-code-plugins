---
name: definition-of-done
description: Use when defining, applying, or updating the Definition of Done. Triggers when Phase 4 is about to start, when a story is declared complete, or when quality standards need to be updated across sprint and release levels.
---

# Definition of Done

## Purpose
The Definition of Done (DoD) is a formal, team-agreed checklist that distinguishes genuinely completed work from work that is merely coded. It operates at three levels: story, sprint, and release. It must be agreed before Phase 4 begins, enforced at every sprint review, and updated as quality standards evolve. Without a DoD, "done" is ambiguous and technical debt accumulates silently.

## When to Use
- Phase 3 is closing and Phase 4 (Iterative Delivery) is about to start — DoD must be agreed first
- A story is about to be declared done in a sprint review — validate against the DoD
- A sprint is closing and release-level criteria need checking
- The team decides to raise or adjust quality standards mid-project
- A new team member needs onboarding on what "done" means for this project
- A gate review requires evidence of quality standards applied

## Instructions

### Step 1: Load the DoD Schema and Template
Open `schemas/definition-of-done.schema.json` to understand the mandatory structure. Use `templates/phase-3/dod-checklist.md.template` to create or update the DoD document. The DoD document is a project-level artefact — it is not per-sprint.

### Step 2: Define Story-Level Done Criteria
A story is done when ALL of the following are true (adapt to project context):
- Code is written, peer-reviewed, and merged to the main branch
- All acceptance criteria for the story pass
- Unit and integration tests are written and pass
- No new linting or static analysis violations introduced
- Code is deployed to the integration/staging environment
- Product Owner has accepted the story against acceptance criteria
- Documentation updated if the story changes user-facing behaviour

### Step 3: Define Sprint-Level Done Criteria
A sprint is done when ALL stories in the sprint backlog are either done (story-level) or explicitly moved out, AND:
- Regression test suite passes
- No unresolved critical or high-severity defects in the sprint scope
- Velocity and metrics recorded
- Sprint review completed and stakeholder feedback captured
- Retrospective completed and action items logged

### Step 4: Define Release-Level Done Criteria
A release is done when ALL sprint-level criteria are met across all sprints in the release, AND:
- Performance tests pass against defined thresholds
- Security scan completed with no open high/critical findings
- User acceptance testing completed with sign-off
- Release notes drafted and approved
- Deployment runbook validated
- Rollback plan documented and tested

### Step 5: Agree the DoD with the Team
Before Phase 4 starts, the DoD must be agreed by the delivery team and the Product Owner:
- Walk through each criterion in a workshop or refinement session
- Remove criteria that are impractical for the current project context (document the removal rationale)
- Add project-specific criteria not covered by the template
- Obtain explicit agreement — the DoD is a team commitment, not a management mandate

### Step 6: Apply the DoD at Every Sprint Review
For each story presented in the sprint review:
- Check each story-level criterion explicitly
- Stories that do not meet the DoD are not accepted — they return to the backlog
- Sprint-level criteria are checked before the sprint is officially closed
- Any waived criterion requires a formal waiver entry in the evidence index

### Step 7: Update the DoD Over Time
Review the DoD at each phase gate and after major retrospectives:
- Add criteria for newly identified quality risks
- Remove criteria no longer relevant (document why)
- Align with external standards if compliance requirements change
- Version the DoD document — teams and reviewers must know which version applies to which sprints

## Key Principles
1. **Done means done** — partial completion is not done; a story either passes all criteria or it does not.
2. **The DoD is a team agreement** — no external party can unilaterally change it; changes require team consent.
3. **Waivers are exceptions, not the norm** — if the same criterion is waived repeatedly, the DoD needs updating, not more waivers.
4. **Three levels prevent confusion** — story-level, sprint-level, and release-level serve different purposes; conflating them creates gaps.
5. **The DoD is an evidence artefact** — it is referenced in gate reviews as proof of quality standards applied.

## Reference Materials
- `templates/phase-3/dod-checklist.md.template` — DoD checklist template with story/sprint/release sections
- Schema: `schemas/definition-of-done.schema.json`
- `references/artefact-catalog.md` — DoD as mandatory artefact for Phase 3 exit
- `templates/phase-3/test-plan.md.template` — Test plan template complements DoD at sprint and release level

## Quality Checks
- DoD document exists as a formal project artefact before Phase 4 starts
- All three levels (story, sprint, release) are defined
- Every sprint review references the DoD explicitly
- Waivers are documented in the evidence index with rationale and approver
- DoD version is referenced in each sprint contract
- DoD reviewed and updated at each phase gate
