# Sprint Health Reference

## Overview

Sprint health is a multi-dimensional view of delivery performance within a sprint. It goes beyond velocity to include commitment quality, defect accumulation, blocked work, scope management, and team morale. Sprint health is captured in the Sprint Health Record (`schemas/sprint-health.schema.json`) and reviewed at every sprint retrospective and phase gate.

---

## Health Indicators and Definitions

### 1. Velocity

**Definition:** Story points completed and accepted (meeting DoD) in the sprint.

**Target range:** Stable within ±20% of the team's 3-sprint rolling average.

| Condition | Interpretation |
|-----------|---------------|
| Velocity within ±20% of rolling avg | Healthy — team is predictable |
| Velocity 20–30% below rolling avg | Watch — one sprint may be anomaly (sick days, holiday, incident) |
| Velocity > 30% below for 2+ sprints | Problem — investigate root cause |
| Velocity trending up steadily | Positive — team improving or understanding growing |
| Velocity trending down steadily | Concerning — investigate: tech debt, morale, complexity growth |

**Interpreting trends:**
- A sudden drop (1 sprint) is usually an event (illness, incident, sprint with heavy meetings).
- A sustained drop (2–3 sprints) indicates systemic issues: tech debt, unclear requirements, blocked dependencies, or morale.
- Velocity spikes without corresponding commitment ratio improvement may indicate scope estimation inflation.

**Schema field:** `sprint-health.velocity`, `sprint-health.planned_velocity`

---

### 2. Commitment Ratio

**Definition:** Proportion of sprint-committed story points that are completed by sprint end.

**Formula:** `velocity_actual / capacity_points` (committed scope at planning)

**Thresholds:**

| RAG | Value | Interpretation |
|-----|-------|---------------|
| Green | ≥ 0.8 (80%) | Healthy — team is delivering what it commits |
| Amber | 0.6–0.79 | Warning — consistent underdelivery needs investigation |
| Red | < 0.6 | Problem — sprint planning is unreliable or team is overloaded |

**What 0.8 means:** A ratio of 0.8 is the standard floor for a healthy team. Teams consistently below 0.8 are either over-committing at planning or encountering unplanned work.

**Common causes of low commitment ratio:**
- Over-optimistic estimation at planning
- Unplanned interruptions (bugs, incidents, ad-hoc requests)
- Blockers not surfaced early enough
- Acceptance criteria ambiguity causing rework
- Tech debt slowing development

**Action triggers:**
- Amber for 2 consecutive sprints → retrospective deep-dive on root cause
- Red for any sprint → immediate PM investigation; consider reducing commitment in next sprint

**Schema field:** `sprint-health.commitment_ratio`

---

### 3. Defect Count and Accumulation

**Definition:** Number of defects identified during the sprint (pre-production).

**Thresholds (per sprint, normalized to 40 capacity points):**

| RAG | Count | Interpretation |
|-----|-------|---------------|
| Green | ≤ 3 | Low defect rate — quality is good |
| Amber | 4–8 | Medium — monitor trend; check test coverage |
| Red | > 8 | High — quality issue; DoD may not be applied rigorously |

**Defect age:** Track how long defects remain open. Defects older than 2 sprints are "aged defects" and must be triaged.

**Severity distribution:** A few P3/P4 defects are normal. Any P1/P2 defects open at sprint end are red flag.

**Trends to watch:**
- Increasing defect count per sprint → test coverage degrading or codebase complexity growing
- Defects concentrated in specific modules → tech debt hotspot
- Defects primarily from regression → insufficient regression test automation

**Schema field:** `sprint-health.defect_count`

---

### 4. Blocked Items

**Definition:** Number of backlog items blocked (cannot progress due to external dependency, clarification needed, or technical blocker).

**Thresholds:**

| RAG | Count | Interpretation |
|-----|-------|---------------|
| Green | 0–1 | Normal — minor blockers quickly resolved |
| Amber | 2–3 | Watch — blockers may be impacting velocity |
| Red | ≥ 4 | Problem — team is unable to make progress; escalation needed |

**Resolution time SLA:**
- Blocker identified in daily standup: owner must provide update within 24 hours
- Blocker unresolved after 48 hours: PM escalates to dependency owner
- Blocker unresolved after 5 days: dependency log entry created; steering committee notified if critical path

**Escalation triggers:**
- More than 3 items blocked by the same external dependency → dependency log entry; dependency risk elevated to high
- Any blocked item on the sprint critical path → immediate PM action

**Schema field:** `sprint-health.blocked_items`

---

### 5. Scope Creep

**Definition:** Percentage of sprint scope added after sprint planning (additions that were not in the committed work set).

**Formula:** `(story_points_added_after_planning / capacity_points) * 100`

**Acceptable range:** ≤ 10% per sprint.

**Measurement method:**
1. Record committed scope at sprint start (total story points in committed work set).
2. At sprint end, total story points of items added to the sprint after planning started.
3. Calculate as percentage of original committed scope.

**Thresholds:**

