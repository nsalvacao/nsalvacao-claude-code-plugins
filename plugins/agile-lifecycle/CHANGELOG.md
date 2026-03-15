# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [0.2.0] - 2026-03-15

### Added
- `docs/genai-overlay.md` — AI/ML-specific lifecycle extensions and GenAI decision frameworks
- `docs/tailoring-guide.md` — Configuration guide for tailoring the lifecycle to different product types (SaaS, AI/ML, web, MVP)
- `tests/validate-plugin.sh` — Static validation suite with 6 core checks (manifest, agents CRLF, skills, commands, hooks schema, documentation)
- 7 missing SKILL.md files implementing all 16 skills referenced in the plugin

### Changed
- Updated skill count from 13 to 16 across all descriptions (README, plugin.json, skill-index.md)
- Expanded Phase 7 documentation for operational readiness and continuous improvement
- Improved documentation coverage across all phase guides
- Enhanced genai-overlay with additional AI/ML-specific decision frameworks and tailoring patterns

### Fixed
- Corrected template references in all 7 phase-essentials files
- Converted bold Quality/Output/Edge headings to Markdown level-2 headings in 4 transversal agents
- Phase-essentials and structural quality improvements across all 31 agents and 10 documentation files
- Documentation alignment with current 16-skill architecture

## [0.1.0] - 2026-03-15

### Added

**Agents (31):**
- 5 transversal agents: lifecycle-orchestrator, gate-reviewer, artefact-generator, risk-assumption-tracker, metrics-analyst
- 4 Phase 1 agents: opportunity-framing, feasibility-screening, problem-validation, hypothesis-mapping
- 3 Phase 2 agents: solution-architecture, iteration-planning, risk-register
- 3 Phase 3 agents: sprint-design, acceptance-criteria, test-strategy
- 4 Phase 4 agents: feature-builder, integration-engineer, ai-implementation, quality-assurance
- 4 Phase 5 agents: functional-validation, ai-model-validation, gate-preparation, stakeholder-review
- 3 Phase 6 agents: release-manager, deployment-engineer, hypercare-lead
- 5 Phase 7 agents: operations-monitor, ai-ops-analyst, continuous-improvement, lifecycle-close, retirement-planner

**Commands (11):**
- /agile-init, /agile-status, /agile-phase-start, /agile-gate-review, /agile-artefact-gen
- /agile-risk-update, /agile-sprint-plan, /agile-retrospective, /agile-metrics-report
- /agile-change-request, /agile-tailoring

**Skills (13):**
- phase-contract, gate-checklist, artefact-authoring, risk-management, metrics-tracking
- sprint-facilitation, ai-lifecycle, change-control, operational-readiness, lifecycle-tailoring
- evidence-management, retrospective, definition-of-done

**Schemas (17 — JSON Schema draft 2020-12, $id prefixed `agile-lifecycle/`):**
- phase-contract, sprint-contract, risk-register, assumption-register, clarification-log
- dependency-log, change-log, change-request, evidence-index, handover-log, gate-review
- lifecycle-state, artefact-manifest, waiver-log, definition-of-done, sprint-health, retrospective

**Templates (54):**
- Phase 1 (6): opportunity-brief, feasibility-note, hypothesis-canvas, risk-register-init, stakeholder-map, gate-a-pack
- Phase 2 (7): solution-brief, architecture-decision, iteration-plan, risk-register, assumption-register, dependency-map, gate-b-pack
- Phase 3 (6): sprint-backlog, acceptance-criteria, test-plan, dod-checklist, sprint-risk-note, gate-c-pack
- Phase 4 (8): feature-spec, code-review-record, integration-test-record, ai-experiment-log, model-card, dataset-doc, defect-log, gate-d-pack
- Phase 5 (7): functional-test-report, ai-validation-report, uat-report, residual-risk-note, waiver-log, traceability-evidence, gate-e-pack
- Phase 6 (6): release-plan, deployment-record, rollback-plan, hypercare-report, operations-handover, gate-f-pack
- Phase 7 (5): service-report, ai-monitoring-report, retrospective-record, improvement-backlog, lifecycle-closure
- Transversal (9): risk-entry, assumption-entry, clarification-entry, gate-review-report, evidence-entry, handover-entry, change-request, waiver-entry, significant-change

**Reference docs (8):**
- lifecycle-overview, gate-criteria-reference, artefact-catalog, metrics-reference
- handover-reference, tailoring-guide, genai-overlay, sprint-health-reference

**Scripts (14):**
- validate-schema, render-template, init-lifecycle, check-phase-contract, check-gate-criteria
- track-artefacts, check-assumptions, check-sprint-health, check-definition-of-done
- generate-metrics-report, validate-lifecycle-state, export-evidence-index
- check-release-readiness, lifecycle-summary

**Hooks:**
- hooks.json (wrapper format)
- validate-artefact.sh, check-phase-state.sh, lf-check.sh

**Documentation:**
- getting-started, lifecycle-overview, phase-guide, gate-guide, artefact-guide
- agent-index, skill-index, command-reference, schema-reference, tailoring-guide
- ai-product-guide, phase-essentials-overview

### Framework

- 7 phases: Discovery & Framing → Architecture & Planning → Iteration Design → Build & Integrate → Validate & Gate → Release → Operate & Improve
- 6 formal gates (A-F) with PASS/FAIL/WAIVED outcomes
- Hybrid/gated-iterative positioning (not pure Scrum, not SAFe)
- Full GenAI/LLM overlay for AI products (red-team at Gate E mandatory for LLM)
- Lifecycle tailoring by product type (SaaS, web, desktop, CLI, AI/ML, data-product, internal, MVP)
