# Phase 4 — Iterative Delivery and Continuous Validation Essentials

## What to Do
- Run time-boxed sprints: plan iteration goals and committed work sets, then build and integrate
- Execute AI/ML delivery loop: design experiments, train models, evaluate results, log findings
- Validate continuously: test against DoD and acceptance criteria each sprint; collect validation evidence
- Review and adapt each sprint cycle; refine backlog and update retrospective records
- Assemble release-level evidence (security, performance, rollback plan) before Gate D

## Who
| Role | Responsibility |
|------|----------------|
| PO + Team | Iteration Goal, Committed Work Set |
| Delivery Lead | Iteration Plan, sprint health tracking |
| Development Team | Feature implementation, code review, CI/CD |
| ML Lead | Experiment Log, Evaluation Results |
| QA Lead | Validation Evidence, Definition of Done (release level) |
| PM | Review Outcomes, Sprint Health Records |

## Evidence Required for Gate D
| Artefact | Template | Evidence Level |
|----------|----------|----------------|
| Validation Evidence (aggregate) | `templates/phase-4/validation-evidence.md.template` | Mandatory (approved) |
| Definition of Done (release level) | — | Mandatory (approved) |
| Sprint Health Records | — | Mandatory (reviewed) |
| Risk Register (current) | `templates/transversal/risk-register-entry.md.template` | Mandatory (reviewed) |
| Security Assessment | — | Mandatory (approved) |
| Performance Test Results | — | Mandatory (reviewed) |
| Release Readiness Pack (draft) | `templates/phase-5/release-readiness-pack.md.template` | Mandatory (reviewed) |
| Experiment Log | `templates/phase-4/experiment-log.md.template` | Conditional (if AI/ML in scope) |
| Red-team Evidence (if LLM) | — | Conditional (reviewed; cannot be waived for public LLMs) |

## Key Skills
- `sprint-facilitation` — use for sprint planning, daily standup, sprint review, and retrospective
- `definition-of-done` — use when verifying story-level and sprint-level DoD each iteration
- `ai-lifecycle` — use when running the AI delivery loop (subfases 4.3) and evaluating models
- `metrics-tracking` — use when recording sprint metrics and tracking threshold breaches
- `risk-management` — use to update risks and clarifications throughout the delivery sprints
- `gate-checklist` — use when preparing the Gate D evidence package at release readiness

## Entry Criteria
- Gate C passed; backlog ready; team and environment set up

## Exit Criteria
- Release criteria met across all sprints; Gate D passed; product authorized for release process
