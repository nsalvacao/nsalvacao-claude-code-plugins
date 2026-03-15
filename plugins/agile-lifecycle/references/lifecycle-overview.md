# Lifecycle Overview — Agile-Lifecycle Framework

## Framework Positioning

The `agile-lifecycle` framework is a **hybrid/gated-iterative** enterprise lifecycle for AI/ML and software products. It is not pure Scrum (no formal gates, no phase contracts) and not SAFe (not a scaled framework). Its core design principle is:

> Iterative delivery within governed phases, with mandatory gate reviews at phase boundaries.

Sprints and iterations run inside phases. Gates are not sprint ceremonies — they are formal governance checkpoints that authorize progression to the next phase. This distinction is fundamental: a team can be "agile" inside Phase 4 while still being subject to Gate D before entering Phase 5.

---

## Framework Summary

| Phase | Name | Subfases | Closing Gate |
|-------|------|----------|--------------|
| 1 | Opportunity and Portfolio Framing | 1.1, 1.2, 1.3 | A |
| 2 | Inception and Product Framing | 2.1, 2.2, 2.3, 2.4 | B |
| 3 | Discovery and Backlog Readiness | 3.1, 3.2, 3.3, 3.4 | C |
| 4 | Iterative Delivery and Continuous Validation | 4.1, 4.2, 4.3, 4.4, 4.5 | D |
| 5 | Release, Rollout and Transition | 5.1, 5.2, 5.3, 5.4 | E |
| 6 | Operations, Measurement and Improvement | 6.1, 6.2, 6.3, 6.4 | F |
| 7 | Retire or Replace | 7.1, 7.2 | (lifecycle close) |

---

## Phase Descriptions

### Phase 1 — Opportunity and Portfolio Framing

**Purpose:** Determine whether the opportunity is worth pursuing, whether AI is justified, and whether the project should enter the portfolio.

**Subfases:**
- **1.1 Problem Framing** — Define the opportunity, pain point, or market gap. Produce an Opportunity Statement.
- **1.2 Early Feasibility** — Assess technical, data, and AI feasibility at high level. Identify blockers early.
- **1.3 Portfolio Decision** — Present to governance for funding and portfolio entry decision.

**Key outputs:** Opportunity Statement, Value Hypothesis, Stakeholder Map, Early Feasibility Note, AI/Data Feasibility Note, Funding Recommendation, Portfolio Decision Record.

**Entry criteria:** A problem or opportunity has been identified by a business sponsor or product owner.
**Exit criteria:** Portfolio Decision Record signed off; Gate A passed; project formally funded and in portfolio.

---

### Phase 2 — Inception and Product Framing

**Purpose:** Define the product vision, ways of working, initial architecture direction, and roadmap baseline before discovery.

**Subfases:**
- **2.1 Product Vision** — Establish product vision, goals, and success metrics.
- **2.2 Ways of Working** — Agree governance model, team structure, working agreements, and decision rights.
- **2.3 Initial Architecture** — Establish architectural principles and initial ADRs.
- **2.4 Roadmap and Release Planning** — Produce initial roadmap and release plan aligned to business goals.

**Key outputs:** Product Vision, Product Goal Set, Working Model, Governance Model, Role-Responsibility Map, Initial Architecture Pack, Initial ADR(s), Initial Roadmap, Inception Closure Pack.

**Entry criteria:** Gate A passed; project funded; team assembled.
**Exit criteria:** Inception Closure Pack signed off; Gate B passed.

---

### Phase 3 — Discovery and Backlog Readiness

**Purpose:** Discover user needs, shape requirements into a ready backlog, and establish data and AI control points before delivery begins.

**Subfases:**
- **3.1 Problem Discovery** — User research, pain point mapping, user journey analysis.
- **3.2 Requirements Shaping** — Acceptance criteria catalog, backlog structure, prioritization.
- **3.3 Data and AI Control** — Data readiness assessment, AI model selection, experiment baseline.
- **3.4 Ready for Delivery** — Backlog Readiness Review; team and environment ready.

**Key outputs:** Discovery Findings, Pain Point Map, User Journey Map, Acceptance Criteria Catalog, AI Backlog Items, Data Readiness Notes, Readiness Notes.

