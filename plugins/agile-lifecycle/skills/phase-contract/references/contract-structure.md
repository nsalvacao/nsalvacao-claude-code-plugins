# Phase Contract Structure

## Overview
A phase contract is the formal operational agreement that governs a lifecycle phase. It establishes accountability, defines measurable completion conditions, and ensures traceability between work done and evidence produced.

## Mandatory Fields

| Field | Type | Description |
|-------|------|-------------|
| `phase_id` | integer (1–7) | Lifecycle phase number |
| `phase_name` | string | Canonical phase name (e.g., "Opportunity and Portfolio Framing") |
| `status` | enum | Current phase state (see status enum below) |
| `owner` | string | Named role or person accountable for phase delivery |
| `start_date` | ISO date | Date phase formally opened (entry criteria confirmed met) |
| `target_end_date` | ISO date | Planned completion date |
| `entry_criteria` | list | Conditions that must be TRUE before phase work begins |
| `exit_criteria` | list | Conditions that must be TRUE before gate review can be triggered |
| `evidence_required` | list | Artefact IDs or evidence entries proving completion |
| `sign_off_authority` | string | Role responsible for approving phase completion |

## Optional Fields

| Field | Type | Description |
|-------|------|-------------|
| `actual_end_date` | ISO date | Date phase was formally closed |
| `assumptions` | list | Documented assumptions with owner and review date |
| `clarifications` | list | Open decisions with owner, due date, and resolution |
| `dependencies` | list | External dependencies with status |
| `risks` | list | Phase-specific risks (link to risk register entries) |
| `notes` | string | Freeform context or decisions not captured elsewhere |
| `waivers` | list | Formally waived criteria with justification and approver |

## Status Enum

| Status | Meaning |
|--------|---------|
| `not_started` | Phase contract drafted but phase not yet formally opened |
| `in_progress` | Phase actively being worked |
| `blocked` | Phase is halted due to unresolved blocker |
| `ready_for_review` | Phase work complete, under internal review |
| `ready_for_gate` | All exit criteria met; gate review triggered |
| `approved` | Gate passed; phase formally approved/closed |
| `closed` | Phase archived after approval |

## Entry/Exit Criteria Templates by Phase

### Phase 1 — Opportunity and Portfolio Framing
**Entry criteria:**
- Opportunity or problem statement drafted
- Sponsor identified and engaged
- Initial stakeholder map available

**Exit criteria:**
- Hypothesis canvas completed
- Feasibility note produced (technical, data, commercial)
- Portfolio decision record approved by sponsor
- Gate A pack assembled

### Phase 2 — Inception and Product Framing
**Entry criteria:**
- Gate A passed (portfolio decision record approved)
- Product team assembled (PM, tech lead, at least 1 engineer)
- Funding confirmed for inception phase

**Exit criteria:**
- Product vision and goals documented
- Ways of working agreed (governance model, ceremonies)
- Initial architecture decision recorded (ADR)
- Roadmap and release plan drafted
- Gate B pack assembled

### Phase 3 — Discovery and Backlog Readiness
**Entry criteria:**
- Gate B passed
- Product vision approved
- Team onboarded and working model active

**Exit criteria:**
- Discovery findings documented (user research, pain points)
- Acceptance criteria catalog produced
- Backlog readiness review completed (all P1 stories have AC)
- Data/AI readiness notes completed (if AI component)
- Gate C pack assembled

### Phase 4 — Iterative Delivery and Continuous Validation
**Entry criteria:**
- Gate C passed (backlog readiness review approved)
- Sprint 0 completed (environment, CI/CD, DoD agreed)
- At least 2 sprints of backlog ready

**Exit criteria:**
- All committed features built and validated
- Defect log below threshold (no open P1 defects)
- AI experiment log updated (if AI component)
- Model card produced (if ML model trained)
- Gate D pack assembled

### Phase 5 — Release, Rollout and Transition
**Entry criteria:**
- Gate D passed (build quality approved)
- Release candidate identified
- Ops team engaged for transition planning

**Exit criteria:**
- Functional test report produced
- AI validation report produced (if AI component; red-team evidence for LLMs)
- UAT report signed off
- Rollback plan documented and tested
- Gate E pack assembled

### Phase 6 — Operate, Measure and Improve
**Entry criteria:**
- Gate E passed (release readiness approved)
- Operations handover completed
- Monitoring and alerting live

**Exit criteria:**
- Service report cadence established
- AI monitoring report active (if AI component)
- Improvement backlog seeded from retrospective
- Gate F pack assembled

### Phase 7 — Retire or Replace
**Entry criteria:**
- Retirement decision approved by product owner and sponsor
- Replacement product/service identified (if applicable)
- Sunset plan drafted

**Exit criteria:**
- All data migrated or archived
- Decommissioning record produced
- Final closure pack assembled and approved

## Validation Rules

1. `start_date` must be on or after the date entry criteria were confirmed met
2. `target_end_date` must be after `start_date`
3. `actual_end_date` (when present) must be on or after `start_date`
4. All items in `entry_criteria` must have a status (met/not met/partial)
5. All items in `exit_criteria` must have a status (met/waived/not started/in progress)
6. A criterion marked as `waived` must have a corresponding waiver entry
7. `sign_off_authority` must not be "TBD" when phase reaches `ready_for_gate`
8. `evidence_required` items must all be present in the evidence index before gate review

## Sign-off Authority Guidance

Sign-off authority is assigned by convention, not rigid enforcement. Use this as guidance:

| Phase | Typical Sign-off Authority |
|-------|--------------------------|
| Phase 1 | Sponsor or Portfolio Owner |
| Phase 2 | Product Owner + Architecture Lead |
| Phase 3 | Product Owner |
| Phase 4 | Product Owner + QA Lead |
| Phase 5 | Release Manager + Product Owner |
| Phase 6 | Operations Lead + Product Owner |
| Phase 7 | Sponsor + Product Owner |

## Examples

### Complete Contract (Phase 1)
```yaml
phase_id: 1
phase_name: "Opportunity and Portfolio Framing"
status: approved
owner: "Jane Smith (Product Manager)"
start_date: "2026-01-10"
target_end_date: "2026-02-07"
actual_end_date: "2026-02-05"
entry_criteria:
  - description: "Opportunity statement drafted"
    status: met
  - description: "Sponsor identified and available"
    status: met
exit_criteria:
  - description: "Hypothesis canvas completed"
    status: met
    evidence: "artefacts/phase-1/hypothesis-canvas-v1.md"
  - description: "Feasibility note produced"
    status: met
    evidence: "artefacts/phase-1/early-feasibility-note.md"
  - description: "Portfolio decision record approved"
    status: met
    evidence: "artefacts/phase-1/portfolio-decision-record.md"
sign_off_authority: "Carlos Mendes (Portfolio Owner)"
```

### Incomplete Contract (Phase 2 — blocked)
```yaml
phase_id: 2
phase_name: "Inception and Product Framing"
status: blocked
owner: "Jane Smith"
start_date: "2026-02-10"
target_end_date: "2026-03-15"
entry_criteria:
  - description: "Gate A passed"
    status: met
  - description: "Engineering team assembled (min 2 engineers)"
    status: not_met
    blocker: "Backend engineer allocation pending. Owner: Eng Manager. Due: 2026-02-17"
exit_criteria:
  - description: "Product vision documented"
    status: not_started
sign_off_authority: "TBD — to assign once team assembled"
```
