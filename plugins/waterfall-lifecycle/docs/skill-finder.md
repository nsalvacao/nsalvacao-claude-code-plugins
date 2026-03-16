# Skill Finder — waterfall-lifecycle

Use this table to find the right skill for your current goal.

| Goal | Skill | When to Use | Status |
|------|-------|-------------|--------|
| Create or validate a phase contract | `phase-contract` | At phase start | v0.1.0 |
| Enforce contract compliance at gate | `phase-contract-enforcement` | Before gate review | v0.1.0 |
| Review gate criteria (all 8 gates) | `gate-checklist` | During gate review | v0.1.0 |
| Author a lifecycle artefact | `artefact-authoring` | When creating any artefact | v0.1.0 |
| Manage risks and all registers | `risk-management` | Throughout lifecycle | v0.1.0 |
| Elicit and baseline requirements | `requirements-elicitation` | Phase 2 | v0.2.0 (planned) |
| Manage requirements traceability | `traceability-matrix` | Phase 2–5 | v0.2.0 (planned) |
| Review architecture decisions | `architecture-review` | Phase 3 | v0.3.0 (planned) |
| Plan V&V activities | `vv-planning` | Phase 5 | v0.5.0 (planned) |
| Assess release readiness | `release-readiness` | Phase 6 | v0.6.0 (planned) |
| Manage operational metrics | `metrics-tracking` | Phase 7 | v0.7.0 (planned) |
| Handle change requests | `change-control` | Phase 2+ (post-baseline) | v0.2.0 (planned) |
| Assess operational readiness | `operational-readiness` | Phase 6–7 | v0.6.0 (planned) |
| Tailor lifecycle to context | `lifecycle-tailoring` | Any phase | v0.9.0 (planned) |
| Apply GenAI overlay | `genai-overlay` | Any phase with LLM | v0.9.0 (planned) |

## How to Invoke a Skill

Skills are invoked automatically by agents. To invoke directly, reference the skill name
in your prompt or use `/waterfall-artefact-gen` which invokes `artefact-authoring`.
