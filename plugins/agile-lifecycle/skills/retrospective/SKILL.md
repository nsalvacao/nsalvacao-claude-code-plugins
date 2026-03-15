---
name: retrospective
description: Use when facilitating sprint retrospectives or phase retrospectives, managing an improvement backlog, or tracking retrospective action items. Triggers at the end of each sprint, at each phase gate, or when the team needs a structured process improvement session.
---

# Retrospective

## Purpose
The retrospective is the primary continuous improvement mechanism in the lifecycle. It operates at two levels: sprint retrospective (end of each sprint) and phase retrospective (post-gate, before the next phase starts). When well-facilitated, retrospectives produce a concrete improvement backlog that reduces friction sprint over sprint. This skill provides facilitation formats, action item tracking, and quality indicators for both levels. Note: `skills/sprint-facilitation/SKILL.md` references this skill for deep retrospective guidance — these skills must be used together.

## When to Use
- A sprint has ended and a sprint retrospective needs structure
- A phase has completed its gate review and a phase retrospective is due
- The team's improvement backlog needs review and prioritisation
- Retrospective action items from a previous sprint need follow-up
- A retrospective is running ineffectively (dominated by one voice, no actions produced, recurring complaints without resolution)
- A new team member needs to understand the retrospective format

## Instructions

### Step 1: Determine the Retrospective Level
Identify whether this is a sprint retrospective or a phase retrospective:
- **Sprint retrospective**: 45–60 min, end of every sprint, team-level, focuses on process and collaboration
- **Phase retrospective**: 90–120 min, post-gate, broader audience (can include stakeholders), focuses on phase governance and delivery quality

Structure the session using the retrospective schema in `schemas/retrospective.schema.json`. For phase retrospectives, extend with phase-level sections covering contract adherence, RACI effectiveness, and governance quality.

### Step 2: Prepare the Session
Before the session:
- Confirm participants: whole delivery team for sprint; delivery team + PO + sponsor for phase
- Book a timebox and a facilitator (ideally not the Delivery Lead — use rotation to prevent bias)
- Provide the team with a way to submit anonymous input before the session (sticky notes, digital board, or written input)
- Review action items from the previous retrospective — these are the opening agenda item

### Step 3: Review Previous Action Items
Open every retrospective by reviewing what was committed in the last one:
- For each action item: completed | partially completed | not started | no longer relevant
- If not started or partially completed: why? Is it still worth pursuing?
- Carry forward incomplete but still-relevant actions to this session's action list
- Close actions that are no longer relevant with a brief note

This prevents retrospectives from becoming performative — teams that never follow up on actions lose trust in the format.

### Step 4: Run the Start/Stop/Continue Format
For sprint retrospectives, use the Start/Stop/Continue format (default):
1. **STOP (10 min)**: What should we stop doing? Practices, habits, or patterns that are causing harm or adding no value.
2. **START (10 min)**: What should we start doing? New practices, tools, or habits that would improve the team.
3. **CONTINUE (10 min)**: What is working well that we must preserve? Practices to protect from change pressure.

Facilitation rules:
- Every participant contributes at least one item per category
- Group similar items and dot-vote to identify the highest-priority themes
- The facilitator ensures no single voice dominates
- Hot takes and blame are reframed as systemic observations

### Step 5: Define Action Items
From the prioritised themes:
- Select 1–3 action items (no more — focus over completeness)
- For each action item, define with the following fields (validate against `schemas/retrospective.schema.json`):
  - `action`: specific, concrete change to be made
  - `owner`: named person (not a role — a real name)
  - `due_date`: specific date within the next sprint or phase
  - `success_indicator`: how the team will know it worked
- Add action items to the improvement backlog

### Step 6: Manage the Improvement Backlog
The improvement backlog is a persistent, prioritised list of team improvement actions:
- Validate against `schemas/retrospective.schema.json`
- New actions from each retrospective are added to the backlog
- At the start of each sprint planning, the top improvement backlog item is reviewed
- Actions that have been open for more than 3 sprints without progress are escalated to the Delivery Lead
- Completed actions are archived with outcome notes

### Step 7: Conduct Phase Retrospective
At each phase gate, run a phase retrospective in addition to the sprint retrospective:
- Review the full phase: what went well, what was difficult, what would be done differently
- Review phase contract adherence: were estimates accurate? Were assumptions valid?
- Review the RACI: did accountability assignments work in practice?
- Produce phase improvement recommendations — these feed into the next phase contract and tailoring decisions
- Record phase retrospective outcomes in the evidence index as a gate artefact

## Key Principles
1. **Action items over complaints** — a retrospective that ends without concrete actions is a therapy session, not a governance tool.
2. **Follow-up is the credibility of the retrospective** — if actions are never reviewed, the team stops caring about the format.
3. **Facilitation rotation prevents bias** — the same facilitator every sprint creates a power dynamic; rotate the role.
4. **Phase retrospectives are governance artefacts** — their outcomes feed into the next phase contract and the evidence index.
5. **Improvement is iterative** — 1–3 focused actions per sprint, consistently followed through, outperforms 10 aspirational actions never completed.

## Reference Materials
- Schema: `schemas/retrospective.schema.json`
- `references/artefact-catalog.md` — Phase retrospective as mandatory phase gate artefact
- `skills/sprint-facilitation/SKILL.md` — Sprint ceremony context; Step 5 references this skill

## Quality Checks
- Every retrospective opens with a review of previous action items
- Each session produces 1–3 action items with named owner and due date
- Action items are added to the improvement backlog and tracked
- Actions open for more than 3 sprints are escalated
- Phase retrospective is conducted at each gate and recorded in the evidence index
- Retrospective schema is valid for all entries in the improvement backlog
