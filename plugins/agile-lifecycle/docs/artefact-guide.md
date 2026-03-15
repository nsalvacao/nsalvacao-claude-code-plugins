# Artefact Guide

## What Are Lifecycle Artefacts?

Artefacts are structured documents produced at specific phases to serve as evidence of work completed. Each artefact has:
- A template (`templates/phase-N/artefact-name.md.template`)
- A JSON schema for validation (`schemas/*.schema.json`)
- An evidence level requirement per gate (exists / reviewed / approved)
- A closure obligation (which gate requires it)

## How to Create an Artefact

### Method 1: Slash command
```
/agile-artefact-gen opportunity-brief
```

### Method 2: Artefact Generator agent
Ask the `artefact-generator` transversal agent to create a specific artefact.

### Method 3: Manual template
1. Copy the relevant `.md.template` file
2. Fill all `{{placeholder}}` fields
3. Remove guidance comments
4. Validate against the schema

## Evidence Levels

| Level | Meaning | Who Sets It |
|-------|---------|------------|
| exists | Document created and filed | Author |
| reviewed | Reviewed by a peer (not author) | Reviewer |
| approved | Formally approved by authority | Decision maker |

Gates require different evidence levels. See `references/gate-criteria-reference.md`.

## Artefact Lifecycle

```
draft → reviewed → approved → archived
```

- **draft:** Template filled, not yet reviewed
- **reviewed:** Peer-reviewed, not yet formally approved
- **approved:** Formally approved by designated authority
- **archived:** Lifecycle closed, artefact in final archive

## Key Artefacts by Phase

| Phase | Artefact | Template | Gate |
|-------|----------|---------|------|
| 1 | Opportunity Brief | `templates/phase-1/opportunity-brief.md.template` | A |
| 1 | Hypothesis Canvas | `templates/phase-1/hypothesis-canvas.md.template` | A |
| 2 | Iteration Plan | `templates/phase-2/iteration-plan.md.template` | B |
| 3 | Sprint Backlog | `templates/phase-3/sprint-backlog.md.template` | C |
| 4 | Defect Log | `templates/phase-4/defect-log.md.template` | D |
| 5 | Functional Test Report | `templates/phase-5/functional-test-report.md.template` | E |
| 5 | AI Validation Report | `templates/phase-5/ai-validation-report.md.template` | E |
| 6 | Release Plan | `templates/phase-6/release-plan.md.template` | F |
| 6 | Hypercare Report | `templates/phase-6/hypercare-report.md.template` | F |

## Transversal Artefacts

These artefacts run across all phases:
- Risk Register (updated continuously)
- Assumption Register (updated continuously)
- Evidence Index (gate evidence tracking)
- Gate Review Reports (one per gate)

## Schema Validation

All structured artefacts (JSON-based registers) can be validated:
```bash
bash plugins/agile-lifecycle/scripts/validate-schema.sh \
  my-lifecycle-state.json \
  plugins/agile-lifecycle/schemas/lifecycle-state.schema.json
```
