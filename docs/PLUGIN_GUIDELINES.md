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

## Versioning Guidance

- Start new plugins at `0.1.0`
- Increment:
  - Patch: content fixes and non-breaking improvements
  - Minor: new backward-compatible capabilities
  - Major: breaking changes
