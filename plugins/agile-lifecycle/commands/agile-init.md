---
name: agile-init
description: Initialize agile-lifecycle framework for a new project. Creates lifecycle-state.json, directory structure, and bootstraps Phase 1.
---

# /agile-init [project-name]

## Overview

Bootstraps the agile-lifecycle framework in the current project. Creates the `.agile-lifecycle/` directory structure, initializes `lifecycle-state.json`, prompts for project metadata, and prepares the environment to start Phase 1 (Opportunity and Portfolio Framing).

Run this command once at the start of any new project. It is idempotent — re-running it will not overwrite existing state.

## Usage

```
/agile-init [project-name]
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `project-name` | Optional | Name of the project. If omitted, you will be prompted. |

## What It Does

1. Checks if `.agile-lifecycle/` already exists in the working directory.
2. If not found, creates the full directory structure:
   - `.agile-lifecycle/artefacts/` — phase artefacts storage
   - `.agile-lifecycle/evidence/` — evidence index entries
   - `.agile-lifecycle/registers/` — risk, assumption, clarification, dependency registers
   - `.agile-lifecycle/gate-reports/` — gate review reports
   - `.agile-lifecycle/metrics/` — metrics snapshots
3. Prompts for project metadata:
   - Project name
   - Product type (saas | web | desktop | cli | ai-ml | data-product)
   - Team name and initial members
   - Sponsor name
4. Initializes `lifecycle-state.json` using `schemas/lifecycle-state.schema.json`.
5. Sets Phase 1 status to `in_progress`, all other phases to `not_started`.
6. Prints a summary of what was created and suggests the next step: `/agile-phase-start 1`.

## Examples

```
# Initialize with interactive prompts
/agile-init

# Initialize with project name provided
/agile-init my-ai-product
```

```
# Expected output
Initializing agile-lifecycle framework...
  ✓ Created .agile-lifecycle/
  ✓ Created lifecycle-state.json
  ✓ Phase 1 set to: in_progress

Next step: /agile-phase-start 1
```

## Related Commands

- `/agile-status` — view current lifecycle state after initializing
- `/agile-phase-start 1` — start Phase 1 after initialization
- `/agile-tailoring` — configure tailoring before starting phases

## Related Agents

- `agents/transversal/lifecycle-orchestrator` — validates state and creates initial lifecycle-state.json