**Entry criteria:** Gate B passed; product vision and working model in place.
**Exit criteria:** Backlog Readiness Review passed (Review C); Gate C passed; team can begin delivery.

---

### Phase 4 — Iterative Delivery and Continuous Validation

**Purpose:** Build, integrate, and continuously validate the product through time-boxed sprints, with AI delivery loops and adaptation cycles.

**Subfases:**
- **4.1 Iteration Planning** — Sprint planning, goal setting, committed work set.
- **4.2 Build and Integration** — Development, integration, CI/CD, code review.
- **4.3 AI Delivery Loop** — AI/ML model development, experiment execution, evaluation.
- **4.4 Continuous Validation** — Testing, DoD verification, validation evidence.
- **4.5 Review and Adaptation** — Sprint review, retrospective, backlog refinement.

**Key outputs:** Iteration Goals, Committed Work Sets, Experiment Logs, Evaluation Results, Validation Evidence, Review Outcomes, Sprint Health Records, Retrospectives.

**Entry criteria:** Gate C passed; backlog ready; team set up.
**Exit criteria:** Release criteria met; Gate D passed; product ready for release process.

---

### Phase 5 — Release, Rollout and Transition

**Purpose:** Formally release the product, execute rollout, complete operational transition, and manage hypercare.

**Subfases:**
- **5.1 Release Readiness** — Final validation gate, release readiness pack, go/no-go decision.
- **5.2 Deployment and Rollout** — Deployment execution, rollout strategy (canary, blue/green, phased).
- **5.3 Operational Transition** — Handover to operations, support acceptance, runbook completion.
- **5.4 Hypercare** — Intensive post-release monitoring, rapid response to incidents.

**Key outputs:** Release Readiness Pack, Deployment Record, Rollout Log, Operational Transition Pack, Support Acceptance, Hypercare Report.

**Entry criteria:** Gate D passed; deployment environments ready; ops team briefed.
**Exit criteria:** Hypercare period closed; Gate E passed; product in steady-state operations.

---

### Phase 6 — Operations, Measurement and Improvement

**Purpose:** Operate the product, measure outcomes against goals, monitor AI/ML model health, and drive continuous improvement.

**Subfases:**
- **6.1 Service Operations** — Incident management, SLO monitoring, operational reporting.
- **6.2 Product Analytics** — Adoption, feature utilization, NPS/CSAT measurement.
- **6.3 AI/ML Ops and Monitoring** — Model performance, drift detection, retraining triggers.
- **6.4 Continuous Improvement** — Improvement backlog, change recommendations, tech debt tracking.

**Key outputs:** Service Reports, Product Analytics Reports, AI Monitoring Reports, Improvement Backlog, Change Recommendations.

**Entry criteria:** Gate E passed; product live; operational baseline established.
**Exit criteria:** Gate F passed (periodic governance review); or retirement decision made.

---

### Phase 7 — Retire or Replace

**Purpose:** Formally retire or replace the product, completing all closure obligations, data archival, and decommissioning.

**Subfases:**
- **7.1 Retirement Decision** — Evaluate retirement triggers, alternatives, impact, and produce decision record.
- **7.2 Decommissioning** — Sunset plan execution, data migration/deletion, final closure pack.

**Key outputs:** Retirement Decision Record, Impact Assessment, Sunset Plan, Decommissioning Record, Final Closure Pack.

**Entry criteria:** Retirement trigger confirmed; Gate F passed or waived; decision made to retire.
**Exit criteria:** All closure obligations met; Final Closure Pack signed off; lifecycle closed.

---

## Gate Summary

| Gate | Name | Timing | Key Question |
|------|------|--------|--------------|
| A | Portfolio Entry | End of Phase 1 | Is this worth funding and pursuing? |
| B | Inception Closure | End of Phase 2 | Are we ready to discover and build? |
| C | Backlog Readiness | End of Phase 3 | Is the team ready to deliver? |
| D | Release Authorization | End of Phase 4 | Is the product safe to release? |
| E | Operations Handover | End of Phase 5 | Is the product stable in production? |
| F | Governance Review | Periodic in Phase 6 | Should we continue, pivot, or retire? |

