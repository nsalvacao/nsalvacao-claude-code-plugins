---
name: operational-readiness
description: This skill should be used when preparing for production deployment, assessing operational readiness, or planning the ops transition. Triggers before Gate E (release readiness) or when transitioning to Phase 6.
---

# Operational Readiness

## Purpose
Operational readiness ensures the product, the team, and the infrastructure are ready for production before deployment. A product that meets all functional requirements but launches into an unprepared operations environment will fail. This skill covers technical readiness, process readiness, documentation readiness, and stakeholder readiness — the four pillars that must all be in place before Gate E.

## When to Use
- Gate E (release readiness) is approaching and the ops readiness assessment needs to be done
- The operations team needs to be engaged for transition planning
- Monitoring, alerting, and runbooks need to be created or validated
- Rollback procedures need to be planned and tested
- Support model and escalation paths need to be defined
- SLO definitions need to be agreed between product and operations teams

## Instructions

### Step 1: Engage the Operations Team Early
Operations readiness cannot be completed in the week before deployment. Engage the operations team from Phase 5 (or earlier for complex products):
- Introduce the product, its architecture, and its dependencies
- Walk through the deployment plan and rollback procedure
- Identify ops-specific requirements (monitoring, alerting, runbooks)
- Agree on the support model for hypercare period

### Step 2: Assess Technical Readiness
Work through the technical readiness checklist in `references/readiness-checklist.md`:
- Infrastructure provisioned and tested in production-equivalent environment
- Monitoring configured: metrics collection, dashboards active
- Alerts set and tested: alert thresholds calibrated, notification channels tested
- Runbooks created for all common operational scenarios
- Deployment procedure documented and tested in staging
- Data migration completed and verified (if applicable)
- Performance baseline established (load test results documented)

### Step 3: Assess Process Readiness
- Support team trained on the product
- Escalation paths defined: who to call for what type of incident
- Incident response plan documented and reviewed
- On-call schedule defined for hypercare period
- Communication plan for outages prepared

### Step 4: Assess Documentation Readiness
- User documentation complete and reviewed
- API documentation complete (if external API)
- Runbooks complete for all P1 and P2 incident scenarios
- Architecture documentation updated to reflect production deployment

### Step 5: Assess AI/ML Readiness (if AI component)
- Model monitoring configured: drift detection, accuracy tracking, latency monitoring
- Drift alerts set and tested
- Retraining pipeline documented and tested in staging
- Model card finalized with production deployment details added
- AI-specific runbooks created (model degradation, drift alert, emergency rollback)

### Step 6: Assess Go-live Readiness
Final pre-deployment checks:
- Rollback plan tested: confirm rollback procedure can be executed within defined RTO
- Data migration tested: data integrity verified after migration rehearsal
- Performance tested: load test results show system handles expected traffic
- Security scan completed: no critical or high vulnerabilities open
- Sign-offs obtained: all required approvers have signed the release plan

### Step 7: Produce Operations Handover Document
Document the operational handover in `templates/phase-5/operational-transition-pack.md.template`:
- System overview for ops team
- Architecture diagram with infrastructure components
- Monitoring dashboard links
- Alert definitions and response guidance
- Runbook index
- Escalation contacts
- SLO definitions and alert thresholds
- Known limitations and workarounds

### Step 8: Define SLOs
Before Gate E, SLOs must be agreed and documented:
- **Availability SLO**: e.g., 99.5% uptime per month
- **Latency SLO**: e.g., p99 ≤ 500ms for API calls
- **Error rate SLO**: e.g., < 1% 5xx errors per hour
- **AI-specific SLOs** (if AI): e.g., model inference p99 ≤ 200ms, accuracy ≥ 0.85
- SLO breach thresholds: define when SLO breach triggers incident

## Key Principles
1. **Operations readiness starts in Phase 2** — architecture decisions must consider operational requirements from the beginning.
2. **Runbooks are tested, not written** — a runbook that has not been rehearsed is a documentation artefact, not an operational tool.
3. **Rollback plans must be tested** — testing in staging before production deployment is mandatory; a rollback untested is a rollback unavailable.
4. **SLOs are agreements, not aspirations** — they must be achievable and must have consequences when breached.
5. **Hypercare is planned, not improvised** — the hypercare plan (who is on-call, for how long, what triggers escalation) must be agreed before go-live.

## Reference Materials
- `references/readiness-checklist.md` — Detailed readiness checklists for all readiness dimensions
- `templates/phase-5/operational-transition-pack.md.template` — Operations handover template
- Schema: `schemas/release-readiness.schema.json`

## Quality Checks
- Technical readiness checklist fully completed (no gaps)
- All runbooks reviewed and tested by operations team
- Rollback plan tested in staging environment
- SLOs defined, agreed, and configured in monitoring system
- Operations team confirmed self-sufficient (sign-off obtained)
- AI monitoring live and tested alerts working (if AI component)
- Operations handover document produced and approved
