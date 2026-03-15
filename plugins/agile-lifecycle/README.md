# agile-lifecycle

> Hybrid gated-iterative lifecycle framework for AI/ML and digital products

A Claude Code plugin that operationalizes enterprise agile lifecycle management with **7 phases**, **6 formal gates**, **31 specialized agents**, **16 skills**, and comprehensive artefact management.

## Overview

`agile-lifecycle` is positioned as a **hybrid/gated-iterative** framework — not pure Scrum, not SAFe. It combines the governance rigor of gated lifecycles with the flexibility of iterative delivery. Formal gates (A-F) provide governance checkpoints between phases, while sprint-based delivery within phases provides agility.

Designed for: **AI/ML products**, **SaaS**, **web applications**, and any product where governance and evidence-based decision-making matter.

## Quick Start

```
/agile-init
```

This initializes the lifecycle structure, prompts for project type, and bootstraps Phase 1.

Then:
```
/agile-phase-start 1
```

## Framework Structure

### 7 Phases

| Phase | Name | Gate |
|-------|------|------|
| 1 | Discovery & Framing | → Gate A |
| 2 | Architecture & Planning | → Gate B |
| 3 | Iteration Design | → Gate C (per sprint) |
| 4 | Build & Integrate | → Gate D |
| 5 | Validate & Gate | → Gate E |
| 6 | Release | → Gate F |
| 7 | Operate & Improve | (continuous) |

### 31 Agents

**Transversal:** lifecycle-orchestrator · gate-reviewer · artefact-generator · risk-assumption-tracker · metrics-analyst

**Phase 1:** opportunity-framing · feasibility-screening · problem-validation · hypothesis-mapping

**Phase 2:** solution-architecture · iteration-planning · risk-register

**Phase 3:** sprint-design · acceptance-criteria · test-strategy

**Phase 4:** feature-builder · integration-engineer · ai-implementation · quality-assurance

**Phase 5:** functional-validation · ai-model-validation · gate-preparation · stakeholder-review

**Phase 6:** release-manager · deployment-engineer · hypercare-lead

**Phase 7:** operations-monitor · ai-ops-analyst · continuous-improvement · lifecycle-close · retirement-planner

## Commands

| Command | Purpose |
|---------|---------|
| `/agile-init` | Initialize lifecycle for project |
| `/agile-status` | Show current lifecycle status |
| `/agile-phase-start <N>` | Start or resume a phase/subfase |
| `/agile-gate-review <gate>` | Execute a formal gate review (A-F) |
| `/agile-artefact-gen [type]` | Generate a lifecycle artefact |
| `/agile-risk-update [register]` | Add/update risk register entries |
| `/agile-sprint-plan` | Plan or review current sprint |
| `/agile-retrospective [scope]` | Facilitate a retrospective |
| `/agile-metrics-report [scope]` | Generate metrics report |
| `/agile-change-request` | Evaluate a change request |
| `/agile-tailoring [type]` | Configure lifecycle for product type |

## Skills

phase-contract · gate-checklist · artefact-authoring · risk-management · metrics-tracking · sprint-facilitation · ai-lifecycle · change-control · operational-readiness · lifecycle-tailoring · evidence-management · retrospective · definition-of-done · backlog-management · phase-contract-enforcement · responsibility-flows

## Tailoring

```
/agile-tailoring saas        # SaaS product (full lifecycle)
/agile-tailoring ai-ml       # AI/ML product (GenAI overlay active)
/agile-tailoring web         # Web application
/agile-tailoring mvp         # MVP/prototype (Phases 1-3 only)
```

## Limitations

This plugin does **not** include:

- **Team collaboration tracking** — No issue tracker or sprint board integration. Use your existing Jira/Linear/GitHub Issues workflow; the plugin provides governance overlays on top.
- **Real-time metrics dashboards** — Metrics are generated on-demand via `/agile-metrics-report`, not streamed live.
- **Automated testing/CI-CD orchestration** — The plugin validates testing strategy and QA readiness but does not run or manage CI/CD pipelines.
- **Resource capacity planning** — No workload balancing or team allocation tools. Assumes teams manage capacity externally.
- **Budget/cost tracking** — Financial governance is out of scope; focus is on product lifecycle and quality gates.
- **Stakeholder communication templates** — Provides structure and agents; you author the actual comms.

The framework is **gated-iterative, not waterfall**. Gates are decision checkpoints, not hard blockers—you can waive or re-plan before proceeding.

## Documentation

- `docs/getting-started.md` — Quick start guide
- `docs/lifecycle-overview.md` — Framework reference and state machine
- `docs/phase-guide.md` — Phase-by-phase guide
- `docs/gate-guide.md` — Gate operating model
- `docs/agent-index.md` — All 31 agents
- `docs/skill-index.md` — All 16 skills
- `docs/command-reference.md` — All 11 commands
- `docs/ai-product-guide.md` — AI/ML specific guidance

## License

MIT
