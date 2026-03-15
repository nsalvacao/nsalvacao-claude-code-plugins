# Gate Guide

## What Are Gates?

Gates are formal review checkpoints between lifecycle phases. Each gate has defined criteria that must be met (PASS) or formally waived (WAIVED) before proceeding. A FAIL means the project cannot proceed until gaps are addressed.

## Gate Operating Model

- **Who reviews:** An independent gate reviewer (not the delivery team)
- **How decisions are made:** Evidence-based — all criteria must map to specific artefacts at defined evidence levels (exists / reviewed / approved)
- **Timing:** Scheduled when all phase validation activities are complete
- **Outcomes:** PASS | FAIL | WAIVED | DEFERRED

## Gates Summary

| Gate | After Phase | Blocking? | Key Decision |
|------|------------|-----------|-------------|
| A | Phase 1 | Yes | Fund the opportunity and proceed to architecture? |
| B | Phase 2 | Yes | Start iterative delivery with this architecture? |
| C | Phase 3 | Per sprint | Is this sprint ready to execute? |
| D | Phase 4 | Yes | Quality sufficient to proceed to validation? |
| E | Phase 5 | Yes | Safe to deploy to production? |
| F | Phase 6 | Yes | Ops ready? What's the lifecycle next step? |

## Gate A — Opportunity Approval

**Timing:** After Phase 1 (Hypothesis Canvas complete)

**Key Criteria:**
- Opportunity Brief approved
- Feasibility screened (technical + commercial)
- Problem validated with evidence
- Hypothesis Canvas complete with experiment proposals
- Initial stakeholder map and risk register

## Gate B — Architecture Approval

**Timing:** After Phase 2 (Iteration Plan complete)

**Key Criteria:**
- Solution architecture documented with ADRs
- Iteration plan reviewed and approved
- Risk register comprehensive with mitigations
- Assumption register with owners and due dates
- Team capacity confirmed

## Gate C — Sprint Readiness

**Timing:** Before each sprint (repeated each cycle)

**Key Criteria:**
- Sprint backlog committed with acceptance criteria
- Test plan defined
- DoD agreed for the sprint
- Team capacity confirmed

## Gate D — Build Quality

**Timing:** After Phase 4 (QA complete)

**Key Criteria:**
- All critical and major defects resolved
- Test coverage meets DoD threshold
- Integration tests pass
- AI model evaluation complete (if AI project)
- Red-team evidence (if LLM project)

## Gate E — Release Readiness

**Timing:** After Phase 5 (all validation complete)

**Key Criteria:**
- Functional Test Report: PASS
- AI Validation Report: PASS (if AI project)
- UAT: ACCEPTED by Product Owner
- Residual risks accepted
- Release Plan approved
- Deployment environment ready

## Gate F — Operations & Hypercare Completion

**Timing:** After hypercare period

**Key Criteria:**
- Hypercare exit criteria met (stability window, no P1 incidents)
- Operations team trained
- Runbooks in place and tested
- Operations Handover formally accepted
- Lifecycle decision made (next iteration / sustain / retire)

## Waiver Process

When a criterion cannot be met:
1. Document the criterion and why it cannot be met
2. Assess residual risk
3. Define compensating controls and monitoring plan
4. Obtain approval from designated authority
5. Record in Waiver Log using `templates/transversal/waiver-entry.md.template`

See `references/gate-criteria-reference.md` for complete criteria and waiver policy.

## Gate Failure Recovery

If gate FAILS:
1. Document all failed criteria with gap description
2. Create action plan with owners and due dates
3. Address gaps
4. Schedule re-gate review
5. Do NOT proceed to next phase until gate passes or criteria are waived
