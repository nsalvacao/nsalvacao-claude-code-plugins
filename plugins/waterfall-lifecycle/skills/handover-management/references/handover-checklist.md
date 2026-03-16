# Handover Checklist Reference

Per-gate artefact checklists, phase transition readiness criteria, and open items transfer guide for all phases of the waterfall lifecycle. Use this reference when preparing or reviewing a handover package prior to any gate submission.

---

## Section 1: Gate C Handover Checklist (Phase 3 → Phase 4)

### Mandatory Artefacts

| Artefact | Produced By | Completeness Criteria |
|----------|-------------|----------------------|
| `hld.md` | Phase 3 — Architecture sub-phase | All sections populated; no `{{variable}}` tokens; reviewed by Architecture Lead |
| `lld.md` | Phase 3 — Design sub-phase | Component-level design complete; interface contracts defined; no placeholders |
| `interface-specifications.md` | Phase 3 — Design sub-phase | All integration points documented; protocol, payload schema, and error handling specified |
| `adr-set/` | Phase 3 — Architecture sub-phase | Directory exists; at least 1 ADR file present; each ADR has status `accepted` or `superseded` |
| `control-matrix.md` | Phase 3 — Compliance sub-phase | All controls mapped to requirements; control owners named; no open controls |
| `test-design-package.md` | Phase 3 — QA sub-phase | Test strategy defined; test cases linked to requirements; coverage targets stated |
| `operational-design-package.md` | Phase 3 — Design sub-phase | Runbook structure, alert design, observability approach, and support model defined |
| `security-design-review.md` | Phase 3 — Security sub-phase | Security design review complete; no critical open findings |
| `ai-control-design-note.md` | Phase 3 — AI Governance sub-phase | AI component risks assessed; control measures documented; reviewed by AI governance lead |
| `design-approval-pack.md` | Phase 3 — Governance sub-phase | All sections complete; sign-off table populated; no CRITICAL open items without carry-forward approval |
| `assumption-register.md` | Phase 3 — All sub-phases | Phase 3 assumptions captured with owners and validation deadlines |
| `clarification-log.md` | Phase 3 — All sub-phases | All blocking design items resolved or tracked with owner and deadline |

### Exit Criteria (Gate C)

1. All 12 mandatory artefacts are present and have status `complete`.
2. Zero unfilled `{{variable}}` placeholder tokens across all artefacts.
3. High-Level Design (HLD) and Low-Level Design (LLD) are internally consistent — component names, interfaces, and data flows align.
4. All Architecture Decision Records are in status `accepted` or `superseded` — no ADRs in `proposed` status.
5. Control matrix maps to requirements baseline — every requirement has at least one control assigned.
6. Test design package covers all functional requirements — no requirement is untested.
7. No CRITICAL open items in the design approval pack (or each has explicit carry-forward approval with named owner).
8. Design approval pack is signed by the Architecture Lead and Solution Architect.

### Sign-off Authority

Architecture Lead + Solution Architect.

---

## Section 2: Gate B Handover Checklist (Phase 2 → Phase 3)

### Mandatory Artefacts

| Artefact | Produced By | Completeness Criteria |
|----------|-------------|----------------------|
| `requirements-baseline.md` | Phase 2 — Requirements sub-phase | All requirements ID'd, categorised, and baselined; no `{{variable}}` tokens; version-controlled and under change control |
| `business-requirements-set.md` | Phase 2 — Requirements sub-phase | Covers full agreed scope; functional requirements complete |
| `ai-requirements-specification.md` | Phase 2 — Requirements sub-phase | All AI/ML requirements specified with testable acceptance thresholds |
| `nfr-specification.md` | Phase 2 — Requirements sub-phase | Non-functional requirements defined with measurable thresholds for security, availability, performance, observability |
| `acceptance-criteria-catalog.md` | Phase 2 — Requirements sub-phase | Acceptance criteria linked to every critical functional requirement; testable statements |
| `requirements-traceability-matrix.md` | Phase 2 — Assurance sub-phase | All critical requirements traced to acceptance criteria; no orphaned requirements |
| `glossary.md` | Phase 2 — Requirements sub-phase | Domain and AI-specific terms defined; no ambiguous terminology in requirements |
| `assumption-register.md` | Phase 2 — All sub-phases | New Phase 2 assumptions captured with owners and validation deadlines |
| `clarification-log.md` | Phase 2 — All sub-phases | All blocking items resolved or escalated; no CRITICAL clarifications outstanding |
| `requirements-baseline-approval-pack.md` | Phase 2 — Governance sub-phase | Compiled gate submission; sign-off table populated; Requirements Lead and Business Owner signatures present |

### Exit Criteria (Gate B)