| RAG | Value | Interpretation |
|-----|-------|---------------|
| Green | ≤ 10% | Healthy — minor additions within normal |
| Amber | 11–20% | Watch — sprint goal at risk; planning quality may be low |
| Red | > 20% | Problem — sprint scope not protected; commitment unreliable |

**Intervention threshold:** > 20% scope creep for 2+ sprints → PM introduces scope protection protocol with PO (no mid-sprint scope additions without removing equivalent scope).

**Schema field:** `sprint-health.scope_creep_pct`

---

### 6. Team Morale

**Definition:** RAG assessment of the team's morale and psychological safety, based on retrospective signals or formal survey.

| RAG | Signals |
|-----|---------|
| Green | Team engaged and energetic; retrospective is lively; no resignation signals; people willing to flag problems |
| Amber | Quieter retrospective; 1–2 team members expressing frustration; low participation in ceremonies |
| Red | Open disengagement; retrospective dysfunction (silence, conflict); resignation indicators; absenteeism |

**Survey frequency:** At minimum, a 1-question morale pulse at each sprint retrospective. Options:
- "How did you feel about this sprint?" (1–5 scale, anonymous)
- Niko-Niko calendar (daily emoji/mood tracking)
- More detailed survey quarterly (eNPS or similar)

**Correlation with velocity:** Teams with sustained Red morale for 2+ sprints typically show velocity decline within 3 sprints. Morale is a leading indicator.

**PM action on Amber:** 1:1 conversations with team members; retrospective with psychological safety focus; shield team from external interruptions.

**PM action on Red:** Escalation to people lead or HR. Removal of unnecessary ceremonies. Reduce sprint commitment. Investigate root cause (management, tech, product quality, personal).

**Schema field:** `sprint-health.team_morale`

---

### 7. AI Experiment Health

**Definition:** The proportion of AI/ML experiments in the sprint that met their stated hypothesis.

**Formula:** `experiments_meeting_hypothesis / total_experiments`

**Target:** ≥ 0.3 (30%) — AI experimentation is inherently uncertain; a 30% hypothesis-validation rate is healthy.

**Thresholds:**

| RAG | Value | Interpretation |
|-----|-------|---------------|
| Green | ≥ 0.3 | Healthy — team is generating valid hypotheses and learning |
| Amber | 0.15–0.29 | Watch — hypothesis quality may be low; review experiment design |
| Red | < 0.15 for 3+ sprints | Problem — methodology issue; revisit experiment design process |

**Experiment cycle time:** Time from hypothesis to result. Target: ≤ 1 sprint per experiment.

**Experiments with no result logged:** If an experiment runs for > 1 sprint with no evaluation result, it is overdue — flag in retrospective.

**Schema field:** `sprint-health.ai_experiment_success_rate`

---

## Sprint Health Report Cadence

### Daily (standups)

Track informally:
- Any new blockers?
- Is the team on track to meet sprint goal?
- Any scope additions requested?

No formal health record update required daily.

### At Sprint Review

Capture sprint health record (`sprint-health`) with:
- Velocity (actual vs planned)
- Commitment ratio
- Defect count (sprint total)
- Blocked items (count at sprint end)
- Scope creep percentage
- AI experiment success rate (if applicable)

### At Sprint Retrospective

Review health record with the team. Discuss:
- Which indicator is most concerning?
- What are the root causes?
- What action do we commit to for next sprint?
- Record retrospective actions in `retrospective` schema.

### At Gate Review

Aggregate sprint health records for the phase. Present:
- Velocity trend (chart: planned vs actual per sprint)
- Commitment ratio trend
- Defect accumulation and closure rate
- Team morale trend
- Any sprint with Red status on any indicator → document in gate review narrative

---

## Composite Sprint Health Status

An overall RAG for sprint health can be derived:

| Overall Status | Condition |
|---------------|-----------|
| Green | All indicators Green |
| Amber | 1–2 indicators Amber, none Red |
| Red | Any indicator Red OR 3+ indicators Amber |

The composite status is not stored in the schema — it is derived by the PM or Scrum Master from the individual fields. Record it in the gate review narrative or phase report.

---

## Common Failure Patterns

| Pattern | Indicators | Root Cause | Intervention |
|---------|-----------|-----------|-------------|
| Velocity cliff | Velocity drops >40% in 1 sprint | Team event (illness, incident) or major tech blocker | One-time; no intervention unless repeated |
| Commitment decay | Commitment ratio dropping sprint over sprint | Over-commitment; growing backlog complexity | Reduce sprint commitment; improve estimation process |
| Defect accumulation | Defect count increasing each sprint | Test automation insufficient; DoD not applied | Mandatory test coverage sprint; DoD enforcement |
| Blocker cluster | 4+ blockers in same sprint | Single external dependency failing | Dependency escalation; parallel workstream |
| Morale-velocity lag | Morale Red; velocity still OK | Team delivering despite low morale; not yet impacting output | Immediate people action before velocity drops |
| Scope inflation | Scope creep >20% every sprint | PO adding scope mid-sprint; unclear sprint goal | Scope protection protocol with PO |
