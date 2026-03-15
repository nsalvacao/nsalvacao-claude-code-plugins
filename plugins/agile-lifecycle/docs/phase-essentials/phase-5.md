# Phase 5 — Release, Rollout and Transition Essentials

## What to Do
- Conduct final release readiness assessment and produce the Release Readiness Pack
- Execute deployment using the chosen rollout strategy (canary, blue/green, or phased)
- Complete operational transition: handover runbook, escalation paths, support acceptance
- Manage hypercare period: intensive monitoring and rapid incident response
- Close hypercare and prepare Gate E evidence pack

## Who
| Role | Responsibility |
|------|----------------|
| PM + PO | Release Readiness Pack (sign-off), go/no-go decision |
| Engineering Lead | Deployment Record, Rollout Log |
| Ops Lead + PM | Operational Transition Pack |
| Ops Lead | Support Acceptance (formal sign-off) |
| PM + Ops Lead | Hypercare Report |

## Evidence Required for Gate E
| Artefact | Template | Evidence Level |
|----------|----------|----------------|
| Deployment Record | `templates/phase-6/deployment-record.md.template` | Mandatory (approved) |
| Release Plan | `templates/phase-6/release-plan.md.template` | Mandatory (reviewed) |
| Operations Handover | `templates/phase-6/operations-handover.md.template` | Mandatory (approved) |
| UAT Report | `templates/phase-5/uat-report.md.template` | Mandatory (approved; cannot be waived) |
| Hypercare Report | `templates/phase-6/hypercare-report.md.template` | Mandatory (reviewed) |
| SLO Baseline Data | — | Mandatory (exists) |

## Key Skills
- `operational-readiness` — use when assessing readiness before deployment and planning ops transition
- `gate-checklist` — use when conducting the Gate E review and validating evidence thresholds
- `metrics-tracking` — use when establishing SLO baseline and monitoring during hypercare
- `risk-management` — use to track and close hypercare incidents and residual risks

## Entry Criteria
- Gate D passed; deployment environments ready; ops team briefed

## Exit Criteria
- Hypercare period closed with no unresolved critical incidents; Gate E passed; product in steady-state operations
