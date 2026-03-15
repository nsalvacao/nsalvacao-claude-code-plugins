# Sprint Patterns

## Overview
This document provides patterns, facilitation structures, and health indicators for sprint ceremonies in the agile-lifecycle framework. Patterns are guidelines — adapt them to your team's needs, but maintain the core intent.

## Sprint Planning Patterns

### Goal Setting
A good sprint goal is:
- **Specific**: "Ship user authentication with OAuth2 for Google and GitHub" not "Work on auth"
- **Achievable**: team can reasonably complete it in one sprint
- **Meaningful**: stakeholders care about it
- **Testable**: there is a clear way to know if it was achieved

Anti-patterns:
- "Continue work on feature X" — not a goal, just a continuation
- "Do everything in the backlog" — not a goal, just a list
- Goal set by PM with no team input — not committed

### Backlog Refinement Before Planning
Backlog is "sprint-ready" when for every P1 story:
- Acceptance criteria are written and reviewed by product owner
- Story is sized (estimated)
- Dependencies are identified
- No open questions that would block implementation

If backlog is not ready, sprint planning cannot proceed — this triggers Gate C's backlog readiness review.

### Capacity Planning
- Count working days in sprint for each team member
- Subtract: public holidays, planned leave, recurring meetings (if >20% of day), cross-team commitments
- Convert available days to story points using team's historical velocity per person
- Commit to ≤ 90% of available capacity (buffer for unexpected work)

### AI Experiment Timebox
For sprints containing AI experiments:
- Define hypothesis: "We believe [experiment] will achieve [metric] because [rationale]"
- Define success criteria: specific, measurable threshold
- Set timebox: maximum effort allocated (e.g., 5 SP or 3 days)
- Define decision point: at timebox end, evaluate and decide: continue, pivot, or abandon

---

## Sprint Review Patterns

### Demo Structure
1. Introduce the sprint goal (1 min)
2. State whether the goal was achieved (1 min)
3. For each completed story (3–5 min per story):
   - State the acceptance criterion being demonstrated
   - Show it working in the staging/test environment
   - Ask stakeholders to validate acceptance
4. Show metrics for the sprint (2 min)
5. Open for questions and feedback (10 min)

### Stakeholder Feedback Capture
- Assign a note-taker role for the sprint review
- Capture all feedback as backlog items immediately (do not filter)
- PM triages after the meeting: new stories, changes, rejected feedback (with reason)
- Feedback items are visible in the next sprint planning

### What Counts as "Done" for Demo
A story is done and demo-able when:
- All acceptance criteria verified
- Code reviewed
- Tests passing
- Deployed to staging/demo environment
- No P1 defects open against it

---

## Retrospective Formats

### Start/Stop/Continue (Default)
**Best for:** Teams looking for quick, actionable improvement
**Timebox:** 45 min
1. Individual brainstorm: 5 min (silent sticky notes or shared doc)
2. Group by theme: 10 min
3. Vote on top items: 5 min
4. Discuss top 3–5 items: 15 min
5. Define 1–3 actions with owner + due date: 10 min

### 4Ls — Liked / Learned / Lacked / Longed For
**Best for:** Teams reflecting on a significant event (phase end, major release)
**Timebox:** 60 min
- **Liked**: What did we appreciate about this sprint/phase?
- **Learned**: What did we learn that we did not know before?
- **Lacked**: What was missing that would have helped us?
- **Longed For**: What do we wish we had done differently?

### Timeline Retrospective
**Best for:** Phase retrospectives; when events need to be ordered and discussed in context
**Timebox:** 90 min
1. Build a timeline of key events in the phase on a shared board
2. Mark positive events (green) and negative events (red)
3. Identify patterns and root causes
4. Define systemic improvements

### KALM — Keep / Add / Less / More
**Best for:** Teams wanting to fine-tune existing practices
1. **Keep**: practices working well that must continue exactly as is
2. **Add**: new practices to introduce
3. **Less**: things to do less of (not stop, just reduce)
4. **More**: things to do more of

---

## Sprint Health Indicators

| Indicator | Healthy | Warning | Action Required |
|-----------|---------|---------|----------------|
| Velocity trend | Stable ±15% over 3 sprints | Declining >15% for 2 sprints | Investigate capacity, scope creep, quality issues |
| Commitment ratio | 85–100% | 70–84% | Review backlog readiness, estimation accuracy |
| Carry-over rate | ≤ 10% of committed SP | 10–20% | Review story sizing, dependency management |
| Blocked time | < 10% of cycle time | 10–25% | Daily blocker tracking, escalation process |
| Defect accumulation | 0 P1 open, P2 decreasing | Any P1 open end of sprint | Halt new features until P1 resolved |
| Scope creep | No mid-sprint additions | 1–2 additions (with trade-off) | Change control for mid-sprint scope additions |
| Retrospective action completion | >80% of actions done by next sprint | 50–79% | Review if actions are realistic and owned |

### Velocity Drop Investigation Checklist
When velocity drops >20% for 2+ sprints:
- [ ] Are team members available (absence, leave, reassignment)?
- [ ] Was there a surge in defect fixing reducing new feature work?
- [ ] Were stories larger than estimated?
- [ ] Were there unplanned dependencies blocking completion?
- [ ] Was the backlog well-refined before planning?
- [ ] Is technical debt slowing down implementation?

---

## AI Sprint Specifics

### Model Evaluation Checkpoints
Include in sprint planning for AI sprints:
- Define which model metrics to evaluate (accuracy, latency, drift indicators)
- Identify when in the sprint evaluation will occur
- Allocate capacity for evaluation (do not treat it as free; it requires time)

### Experiment Retrospective
After an AI experiment sprint or timebox:
- Document: hypothesis, result, what was learned
- Decision: validate hypothesis (continue), invalidate (pivot), inconclusive (extend timebox or change approach)
- Update the AI experiment log (artefact: `ai-experiment-log.md`)

### Handling Failed Experiments
A failed experiment is not a failed sprint — it is a learning. During sprint review:
- Share what was learned, not just what failed
- Avoid blame language; use "the experiment showed..."
- Reframe the next experiment based on learnings