---

## Entry and Exit Criteria Summary

| Phase | Entry Must Have | Exit Must Have |
|-------|----------------|----------------|
| 1 | Opportunity identified, sponsor available | Portfolio Decision Record, Gate A passed |
| 2 | Gate A passed, team assembled | Inception Closure Pack, Gate B passed |
| 3 | Gate B passed, product vision approved | Backlog Readiness Review, Gate C passed |
| 4 | Gate C passed, backlog ready | Release criteria met, Gate D passed |
| 5 | Gate D passed, environments ready | Hypercare closed, Gate E passed |
| 6 | Gate E passed, product live | Gate F passed or retirement decision |
| 7 | Retirement decision made | Final Closure Pack, lifecycle closed |

---

## State Machine — Lifecycle State Transitions

The lifecycle state machine governs valid transitions for phases and subfases.

### Phase-Level State Transitions

| Current State | Event | Next State | Evidence Required | Who Triggers |
|---------------|-------|------------|------------------|--------------|
| `not_started` | Phase Start approved | `in_progress` | Entry criteria verified | Lifecycle Orchestrator / PM |
| `in_progress` | Blocker encountered | `blocked` | Dependency or risk log entry | Team / PM |
| `blocked` | Blocker resolved | `in_progress` | Dependency log closed | Owner / PM |
| `in_progress` | All subfases complete | `ready_for_gate` | Exit criteria met, artefacts complete | PM |
| `ready_for_gate` | Gate review initiated | `ready_for_review` | Gate review scheduled | Gate Reviewer |
| `ready_for_review` | Gate passes | `approved` | Gate Review Record (outcome: pass) | Gate Reviewer |
| `ready_for_review` | Gate fails | `rejected` | Gate Review Record (outcome: fail) | Gate Reviewer |
| `ready_for_review` | Gate waived | `waived` | Waiver Log entry, Gate Review Record | Gate Reviewer + Authority |
| `approved` | Lifecycle closes | `closed` | Final Closure Pack or next phase started | PM / Steering |
| `rejected` | Issues remediated | `in_progress` | Remediation evidence | PM |
| `waived` | Conditions fulfilled | `closed` | Waiver conditions marked complete | Gate Reviewer |

### Subfase-Level State Transitions

| Current State | Event | Next State | Evidence Required | Who Triggers |
|---------------|-------|------------|------------------|--------------|
| `not_started` | Subfase started | `in_progress` | Phase Contract entry_criteria verified | Subfase Agent / PM |
| `in_progress` | Work blocked | `blocked` | Clarification or dependency log entry | Team |
| `blocked` | Unblocked | `in_progress` | Resolution documented | Owner |
| `in_progress` | Exit criteria met | `ready_for_review` | All artefacts produced, exit criteria checked | PM / Owner |
| `ready_for_review` | Review passed | `closed` | Sign-off from sign_off_authority | Sign-off Authority |
| `ready_for_review` | Review rejected | `in_progress` | Rejection documented, remediation planned | Reviewer |
| `closed` | — | — | No further transitions | — |

---

## Framework Components Map

| Component Type | Count | Purpose |
|---------------|-------|---------|
| Agents | 31 | AI agents per subfase + transversal orchestrators |
| Commands | 11 | Slash commands for lifecycle operations |
| Skills | 13 | Reusable capability modules |
| Schemas | 17 | JSON Schema validation for lifecycle artefacts |
| Templates | ~58 | Structured templates with placeholders |
| References | 8 | Comprehensive reference documentation |
| Scripts | 14 | Automation and validation utilities |
| Hooks | 1 (+ scripts) | Pre-tool validation hooks |

---

## Related References

- `references/gate-criteria-reference.md` — detailed gate criteria, pass/fail rules, waivers
- `references/artefact-catalog.md` — full artefact catalog with closure obligations
- `references/tailoring-guide.md` — product type tailoring profiles
- `references/genai-overlay.md` — GenAI/LLM-specific activities by phase
- `schemas/lifecycle-state.schema.json` — machine-readable lifecycle state schema
