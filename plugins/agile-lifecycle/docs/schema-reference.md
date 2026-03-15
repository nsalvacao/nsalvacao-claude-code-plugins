# Schema Reference

All 17 JSON schemas in the agile-lifecycle plugin. All use JSON Schema draft 2020-12 and `$id` prefixed with `agile-lifecycle/`.

## Schemas

| Schema File | $id | Purpose | Required Fields |
|-------------|-----|---------|----------------|
| `phase-contract.schema.json` | agile-lifecycle/phase-contract | Phase/subfase operational contract | id, phase, subfase, status, owner, entry_criteria, exit_criteria |
| `sprint-contract.schema.json` | agile-lifecycle/sprint-contract | Sprint planning record | id, sprint_number, phase, goal, committed_items, status |
| `risk-register.schema.json` | agile-lifecycle/risk-register | Individual risk entry | id, description, probability, impact, owner, phase, status |
| `assumption-register.schema.json` | agile-lifecycle/assumption-register | Individual assumption entry | id, description, owner, phase, status, due_date |
| `clarification-log.schema.json` | agile-lifecycle/clarification-log | Open question / decision | id, question, raised_by, phase, status |
| `dependency-log.schema.json` | agile-lifecycle/dependency-log | External dependency | id, description, owner, dependent_team, phase, status, due_date |
| `change-log.schema.json` | agile-lifecycle/change-log | Change log entry | id, description, phase, type, status, requested_by, requested_date |
| `change-request.schema.json` | agile-lifecycle/change-request | Formal change request | id, title, description, requested_by, phase, classification, impact |
| `evidence-index.schema.json` | agile-lifecycle/evidence-index | Evidence index entry | id, title, type, phase, gate, status, path, created_by, created_date |
| `handover-log.schema.json` | agile-lifecycle/handover-log | Phase handover record | id, from_phase, to_phase, handover_date, handed_by, received_by, artefacts_handed, status |
| `gate-review.schema.json` | agile-lifecycle/gate-review | Gate review result | id, gate, phase, review_date, reviewer, outcome, criteria_checked |
| `lifecycle-state.schema.json` | agile-lifecycle/lifecycle-state | Full lifecycle state machine | project_id, project_name, current_phase, phases, last_updated |
| `artefact-manifest.schema.json` | agile-lifecycle/artefact-manifest | Artefact production status | project_id, phase, artefacts |
| `waiver-log.schema.json` | agile-lifecycle/waiver-log | Waiver entry | id, gate, criterion, justification, requested_by, approved_by, approval_date |
| `definition-of-done.schema.json` | agile-lifecycle/definition-of-done | DoD checklist | id, phase, sprint, level, items, status, verified_by, verification_date |
| `sprint-health.schema.json` | agile-lifecycle/sprint-health | Sprint health metrics | sprint_id, phase, measurement_date, velocity, commitment_ratio, defect_count |
| `retrospective.schema.json` | agile-lifecycle/retrospective | Retrospective record | id, scope, phase, date, facilitator, what_went_well, what_to_improve, actions |

## Status Enums

**Phase status** (used in lifecycle-state, phase-contract):
`not_started | in_progress | blocked | ready_for_review | ready_for_gate | approved | rejected | waived | closed`

**Gate** (used in gate-review, evidence-index):
`A | B | C | D | E | F | none`

**Evidence level** (used in evidence-index):
`exists | reviewed | approved`

## Validation

```bash
# Validate a JSON file against a schema
bash plugins/agile-lifecycle/scripts/validate-schema.sh <file.json> <schema.schema.json>

# Validate all schemas are valid JSON
for f in plugins/agile-lifecycle/schemas/*.schema.json; do
  python3 -c "import json; json.load(open('$f'))" && echo "OK: $f"
done
```
