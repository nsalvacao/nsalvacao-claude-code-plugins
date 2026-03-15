---
name: sprint-facilitation
description: This skill should be used when facilitating sprint ceremonies — sprint planning, daily standup, or sprint review. Triggers when a new sprint starts, when a standup is losing focus, or when a sprint review needs stakeholder demo structure. For deep retrospective facilitation or improvement backlog management, use the retrospective skill instead. Also applies when AI/ML experiment checkpoints need to be integrated into sprint ceremonies.
---

# Sprint Facilitation

## Purpose
Sprint ceremonies are the operational heartbeat of Phase 4 (Iterative Delivery). When facilitated well, they maintain team alignment, surface blockers early, demonstrate value to stakeholders, and create a continuous improvement loop. This skill provides structure, facilitation prompts, and health indicators for all four core sprint ceremonies plus AI-specific checkpoints.

## When to Use
- A new sprint is starting and sprint planning needs facilitation
- Daily standup is running long or losing focus
- Sprint review needs structure for stakeholder demos
- Retrospective needs a format and facilitation guide
- Sprint health indicators need checking before the next sprint starts
- An AI/ML sprint needs experiment evaluation integrated into ceremonies

## Instructions

### Step 1: Identify the Sprint Event
Determine which ceremony needs facilitation:
- **Sprint Planning**: start of sprint; define goal, select backlog, commit
- **Daily Standup**: daily; sync on progress, blockers, plan
- **Sprint Review**: end of sprint; demo to stakeholders, collect feedback
- **Retrospective**: end of sprint; reflect on process, define improvements

Load the patterns from `references/sprint-patterns.md` for the specific ceremony.

### Step 2: Sprint Planning Facilitation
**Timebox:** 2h for 2-week sprint; scale proportionally.

1. **Sprint Goal setting (15 min):** Product Owner proposes goal. Team challenges and refines until it is achievable and meaningful. Goal must be specific, measurable, and linked to the product roadmap.
2. **Backlog selection (60 min):** Pull from top of prioritized backlog. For each story: clarify acceptance criteria, estimate if not estimated, identify dependencies and risks.
3. **Capacity check (15 min):** Account for team availability (holidays, planned leave, meetings). Calculate available capacity in story points or hours. Do not over-commit.
4. **Commitment (15 min):** Team commits to sprint backlog. Sprint goal is written and visible. Risks and assumptions for the sprint are documented.
5. **AI sprint specifics:** If sprint contains AI experiments, define the experiment hypothesis, success criteria, and timebox before planning ends.

### Step 3: Daily Standup Facilitation
**Timebox:** 15 minutes. Not a status meeting — it is a coordination meeting.

Structure each standup with three questions:
1. What did I complete since last standup?
2. What will I complete before next standup?
3. What is blocking me (or might block me)?

**Facilitation rules:**
- Start on time, always
- Blockers are noted; not solved during standup (take offline)
- If discussion exceeds 5 min, timebox and schedule a follow-up
- The facilitator ensures everyone speaks; no single person dominates

**AI standup additions:** If an AI experiment is running, add: "Is the experiment on track? Any early signals on the hypothesis?"

### Step 4: Sprint Review Facilitation
**Timebox:** 1h for 2-week sprint.

1. **Review sprint goal (5 min):** Was the sprint goal achieved? If not, why?
2. **Demo completed stories (40 min):** For each completed story, demonstrate against acceptance criteria. Stakeholders validate acceptance. Only "done" stories are demoed.
3. **Stakeholder feedback (10 min):** Open discussion. Capture feedback in backlog items (new stories, changes to existing ones).
4. **Metrics review (5 min):** Velocity, commitment ratio, defect count for sprint. Flag any threshold breaches.

**What not to include in sprint review:** Stories that are not done. No "partial demos" of incomplete work.

### Step 5: Retrospective Facilitation
See also: `skills/retrospective/SKILL.md` for full retrospective facilitation detail.

**Timebox:** 45–60 min for sprint retrospective.

Quick format (Start/Stop/Continue):
1. **What should we START doing?** (10 min): New practices, tools, habits that would improve the team
2. **What should we STOP doing?** (10 min): Things that are not adding value or are causing harm
3. **What should we CONTINUE doing?** (10 min): Things working well that must be preserved
4. **Action items (15 min):** From all items, select 1–3 actions. Each must have: specific action, owner, due date. Add to improvement backlog.

### Step 6: Check Sprint Health Indicators
After each sprint, assess sprint health against indicators in `references/sprint-patterns.md`:
- **Velocity trend**: stable, improving, or degrading?
- **Scope creep**: were stories added mid-sprint without removing others?
- **Blocked items**: average time in "blocked" status
- **Defect accumulation**: are defects growing sprint over sprint?
- **Carry-over rate**: stories not completed and carried to next sprint (target: ≤ 10% of commitment)

## Key Principles
1. **Ceremonies serve the team, not the process** — if a ceremony is not adding value, adapt it; do not abolish it without a replacement.
2. **Sprint goals are commitments** — not aspirations. Commit to what can be done; be honest about capacity.
3. **Blockers raised in standup must be resolved the same day** — unresolved blockers compound and destroy velocity.
4. **Demos are for stakeholders** — show working software against acceptance criteria; do not explain what was done in theory.
5. **Retrospective actions must be timeboxed** — an action without a deadline is a wish, not a plan.

## Reference Materials
- `references/sprint-patterns.md` — Sprint ceremony patterns, facilitation tips, health indicators
- `templates/phase-4/iteration-plan.md.template` — Sprint planning output template
- `templates/phase-4/review-outcomes.md.template` — Sprint review output template

## Quality Checks
- Sprint goal is written down and accessible to the whole team
- Sprint backlog is committed based on capacity, not pressure
- Every daily standup produces at least a blocker list (even if empty)
- Sprint review demos only completed stories
- Every retrospective produces 1–3 action items with owner and deadline
- Sprint health indicators reviewed at end of each sprint
