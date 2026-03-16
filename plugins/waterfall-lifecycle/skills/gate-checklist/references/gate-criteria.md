# Gate Criteria Quick Reference

Summary checklists for all 8 gates (A–H) of the waterfall-lifecycle framework. Each gate section includes pass criteria, common failure reasons, and waiver guidelines.

> Full obligation matrix and evidence thresholds: `references/gate-criteria-reference.md`

---

## Gate A: Project Initiation

**Objective:** Confirm the project has a valid mandate, sponsor commitment, and feasibility basis before committing resources.

### Pass Criteria
- [ ] Project charter is complete, approved, and signed by sponsor
- [ ] Business case is documented and accepted by steering committee
- [ ] Feasibility study (technical, financial, regulatory) completed
- [ ] Project sponsor formally assigned with name and accountability
- [ ] Initial scope statement agreed — no unresolved scope conflicts
- [ ] Governance structure defined (steering committee, PMO escalation path)

### Common Failure Reasons
- Project charter signed but business case not formally reviewed
- Feasibility study treats assumptions as conclusions (e.g., "we assume it is feasible")
- Sponsor assigned informally — no documented acceptance of accountability
- Scope agreed verbally but not documented

### Waiver Guidelines
Waivers at Gate A are rarely acceptable. The charter and business case are foundational — proceeding without them creates uncontrolled scope and accountability risk. A waiver may be considered for the feasibility study if a pre-existing study covers the same scope and is explicitly referenced.

---

## Gate B: Requirements Baseline

**Objective:** Confirm that requirements are complete, agreed, traceable, and ready to drive design work.

### Pass Criteria
- [ ] Software Requirements Specification (SRS) approved by all stakeholders
- [ ] Non-functional requirements (NFRs) reviewed and accepted by architect
- [ ] Requirements traceability matrix links all requirements to business objectives
- [ ] All requirements are unambiguous, testable, and uniquely identified
- [ ] Requirements change control process established and communicated
- [ ] Stakeholder sign-off obtained from all required parties

### Common Failure Reasons
- SRS has open TBD sections that affect design decisions
- NFRs are aspirational ("the system should be fast") rather than measurable
- Traceability matrix exists but is not current (requirements added post-matrix)
- Stakeholder sign-off obtained from subset of required parties

### Waiver Guidelines
Individual requirements may be deferred to a later baseline with formal change control. The waiver must specify: which requirements are deferred, the target gate for resolution, and confirmation that design can proceed without them.

---

## Gate C: Architecture Approval

**Objective:** Confirm the system architecture is sound, approved, and detailed enough to drive detailed design.

### Pass Criteria
- [ ] Architecture Decision Record (ADR) documents all major decisions with rationale
- [ ] Technical architecture document reviewed and approved by technical authority
- [ ] Technology stack and toolchain decisions finalised and justified
- [ ] Non-functional requirements mapped to architectural decisions
- [ ] Security architecture reviewed by security authority
- [ ] Architecture risks documented with mitigation strategies

### Common Failure Reasons
- ADR missing for decisions that were made informally during design workshops
- Technology choices documented but justification absent
- NFR traceability to architecture not demonstrated — architecture may not meet requirements
- Security review scheduled but not yet completed at gate time

### Waiver Guidelines
Security architecture review may be waived if a formal security review is scheduled within the first milestone of Phase 4. Risk acceptance statement must confirm the waiver holder accepts responsibility for security gaps discovered post-gate.

---

## Gate D: Design Completion

**Objective:** Confirm that detailed design is complete, reviewed, and ready for implementation.

### Pass Criteria
- [ ] Detailed design documents (DDD) completed for all system components
- [ ] Database schema finalised and approved by data architect
- [ ] Interface specifications (APIs, integrations) complete and agreed with all parties
- [ ] Design reviewed against SRS — all requirements demonstrably addressed
- [ ] Prototype or proof-of-concept results reviewed (if applicable)
- [ ] Implementation plan and sprint/module breakdown approved

### Common Failure Reasons
- DDD complete for core modules but missing for integration components
- Interface specifications agreed internally but not validated with external system owners
- Design-to-requirements traceability not verified — requirements may be missed in implementation
- Implementation plan missing resource assignments or milestone dates

