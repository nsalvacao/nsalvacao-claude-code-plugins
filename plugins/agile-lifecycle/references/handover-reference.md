# Handover Reference

## Overview

Phase handovers are formal transitions of responsibility from one lifecycle phase or subfase to the next. A handover is not automatic — it requires the receiving team or role to explicitly accept the artefacts and responsibilities being transferred.

This reference defines what constitutes a valid handover, what must be transferred, and how to handle conditional acceptance or rejection.

---

## What Constitutes a Valid Handover

A handover is valid when all of the following conditions are met:

1. **All mandatory artefacts are produced** at the minimum evidence threshold required by the receiving phase.
2. **The receiving team has been briefed** on the artefacts and their content.
3. **A Handover Log entry exists** (schema: `agile-lifecycle/handover-log`) with all required fields populated.
4. **The receiving party has accepted** — status in the log is `accepted` or `conditional`.
5. **Any conditions on a conditional acceptance are tracked** with owners and due dates.
6. **The gate for the outgoing phase has been passed** (or formally waived).

---

## Handover Log Entry Format

Each handover is captured in the Handover Log. See `schemas/handover-log.schema.json` for the full schema. Key fields:

| Field | Required | Description |
|-------|----------|-------------|
| `id` | Yes | Unique identifier (e.g. HO-001) |
| `from_phase` | Yes | Phase handing over |
| `to_phase` | Yes | Phase receiving |
| `handover_date` | Yes | Date handover was initiated |
| `handed_by` | Yes | Role or person handing over |
| `received_by` | Yes | Role or person accepting |
| `artefacts_handed` | Yes | List of artefact IDs/names transferred |
| `status` | Yes | pending / accepted / rejected / conditional |
| `conditions` | If conditional | List of conditions to be fulfilled |
| `sign_off_date` | When accepted | Date formal sign-off occurred |

---

## Phase-to-Phase Handover Checklists

### Phase 1 → Phase 2 Handover (Gate A)

**Handed by:** PM / Portfolio Manager
**Received by:** Product Owner + Engineering Lead

**Artefacts to hand:**
- Opportunity Statement (reviewed)
- Value Hypothesis (reviewed)
- Stakeholder Map (exists)
- Early Feasibility Note (reviewed)
- AI/Data Feasibility Note (reviewed)
- Initial Risk Note (exists)
- Portfolio Decision Record (signed by Governance Board)

**Checklist before accepting:**
- [ ] Portfolio Decision Record is signed and funding is confirmed.
- [ ] Opportunity Statement describes a clear, bounded problem.
- [ ] AI justification is substantiated in the AI/Data Feasibility Note.
- [ ] Stakeholder Map identifies sponsor, product owner, and key business stakeholders.
- [ ] Initial risks do not include any unresolvable blockers.

**Acceptance mechanism:** Product Owner and Engineering Lead joint sign-off on the handover log entry.

---

### Phase 2 → Phase 3 Handover (Gate B)

**Handed by:** PM + Product Owner
**Received by:** UX Lead + Delivery Lead

**Artefacts to hand:**
- Product Vision (reviewed)
- Product Goal Set (reviewed)
- Working Model (approved)
- Governance Model (approved)
- Role-Responsibility Map (reviewed)
- Initial Architecture Pack (reviewed)
- Initial ADR(s) (exists)
- Initial Roadmap (reviewed)
- Inception Closure Pack (reviewed)
- Updated Risk Register

**Checklist before accepting:**
- [ ] Product Vision is unambiguous and approved by the sponsor.
- [ ] Working Model is agreed by all team leads.
- [ ] Role-Responsibility Map names all roles with accountabilities.
- [ ] Initial Architecture Pack is sufficient to begin discovery without architectural assumptions.
- [ ] Roadmap shows at least 2 phases with milestone dates.
- [ ] Risk register has been updated since Phase 1.

**Acceptance mechanism:** Delivery Lead and UX Lead sign off jointly.

---

### Phase 3 → Phase 4 Handover (Gate C)

**Handed by:** Product Owner + Delivery Lead
**Received by:** Engineering Team + QA Lead + ML Lead (if applicable)

**Artefacts to hand:**
- Discovery Findings (reviewed)
- Acceptance Criteria Catalog (reviewed)
- AI Backlog Items (reviewed, if applicable)
- Data Readiness Notes (reviewed)
- Readiness Notes (approved)
- Backlog (ready items for ≥ 2 sprints)

