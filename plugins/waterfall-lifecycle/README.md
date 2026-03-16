# waterfall-lifecycle

Formal predictive waterfall lifecycle framework for AI/ML products — 8 phases, 8 formal gates (A–H), 33 agents, 15 skills, and full artefact management.

## Overview

waterfall-lifecycle operationalises a predictive waterfall framework designed for regulated environments, projects with well-defined requirements, and contexts where formal change control, baseline management, and explicit handovers are required. Every phase is governed by a formal contract; every transition is controlled by a gate.

This plugin integrates AI/ML and GenAI/LLM considerations into every phase and gate.

## When to Use This Plugin

**Use waterfall-lifecycle when:**
- Requirements are well-defined upfront and unlikely to change significantly
- Formal sign-offs, baseline control, and audit trails are required
- Operating in regulated industries (healthcare, finance, government)
- Handovers between teams require formal acceptance
- V&V must be a dedicated, auditable phase

**Use agile-lifecycle instead when:**
- Requirements will evolve through iteration
- Fast delivery cycles and continuous feedback are the priority
- Teams are co-located and can collaborate continuously
- Governance is lightweight and flexible

## waterfall-lifecycle vs agile-lifecycle

| Dimension | waterfall-lifecycle | agile-lifecycle |
|-----------|--------------------|-----------------|
| Phases | 8 (Requirements and Architecture are separate; V&V is dedicated) | 7 |
| Gates | 8 (A–H) | 6 (A–F) |
| Handovers | Formal with dual sign-off | Flow of responsibility |
| Requirements | Baselined in Phase 2; change control post-baseline | Continuous refinement |
| V&V | Dedicated Phase 5 | Continuous across delivery |
| Baselines | Formal (requirements, design) | None |
| Phase states | 8 (no ready_for_review) | 9 (includes ready_for_review) |
| Target context | Regulated, formal governance, formal contracts | Enterprise agile, hybrid governance |

## Phase Overview

| Phase | Name | Gate | Description |
|-------|------|------|-------------|
| 1 | Opportunity and Feasibility | A | Problem definition, feasibility assessment, project charter |
| 2 | Requirements and Baseline | B | SRS, traceability matrix, requirements baseline |
| 3 | Architecture and Solution Design | C | Architecture, solution design, design baseline |
| 4 | Build and Integration | D | Implementation, integration, build evidence |
| 5 | Verification and Validation | E | V&V plan, test execution, V&V report |
| 6 | Release and Transition | F | Release plan, deployment, transition |
| 7 | Operate, Monitor and Improve | G | Operations, monitoring, improvement backlog |
| 8 | Retire or Replace | H | Retirement plan, decommission, archive |

## Quickstart

1. `/waterfall-lifecycle-init` — initialise framework, create directory structure
2. `/waterfall-phase-start 1` — start Phase 1, get guided by the phase agent
3. Generate artefacts with agents, submit for Gate A review with `/waterfall-gate-review A`

## Components (v0.1.0)

| Type | Count | Notes |
|------|-------|-------|
| Agents | 9 | 5 transversal + 4 Phase 1 (33 planned at v1.0.0) |
| Skills | 5 | Core skills (15 planned at v1.0.0) |
| Commands | 5 | `/waterfall-*` namespaced |
| Schemas | 6 | Core schemas |
| Templates | 14 | Phase 1 (9) + transversal (5) |
| References | 6 | Lifecycle, gates, artefacts, handover, assumptions, roles |

## Documentation

- `docs/phase-essentials/` — 1-page reference cards for each phase
- `docs/skill-finder.md` — find the right skill for your goal
- `docs/worked-example-phase1-1.md` — fully worked Phase 1 example
- `docs/walkthrough-*.md` — step-by-step guides

## License

MIT
