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

## Active Development: plugin-studio (Issues #1–#20)

The major in-progress effort is **plugin-studio** — a visual dashboard plugin
for creating and managing Claude Code plugins. It will live at
`plugins/plugin-studio/`. All 20 open issues in the repository track this work.

### Milestones

| Milestone | Issues | Scope |
|-----------|--------|-------|
| **v0.1 — Core Dashboard MVP** | #1–#11, #20 | Plugin scaffold, Node.js server, REST APIs (filesystem + validation), 4-panel layout (tree, editor, preview, validation), integration tests, README |
| **v0.2 — AI Chat (Claude CLI)** | #12–#14 | AI routes with Claude CLI provider, chat sidebar panel, tree context menu (rename/delete/duplicate) |
| **v0.3 — Scaffold & Create** | #15–#17 | New Plugin wizard (5 steps), scaffold routes + templates, frontmatter form editor with bidirectional sync |
| **v0.4 — Multi-Provider AI** | #18–#19 | Provider abstraction layer (Claude API, Claude CLI, Ollama, OpenAI-compat, CLI OAuth providers), settings UI |

### Tech Stack (plugin-studio only)

- **Package manager**: pnpm (not npm)
- **Runtime**: Node.js 18+
- **Server**: `plugins/plugin-studio/server/` — Express or Fastify, TypeScript in strict mode, tsx for dev execution
- **Frontend**: `plugins/plugin-studio/app/` — Vite + React + Tailwind CSS
- **Editor**: Monaco Editor (async lazy-loaded, ~2MB bundle)
- **Testing**: Vitest for both frontend and backend, Playwright for E2E
- **Distribution**: `app/dist/` is **pre-built by CI and committed** — users never run a build step; `scripts/start.sh` just runs `node server/index.js`

### Architecture

```text
plugins/plugin-studio/
├── .claude-plugin/plugin.json   # Plugin manifest
├── commands/
│   ├── open.md                  # /plugin-studio:open [path]
│   └── settings.md              # /plugin-studio:settings
├── skills/plugin-anatomy/SKILL.md
├── hooks/hooks.json             # SessionStart: check if server is running
├── server/                      # Node.js backend (TypeScript)
│   └── index.js                 # Entry point — serves app/dist/ + REST API
├── app/                         # React frontend (Vite + Tailwind)
│   └── dist/                    # Pre-built — committed in release tags
├── scripts/
│   ├── start.sh                 # Production: just `node server/index.js`
│   └── dev.sh                   # Development: Vite dev server + tsx hot-reload
└── README.md
```

**REST API endpoints** (defined across issues #3, #4, #12, #16):

- `GET/PUT/POST/DELETE /api/fs/*` — filesystem CRUD (tree, file read/write/rename/duplicate)
- `POST /api/validate/*` — bridge to plugin-dev validation scripts
- `GET/POST /api/ai/*` — AI completion/suggestion (Claude CLI → multi-provider in v0.4)
- `POST /api/scaffold/*` — create plugins/components from templates

### Issue Dependency Chain

```text
#1 (scaffold) → #2 (server) → #3 (fs API) ──→ #6 (tree) → #14 (context menu) → #15 (wizard)
                             → #4 (validate) → #9 (validation panel)
                             → #5 (layout) ──→ #7 (editor) → #8 (preview) → #17 (frontmatter form)
                                             → #20 (README)
                             → #10 (open cmd)
#3, #4, #10 → #11 (integration tests)
#4 → #12 (AI routes) → #13 (chat panel)
                      → #18 (providers) → #19 (settings UI)
#4 → #16 (scaffold routes) → #15 (wizard)
```

### Security Requirements (plugin-studio)

These are explicitly mandated in the issues and **must** be followed:

- **Path traversal prevention** (#3): Filesystem API must never serve files
  outside the plugin root directory — return 403 on any traversal attempt.
  Sanitise all paths; support both `/` and `\` (WSL + Windows).
- **Prompt injection mitigation** (#12): The AI CLI bridge runs
  `claude -p "<prompt>"` where content may include user-controlled file data.
  **Never** interpolate file content directly into shell arguments — pass
  context via **stdin** (pipe) or a **temp file**. Escape all arguments with
  `shell-quote` or equivalent.
- **API key storage** (#19): Keys go in `.plugin-studio.config.json` outside
  the plugin directory, **never committed**. Auto-add to `.gitignore`.
- **Timeouts**: 10 s on filesystem ops, 30 s on validation calls, 60 s on
  AI completions.

### plugin-studio Development Notes

- The `open` command (#10) must do a **pre-flight check**: verify Node.js ≥ 18
  (hard error if absent), detect plugin-dev (soft warning if absent), auto-resolve
  stale PID port locks, and open the browser cross-platform (WSL/macOS/Linux).
- Auto-save with 500 ms debounce; Ctrl+S for immediate save.
- Monaco lazy-loaded asynchronously — must not block initial page render.
- Validation auto-runs on plugin open and on each save.
- All new plugins created via the wizard must pass plugin-dev validation
  with zero warnings.

## Key References

- `CONTRIBUTING.md` — Contribution process and plugin checklist
- `docs/PLUGIN_GUIDELINES.md` — Plugin quality bar and required structure
- `docs/RELEASE_CHECKLIST.md` — Pre-release validation steps
- `SECURITY.md` — Vulnerability reporting process
- `CODE_OF_CONDUCT.md` — Community standards
- `ROADMAP.md` — Mid-term project priorities
