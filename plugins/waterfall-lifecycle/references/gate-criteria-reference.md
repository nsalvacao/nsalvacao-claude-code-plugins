# Gate Criteria Reference — Waterfall-Lifecycle Framework

## Table of Contents

1. [Gate A — Initiation Approval](#gate-a--initiation-approval)
2. [Gate B — Requirements Baseline Approval](#gate-b--requirements-baseline-approval)
3. [Gate C — Design Approval](#gate-c--design-approval)
4. [Gate D — Build Complete / Integration Ready](#gate-d--build-complete--integration-ready)
5. [Gate E — Validation Complete / Release Readiness](#gate-e--validation-complete--release-readiness)
6. [Gate F — Go-live Approval](#gate-f--go-live-approval)
7. [Gate G — Hypercare Exit / Service Acceptance](#gate-g--hypercare-exit--service-acceptance)
8. [Gate H — Retirement Approval](#gate-h--retirement-approval)
9. [Evidence Threshold Definitions](#evidence-threshold-definitions)
10. [Waiver Authority Levels](#waiver-authority-levels)

---

## Gate A — Initiation Approval

### Objective

Authorize transition from opportunity exploration to formal requirements work. Gate A answers: is the problem real, is the value hypothesis credible, is the AI usage justified, and are the minimum conditions present to proceed to Phase 2?

### Timing

End of Phase 1 (Opportunity and Feasibility). All Phase 1 subfases (1.1–1.4) must be complete before Gate A is convened.

### Pass Criteria

All of the following must be satisfied:

1. Problem statement is documented, unambiguous, and endorsed by at least one named business sponsor.
2. Value hypothesis is documented with at least one measurable outcome indicator.
3. Stakeholder map identifies key roles, decision-makers, and primary users.
4. Feasibility assessment covers technical, data, and AI dimensions; no blocker-class finding is unresolved.
5. Data feasibility note confirms data availability, quality indication, and licensing/privacy compatibility.
6. AI feasibility note confirms that AI is justified (not just technically feasible) and that human oversight requirements are understood.
7. Initial risk register is populated; all risks rated critical or high have an owner and a mitigation direction.
8. Assumption register is populated; all assumptions rated as high-impact have a validation owner and deadline.
9. Clarification log is populated; all open items rated as blocking have a resolution path or escalation.
10. Project charter is drafted and signed by the initiating sponsor.
11. Initiation gate pack is complete and submitted to the gate reviewer.
12. Governance model and decision rights are documented at minimum level.

### Fail Criteria

Gate A is rejected if any of the following apply:

- Problem statement is absent, contradictory, or not endorsed by a sponsor.
- Feasibility assessment has a blocker-class finding (e.g., required data is unavailable, compliance barrier is unresolved, AI cannot be justified for the stated purpose).
- Risks rated critical have no owner or no documented treatment direction.
- Project charter is unsigned or incomplete.
- High-impact assumptions have no validation owner.
- The AI use case requires human oversight mechanisms that have not been acknowledged or planned.
- Privacy or legal blockers have been identified but not escalated.

### Waiver Policy

A waiver allows progression despite one or more pass criteria not being fully met. The following conditions govern waivers at Gate A:

- **Eligible for waiver:** Non-critical artefact gaps (e.g., assumption register partially populated), minor outstanding clarifications, feasibility notes at "reviewed" rather than "approved" level where the gap is documented and tracked.
- **Not eligible for waiver:** Unsigned project charter; unresolved blocker-class feasibility finding; no named sponsor; undocumented high-impact risks.
- **Waiver approval authority:** Sponsor or governance forum chair.
- **Required action:** Written risk acceptance; waiver condition entered in the clarification log with owner and deadline; waiver logged in the Gate Review Record.

### Artefact-to-Obligation Matrix

| Artefact | Required | Evidence Threshold | Notes |
|----------|----------|--------------------|-------|
| Problem statement | Mandatory | Reviewed | Must be endorsed in writing by sponsor |
| Vision statement | Mandatory | Reviewed | May be embedded in project charter if explicit |
| Stakeholder map | Mandatory | Reviewed | Must include names, roles, and decision rights |
| Feasibility assessment | Mandatory | Approved | Must cover technical, data, and AI dimensions |
| Data feasibility note | Mandatory | Reviewed | Must confirm data availability and licensing intent |
| AI feasibility note | Mandatory | Reviewed | Must confirm AI justification and oversight awareness |
| Initial risk register | Mandatory | Reviewed | All critical/high risks must have owner and direction |
| Assumption register | Mandatory | Reviewed | All high-impact assumptions must have validation owner |
| Clarification log | Mandatory | Reviewed | All blocking items must have resolution path |
| Project charter | Mandatory | Approved | Sponsor signature required |
| Initiation gate pack | Mandatory | Approved | Compiled from all Phase 1 artefacts |
| Governance model | Mandatory | Reviewed | Decision rights and governance forum identified |

### State Transitions

| Outcome | Phase State → | Action Required |
|---------|--------------|-----------------|
| Pass | `approved` | PM authorizes Phase 2 start; Phase 2 entry record created |
| Fail | `rejected` | Remediation items logged; phase returns to `in_progress`; re-gate scheduled |
| Waiver | `waived` | Waiver conditions logged with owner and deadline; Gate Review Record updated |

---

## Gate B — Requirements Baseline Approval

### Objective

Freeze the requirements baseline and authorize the transition to formal design. Gate B answers: are the requirements complete enough, testable enough, and internally consistent enough to allow design to proceed without rework risk?

### Timing

End of Phase 2 (Requirements and Baseline). All subfases (2.1–2.4) must be complete.

### Pass Criteria

All of the following must be satisfied:

1. Requirements baseline (SRS or equivalent) is complete, signed off, and under change control.
2. Business requirements set covers all functional scope within the agreed boundaries.
3. AI requirements specification defines acceptance criteria for AI behavior, including output quality thresholds, edge case handling, and human oversight requirements.
4. NFR specification covers performance, availability, security, logging, observability, and recoverability.
5. Acceptance criteria catalog is complete for all critical requirements; each criterion is independently verifiable.
6. Requirements traceability matrix (RTM) is populated for all critical requirements; each requirement traces to at least one acceptance criterion.
7. Glossary covers all domain-specific and AI-specific terms used in the baseline.
8. No requirement rated as critical or high-priority has unresolved ambiguity.
9. Change control mechanism is documented and ready for Phase 3 and beyond.
10. Updated assumption register and clarification log confirm no new blocking items.
11. Requirements baseline approval pack is complete and submitted.

### Fail Criteria

Gate B is rejected if any of the following apply:

- Requirements baseline is not under version control or change control.
- Critical requirements lack acceptance criteria.
- AI acceptance criteria are absent or untestable (e.g., "the AI should perform well").
- Critical NFRs (e.g., security, availability) are absent.
- RTM is incomplete for critical requirements.
- Unresolved ambiguities exist for mandatory requirements.
- Scope boundaries are undefined or contradictory.

### Waiver Policy

- **Eligible for waiver:** Non-critical requirements with documented gaps; lower-priority NFR thresholds pending final stakeholder sign-off; glossary items pending final review.
- **Not eligible for waiver:** Untestable AI acceptance criteria; missing security requirements; incomplete RTM for critical scope; no change control mechanism.
- **Waiver approval authority:** Governance forum or sponsor-designated approver.
- **Required action:** Waiver conditions logged with resolution owner and deadline; baseline approved with exception noted; risk accepted in writing.

### Artefact-to-Obligation Matrix

| Artefact | Required | Evidence Threshold | Notes |
|----------|----------|--------------------|-------|
| Requirements baseline (SRS or equivalent) | Mandatory | Approved | Must be version-controlled and under change control |
| Business requirements set | Mandatory | Approved | Must cover full agreed scope |
| AI requirements specification | Mandatory | Approved | Must include testable AI acceptance criteria |
| NFR specification | Mandatory | Approved | Must cover security, availability, performance, observability |
| Acceptance criteria catalog | Mandatory | Approved | All critical requirements must have criteria |
| Requirements traceability matrix | Mandatory | Reviewed | All critical requirements traced to acceptance criteria |
| Glossary | Mandatory | Reviewed | Domain and AI-specific terms defined |
| Updated assumption register | Mandatory | Reviewed | New assumptions from Phase 2 captured |
| Updated clarification log | Mandatory | Reviewed | All blocking items resolved or escalated |
| Requirements baseline approval pack | Mandatory | Approved | Compiled submission for gate review |

### State Transitions

| Outcome | Phase State → | Action Required |
|---------|--------------|-----------------|
| Pass | `approved` | PM authorizes Phase 3 start; baseline frozen; change control active |
| Fail | `rejected` | Remediation items logged; returns to `in_progress`; re-gate scheduled |
| Waiver | `waived` | Waiver conditions logged; baseline approved with stated exceptions |

---

## Gate C — Design Approval

### Objective

Authorize build to begin with a formally approved architecture, detailed design, control framework, and test strategy. Gate C answers: is the design sufficient to build against, are controls mapped to risks and requirements, and is the test strategy executable?

### Timing

End of Phase 3 (Architecture and Solution Design). All subfases (3.1–3.3) must be complete.

### Pass Criteria

All of the following must be satisfied:

1. HLD is complete and covers logical architecture, integration patterns, environment model, and security architecture.
2. LLD or equivalent detailed design covers all components, interfaces, data flows, AI/ML pipeline, and fallback mechanisms.
3. Interface specifications are complete for all critical external and internal integrations.
4. ADR set documents all significant architectural decisions with rationale, options considered, and consequences.
5. Control matrix maps mandatory controls to specific risks, requirements, and design components.
6. Test design package defines test strategy, test levels, coverage criteria, data requirements, and environment requirements.
7. Operational design package covers runbook structure, alert design, observability approach, and support model.
8. Security design review is complete with no critical open findings.
9. Privacy design review is complete or formally deferred with documented rationale.
10. AI control design note covers guardrails, human oversight mechanisms, fallback behavior, and logging of AI decisions.
11. All critical open design issues have a named owner, timeline, and impact statement.
12. Design approval pack is complete and submitted.

### Fail Criteria

Gate C is rejected if any of the following apply:

- HLD or LLD is absent or incomplete for critical components.
- Critical interfaces lack specifications.
- ADR set is absent for significant architectural decisions.
- Control matrix has unmapped mandatory controls.
- Test design package is absent or untestable (no coverage criteria, no environment plan).
- Security design review identifies critical unresolved findings.
- AI control mechanisms (guardrails, fallback, human oversight) are not designed.
- Open design issues affecting build feasibility are undocumented or unowned.

### Waiver Policy

- **Eligible for waiver:** Lower-priority design detail gaps where build can proceed; operational design items pending infrastructure confirmation; privacy review deferred with documented rationale.
- **Not eligible for waiver:** Missing security design review; no AI control design note; no test strategy; critical interface specifications missing.
- **Waiver approval authority:** Design authority or governance forum.
- **Required action:** Waiver items tracked in clarification log; design approved with stated exceptions; impact on Phase 4 scope documented.

### Artefact-to-Obligation Matrix

| Artefact | Required | Evidence Threshold | Notes |
|----------|----------|--------------------|-------|
| HLD | Mandatory | Approved | Must cover architecture, integration, environment, security |
| LLD or equivalent | Mandatory | Approved | Must cover all critical components and AI/ML pipeline |
| Interface specifications | Mandatory | Approved | All critical integrations must have specs |
| ADR set | Mandatory | Reviewed | All significant decisions documented |
| Control matrix | Mandatory | Approved | Controls mapped to risks and requirements |
| Test design package | Mandatory | Approved | Test strategy, coverage criteria, environment plan |
| Operational design package | Mandatory | Reviewed | Runbook structure, alert design, observability |
| Security design review | Mandatory | Approved | No critical open findings |
| Privacy design review | Conditional | Reviewed | Mandatory if personal data is processed; otherwise deferred with rationale |
| AI control design note | Mandatory | Approved | Guardrails, human oversight, fallback, AI decision logging |
| Design approval pack | Mandatory | Approved | Compiled gate submission |
| Updated assumption register | Mandatory | Reviewed | Phase 3 assumptions captured |
| Updated clarification log | Mandatory | Reviewed | All blocking design items resolved or tracked |

### State Transitions

| Outcome | Phase State → | Action Required |
|---------|--------------|-----------------|
| Pass | `approved` | PM authorizes Phase 4 start; design baseline frozen |
| Fail | `rejected` | Remediation items logged; returns to `in_progress`; re-gate scheduled |
| Waiver | `waived` | Waiver conditions logged; design approved with stated exceptions |

---

## Gate D — Build Complete / Integration Ready

### Objective

Confirm that the solution build is complete for the approved scope, critical integrations are operational, and the solution is ready for formal verification and validation. Gate D answers: is there a stable, integrated build that can be formally tested?

### Timing

End of Phase 4 (Build and Integration). All subfases (4.1–4.4) must be complete.

### Pass Criteria

All of the following must be satisfied:

1. All environments required for Phase 5 testing are provisioned, configured, and accessible.
2. CI/CD pipeline is operational, producing versioned build artefacts with traceability to the requirements baseline.
3. Build packages are complete for all in-scope components.
4. Code review records confirm all critical components have been reviewed and findings resolved or tracked.
5. All critical integration points have integration test evidence confirming they are operational.
6. Experiment log and model package or AI integration package confirm the AI component is built, versioned, and evaluated at minimum level.
7. Readiness checklist draft is complete and confirms minimum readiness for formal V&V.
8. Runbooks for critical operational procedures are drafted.
9. Defect log is current; critical and high defects are resolved or have documented acceptance with rationale.
10. Risk register is updated; no new critical risks are unowned.
11. Assumption register and clarification log are updated.

### Fail Criteria

Gate D is rejected if any of the following apply:

- V&V environments are not ready or accessible.
- Critical integrations have no test evidence or are known to be non-functional.
- AI component is not built or not integrated (no model package, no integration package).
- Critical defects are unresolved with no documented acceptance rationale.
- CI/CD pipeline is non-functional or build artefacts are unversioned.
- Runbooks for critical operational procedures are absent.

### Waiver Policy

- **Eligible for waiver:** Non-critical defects with documented acceptance; minor environment gaps with confirmed resolution timeline; operational design items not yet fully documented.
- **Not eligible for waiver:** Non-functional critical integrations; absent AI component; non-functional CI/CD; unresolved critical defects with no acceptance rationale.
- **Waiver approval authority:** Delivery authority defined in the project governance model.
- **Required action:** Waiver items tracked with owner and deadline; defect acceptance signed by delivery authority; risk entered in risk register.

### Artefact-to-Obligation Matrix

| Artefact | Required | Evidence Threshold | Notes |
|----------|----------|--------------------|-------|
| Environment readiness record | Mandatory | Approved | All V&V environments confirmed ready |
| CI/CD pipeline baseline | Mandatory | Approved | Operational, producing versioned artefacts |
| Build packages | Mandatory | Exists | All in-scope components built and versioned |
| Code review records | Mandatory | Reviewed | All critical components reviewed |
| Integration evidence | Mandatory | Reviewed | All critical integrations confirmed operational |
| Experiment log | Mandatory | Reviewed | AI experiments documented and versioned |
| Model package or integration package | Mandatory | Reviewed | AI component built, versioned, evaluated |
| Model card or equivalent | Conditional | Reviewed | Mandatory if ML model is trained or fine-tuned |
| Readiness checklist draft | Mandatory | Reviewed | Confirms minimum V&V readiness |
| Runbooks (draft) | Mandatory | Exists | Critical operational procedures drafted |
| Updated defect log | Mandatory | Reviewed | Current; critical/high defects resolved or accepted |
| Updated risk register | Mandatory | Reviewed | Phase 4 risks captured, no unowned critical risks |
| Updated assumption register | Mandatory | Reviewed | Phase 4 assumptions captured |
| Updated clarification log | Mandatory | Reviewed | Blocking items resolved or escalated |

### State Transitions

| Outcome | Phase State → | Action Required |
|---------|--------------|-----------------|
| Pass | `approved` | PM authorizes Phase 5 start; build baseline frozen for V&V |
| Fail | `rejected` | Remediation items logged; returns to `in_progress`; re-gate scheduled |
| Waiver | `waived` | Waiver conditions logged; build approved with stated exceptions; risk accepted |

---

## Gate E — Validation Complete / Release Readiness

### Objective

Confirm that the solution has been formally verified and validated against requirements, controls, and operational readiness criteria, and that the risk profile is acceptable for production entry. Gate E answers: is this solution safe and ready to release?

### Timing

End of Phase 5 (Verification and Validation). All subfases (5.1–5.4) must be complete.

### Pass Criteria

All of the following must be satisfied:

1. Functional test report confirms all critical and high-priority requirements have been tested with pass results; all open failures are resolved or formally accepted.
2. RTM is complete: every critical requirement traces from specification to test case to test result.
3. NFR test report confirms performance, security, and availability thresholds have been met or formally accepted.
4. Security validation report has no critical open findings; all high findings are resolved or have documented acceptance.
5. AI evaluation report confirms the AI component meets defined acceptance criteria; performance thresholds are met within agreed bounds.
6. Safety/trust validation is complete for applicable dimensions (fairness, toxicity, robustness, hallucination rate, fallback behavior) per the AI requirements specification.
7. UAT report confirms user acceptance; formal sign-off or documented waiver is in place.
8. Operational readiness review confirms operations and support can manage the solution in production.
9. Training completion evidence confirms operational staff have been trained.
10. Residual risk note documents all remaining risks with formal acceptance by the release authority.
11. Waiver log documents all acceptance of unmet criteria, with approvals.
12. Validation and release readiness pack is complete and submitted.

### Fail Criteria

Gate E is rejected if any of the following apply:

- Critical requirements have no test result or have failed without acceptance.
- RTM completeness is below the defined threshold for critical requirements.
- Security validation has unresolved critical findings.
- AI acceptance criteria are not met and no waiver is in place.
- UAT has not been executed or has critical unresolved failures.
- Operational readiness review identifies critical blockers (e.g., runbooks absent, operations has not accepted).
- Residual risk note is absent or residual risks are unaccepted.

### Waiver Policy

- **Eligible for waiver:** Non-critical test failures with documented acceptance; lower-priority NFR gaps with timeline for resolution; non-critical UAT findings; cosmetic or low-impact defects.
- **Not eligible for waiver:** Critical security findings without resolution; AI behavior outside accepted bounds without explicit acceptance; absence of UAT; operational readiness blockers; unsigned residual risk note.
- **Waiver approval authority:** Governance forum or designated release authority (typically sponsor or product owner with risk authority).
- **Required action:** Each waiver documented with specific criterion, rationale, risk impact, resolution owner, deadline, and formal approval signature. Waiver log becomes part of the Gate Review Record.

### Artefact-to-Obligation Matrix

| Artefact | Required | Evidence Threshold | Notes |
|----------|----------|--------------------|-------|
| Functional test report | Mandatory | Approved | All critical requirements tested; results recorded |
| Traceability completion evidence | Mandatory | Approved | RTM complete for critical requirements |
| Defect closure evidence | Mandatory | Reviewed | All critical/high defects resolved or accepted |
| NFR test report | Mandatory | Approved | Performance, security, availability results recorded |
| Security validation report | Mandatory | Approved | No critical open findings |
| Resilience/recoverability evidence | Conditional | Reviewed | Mandatory if HA/DR requirements exist |
| Observability validation report | Mandatory | Reviewed | Logging, alerting, monitoring confirmed operational |
| AI evaluation report | Mandatory | Approved | AI acceptance criteria tested and results recorded |
| Safety/trust validation note | Mandatory | Approved | Applicable trust dimensions validated |
| UAT report | Mandatory | Approved | User acceptance confirmed or waiver in place |
| Operational readiness review | Mandatory | Approved | Operations and support confirmed ready |
| Training completion evidence | Mandatory | Reviewed | Staff trained on operations, escalation, and runbooks |
| Residual risk note | Mandatory | Approved | All residual risks formally accepted |
| Waiver log | Conditional | Approved | Required if any acceptance of unmet criteria occurred |
| Validation and release readiness pack | Mandatory | Approved | Compiled gate submission |

### State Transitions

| Outcome | Phase State → | Action Required |
|---------|--------------|-----------------|
| Pass | `approved` | PM authorizes Phase 6 start; validation baseline frozen |
| Fail | `rejected` | Remediation items logged; returns to `in_progress`; re-gate scheduled |
| Waiver | `waived` | Waiver log updated; release readiness approved with stated exceptions |

---

## Gate F — Go-live Approval

### Objective

Authorize the transition of the validated solution into production. Gate F answers: is it safe to proceed with production deployment right now, given the current state of the environment, plan, rollback capability, and operational readiness?

### Timing

Mid Phase 6, before deployment execution begins (after 6.1 Release Planning is complete, before 6.2 Deployment and Cutover begins).

### Pass Criteria

All of the following must be satisfied:

1. Release plan is approved, including deployment sequence, go-live window, and owner responsibilities.
2. Cutover plan is approved with step-by-step execution detail, verification checkpoints, and rollback triggers.
3. Rollback plan is documented, tested, and confirmed executable by the deployment team.
4. Communications plan is complete; all affected stakeholders have been notified.
5. Go-live criteria pack confirms all defined go-live conditions are met.
6. Operations team has confirmed readiness in writing (pre-deployment operations acceptance).
7. Support team has confirmed readiness in writing.
8. Observability — monitoring, alerting, and dashboards — is confirmed active in the production environment.
9. Access controls in production are confirmed aligned with the approved access model.
10. No critical incidents are open in the staging/pre-production environment that would block safe deployment.
11. Release authority has given explicit go/no-go decision in writing.

### Fail Criteria

Gate F is rejected if any of the following apply:

- Rollback plan is untested or not confirmed executable.
- Operations or support have not confirmed readiness in writing.
- Observability is not active in production (monitoring, alerting not deployed).
- Critical incidents are open in staging with no resolution.
- Release authority has not given explicit go/no-go decision.
- Go-live window is not confirmed or in conflict with other critical system activities.
- Access controls in production are unverified.

### Waiver Policy

- **Eligible for waiver:** Minor communication gaps (non-critical stakeholder groups not yet notified); non-critical observability gaps with documented timeline.
- **Not eligible for waiver:** Untested rollback plan; absent operations or support readiness confirmation; critical open incidents; no release authority go/no-go decision.
- **Waiver approval authority:** Release authority (typically operations authority or designated release manager with sponsor acknowledgement).
- **Required action:** Waiver items logged with owner and deadline; release authority acknowledges waiver risk in the Gate Review Record.

### Artefact-to-Obligation Matrix

| Artefact | Required | Evidence Threshold | Notes |
|----------|----------|--------------------|-------|
| Release plan | Mandatory | Approved | Deployment sequence, window, owner responsibilities |
| Cutover plan | Mandatory | Approved | Step-by-step with verification checkpoints and rollback triggers |
| Rollback plan | Mandatory | Approved | Must be tested and confirmed executable |
| Communications plan | Mandatory | Reviewed | All critical stakeholders notified |
| Go-live criteria pack | Mandatory | Approved | All go-live conditions confirmed met |
| Pre-deployment operations acceptance | Mandatory | Approved | Written confirmation from operations team |
| Support readiness confirmation | Mandatory | Approved | Written confirmation from support team |
| Observability activation evidence | Mandatory | Reviewed | Monitoring, alerting, dashboards active in production |
| Access model confirmation | Mandatory | Reviewed | Production access controls aligned to approved model |
| Release authority go/no-go decision | Mandatory | Approved | Explicit written decision |

### State Transitions

| Outcome | Phase State → | Action Required |
|---------|--------------|-----------------|
| Pass | `approved` | Deployment authorized; cutover begins per approved plan |
| Fail | `rejected` | Deployment blocked; blocking items remediated; gate re-convened |
| Waiver | `waived` | Waiver items logged; deployment authorized with stated exceptions |

---

## Gate G — Hypercare Exit / Service Acceptance

### Objective

Authorize transition from the hypercare period (early-life support) to normal steady-state operations. Gate G answers: has the service demonstrated sufficient stability, have critical incidents been resolved, and has operations formally accepted ownership?

### Timing

End of Phase 6 (after hypercare period concludes) / early Phase 7. Triggered by fulfillment of hypercare exit criteria as defined in the hypercare plan.

### Pass Criteria

All of the following must be satisfied:

1. Hypercare report documents the hypercare period: duration, incidents, resolutions, and stability metrics.
2. Early-life incident report confirms all critical and high-severity incidents are resolved.
3. Stabilization closure note confirms the service has met defined stability thresholds (e.g., no P1 incident in the last N days, SLO met for N consecutive days).
4. Operations team formally accepts ongoing ownership of the service in writing.
5. Support team confirms procedures, runbooks, and escalation paths are operational and validated in early-life.
6. AI monitoring is confirmed active and producing signal; initial AI behavior is within accepted bounds.
7. Any hypercare-specific controls or escalation paths are transitioned to normal operations procedures.
8. Open incidents or known issues are entered into the normal operations backlog with owners.

### Fail Criteria

Gate G is rejected if any of the following apply:

- Critical or high-severity incidents are unresolved.
- Stability thresholds defined in the hypercare plan have not been met.
- Operations has not issued formal service acceptance.
- AI monitoring is not producing signal or AI behavior is outside accepted bounds.
- Runbooks or escalation paths have not been validated in early-life operation.

### Waiver Policy

- **Eligible for waiver:** Minor stability threshold gaps with documented trend improvement; non-critical procedure gaps with documented resolution timeline.
- **Not eligible for waiver:** Unresolved critical incidents; absent operations acceptance; AI behavior outside bounds without formal acceptance; non-functional monitoring.
- **Waiver approval authority:** Operations authority and sponsor.
- **Required action:** Waiver conditions entered in clarification log; operations accepts ownership with acknowledged exceptions; risk accepted in writing.

### Artefact-to-Obligation Matrix

| Artefact | Required | Evidence Threshold | Notes |
|----------|----------|--------------------|-------|
| Hypercare report | Mandatory | Approved | Covers duration, incidents, resolutions, stability metrics |
| Early-life incident report | Mandatory | Reviewed | All critical/high incidents resolved or tracked |
| Stabilization closure note | Mandatory | Approved | Stability thresholds met; criteria confirmed |
| Operations acceptance (post-hypercare) | Mandatory | Approved | Formal ongoing service ownership accepted |
| Support readiness validation | Mandatory | Reviewed | Procedures, runbooks, escalation validated in production |
| AI monitoring activation evidence | Mandatory | Reviewed | Active signal, initial behavior within bounds |

### State Transitions

| Outcome | Phase State → | Action Required |
|---------|--------------|-----------------|
| Pass | `approved` / Phase 7 `in_progress` | Hypercare closed; Phase 7 steady-state operations begins |
| Fail | `rejected` | Hypercare extended; blocking items resolved; gate re-convened |
| Waiver | `waived` | Waiver conditions logged; operations accepts with stated exceptions |

---

## Gate H — Retirement Approval

### Objective

Authorize the controlled sunset, replacement, or consolidation of the solution. Gate H answers: is the retirement decision properly justified, is the impact understood and managed, and is the closure plan executable without leaving compliance, data, or user obligations unresolved?

### Timing

End of Phase 8, before controlled decommissioning begins (after 8.1 Retirement Decision is complete, before 8.2 Controlled Decommissioning begins).

### Pass Criteria

All of the following must be satisfied:

1. Retirement decision record is documented and formally approved by the sponsoring authority.
2. Impact assessment covers affected users, integrations, data, contracts, and dependencies.
3. Sunset plan defines the decommissioning sequence, timelines, owner responsibilities, and communication strategy.
4. Data strategy is defined: what is archived, what is migrated, what is deleted, with reference to applicable retention policies and legal obligations.
5. All affected integrations have been notified and have confirmed their response plan.
6. Access closure plan identifies all access points, credentials, and service accounts to be revoked.
7. Evidence preservation plan confirms what must be retained for audit, legal, or regulatory purposes, and for how long.
8. No contractual or regulatory obligations prevent retirement on the planned date without formal resolution.
9. Sponsoring authority has issued explicit retirement authorization in writing.

### Fail Criteria

Gate H is rejected if any of the following apply:

- Retirement decision has no formal sponsor authorization.
- Impact assessment is absent or does not cover active integrations or user groups.
- Data strategy is absent (no decision on archival, migration, or deletion).
- Contractual or regulatory blockers are unresolved.
- Affected integrations have not been notified.
- Evidence preservation requirements are undefined.

### Waiver Policy

- **Eligible for waiver:** Minor communication gaps with non-critical stakeholders; secondary documentation gaps with documented resolution timeline.
- **Not eligible for waiver:** Absent sponsor authorization; undefined data strategy; unresolved contractual or regulatory blockers; missing evidence preservation plan.
- **Waiver approval authority:** Sponsor or governance forum, with risk/compliance sign-off for data or regulatory waivers.
- **Required action:** Waiver conditions logged with owner and deadline; compliance or legal sign-off obtained for any data or regulatory waiver.

### Artefact-to-Obligation Matrix

| Artefact | Required | Evidence Threshold | Notes |
|----------|----------|--------------------|-------|
| Retirement decision record | Mandatory | Approved | Formal decision with sponsor authorization |
| Impact assessment | Mandatory | Approved | Covers users, integrations, data, contracts |
| Sunset plan | Mandatory | Approved | Decommissioning sequence, timelines, owners |
| Data closure strategy | Mandatory | Approved | Archive/migrate/delete decisions with retention reference |
| Integration notification evidence | Mandatory | Reviewed | All active integrations notified and response confirmed |
| Access closure plan | Mandatory | Reviewed | All access points, credentials, service accounts identified |
| Evidence preservation plan | Mandatory | Approved | Retention scope and duration defined |
| Decommissioning record | Conditional | Reviewed | Produced during 8.2; required for final closure |
| Access closure evidence | Conditional | Reviewed | Produced during 8.2; confirms access revocation |
| Data closure record | Conditional | Reviewed | Produced during 8.2; confirms data disposition |
| Final closure pack | Mandatory | Approved | Compiled at end of Phase 8; lifecycle closed |

### State Transitions

| Outcome | Phase State → | Action Required |
|---------|--------------|-----------------|
| Pass | `approved` | Decommissioning authorized; Phase 8 subfase 8.2 begins |
| Fail | `rejected` | Decommissioning blocked; blocking items remediated; gate re-convened |
| Waiver | `waived` | Waiver conditions logged; retirement proceeds with stated exceptions |

---

## Evidence Threshold Definitions

Evidence thresholds define the minimum acceptable state of an artefact at gate review time.

| Threshold | Definition |
|-----------|------------|
| **Exists** | The artefact has been created, is stored in a known location, and is accessible to the gate reviewer. Content completeness is not validated at this level. |
| **Reviewed** | The artefact has been reviewed by at least one qualified reviewer (not the sole author). Review outcome is documented. Identified issues are either resolved or tracked with owner and deadline. |
| **Approved** | The artefact has been reviewed and formally approved by the designated approval authority (as defined in the project governance model). Approval is documented with date and approver identity. Approval implies the artefact is fit for its intended purpose at this phase. |

**Important:** "Approved" implies "Reviewed" implies "Exists." An artefact cannot be approved without review, and cannot be reviewed without existing.

---

## Waiver Authority Levels

| Level | Authority | Scope |
|-------|-----------|-------|
| **L1 — PM** | Project Manager | Minor gaps in non-critical artefacts; documentation timing waivers with clear deadline |
| **L2 — Governance forum** | Steering committee or designated gate review board | Non-critical criterion waivers; artefact threshold reductions; deferred items with risk acceptance |
| **L3 — Sponsor** | Executive sponsor or equivalent | Project-level risk acceptance; waivers impacting regulatory or contractual obligations require sponsor co-sign |
| **L4 — Compliance/Legal** | Compliance officer or legal authority | Any waiver involving data retention, privacy obligations, or regulatory compliance must have L4 co-sign regardless of other approvals |

**Waiver log fields (minimum):**

| Field | Description |
|-------|-------------|
| `waiver_id` | Unique identifier |
| `gate` | Gate at which waiver applies |
| `criterion_ref` | Which pass criterion is being waived |
| `rationale` | Why the criterion cannot be met |
| `risk_accepted` | Description of risk accepted |
| `resolution_owner` | Who is responsible for resolving or monitoring |
| `resolution_deadline` | Target date for resolution |
| `approval_authority` | Who approved the waiver (name, role) |
| `approval_date` | Date of approval |
| `status` | Open / Resolved / Accepted-permanent |
