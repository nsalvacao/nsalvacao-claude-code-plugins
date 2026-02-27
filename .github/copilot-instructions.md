# Copilot Coding Agent Instructions

## Repository Overview

This repository is a **Claude Code plugin portfolio** — a structured collection of
production-grade plugins for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).
It contains 6 plugins under `plugins/`, a root marketplace manifest, automated CI
validation, AI-powered PR reviews, and docs-sync automation.

There is **no traditional build system** (no `npm`, `pip install`, `make`, etc.).
The codebase is primarily **Markdown, JSON, YAML, Bash, and Python**. Validation
is done via CI workflows and shell scripts.

## Repository Structure

```text
.
├── .claude-plugin/          # Root marketplace manifest
│   └── marketplace.json     # Lists all publishable plugins
├── .github/
│   ├── workflows/           # CI/CD workflows (validation, release, docs sync, etc.)
│   ├── ISSUE_TEMPLATE/      # Bug report and feature request forms
│   └── PULL_REQUEST_TEMPLATE.md
├── docs/
│   ├── PLUGIN_GUIDELINES.md # Quality bar and required plugin structure
│   ├── RELEASE_CHECKLIST.md # Pre-release validation checklist
│   └── plugins-inventory.md # Auto-generated plugin inventory (do NOT edit manually)
├── plugins/
│   ├── plugin-dev/          # Dev toolkit (validators, linters, scaffolding — NOT a marketplace plugin)
│   ├── strategy-toolkit/    # Strategic ideation plugin
│   ├── repo-structure/      # Repository structure analyzer/validator
│   ├── product-management/  # Product management workflow plugin
│   ├── productivity/        # Task/memory management plugin
│   └── productivity-cockpit/# Productivity dashboard with web UI
├── scripts/
│   └── sync-docs.py         # Auto-generates README table and plugins-inventory.md
├── CONTRIBUTING.md           # Contribution guide and plugin checklist
├── release-please-config.json
└── .release-please-manifest.json
```

## Plugin Architecture

Each plugin lives under `plugins/<plugin-name>/` and must contain:

- `.claude-plugin/plugin.json` — manifest with `name`, `version`, `description`, `author`
- `README.md` — problem statement, components, install instructions, usage examples

Plugins contain one or more of:

- **Commands** (`commands/*.md`): YAML frontmatter (`description` required) + Markdown body
- **Skills** (`skills/*/SKILL.md`): YAML frontmatter (`name`, `description` required) + Markdown body
- **Agents** (`agents/*.md`): YAML frontmatter (`name`, `description`, `model`, `color`) + system prompt body
- **Hooks** (`hooks/hooks.json`): JSON with event handlers (`PreToolUse`, `PostToolUse`, etc.)
- **MCP** (`mcp-template.json`): MCP server configuration template

**Important:** `plugins/plugin-dev/` is a development toolkit, **not** a marketplace
plugin. It provides validation scripts, linters, and scaffolding used by CI and
other plugins. It is excluded from marketplace sync checks.

## Validation and Testing

### CI Workflows

- **Plugin Validation** (`plugin-validation.yml`): push/PR to `main` — validates JSON, READMEs, manifests, hooks, agents, frontmatter, shellcheck, markdownlint
- **Release** (`release.yml`): push to `main` — creates release PRs via release-please
- **Docs Sync** (`docs-sync.yml`): push to `main` (plugin/manifest changes) — auto-updates README table and `docs/plugins-inventory.md`
- **AI Review** (`ai-review.yml`): PR to `main` (plugin changes) — AI-powered plugin review via GitHub Models
- **Security** (`security.yml`): push to `main` / weekly — OpenSSF Scorecard + CodeQL (Python)
- **Housekeeping** (`housekeeping.yml`): daily — closes stale issues and PRs

### Running Validation Locally

There is no single `test` or `build` command. To validate locally:

