# Operational Readiness Checklist

Reference checklist for assessing readiness to transition from Phase 6 (Release and Hypercare) to Phase 7 (Operations). Use this checklist to validate that the product, team, and processes are ready for steady-state operations.

---

## Pre-Launch Readiness

Validate before go-live (Gate F entry):

### Infrastructure and Deployment
- [ ] All production infrastructure provisioned and tested
- [ ] Deployment runbook validated in staging environment
- [ ] Rollback procedure tested and confirmed executable within 15 minutes
- [ ] Infrastructure-as-code committed and version-controlled
- [ ] Secrets and credentials rotated for production environment

### Monitoring and Alerting
- [ ] All SLO metrics instrumented and verified against production data
- [ ] Alert thresholds calibrated (no alert fatigue — ≤5 non-critical alerts/day baseline)
- [ ] Runbooks written for all P1 and P2 alert types
- [ ] Dashboards accessible to on-call team
- [ ] On-call rotation schedule confirmed with escalation contacts listed

### AI/ML Model
- [ ] Model version registered in model registry with full metadata
- [ ] Model serving performance meets latency SLO under expected load
- [ ] Drift monitoring configured with baseline established from holdout data
- [ ] A/B testing framework in place for future model version changes
- [ ] Model card reviewed and approved by Product Manager

---

## Operational Readiness

Validate before exiting Hypercare (Gate G entry):

### Support and Incident Response
- [ ] Support team trained on product functionality and AI system behaviour
- [ ] Incident classification guide distributed to on-call team (P1/P2/P3 definitions)
- [ ] Incident response playbooks validated in at least one drill
- [ ] Escalation path documented and confirmed with all stakeholders
- [ ] SLA commitments communicated to users and tracked in monitoring

### Data and Compliance
- [ ] Data retention policy documented and signed off by Legal
- [ ] PII data handling procedures confirmed compliant with applicable regulations
- [ ] Access control audit completed — principle of least privilege applied
- [ ] Audit logging enabled for all regulated data access
- [ ] GDPR/CCPA subject access request procedure documented (if applicable)

### Team Readiness
- [ ] Operations team owns and understands all monitoring runbooks
- [ ] On-call schedule for first 90 days confirmed and communicated
- [ ] Knowledge base populated with Phase 6 incident learnings
- [ ] Hypercare exit criteria confirmed met and documented
- [ ] Transition date agreed between delivery team and operations team

---

## Handover Readiness

Validate before formal lifecycle transition to operations (Gate H):

### Documentation Completeness
- [ ] System architecture document current and reflects production deployment
- [ ] API documentation current and accessible to operations team
- [ ] Operational runbook covers all known failure modes
- [ ] Data dictionary current for all data sources and outputs
- [ ] Known limitations and gotchas documented in the operational knowledge base

### Knowledge Transfer
- [ ] At least two operations team members can diagnose and resolve P2 incidents without delivery team assistance
- [ ] On-call shadowing completed (minimum 2 sprints of paired on-call)
- [ ] Model retraining process documented and tested by operations team
- [ ] Deployment process tested independently by operations team (without delivery team present)

### Governance
- [ ] Lifecycle-state.json updated to reflect Phase 7 active status
- [ ] Delivery team formally released from operational accountability
- [ ] Product Manager confirmed as ongoing product owner for Phase 7
- [ ] Next scheduled review dates confirmed (quarterly operational review, annual strategy review)
