# Validation Sources

The `plugin-studio` validation engine is native to this plugin and evolves independently.

Its first implementation was adapted from the validation semantics and checks documented in:

- `plugins/plugin-dev/skills/hook-development/scripts/validate-hook-schema.sh`
- `plugins/plugin-dev/skills/agent-development/scripts/validate-agent.sh`
- `plugins/plugin-dev/skills/hook-development/scripts/hook-linter.sh`
- `plugins/plugin-dev/README.md`
- `plugins/plugin-dev/agents/plugin-validator.md`

Why the logic was reimplemented here instead of consumed as an external dependency:

- `plugin-studio` must be installable and usable without `plugin-dev`
- the backend needs stable, structured output for the UI
- line and column data must be derived in-process where possible
- known limitations in the original scripts need to be encapsulated locally

This file exists to preserve provenance and make future evolution explicit.
