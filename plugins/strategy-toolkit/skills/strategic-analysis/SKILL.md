---
name: Strategic Analysis
description: >
  This skill should be used when the user asks to "brainstorm ideas",
  "analyze strategic options", "plan a product launch", "think about expansion",
  "do ideation", "create an execution plan", "assess risks", "plan growth strategy",
  "evaluate before launch", "do a pre-mortem", "analyze the market",
  "think about competitive positioning", or mentions SCAMPER, Blue Ocean,
  divergent thinking, second-order effects, or flywheel mapping.
  Provides structured strategic frameworks for project expansion, market analysis,
  and execution planning.
version: 1.0.0
---

# Strategic Analysis Toolkit

Structured frameworks for strategic ideation, execution planning, and pre-launch evaluation.
Produces reproducible, high-quality strategic documents adaptable to any project.

## What This Skill Provides

Three modular phases that can be run independently or sequentially:

1. **`/brainstorm`** — Divergent ideation with 8 frameworks producing a comprehensive expansion document
2. **`/execution-plan`** — Convergent planning with second-order thinking, risk register, operationalized roadmap
3. **`/strategic-review`** — Pre-launch evaluation with systematic quality scoring and improvement recommendations

## When to Use

This skill applies when:
- Starting a new open-source project and planning its growth trajectory
- Analyzing an existing project for expansion opportunities
- Preparing for public launch (HN, Product Hunt, blog posts)
- Seeking out-of-the-box thinking about a solution's broader potential
- Planning multi-phase execution with risk awareness
- Wanting structured ideation instead of ad-hoc brainstorming

## How to Use

### Sequential Workflow (Recommended for new projects)
```
/brainstorm → review output → /execution-plan → review output → /strategic-review
```

### Independent Usage
Each command works standalone. `/brainstorm` for pure ideation, `/execution-plan` when strategy is clear, `/strategic-review` before any public exposure.

### Output Location
All documents are saved to `.ideas/` in the current project directory. This directory should be gitignored (private strategic thinking).

## Frameworks Reference

For detailed framework descriptions, templates, and application guides, consult:
- **`references/frameworks.md`** — Complete reference for all 12 strategic frameworks
  - SCAMPER (7 lenses), Divergent/Convergent thinking, Blue Ocean Strategy
  - TAM/SAM/SOM market sizing, Jobs-to-be-Done, Moat Analysis (Buffett)
  - Flywheel Mapping, Pre-Mortem Analysis, Contrarian Thinking
  - Tier ranking methodology, Growth modeling, Risk assessment

## Key Principles

- **Adaptive**: Analyze the actual project (code, README, structure) before applying frameworks
- **Asset-first**: Always start by identifying the REAL asset — often not the code itself
- **Second-order**: Think about what happens AFTER success, not just the success itself
- **Honest**: Include failure modes, competitive threats, and uncomfortable truths
- **Actionable**: Every insight must connect to a concrete next step
