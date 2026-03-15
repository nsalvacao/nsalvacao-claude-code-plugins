---
name: artefact-authoring
description: This skill should be used when a user needs to create, fill, or validate a lifecycle artefact using the framework's template library — including selecting the correct template for a phase or gate artefact, filling all mandatory fields, removing guidance comments, and validating against a JSON schema. Triggers when the user says "create the [artefact name]", "fill in the template for", or "is this artefact gate-ready".
---

# Artefact Authoring

## Purpose
Lifecycle artefacts are the formal outputs that provide evidence of work done and enable gate reviews. This skill guides the selection, creation, and validation of artefacts using the framework's template library. Artefacts produced without using the correct template or without satisfying all mandatory fields are not valid for gate reviews.

## When to Use
- A new artefact needs to be created for a phase or gate
- The correct template for an artefact type needs to be identified
- An existing artefact needs completeness validation against its schema
- Multiple artefacts for a gate pack need to be assembled
- Placeholder values in a template need to be filled with project-specific content

## Instructions

### Step 1: Identify the Artefact Type
Determine what artefact is needed based on the current phase, activity, or gate requirement. Consult the artefact catalog at `references/artefact-catalog.md` to:
- Confirm the artefact name and ID
- Identify the owning phase and subfase
- Find the template path
- Understand the closure obligation

### Step 2: Locate the Template
Templates are in `templates/<phase>/` or `templates/transversal/` for cross-cutting artefacts. Each template uses `{{variable}}` placeholders and includes `<!-- guidance -->` comments explaining what to fill in each section.

### Step 3: Fill All Mandatory Fields
Open the template and fill every `{{variable}}` placeholder. Do not leave placeholders unfilled. For each section:
- Read the `<!-- guidance -->` comment to understand what is expected
- Fill with project-specific content (not generic descriptions)
- If a section is not applicable, state why explicitly rather than leaving it blank

### Step 4: Remove Template Guidance
After filling all placeholders:
- Remove all `<!-- guidance -->` comments
- Remove unfilled optional sections or mark them "N/A — [reason]"
- Ensure the final document reads naturally and professionally

### Step 5: Validate Against Schema
If the artefact type has a corresponding JSON schema in `schemas/`:
- Extract structured metadata from the artefact
- Validate against the schema to confirm required fields and value constraints
- Correct any validation errors before proceeding

### Step 6: Run Completeness Checklist
Each template includes a completeness checklist at the bottom. Work through every checklist item:
- [ ] All mandatory sections populated
- [ ] Placeholders replaced with real content
- [ ] Owner and date fields filled
- [ ] References to other artefacts are correct and those artefacts exist

### Step 7: Register in Evidence Index
After the artefact is complete:
- Create an evidence index entry (template: `templates/transversal/evidence-entry.md.template`)
- Record: artefact ID, type, path, author, review status, gate it satisfies
- Update the artefact manifest if one is maintained for the project

## Key Principles
1. **One artefact, one template** — always use the designated template; improvised formats are not valid for gate reviews.
2. **Placeholders are mandatory** — a template with unfilled `{{variable}}` entries is not a completed artefact.
3. **Guidance comments are removed in final output** — they exist for the author, not for reviewers or gate panels.
4. **Schema validation before gate** — artefacts with schema violations are not gate-ready.
5. **Evidence index is kept current** — an artefact that is not in the evidence index does not exist for gate purposes.

## Reference Materials
- `references/artefact-catalog.md` — Complete catalog of all lifecycle artefacts with template paths and closure obligations
- `templates/` — All template files organized by phase and transversal
- Schema: `schemas/artefact-manifest.schema.json`
- Schema: `schemas/evidence-index.schema.json`

## Quality Checks
- No `{{variable}}` placeholders remain in the final artefact
- No `<!-- guidance -->` comments remain in the final artefact
- Completeness checklist at the bottom of the template is fully checked
- Artefact is registered in the evidence index
- If schema exists: schema validation passes with no errors
