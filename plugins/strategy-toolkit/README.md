# Strategy Toolkit Plugin

`strategy-toolkit` is a Claude Code plugin focused on structured strategic thinking and execution planning.

## Problem

Teams and builders often rely on unstructured brainstorming, which leads to:

- Inconsistent decision quality
- Missing risk analysis
- Weak execution planning
- Poor launch readiness checks

## What This Plugin Solves

This plugin provides repeatable strategy workflows through dedicated commands and a framework-backed skill.

It helps users:

- Generate high-quality strategic options
- Convert ideas into operational plans
- Evaluate readiness before public launch

## Components

## Commands

- `brainstorm`: structured ideation with multiple strategic frameworks
- `execution-plan`: second-order planning, roadmap definition, and risk mapping
- `strategic-review`: pre-launch quality and readiness assessment

## Skill

- `strategic-analysis`: reusable methodology and guidance for strategic ideation, planning, and review

## Generated Outputs

Commands are designed to write strategy artifacts into:

- `.ideas/brainstorm-expansion.md`
- `.ideas/execution-plan.md`
- `.ideas/evaluation-results.md`
- `.ideas/launch-blockers.md` (when needed)

The `.ideas/` directory is expected to remain private and ignored by Git.

## Install in Claude Code (Marketplace)

Run these commands inside a Claude Code session:

```text
/plugin marketplace add nsalvacao/nsalvacao-claude-code-plugins
/plugin install strategy-toolkit@nsalvacao-claude-code-plugins
```

## Local Development Usage

From the repository root:

```bash
claude --plugin-dir "$(pwd)/plugins/strategy-toolkit"
```

## Version

- Current version: `0.1.0`

## Maintainer

- Nuno Salvacao