### Waiver Guidelines
Minor interface specifications for non-critical integrations may be deferred to Phase 4 milestone if the integration is not on the critical path for initial implementation. Requires explicit sign-off from the technical authority.

---

## Gate E: Implementation Complete

**Objective:** Confirm that all code is developed, peer-reviewed, and unit-tested to the defined standard.

### Pass Criteria
- [ ] All planned features implemented against approved design
- [ ] Unit test coverage meets defined threshold (documented in project standards)
- [ ] Static analysis and code quality checks passed (no open critical/high issues)
- [ ] All code peer-reviewed and review findings resolved
- [ ] Build pipeline executes successfully on clean environment
- [ ] Known defects triaged — no open critical defects; medium/low defects documented

### Common Failure Reasons
- Coverage threshold met overall but critical modules below threshold
- Static analysis findings acknowledged but not resolved (deferred without formal acceptance)
- Peer review completed but review comments not addressed or disputed findings not escalated
- Build passes on developer machine but fails in CI environment

### Waiver Guidelines
Feature waivers at Gate E require explicit agreement from the product owner and sponsor that the deferred feature does not affect the test scope planned for Phase 6. Each deferred feature must have a documented resolution plan and target gate.

---

## Gate F: Testing Complete

**Objective:** Confirm that all planned testing is complete, defects are resolved or accepted, and the system is ready for User Acceptance Testing.

### Pass Criteria
- [ ] System test plan executed — all planned test cases run
- [ ] Test execution report showing pass/fail/deferred breakdown
- [ ] No open critical or high severity defects (or all formally accepted with risk statement)
- [ ] Performance testing completed against NFR benchmarks
- [ ] Security testing completed (penetration test or equivalent)
- [ ] Regression suite passes on final build
- [ ] Test completion sign-off from QA Lead

### Common Failure Reasons
- Test plan executed but not all test cases run — missing coverage not documented
- Defect triage shows "deferred" without formal acceptance or risk statement
- Performance testing results available but not compared against NFR targets
- Security testing scheduled but not completed — deferred as "low risk"

### Waiver Guidelines
Individual test cases may be waived if they cover functionality deferred at Gate E. Each waiver must reference the Gate E feature waiver and confirm scope alignment.

---

## Gate G: UAT Sign-Off

**Objective:** Confirm that the system is accepted by end users and business stakeholders as fit for purpose.

### Pass Criteria
- [ ] UAT plan executed by designated business users (not developers or QA)
- [ ] UAT acceptance criteria met — all must-have criteria passed
- [ ] Business user sign-off from designated acceptance authority
- [ ] Open UAT defects triaged — no blocking or critical defects accepted
- [ ] Training materials reviewed and accepted by business
- [ ] Go/No-Go decision formally recorded with rationale

### Common Failure Reasons
- UAT executed by power users but not the designated acceptance authority
- Acceptance criteria partially met — "close enough" treated as pass without formal waiver
- Blocking defects "accepted" by developer team without business authority sign-off
- Go/No-Go decision made verbally at meeting — not recorded in writing

### Waiver Guidelines
UAT waivers are the most scrutinised in the lifecycle. A waiver on acceptance criteria requires sign-off from the business sponsor (not the project manager) with explicit risk acceptance. Waivers on blocking defects require the defect to have a confirmed fix date pre-agreed before go-live.

---

## Gate H: Deployment Approval

**Objective:** Confirm the system is ready for production deployment, all operational prerequisites are met, and rollback is planned.

### Pass Criteria
- [ ] Deployment plan approved by release manager and operations lead
- [ ] Rollback plan documented, tested, and approved
- [ ] Production environment validated against deployment prerequisites
- [ ] Operations runbook complete and reviewed by operations team
- [ ] Monitoring and alerting configured and verified in staging
- [ ] Business continuity and downtime window agreed with stakeholders
- [ ] Final security review completed and sign-off obtained

### Common Failure Reasons
- Deployment plan approved but rollback plan not tested — rollback validity unconfirmed
- Production environment "assumed ready" without explicit validation against prerequisites
- Operations team reviewed deployment plan but not the runbook
- Monitoring configured but not tested — alert thresholds not verified

### Waiver Guidelines
Rollback plan testing waivers are unacceptable at Gate H — an untested rollback is equivalent to no rollback. Waivers on monitoring completeness require a confirmed timeline for full monitoring coverage with post-deployment verification milestone.
