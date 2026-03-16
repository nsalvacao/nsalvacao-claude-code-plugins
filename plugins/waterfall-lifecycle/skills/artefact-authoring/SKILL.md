---
name: artefact-authoring
description: This skill should be used when creating, completing, or reviewing a waterfall lifecycle artefact. Ensures artefacts follow templates, satisfy completeness requirements, and are ready for gate evidence submission with correct closure obligations.
---

# Artefact Authoring

## Purpose
Every waterfall phase produces artefacts that serve as evidence at gate reviews. This skill ensures artefacts are authored against their designated templates, meet the evidence threshold required for their gate, and are registered in the evidence index. It also tracks closure obligations — the mandatory actions required for each artefact at phase end.

## When to Use
- A new phase artefact must be created from scratch
- An existing artefact must be completed to a higher evidence threshold (e.g., from `exists` to `approved`)
- An artefact must be reviewed for gate evidence submission
- Phase closure requires artefact archiving, baselining, or handover
- An artefact's completeness must be self-assessed before peer review

## Instructions

### Step 1: Look Up the Artefact in the Catalog
Identify the artefact by its ID or name in `skills/artefact-authoring/references/artefact-catalog.md`:
- Note the artefact's `template` path — this is the authoritative structure
- Note the `gate` this artefact must satisfy
- Note the `evidence_threshold` required for that gate (`exists` / `reviewed` / `approved`)
- Note the `closure_obligation` — what must happen to this artefact at phase end

### Step 2: Open the Template
Open the template at the path identified in Step 1. Use the `{{placeholder}}` sections as a mandatory guide:
- Every section in the template must be addressed
- Do not delete sections — if a section is not applicable, note why with a brief statement
- Template sections reflect the minimum viable completeness for gate evidence

### Step 3: Fill All Mandatory Sections
Complete every mandatory section:
- Do not leave sections as "TBD", "N/A" without explanation, or empty
- Use concrete specifics — names, dates, version numbers, decision rationale
- Reference other artefacts by their canonical IDs (not file paths or informal names)
- If information is genuinely unknown, document it as an open assumption with owner and due date

### Step 4: Check Closure Obligation
Determine what must happen to this artefact at phase end based on its `closure_obligation`:
- `baselined` — artefact must be version-locked and tagged; no further edits without change control
- `archived` — artefact moves to the phase archive and is no longer actively maintained
- `handed_over` — artefact must be formally transferred to the receiving team or stakeholder
- `updated` — artefact requires a specific update at phase closure (e.g., final status summary)
- `closed` — artefact requires a formal closure action (e.g., all items resolved, closure statement signed)

Plan for this obligation before phase closure — do not discover it at gate review time.

### Step 5: Verify Evidence Threshold
Confirm the artefact meets its required gate evidence threshold:
- `exists` — file is present, named correctly, and registered in the evidence index
- `reviewed` — artefact has been reviewed by the designated reviewer role; review record exists
- `approved` — artefact has formal sign-off from the designated approver; approval record exists and is referenced

If the artefact is authored to `exists` level but the gate requires `approved`, this is a gap — escalate or plan the review/approval process before gate date.

### Step 6: Validate Against Schema (if applicable)
If a JSON or YAML schema exists for this artefact type (check `schemas/`):
- Validate the artefact structure against the schema
- Resolve all schema validation errors before submission
- Record the schema validation result in the artefact header or evidence index entry

### Step 7: Register in the Evidence Index
Add the artefact to the evidence index at `.waterfall-lifecycle/evidence/`:
- Record artefact ID, name, path, gate, evidence threshold met, and responsible owner
- An artefact not registered in the evidence index does not exist for gate purposes
- Update the entry if the artefact moves from `exists` to `reviewed` or `approved`

## Key Principles
1. **Templates define completeness** — all sections must be addressed, not just the sections that seem relevant to the current context.
2. **Closure obligations are mandatory** — artefacts do not simply "sit" after phase closure; each has a defined end-state that must be executed.
3. **Evidence thresholds are gate requirements** — authoring to `exists` when the gate requires `approved` is a structural gap that will block the review.
4. **Review before submission** — self-review using the template's completeness checklist before requesting peer review or approval.
5. **Register all evidence** — artefacts not in the evidence index are invisible to gate reviewers and do not count as evidence.

## Reference Materials
- `skills/artefact-authoring/references/artefact-catalog.md` — Abbreviated catalog with phase 1 artefacts and transversal objects
- `references/artefact-catalog.md` — Full artefact catalog for all phases
- `references/lifecycle-overview.md` — Phase-to-gate mapping and artefact context
- `schemas/` — JSON/YAML schemas for structured artefact types

## Quality Checks
- Artefact located in catalog before authoring begins (not created from scratch without template)
- All template sections addressed — no empty or "TBD" sections without documented rationale
- Closure obligation identified and planned before phase closure
- Evidence threshold verified against gate requirement — gap identified if authoring level is below gate requirement
- Artefact registered in evidence index with correct gate and threshold status
- Schema validation completed (if schema exists for this artefact type)
