---
name: waterfall-artefact-gen
description: Generate a waterfall lifecycle artefact from a template, pre-populated with project context.
---

# /waterfall-artefact-gen <artefact-name> [phase] [output-path]

## Overview

Generates a waterfall lifecycle artefact by looking up its template in the artefact catalog, reading project metadata from `lifecycle-state.json`, and rendering the template with `{{variable}}` placeholders replaced by actual project values.

The generated file is saved to the appropriate phase artefact directory or a custom path if specified. This command accelerates artefact creation while ensuring consistency with project metadata and template standards.

## Usage

```
/waterfall-artefact-gen <artefact-name> [phase] [output-path]
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `artefact-name` | Required | Artefact identifier as listed in `references/artefact-catalog.md` (e.g., `project-charter`, `system-design-document`, `test-plan`). |
| `phase` | Optional | Phase number (1–8). If omitted, inferred from the artefact catalog entry or the current active phase in `lifecycle-state.json`. |
| `output-path` | Optional | Custom output path. If omitted, defaults to `.waterfall-lifecycle/artefacts/phase-N/<artefact-name>.md`. |

## What It Does

1. Looks up `artefact-name` in `references/artefact-catalog.md` to find the associated template path (e.g., `templates/phase-1/project-charter.md.template`) and default phase.
2. Reads project metadata from `.waterfall-lifecycle/lifecycle-state.json` (project name, product type, team, sponsor, current phase, date).
3. Renders the template by replacing all `{{variable}}` placeholders with resolved values from project metadata and the current date.
4. Saves the rendered artefact to `.waterfall-lifecycle/artefacts/phase-N/<artefact-name>.md` or the specified `output-path`.
5. Prints the full path to the generated file.

## Examples

```
# Generate Project Charter for Phase 1 (inferred from catalog)
/waterfall-artefact-gen project-charter
```

```
# Expected output
Generating artefact: project-charter
  Template: templates/phase-1/project-charter.md.template
  Phase: 1 (inferred from catalog)
  Project: enterprise-billing-platform
  ✓ Generated: .waterfall-lifecycle/artefacts/phase-1/project-charter.md
```

```
# Generate System Design Document for Phase 3
/waterfall-artefact-gen system-design-document 3
```

```
# Expected output
Generating artefact: system-design-document
  Template: templates/phase-3/system-design-document.md.template
  Phase: 3
  ✓ Generated: .waterfall-lifecycle/artefacts/phase-3/system-design-document.md
```

```
# Generate test plan with custom output path
/waterfall-artefact-gen test-plan 5 docs/test-plan-v1.md
```

```
# Expected output
Generating artefact: test-plan
  Template: templates/phase-5/test-plan.md.template
  Phase: 5
  ✓ Generated: docs/test-plan-v1.md
```

```
# Unknown artefact name
/waterfall-artefact-gen unknown-doc

# Expected output
ERROR: Artefact 'unknown-doc' not found in references/artefact-catalog.md.
       Run /waterfall-lifecycle-status to see expected artefacts for the current phase.
```

## Related Commands

- `/waterfall-lifecycle-status` — identify missing artefacts for the current phase
- `/waterfall-gate-review <gate>` — run gate review after required artefacts are generated
- `/waterfall-phase-start <N>` — start a phase that requires specific artefacts

## Related Agents

- `agents/transversal/artefact-generator` — generates and validates artefact content from templates