**Checklist before accepting:**
- [ ] Backlog has at least 2 sprints of ready items with acceptance criteria.
- [ ] Development environment is provisioned and CI/CD is operational.
- [ ] Data access for Phase 4 work is confirmed.
- [ ] AI experiment hypotheses are documented for all AI backlog items.
- [ ] Team velocity baseline has been estimated.
- [ ] Definition of Done is agreed at story and sprint levels.

**Acceptance mechanism:** Engineering Lead and QA Lead sign off.

---

### Phase 4 → Phase 5 Handover (Gate D)

**Handed by:** Delivery Lead + QA Lead + Engineering Lead
**Received by:** Operations Lead + Release Manager

**Artefacts to hand:**
- Validation Evidence (aggregate, approved)
- Definition of Done (release level, approved)
- Security Assessment (approved)
- Performance Test Results (reviewed)
- Release Readiness Pack (reviewed)
- Red-team evidence (if LLM used, reviewed)
- Updated Risk Register (reviewed)

**Checklist before accepting:**
- [ ] All release acceptance criteria are verified.
- [ ] Security assessment is complete with no open critical findings.
- [ ] Performance targets met (or deviation formally accepted).
- [ ] Rollback plan exists and has been tested.
- [ ] Operations team has been briefed on the deployment plan.
- [ ] SRE / Ops runbook draft is available.

**Acceptance mechanism:** Operations Lead and Release Manager joint sign-off. Steering Committee notified.

---

### Phase 5 → Phase 6 Handover (Gate E)

**Handed by:** PM + Delivery Team
**Received by:** Operations Lead + Product Lead

**Artefacts to hand:**
- Deployment Record (approved)
- Rollout Log (reviewed)
- Operational Transition Pack (approved)
- Support Acceptance (approved)
- Hypercare Report (reviewed)
- SLO baseline data (exists)

**Checklist before accepting:**
- [ ] Support Acceptance is signed by the Ops Lead.
- [ ] All hypercare incidents are closed or have accepted mitigations.
- [ ] SLO monitoring is operational.
- [ ] Escalation paths are documented and tested.
- [ ] On-call rota is established.
- [ ] Delivery team knowledge transfer is complete.

**Acceptance mechanism:** Operations Lead formal sign-off on Operational Transition Pack and Handover Log.

---

### Phase 6 → Phase 7 Handover (Retirement Decision)

**Handed by:** Product Lead + Ops Lead
**Received by:** Retirement Program Lead (or PM)

**Artefacts to hand:**
- Retirement Decision Record (approved by Steering)
- Impact Assessment (reviewed)
- Current Risk Register
- Active dependency list

**Checklist before accepting:**
- [ ] Retirement Decision Record is signed by the Steering Committee.
- [ ] Impact Assessment covers all affected users, integrations, and data.
- [ ] No critical incidents open at handover date.
- [ ] Data retention and deletion plan is initiated.

**Acceptance mechanism:** Retirement Program Lead sign-off on handover log.

---

## Handover Failure Modes and Resolution

| Failure Mode | Cause | Resolution |
|-------------|-------|-----------|
| Rejection by receiving team | Mandatory artefacts missing or below threshold | Outgoing team completes artefacts; re-initiates handover |
| Conditional acceptance stalls | Conditions not fulfilled within agreed time | PM escalates; conditions become blocked items in next phase |
| Sign-off authority unavailable | Named approver absent | Delegate escalation path; document delegation in log |
| Receiving team disputes content | Artefact quality insufficient | Outgoing team revises; peer review before re-submission |
| Gate not yet passed | Handover attempted before gate | Block handover; complete gate process first |

---

## Conditional Acceptance

A conditional acceptance allows the receiving team to begin Phase N+1 work while conditions from the handover are outstanding. This is appropriate when:

- The missing artefact does not block Phase N+1 entry work.
- The condition has a clear owner, due date, and tracking mechanism.
- The receiving team explicitly accepts the residual risk.

**Conditions must be:**
1. Listed in the Handover Log `conditions` field.
2. Each condition must have an owner and due date.
3. Tracked as clarification log entries or dependency log entries.
4. Closed before the next gate review; open conditions are a gate fail criterion.

**Conditional acceptance does not remove the obligation** to produce the missing artefact — it defers the closure to a defined later date.
