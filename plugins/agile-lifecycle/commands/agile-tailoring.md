---
name: agile-tailoring
description: Configure lifecycle tailoring for the project type — SaaS, web, desktop, CLI, AI/ML product. Adjusts gates, artefacts, and phase depth.
---

# /agile-tailoring [product-type]

## Overview

Configures the lifecycle framework for a specific product type. Different product types require different gate rigor, artefact sets, and phase depth. This command applies a tailoring profile that adjusts the lifecycle without removing governance safeguards.

Tailoring should be applied at the start of the project (before or just after `/agile-init`) and can be revisited if the product type changes significantly.

## Usage

```
/agile-tailoring [product-type]
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `product-type` | Optional | Product type profile to apply. If omitted, prompts for selection. |

## Supported Product Types

| Type | Description |
|------|-------------|
| `saas` | SaaS platform — full gates, multi-tenant considerations, ops/SLO focus |
| `web` | Web application — standard gates, UX-heavy discovery, deployment focus |
| `desktop` | Desktop application — release management, distribution gates, update lifecycle |
| `cli` | CLI tool — lightweight gates, documentation-heavy, release automation |
| `ai-ml` | AI/ML product — GenAI overlay active, all AI gates enforced, red-team at Gate D |
| `data-product` | Data product — data quality gates, lineage requirements, privacy compliance overlay |

## What It Does

1. Reads current `lifecycle-state.json` to check if tailoring has already been applied.
2. If `product-type` not provided, shows the tailoring options with descriptions and prompts for selection.
3. Loads the tailoring profile from `references/tailoring-guide.md`.
4. Applies tailoring adjustments:
   - **Gates**: marks which gates are mandatory, optional, or simplified for this type.
   - **Artefacts**: lists required vs optional artefacts per phase for this type.
   - **Phase depth**: indicates which phases require full depth vs lightweight treatment.
   - **GenAI overlay**: activates `references/genai-overlay.md` for `ai-ml` and `data-product` types.
5. Updates `lifecycle-state.json` with `product_type` and `tailoring_profile`.
6. Shows a summary of the applied tailoring — what is mandatory, what is optional, what is waivable.
7. Suggests reading `docs/phase-essentials/phase-1.md` as the next step.

## Examples

```
# Interactive tailoring
/agile-tailoring

# Apply SaaS tailoring
/agile-tailoring saas

# Apply AI/ML product tailoring (activates GenAI overlay)
/agile-tailoring ai-ml

# Apply CLI tool tailoring (lightweight profile)
/agile-tailoring cli
```

## Related Commands

- `/agile-init` — initialize lifecycle before or after tailoring
- `/agile-phase-start 1` — start Phase 1 after tailoring is applied
- `/agile-gate-review` — gate criteria are adjusted based on tailoring profile

## Related Agents

- `agents/transversal/lifecycle-orchestrator` — applies tailoring profile to lifecycle state and validates consistency
