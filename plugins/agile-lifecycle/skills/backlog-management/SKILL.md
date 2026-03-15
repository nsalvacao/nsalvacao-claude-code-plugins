---
name: backlog-management
description: Use when shaping the product backlog, prioritizing stories, or preparing items for sprint readiness. Triggers when entering Phase 3 (Discovery), transitioning to Phase 4 (Delivery), or when backlog health needs assessment.
---

# Backlog Management

## Purpose
The product backlog is the single source of truth for all work. This skill governs how backlog items are shaped, estimated, prioritized, and declared sprint-ready. It bridges the discovery output of Phase 3 into a delivery-ready backlog for Phase 4. A well-managed backlog reduces sprint planning friction, prevents scope creep, and maintains alignment between the Product Owner and the delivery team.

## When to Use
- Discovery outputs (user research, problem statements, feature maps) need to be converted into backlog items
- Existing backlog items lack acceptance criteria or are too coarse for sprint planning
- Backlog needs re-prioritization after a gate review or stakeholder change
- Refinement session needs structure and facilitation prompts
- Sprint planning is blocked because the top of the backlog is not sprint-ready
- Backlog health metrics (coverage, staleness, readiness ratio) need assessment

## Instructions

### Step 1: Load Backlog Context
Review existing backlog items and their current status. Load `references/artefact-catalog.md` to understand mandatory backlog artefacts for the current phase. If transitioning from Phase 3, check that discovery output artefacts are available as input.

### Step 2: Create Backlog Items from Discovery Output
For each feature or capability identified in Phase 3:
- Use `templates/phase-3/backlog-item.md.template` to structure each item
- Set: `id`, `title`, `epic` (parent feature), `user_story` (As a / I want / So that), `business_value`, `priority`
- Tag with phase origin and source artefact reference
- Link to any related assumption or risk entries

### Step 3: Write Acceptance Criteria
For each backlog item, define acceptance criteria using the format in `templates/phase-3/acceptance-criteria-catalog.md.template`:
- Each criterion must be independently verifiable
- Use Given/When/Then where behaviour is involved
- Include non-functional requirements as separate criteria (performance, security, accessibility)
- Cross-check against the Definition of Done (`skills/definition-of-done/SKILL.md`)

### Step 4: Estimate and Size Items
With the delivery team during refinement:
- Estimate items in story points or t-shirt sizes (team decides the unit at Phase 3/4 boundary)
- Break down any item larger than the team's maximum sprint capacity
- Flag items with high estimation uncertainty — these need a spike or proof of concept first
- Record estimation assumptions in the item

### Step 5: Prioritize the Backlog
The Product Owner orders the backlog based on:
- Business value and strategic alignment
- Dependency ordering (prerequisites first)
- Risk reduction (high-risk items early to validate assumptions)
- Stakeholder agreements from gate reviews

Apply MoSCoW or weighted shortest job first (WSJF) as the team's chosen prioritization method. Document the method chosen and rationale for top-of-backlog ordering.

### Step 6: Apply Readiness Criteria
Before an item enters sprint planning, it must be sprint-ready:
- User story is written and understood by the team
- Acceptance criteria are defined and agreed
- Item is estimated
- Dependencies are identified and either resolved or sequenced
- Design artefacts (if needed) are available and linked

Items that do not meet readiness criteria stay in refinement — they do not enter the sprint backlog.

### Step 7: Maintain Backlog Health
At the end of each sprint and before each gate review, assess backlog health:
- Readiness ratio: percentage of top-N items that are sprint-ready (target: ≥ 80% of next 2 sprints)
- Staleness: items not updated in more than 2 sprints need review or removal
- Coverage: backlog coverage of committed phase scope (are all planned features represented?)
- Report health status in the evidence index

## Key Principles
1. **The backlog is owned by the Product Owner** — ordering decisions are the PO's responsibility; the team influences but does not override.
2. **Sprint-ready is a quality gate** — not a checklist; an item is ready when the team can build it without needing more information.
3. **Backlog size has diminishing returns** — items more than 3 sprints away should be kept coarse; refine just-in-time.
4. **Discovery does not end at Phase 3** — the backlog evolves with each sprint review; new insights must flow back.
5. **Backlog health is a delivery risk** — low readiness ratio is an early warning sign for sprint planning failure.

## Reference Materials
- `templates/phase-3/backlog-item.md.template` — Backlog item structure and required fields
- `templates/phase-3/acceptance-criteria-catalog.md.template` — Acceptance criteria patterns
- `references/artefact-catalog.md` — Mandatory backlog artefacts by phase
- Schema: `schemas/sprint-contract.schema.json`

## Quality Checks
- Every backlog item in the top 2 sprints has a written user story and acceptance criteria
- No item enters sprint planning without an estimate
- Backlog is ordered with explicit rationale for the top 10 items
- Items flagged as high-uncertainty have a corresponding spike or proof-of-concept entry
- Readiness ratio is tracked and visible to the team
- Backlog health reviewed at each sprint review and phase gate