1. All 10 mandatory artefacts are present and have status `complete`.
2. Zero unfilled `{{variable}}` placeholder tokens across all artefacts.
3. Requirements baseline is version-controlled and under formal change control.
4. RTM has no orphaned requirements — all requirements trace to at least one acceptance criterion.
5. All AI acceptance thresholds are testable — no vague statements such as "the AI should perform well".
6. All critical NFRs (security, availability, performance, observability) are defined with numeric targets.
7. No expired unvalidated assumptions in the assumption register.
8. All CRITICAL clarifications in the clarification log are resolved — none outstanding.
9. Glossary covers all domain and AI-specific terms used in the requirements set.
10. Requirements baseline approval pack signed by Requirements Lead and Business Owner.

### Sign-off Authority

Requirements Lead + Business Owner.

---

## Section 3: Open Items Transfer Protocol

When a phase ends with open items in any register, those items transfer to the next phase. Open items do not disappear between phases.

### Transfer Steps

1. **Identify open items**: Review the following 5 register types (risk, assumption, clarification, dependency, evidence index) for any item with status `open` or equivalent unresolved status.

2. **Assess each item**: Determine whether the item is a blocker for gate passage:
   - CRITICAL severity items that cannot carry forward block the gate unless explicitly waived by the sign-off authority.
   - HIGH, MEDIUM, and LOW items may carry forward with a documented transition note.

3. **Write a transition note**: For each open item being transferred, add a `transition_note` field explaining:
   - Why it was not resolved in the current phase
   - What action is needed in the next phase
   - Who is responsible for resolving it

4. **Copy to next phase register**: Duplicate the item to the next phase's register, preserving:
   - The original item ID (do not reassign IDs)
   - The full history of the item
   - The new `transition_note`
   - A `transferred_from` field (e.g., `phase-2`)

5. **Document transfer count**: Record the number of items transferred per register type in the handover summary:
   ```
   Open items transferred from Phase 2 to Phase 3:
     Risk register:       3 items
     Assumption register: 2 items
     Clarification log:   1 item
     Dependency log:      0 items
     Evidence index:      0 items
     Total:               6 items
   ```

6. **Receiving PM acknowledges**: The Phase N+1 PM must review the transferred items list and explicitly acknowledge receipt before Phase N+1 work begins. This acknowledgement is recorded in the Phase N+1 phase contract.

---

## Section 4: Placeholder Resolution Checklist

Artefacts generated from templates contain `{{variable}}` placeholder tokens that must be replaced before the artefact is considered complete. Any artefact with remaining placeholders is `incomplete` and blocks gate passage.

### Common Placeholder Patterns

| Pattern | Meaning | Resolution Owner |
|---------|---------|-----------------|
| `{{owner}}` | Named owner of the artefact or item | Phase lead assigns an individual |
| `{{review_date}}` | Date the artefact was reviewed | Set to the actual review date |
| `{{version}}` | Document version number | Set to current version (e.g., `1.0`) |
| `{{project_name}}` | Name of the project | Set from `lifecycle-state.json` `project.name` |
| `{{phase}}` | Phase number | Set to the current phase number |
| `{{gate}}` | Gate label | Set to the current gate label |
| `{{sign_off_authority}}` | Name of the signing authority | Set to the named individual, not a role |
| `{{test_lead}}` | Lead responsible for testing | Assigned by the QA lead |
| `{{coverage_target}}` | Numeric test coverage target | Set by QA policy or project agreement |

### Resolution Process

1. Run a placeholder scan across all mandatory artefacts:
   ```
   grep -r "{{" .waterfall-lifecycle/artefacts/phase-N/
   ```
2. List every file containing placeholder tokens with the line numbers.
3. For each placeholder:
   - Identify the correct value from the project context, `lifecycle-state.json`, or the relevant register.
   - Replace the token with the actual value.
   - Do not leave any placeholder with a descriptive value (e.g., `{{owner}} → "TBD"` is not acceptable).
4. Re-run the scan to confirm zero remaining placeholders.
5. Document the resolution in the handover summary.

---

## Section 5: Universal Transition Readiness Criteria

The following 5 criteria apply at every gate transition regardless of phase. All 5 must be satisfied before a gate review is submitted.

1. **All mandatory artefacts present with complete status** — no artefact in the mandatory set for the gate is `missing` or `incomplete`. Every artefact has been reviewed and is not in draft state.

2. **Zero unfilled placeholders in any artefact** — a full placeholder scan across all mandatory artefacts returns zero results for `{{` tokens. Artefacts with placeholders are not complete.

3. **All CRITICAL open items resolved or carry-forward approved** — no item in any register has CRITICAL severity and status `open` unless it has been explicitly approved for carry-forward by the sign-off authority, with the approver name and date recorded.

4. **Gate approval pack signed by the designated authority** — the authority listed for the current gate has reviewed and signed the approval pack. The signature must be present before gate submission, not collected retroactively.

5. **Next phase receiving PM has acknowledged inherited open items** — the PM who will lead Phase N+1 has reviewed the list of open items being transferred and confirmed acceptance. This acknowledgement is documented before Phase N+1 begins.
