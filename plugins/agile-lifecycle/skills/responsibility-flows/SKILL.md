---
name: responsibility-flows
description: This skill should be used when creating RACI charts, mapping accountability by activity, resolving accountability gaps, or producing the Role-Responsibility Map artefact. Triggers when entering Phase 2 (Architecture) or Phase 3 (Discovery), or when team structure changes during delivery.
---

# Responsibility Flows

## Purpose
Clarity about who is responsible, accountable, consulted, and informed for each lifecycle activity prevents decisions from stalling, artefacts from being orphaned, and escalation paths from being unclear. This skill produces RACI charts per phase, maps accountability to named roles, and generates the Role-Responsibility Map — a mandatory Phase 2 artefact. It is maintained throughout all phases as team structure evolves.

## When to Use
- Phase 2 (Architecture) requires a Role-Responsibility Map as a deliverable
- Phase 3 (Discovery) is starting and it is unclear who owns each backlog artefact
- A decision is blocked because no one knows who is accountable
- A new team member joins and needs to understand their accountability boundaries
- Team structure changes (role added, removed, or redefined)
- A gate review reveals accountability gaps in the phase evidence
- An artefact is produced but has no named owner

## Instructions

### Step 1: Identify Roles in Scope
List all roles participating in the project. Roles, not individuals — the RACI must remain valid when people change. Reference `references/role-accountability-model.md` for standard role definitions in this framework. Common roles:
- Product Owner (PO)
- Delivery Lead / Scrum Master
- Technical Lead / Architect
- Developer
- QA / Test Engineer
- Security Engineer (if applicable)
- Data Engineer / Scientist (if applicable)
- Sponsor / Business Owner
- Gate Reviewer

For each role, record: name of role, current person filling it (for the project), and phase entry/exit date if temporary.

### Step 2: Map Activities to RACI per Phase
For each lifecycle phase in scope (determined by the tailoring profile from `skills/lifecycle-tailoring/SKILL.md`):
- List all activities in the phase (reference `references/artefact-catalog.md` and `references/lifecycle-overview.md`)
- For each activity, assign:
  - **R (Responsible)**: does the work
  - **A (Accountable)**: owns the outcome; signs off; only one A per activity
  - **C (Consulted)**: input required before or during the activity
  - **I (Informed)**: notified of outcome; no input required

Rules: every activity has exactly one A. Multiple R entries are allowed. C and I are optional. Activities with no A are accountability gaps — resolve before phase start.

### Step 3: Identify and Resolve Accountability Gaps
An accountability gap exists when:
- An activity has no A assigned
- Two roles both claim to be A for the same activity (dual accountability)
- An artefact is required but no role is R for producing it

For each gap:
- Propose an assignment based on `references/role-accountability-model.md` defaults
- If the gap requires an organisational decision, escalate to the Delivery Lead or Sponsor
- Record resolution decisions in the Role-Responsibility Map

### Step 4: Produce the Role-Responsibility Map Artefact
Create the Role-Responsibility Map as a project artefact:
- Section 1: Role roster with current assignment and phase scope
- Section 2: RACI table per phase (use a table format with roles as columns, activities as rows)
- Section 3: Accountability gaps identified and resolved (or escalated)
- Section 4: Escalation path for each phase (who to contact when the Accountable role is unavailable)

Add the document to the Phase 2 evidence index.

### Step 5: Communicate the RACI to the Team
The RACI is only useful if the team knows it:
- Walk through the RACI in a team session at the start of each phase
- Highlight key R and A assignments for the activities in the upcoming phase
- Confirm that all C and I paths are understood (who needs to be consulted for which decisions)

### Step 6: Maintain the RACI Through Phase Changes
The Role-Responsibility Map is a living document:
- When a team member changes: update the person-to-role assignment; the RACI table itself does not change unless the role changes
- When a new activity is added: add it to the RACI and assign R and A before the activity starts
- When tailoring decisions change the phase scope: update the RACI to reflect removed or added phases
- Version the document and reference the version in each phase contract

## Key Principles
1. **One A per activity** — dual accountability is no accountability; resolve conflicts explicitly.
2. **Roles outlast individuals** — the RACI maps to roles; people are recorded separately.
3. **Gaps before phase start, not during** — identifying accountability gaps mid-phase causes delays; resolve them upfront.
4. **C is a commitment, not a courtesy** — if a role is listed as C, that input is required before the activity completes.
5. **The RACI enables escalation** — when in doubt about a decision, the RACI tells you who the A is; that person decides.

## Reference Materials
- `references/role-accountability-model.md` — Standard role definitions, default RACI patterns, accountability model
- `references/lifecycle-overview.md` — Phase activity lists used as RACI input rows
- `references/artefact-catalog.md` — Artefacts that require an owner (R and A assignment)

## Quality Checks
- Every activity in scope has exactly one A assigned
- No artefact in the phase exists without a named R
- Accountability gaps identified in Step 3 are resolved or formally escalated
- Role-Responsibility Map is produced as a Phase 2 artefact
- RACI is reviewed and confirmed at the start of each phase
- Version of the RACI is referenced in each phase contract
