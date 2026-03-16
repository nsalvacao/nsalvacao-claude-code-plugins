# Changelog

## [0.1.0] — 2026-03-16

### Added
- Plugin manifest (plugin.json) and marketplace registration
- 6 JSON schemas: phase-contract, risk-register, assumption-register, clarification-log, lifecycle-state, gate-io-matrix
- 9 Phase 1 templates (subfases 1.1–1.4) and 5 transversal templates
- 5 transversal agents: lifecycle-orchestrator, gate-reviewer (opus), artefact-generator, risk-assumption-tracker, metrics-analyst
- 4 Phase 1 agents (subfases 1.1–1.4): problem-value-context, feasibility-assessment, risk-compliance-screening, delivery-framing
- 5 skills: phase-contract, gate-checklist, artefact-authoring, risk-management, phase-contract-enforcement
- 5 commands: /waterfall-lifecycle-init, /waterfall-lifecycle-status, /waterfall-phase-start, /waterfall-gate-review, /waterfall-artefact-gen
- 6 reference docs: lifecycle-overview, gate-criteria-reference, artefact-catalog, handover-reference, phase-assumptions-catalog, role-accountability-model
- 4 utility scripts: validate-schema, render-template, init-lifecycle, check-phase-contract
- Hooks: hooks.json (wrapper format), validate-artefact.sh, lf-check.sh
- Documentation: 8 phase essentials cards, skill-finder, worked example (Phase 1), 3 walkthroughs, README
