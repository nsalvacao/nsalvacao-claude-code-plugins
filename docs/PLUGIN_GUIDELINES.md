# Plugin Guidelines

This document defines the minimum quality bar for plugins added to this repository.

## Core Goals

- Keep plugin behavior clear and reproducible
- Keep docs explicit and friendly to first-time users
- Keep repository growth maintainable as the plugin catalog expands

## Required Plugin Structure

Each plugin must be placed under:

`plugins/<plugin-name>/`

Minimum required files:

- `plugins/<plugin-name>/.claude-plugin/plugin.json`
- `plugins/<plugin-name>/README.md`
- At least one of:
  - `commands/`
  - `skills/`
  - `agents/`
  - hooks setup
  - MCP integration artifacts

## `plugin.json` Requirements

A plugin manifest must include at least:

- `name`
- `version`
- `description`
- `author.name`
- `author.email`

## README Requirements (Plugin Level)

Each plugin README should include:

1. Problem statement
2. What the plugin solves
3. Included components (commands/skills/agents)
4. Installation instructions using the official flow:
   - `/plugin marketplace add <owner>/<repo>`
   - `/plugin install <plugin-name>@<marketplace-name>`
5. Usage examples
6. Output behavior and side effects
7. Known limitations
8. Version information

Optional: include a local development mode using `claude --plugin-dir`.

## Repository Registration

Every new plugin must also be added to:

- `.claude-plugin/marketplace.json`

Use consistent naming and description style across entries.

## Quality Checklist

Before opening a PR for a plugin:

- [ ] Manifest is valid JSON
- [ ] README is complete and in English
- [ ] README includes marketplace install steps (`marketplace add` then `plugin install`)
- [ ] Commands/skills are internally consistent
- [ ] Relative paths are correct
- [ ] Side effects and generated files are documented
- [ ] Marketplace entry has been added/updated

## Governance Workflow (Atomic Delivery)

Use this loop for any plugin change (new plugin, plugin update, docs, scripts, hooks, agents, skills).

1. **Plan one logical change** with explicit scope and files.
2. **Split into atomic subtasks** with clear done conditions.
3. **Choose verification mode** (behavior changes: test-first where practical; docs/schema/metadata changes: validation-first).
4. **Implement minimal change** for the current subtask.
5. **Run relevant local validators** for touched artifacts.
6. **Check repository consistency** (`plugins/` and `.claude-plugin/marketplace.json` alignment, frontmatter completeness, hook schema compatibility).
7. **Commit atomically** with a Conventional Commit message.
8. **Push and open PR**, then wait for online GitHub review and full CI pass in `.github/workflows/plugin-validation.yml`.
9. **Do not merge as agent**. Merge is manual and happens only after explicit reviewer/user approval.

### Atomic Commit Rules

- One commit should map to one logical objective.
- Keep coupled updates together when required for consistency (for example validator logic + matching documentation).
- Do not batch unrelated roadmap/plugin tasks in one commit.
- Allowed commit types: `feat`, `fix`, `docs`, `refactor`, `chore`, `plugin`, `update`.

### Validation Baseline

Run what applies to your change:

- `jq empty .claude-plugin/marketplace.json`
- `jq empty plugins/<name>/.claude-plugin/plugin.json`
- `bash plugins/plugin-dev/skills/hook-development/scripts/validate-hook-schema.sh <hooks.json>`
- `bash plugins/plugin-dev/skills/hook-development/scripts/hook-linter.sh <script.sh>`
- `bash plugins/plugin-dev/skills/agent-development/scripts/validate-agent.sh <agent.md>`
- `bash plugins/plugin-dev/skills/plugin-settings/scripts/parse-frontmatter.sh <file> <field>`
- `shellcheck <script.sh>`
- `markdownlint-cli2 <changed-docs>`

### Mandatory Cross-Doc Read Order (Agents)

Before implementation and before any commit/PR operation, agents must read and follow:

1. `AGENTS.md`
2. `.github/copilot-instructions.md`
3. `CLAUDE.md`
4. This document (`docs/PLUGIN_GUIDELINES.md`)
5. Roadmap workflow details when applicable (`.ideas/plugin-dev-roadmap.md`)

## Versioning Guidance

- Start new plugins at `0.1.0`
- Increment:
  - Patch: content fixes and non-breaking improvements
  - Minor: new backward-compatible capabilities
  - Major: breaking changes
