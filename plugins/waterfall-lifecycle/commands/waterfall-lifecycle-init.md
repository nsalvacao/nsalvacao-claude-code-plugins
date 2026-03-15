---
name: waterfall-lifecycle-init
description: Initialize waterfall-lifecycle framework for a new project. Creates lifecycle-state.json, directory structure, and bootstraps Phase 1.
---

# /waterfall-lifecycle-init [project-name]

## Overview

Bootstraps the waterfall-lifecycle framework in the current project. Creates the `.waterfall-lifecycle/` directory structure, initializes `lifecycle-state.json`, prompts for project metadata, and prepares the environment to start Phase 1 (Concept and Initiation).

Run this command once at the start of any new project. If `.waterfall-lifecycle/` already exists, the command warns and exits to prevent accidental overwrite of existing state.

## Usage

```
/waterfall-lifecycle-init [project-name]
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `project-name` | Optional | Name of the project. If omitted, you will be prompted. |

## What It Does

1. Checks if `.waterfall-lifecycle/` already exists in the working directory; if yes, warns and exits without modifying state.
2. Creates the full directory structure:
   - `.waterfall-lifecycle/artefacts/phase-{1-8}/` — phase-specific artefact storage
   - `.waterfall-lifecycle/artefacts/transversal/` — cross-phase artefacts (SLA, test strategy, etc.)
   - `.waterfall-lifecycle/evidence/` — evidence index entries per artefact
   - `.waterfall-lifecycle/registers/` — risk, assumption, clarification, and dependency registers
   - `.waterfall-lifecycle/gate-reports/` — gate review reports (A-H)
   - `.waterfall-lifecycle/metrics/` — metrics snapshots and phase progress data
3. Prompts for project metadata:
   - Project name
   - Product type (`saas` | `web` | `desktop` | `cli` | `ai-ml` | `data-product` | `embedded`)
   - Team name and sponsor name
4. Initializes `lifecycle-state.json` with all 8 phases set to `not_started` and all gates (A-H) set to `pending`.
5. Sets Phase 1 status to `in_progress` and records project metadata.
6. Prints a summary of what was created and suggests the next step: `/waterfall-phase-start 1`.

## Examples

```
# Initialize with interactive prompts
/waterfall-lifecycle-init

# Initialize with project name provided
/waterfall-lifecycle-init enterprise-billing-platform
```

```
# Expected output
Initializing waterfall-lifecycle framework...
  ✓ Created .waterfall-lifecycle/
  ✓ Created artefact directories for phases 1-8
  ✓ Created lifecycle-state.json
  ✓ Gates A-H initialized: pending
  ✓ Phase 1 set to: in_progress

Next step: /waterfall-phase-start 1
```

```
# Re-run on existing project
/waterfall-lifecycle-init

# Expected output
ERROR: .waterfall-lifecycle/ already exists.
       Use /waterfall-lifecycle-status to inspect current state.
       To reset, manually delete .waterfall-lifecycle/ first.
```

## Related Commands

- `/waterfall-lifecycle-status` — view current lifecycle state after initializing
- `/waterfall-phase-start 1` — start Phase 1 after initialization
- `/waterfall-artefact-gen` — generate initial phase artefacts

## Related Agents

- `agents/transversal/lifecycle-orchestrator` — validates state and creates initial lifecycle-state.json