```bash
# Validate all JSON manifests
jq empty .claude-plugin/marketplace.json
find plugins -type f -path "*/.claude-plugin/plugin.json" -exec jq empty {} \;

# Validate hooks.json files
bash plugins/plugin-dev/skills/hook-development/scripts/validate-hook-schema.sh \
  plugins/repo-structure/hooks/hooks.json

# Validate agent files
bash plugins/plugin-dev/skills/agent-development/scripts/validate-agent.sh \
  plugins/repo-structure/agents/structure-architect.md

# Validate command/skill frontmatter
bash plugins/plugin-dev/skills/plugin-settings/scripts/parse-frontmatter.sh \
  plugins/strategy-toolkit/commands/brainstorm.md description

# Shellcheck custom scripts (exclude plugin-dev and examples)
find plugins -name "*.sh" ! -path "*/plugin-dev/*" ! -path "*/examples/*" \
  -exec shellcheck {} \;

# Markdown lint (requires markdownlint-cli2)
# npm install -g markdownlint-cli2
markdownlint-cli2 "plugins/**/README.md" "plugins/**/commands/**/*.md" \
  "plugins/**/skills/**/SKILL.md" "plugins/**/agents/*.md" \
  "#plugins/plugin-dev/**"
```

### Known CI Issue

The **Plugin Validation** workflow on `main` currently fails at the
"Validate hooks.json (plugin-dev)" step. Root cause: in
`plugins/plugin-dev/skills/hook-development/scripts/validate-hook-schema.sh`,
the `((warning_count++))` expression evaluates to 0 (falsy) when
`warning_count` is initially 0, which under `set -euo pipefail` causes
the script to exit with code 1 even though the finding is only a warning.

**Workaround:** If you need to modify `validate-hook-schema.sh`, replace
`((warning_count++))` with `warning_count=$((warning_count + 1))` (and
similarly for `error_count`). The same applies to any new bash scripts
using arithmetic increment under `set -e`.

## Conventions

### File Formatting

- UTF-8 encoding, LF line endings (enforced via `.gitattributes`)
- 2-space indent for Markdown, JSON, YAML (see `.editorconfig`)
- Final newline in all files
- Markdown linting rules in `.markdownlintrc` (MD013/line-length disabled, HTML allowed)

### Naming

- Plugin directories: `kebab-case` (e.g., `strategy-toolkit`)
- Plugin names in manifests: `kebab-case`, no spaces, no uppercase
- Command files: `kebab-case.md` (e.g., `brainstorm.md`, `write-spec.md`)
- Skill directories: `kebab-case` (e.g., `strategic-analysis/`)
- Agent files: `kebab-case.md` (e.g., `structure-validator.md`)

### Commit Messages

Follow **Conventional Commits**:

```text
feat(scope): add plugin onboarding command
fix(strategy-toolkit): improve risk register guidance
docs(repo): update release checklist
chore(ci): update validation workflow
```

### Branch Naming

```text
feat/<short-topic>
fix/<short-topic>
docs/<short-topic>
chore/<short-topic>
```

## Common Tasks

### Adding a New Plugin

1. Create `plugins/<plugin-name>/` directory
2. Add `.claude-plugin/plugin.json` manifest (start at version `0.1.0`)
3. Add `README.md` with problem statement, components, install/usage docs
4. Add at least one component (`commands/`, `skills/`, `agents/`, hooks, or MCP)
5. Register the plugin in `.claude-plugin/marketplace.json`
6. Validate JSON files locally with `jq empty`
7. Verify `markdownlint-cli2` passes on new Markdown files
8. The `scripts/sync-docs.py` will auto-update `README.md` table and
   `docs/plugins-inventory.md` on merge to `main`

### Modifying an Existing Plugin

- Update the plugin's `plugin.json` version if the change is user-facing
- Ensure frontmatter is present and valid on all command/skill/agent files
- Run the relevant validation scripts locally before pushing
- Check that `.claude-plugin/marketplace.json` stays in sync

### Editing CI Workflows

- Workflows live in `.github/workflows/`
- The `plugin-validation.yml` is the primary gating check for PRs
- Be careful with `set -euo pipefail` in bash scripts — arithmetic
  expressions like `((var++))` can fail under `set -e` when `var` is 0

### Auto-Generated Files (Do Not Edit Manually)

- `docs/plugins-inventory.md` — generated by `scripts/sync-docs.py`
- The plugin table in `README.md` between `<!-- PLUGINS-TABLE-START -->` and
  `<!-- PLUGINS-TABLE-END -->` markers — also generated by `scripts/sync-docs.py`

## Key References

- `CONTRIBUTING.md` — Contribution process and plugin checklist
- `docs/PLUGIN_GUIDELINES.md` — Plugin quality bar and required structure
- `docs/RELEASE_CHECKLIST.md` — Pre-release validation steps
- `SECURITY.md` — Vulnerability reporting process
- `CODE_OF_CONDUCT.md` — Community standards
- `ROADMAP.md` — Mid-term project priorities
