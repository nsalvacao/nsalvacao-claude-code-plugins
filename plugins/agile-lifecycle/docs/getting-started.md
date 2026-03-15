# Getting Started with agile-lifecycle

The `agile-lifecycle` plugin implements a hybrid gated-iterative lifecycle framework for AI/ML and digital products. It provides 31 specialized agents, 16 skills, 11 slash commands, and comprehensive artefact management across 7 phases and 6 formal gates.

## Prerequisites

- Claude Code with plugin support
- `agile-lifecycle` plugin installed and active

## Quick Start (5 minutes)

### 1. Initialize your project

```
/agile-init
```

This creates the lifecycle structure, prompts for project name and type, and bootstraps Phase 1.

### 2. Start Phase 1

```
/agile-phase-start 1
```

The `opportunity-framing` agent will guide you through Sub-phase 1.1.

### 3. Check status at any time

```
/agile-status
```

## Key Concepts

**Phases** — 7 macro phases from Discovery to Retire. Each has 2-5 subfases.

**Gates** — 6 formal review points (A-F) between phases. Each gate is PASS/FAIL/WAIVED.

**Phase Contract** — Operational agreement for each subfase: entry criteria, exit criteria, evidence required, sign-off authority.

**Artefacts** — Structured documents produced by agents using templates. Validated against JSON schemas.

**Tailoring** — The framework adapts to your product type. Run `/agile-tailoring` to configure.

## Framework at a Glance

| Phase | Name | Gate |
|-------|------|------|
| 1 | Discovery & Framing | → Gate A |
| 2 | Architecture & Planning | → Gate B |
| 3 | Iteration Design | → Gate C (per sprint) |
| 4 | Build & Integrate | → Gate D |
| 5 | Validate & Gate | → Gate E |
| 6 | Release | → Gate F |
| 7 | Operate & Improve | (continuous) |

## Next Steps

- Read `docs/lifecycle-overview.md` for the full framework reference
- Read `docs/phase-guide.md` for phase-by-phase guidance
- Use `/agile-tailoring` if you need to adjust the framework for your product type
- See `docs/agent-index.md` for all available agents
