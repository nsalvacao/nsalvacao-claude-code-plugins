# Lifecycle Overview

The `agile-lifecycle` framework is a **hybrid gated-iterative** lifecycle for AI/ML and digital products. It is not pure Scrum, not SAFe. It combines the governance rigour of gated lifecycles with the flexibility of iterative delivery.

## Framework Positioning

| Dimension | This Framework |
|-----------|---------------|
| Delivery | Iterative sprints (2-4 weeks) |
| Governance | Formal gates at phase boundaries |
| Artefacts | Structured, schema-validated |
| AI/ML | Full GenAI overlay |
| Tailoring | Per product type and risk level |

## Seven Phases

| Phase | Name | Objective | Key Output | Gate |
|-------|------|-----------|-----------|------|
| 1 | Discovery & Framing | Validate opportunity and hypotheses | Hypothesis Canvas | Gate A |
| 2 | Architecture & Planning | Design solution and plan iterations | Iteration Plan | Gate B |
| 3 | Iteration Design | Plan each sprint | Sprint Backlog | Gate C |
| 4 | Build & Integrate | Implement and integrate | Defect Log | Gate D |
| 5 | Validate & Gate | Validate and prepare for release | Gate E Pack | Gate E |
| 6 | Release | Deploy and stabilise | Hypercare Report | Gate F |
| 7 | Operate & Improve | Run, monitor, improve | Service Reports | — |

## Six Gates

| Gate | Name | Timing | Key Decision |
|------|------|--------|-------------|
| A | Opportunity Approval | After Phase 1 | Fund and proceed to inception? |
| B | Architecture Approval | After Phase 2 | Start iterative delivery? |
| C | Sprint Readiness | Before each sprint | Is backlog ready to execute? |
| D | Build Quality | After Phase 4 | Quality sufficient for validation? |
| E | Release Readiness | After Phase 5 | Safe to deploy to production? |
| F | Operations Closure | After hypercare | Ops team ready? Lifecycle decision? |

## Lifecycle State Machine

| Current State | Event | New State | Evidence Required | Who Triggers |
|--------------|-------|-----------|------------------|-------------|
| not_started | Phase start | in_progress | Phase contract created | PM |
| in_progress | Blocker raised | blocked | Clarification logged | Any team member |
| blocked | Blocker resolved | in_progress | Clarification resolved | PM |
| in_progress | Subfase complete | ready_for_review | All exit criteria met | Delivery Lead |
| ready_for_review | Gate review scheduled | ready_for_gate | Gate pack prepared | PM |
| ready_for_gate | Gate PASS | approved | Gate review report | Gate Reviewer |
| ready_for_gate | Gate FAIL | rejected | Gate review report | Gate Reviewer |
| ready_for_gate | Waiver granted | waived | Waiver log approved | Authority |
| approved | Phase formally closed | closed | Closure record | PM |

## Entry and Exit Criteria Summary

| Phase | Entry Criteria | Exit Criteria |
|-------|---------------|--------------|
| 1 | Business need identified | Gate A: Hypothesis Canvas approved |
| 2 | Gate A passed | Gate B: Iteration Plan + Architecture approved |
| 3 | Gate B passed (or previous sprint done) | Gate C: Sprint backlog committed |
| 4 | Gate C passed | Gate D: All criticals resolved, DoD met |
| 5 | Gate D passed | Gate E: All validation complete, UAT accepted |
| 6 | Gate E passed | Gate F: Hypercare complete, ops handover accepted |
| 7 | Gate F passed | Next iteration or retirement decision |

## Transversal Agents

These agents operate across all phases:
- **lifecycle-orchestrator** — navigation and state management
- **gate-reviewer** — executes any gate (A-F)
- **artefact-generator** — generates artefacts from templates
- **risk-assumption-tracker** — manages all risk registers
- **metrics-analyst** — compiles and reports metrics
