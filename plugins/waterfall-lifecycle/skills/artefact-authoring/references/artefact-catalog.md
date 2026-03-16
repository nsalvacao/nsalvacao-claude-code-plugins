# Artefact Catalog — Quick Reference

Abbreviated catalog for the waterfall-lifecycle framework. This file covers Phase 1 artefacts and transversal operational objects.

> Full catalog for all phases: `references/artefact-catalog.md`

---

## Phase 1: Concept & Feasibility — Artefacts

| ID | Name | Template | Gate | Evidence Threshold | Closure Obligation |
|----|------|----------|------|-------------------|-------------------|
| A-01 | Project Charter | `templates/phase-1/project-charter.md.template` | A | approved | baselined |
| A-02 | Business Case | `templates/phase-1/business-case.md.template` | A | approved | baselined |
| A-03 | Feasibility Study | `templates/phase-1/feasibility-study.md.template` | A | reviewed | archived |
| A-04 | Initial Scope Statement | `templates/phase-1/scope-statement.md.template` | A | approved | baselined |
| A-05 | Governance Structure | `templates/phase-1/governance-structure.md.template` | A | reviewed | handed_over |
| A-06 | Phase 1 Contract | `templates/transversal/phase-contract.md.template` | A | approved | closed |

---

## Transversal Operational Objects

These objects are required across all phases and are not specific to a single gate.

| ID | Name | Template | Active Gates | Evidence Threshold | Closure Obligation |
|----|------|----------|-------------|-------------------|-------------------|
| T-01 | Lifecycle State | `.waterfall-lifecycle/lifecycle-state.json` | All | exists | updated |
| T-02 | Evidence Index | `.waterfall-lifecycle/evidence/` | All | exists | updated |
| T-03 | Phase Contract (per phase) | `templates/transversal/phase-contract.md.template` | Per phase gate | approved | closed |
| T-04 | Gate Review Report | `templates/transversal/gate-review-report.md.template` | Per gate | approved | archived |
| T-05 | Risk Register | `templates/transversal/risk-register.md.template` | All | reviewed | updated |
| T-06 | Decision Log | `templates/transversal/decision-log.md.template` | All | exists | archived |
| T-07 | Change Request Log | `templates/transversal/change-request-log.md.template` | All | exists | closed |

---

## Closure Obligation Quick Guide

| Obligation | What It Means in Practice |
|------------|---------------------------|
| `baselined` | Artefact is version-locked at phase closure. Assign a version tag (e.g., v1.0-baseline). No further edits without a formal change request. File moves to the baseline archive. |
| `archived` | Artefact moves to the phase archive directory at phase closure. No active maintenance. Referenced by ID from future phases but not edited. |
| `handed_over` | Artefact must be formally transferred at phase closure. Record recipient, transfer date, and confirmation of receipt. Often applies to design documents passed to implementation teams. |
| `updated` | Artefact requires a specific content update at phase closure (e.g., adding final status, actual dates, or summary outcome). Not version-locked — can continue to be maintained. |
| `closed` | Artefact requires a formal closure action. Examples: all risk register items resolved or accepted; all change requests closed or deferred with justification; phase contract status set to `closed` with sign-off. |

---

## Notes on Evidence Thresholds

- `exists` — The artefact file is present, has the correct name, and is registered in the evidence index. No review required for gate purposes.
- `reviewed` — The artefact has been reviewed by the designated reviewer role for this artefact type. A review record (meeting minutes, comment thread, or review sign-off) must exist.
- `approved` — The artefact has formal sign-off from the designated approver. The approval record (signature, email confirmation, system approval) must be explicitly referenced in the evidence index entry.

**Authoring to the wrong threshold is a common gate failure cause.** Always check the threshold for the gate this artefact targets before deciding when authoring is complete.
