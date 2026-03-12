# CHANGELOG — plugin-dev

This file tracks all notable changes made in this fork relative to the upstream source.

Upstream: [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official)
Fork maintained by: Nuno Salvação

---

## [1.0.0] — 2026-03-12

### Added

- Registered `plugin-dev` as a marketplace plugin in `.claude-plugin/marketplace.json` (v1.0.0).
- `plugin-validation.yml` CI now includes `plugin-dev` in README and marketplace sync checks.

### Fixed

- `validate-hook-schema.sh`: arithmetic bug replaced (`((n++))` → `n=$((n+1))`) — prevents
  premature exit under `set -e` when the counter starts at 0.
- `validate-hook-schema.sh`: added wrapper format detection and unwrap support — the canonical
  `{"hooks":{...}}` wrapper format is now accepted and validated correctly.
- `hooks/hooks.json` in all 6 plugins: migrated from direct format to wrapper format
  (`{"hooks":{"EventName":[...]}}`) as required by the Claude Code runtime.
- `hook-development/SKILL.md`: corrected canonical `hooks.json` format documentation from
  direct format to wrapper format throughout.
- `hook-development/references/migration.md`: updated all hook configuration examples to use
  the correct wrapper format.

---

## [Upstream Baseline]

Content inherited from `anthropics/claude-plugins-official` at fork point (2026-03-12):

- 7 skills: `hook-development`, `mcp-integration`, `plugin-structure`, `plugin-settings`,
  `command-development`, `agent-development`, `skill-development`
- 3 agents: `agent-creator`, `plugin-validator`, `skill-reviewer`
- 1 command: `create-plugin`
- Validation scripts: `validate-hook-schema.sh`, `validate-agent.sh`, `validate-settings.sh`,
  `parse-frontmatter.sh`, `test-hook.sh`, `hook-linter.sh`
