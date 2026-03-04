# GitHub Copilot — Repository Onboarding Guide

> **One read, zero searches.** This guide enables any LLM coding agent to contribute
> to this repository confidently from first encounter.

---

## 1. Project Intent

Personal marketplace of production-grade **Claude Code plugins** — reusable commands,
skills, agents, and hooks packaged as self-contained plugin directories under `plugins/`.
The repository solves the "scattered prompt files" problem: every plugin follows a shared
quality bar, gets validated in CI, and is discoverable via a root marketplace manifest.

**Typical task types**: add a plugin, extend an existing plugin, fix validation failures,
update documentation, scaffold components (commands/skills/agents/hooks).

**Stake**: Breaking the CI pipeline (`plugin-validation.yml`) blocks the entire release
workflow. Breaking `marketplace.json` sync makes plugins undiscoverable in Claude Code.

---

## 2. Critical Rules

### MUST

- **MUST keep `.claude-plugin/marketplace.json` in sync** with every directory under
  `plugins/` (excluding `plugin-dev`). CI fails hard if they diverge.
  - Rationale: marketplace.json is the discovery index Claude Code users rely on.
  - Violation: `Plugin 'X' in plugins/ but NOT in marketplace.json` → CI exit 1.

- **MUST validate all JSON files with `jq empty <file>`** before committing.
  - Applies to: `marketplace.json`, `plugin.json`, `hooks.json`.
  - Violation: silently corrupt manifests that break Claude Code plugin loading.

- **MUST include required frontmatter in every command and skill file**:
  - Command `.md` files → `description:` field mandatory.
  - `SKILL.md` files → `name:` AND `description:` fields mandatory.
  - Violation: CI step "Validate command/skill frontmatter" exits 1.

- **MUST use `${CLAUDE_PLUGIN_ROOT}` instead of absolute paths** in `hooks.json`
  command strings.
  - Rationale: plugins are installed in different directories per user; hardcoded
    paths break portability.

- **MUST use `var=$((var + 1))`** (not `((var++))`) in bash scripts that use `set -e`.
  - Rationale: `((var++))` returns 0 (falsy) when `var=0` → `set -e` exits immediately.
  - Applies to all `.sh` scripts, especially validators under `plugin-dev/skills/`.

- **MUST use Conventional Commits** format for all commits:
  `feat(scope): …`, `fix(scope): …`, `docs(scope): …`, `chore(scope): …`.

### NEVER

- **NEVER add `plugin-dev` to `marketplace.json`** — it is the dev toolkit, not a
  plugin. CI explicitly excludes it from sync checks.
  - Why: `plugin-dev` contains validators/scaffolders used by CI; treating it as a
    marketplace plugin would expose internal tooling to end users.

- **NEVER use `type: prompt`** in `hooks.json` for events other than
  `Stop`, `SubagentStop`, `UserPromptSubmit`, `PreToolUse`.
  - Why: validator warns on unsupported events; Claude Code may silently ignore them.

- **NEVER hardcode absolute paths** in hook scripts or command prompts.

- **NEVER skip markdownlint** on plugin README, commands, skills, and agent files.
  - Exception: `plugins/plugin-dev/**` is explicitly excluded from markdownlint in CI.

### SHOULD

- **SHOULD run local validation** (see Section 5) before pushing — CI mirrors it exactly.
- **SHOULD keep plugin components at plugin root level** (`commands/`, `skills/`,
  `agents/`, `hooks/`) — never nested inside `.claude-plugin/`.
- **SHOULD start new plugin versions at `0.1.0`**; follow semver for increments.

---

## 3. Repository Structure

```
.
├── .claude-plugin/
│   └── marketplace.json          # ⚠️ Root index — must stay in sync with plugins/
├── .github/
│   ├── ISSUE_TEMPLATE/           # Bug/feature issue templates
│   ├── workflows/
│   │   ├── plugin-validation.yml # 🔑 Primary CI — validates all plugins
│   │   ├── release.yml           # release-please automation
│   │   ├── docs-sync.yml         # Auto-syncs README plugin table
│   │   ├── housekeeping.yml      # Stale issues, dependabot config
│   │   ├── ai-review.yml         # AI-assisted PR review
│   │   └── security.yml          # OpenSSF / security scanning
│   └── PULL_REQUEST_TEMPLATE.md
├── .ideas/                       # Ideation & blueprints (not code)
├── docs/
│   ├── PLUGIN_GUIDELINES.md      # Quality bar for all plugins
│   └── RELEASE_CHECKLIST.md      # Pre-release checklist
├── memory/                       # Session memory for agent context
│   ├── context/repo.md           # Repo-level context notes
│   └── projects/                 # Per-project memory files
├── plugins/
│   ├── plugin-dev/               # 🔧 Dev toolkit (NOT a marketplace plugin)
│   │   ├── commands/             # Scaffolding commands (create-plugin.md)
│   │   └── skills/               # Validator scripts + dev skills
│   │       ├── hook-development/ # validate-hook-schema.sh, hook-linter.sh
│   │       ├── agent-development/# validate-agent.sh
│   │       ├── plugin-settings/  # parse-frontmatter.sh
│   │       └── plugin-structure/ # Plugin layout guidance
│   ├── plugin-studio/            # 🚧 Active development — Node.js server + React UI
│   │   ├── app/                  # Vite/React frontend (app/dist/ pre-built)
│   │   ├── server/               # Node.js HTTP server (no external deps)
│   │   │   ├── index.js          # Entry point; stores PID in server/.pid
│   │   │   └── api/fs.js         # Filesystem REST API
│   │   ├── hooks/hooks.json      # SessionStart → check-server.sh
│   │   └── scripts/check-server.sh
│   ├── strategy-toolkit/         # Stable — strategic planning commands/skills
│   ├── product-management/       # Stable — PM workflow commands/skills
│   ├── productivity/             # Stable — task management + dashboard
│   ├── productivity-cockpit/     # Stable — cockpit dashboard + AI chatbot
│   ├── repo-structure/           # Stable — repo analyzer/validator/scaffolder
│   └── solution-audit/           # Active — continuous meta-quality audit
├── scripts/
│   └── sync-docs.py              # Syncs plugin inventory + README table (CI only)
├── .markdownlint.json            # Markdownlint config (MD013, MD033, MD041 off)
├── .markdownlintrc               # Same config (both files present, identical)
├── release-please-config.json    # Automated release configuration
└── version.txt                   # Current version (managed by release-please)
```

**Key paths for common tasks**:

| Task | Path |
|------|------|
| Add a new plugin | `plugins/<name>/` + update `.claude-plugin/marketplace.json` |
| Add a command | `plugins/<name>/commands/<name>.md` |
| Add a skill | `plugins/<name>/skills/<skill-name>/SKILL.md` |
| Add an agent | `plugins/<name>/agents/<name>.md` |
| Add hooks | `plugins/<name>/hooks/hooks.json` |
| Plugin manifest | `plugins/<name>/.claude-plugin/plugin.json` |
| Validate hooks | `plugins/plugin-dev/skills/hook-development/scripts/validate-hook-schema.sh` |
| Validate agents | `plugins/plugin-dev/skills/agent-development/scripts/validate-agent.sh` |
| Parse frontmatter | `plugins/plugin-dev/skills/plugin-settings/scripts/parse-frontmatter.sh` |

---

## 4. Development Workflow

1. **BRANCH** from `main` using convention: `feat/<topic>`, `fix/<topic>`,
   `docs/<topic>`, `chore/<topic>`

2. **PLAN** — read `docs/PLUGIN_GUIDELINES.md`; check `TASKS.md` for active work;
   review `memory/context/repo.md` for context.

3. **IMPLEMENT** — follow plugin structure (see Section 6). Use `plugin-dev` skills
   as reference: load `plugin-structure` skill for layout, `hook-development` for
   hooks, `agent-development` for agents.

4. **VALIDATE LOCALLY** — run all checks from Section 5 before pushing.

5. **UPDATE MANIFEST** — if adding/removing a plugin, update `.claude-plugin/marketplace.json`.

6. **COMMIT** using Conventional Commits:
   - `feat(plugin-name): add X command`
   - `fix(plugin-name): correct frontmatter in skill Y`
   - `docs(repo): update plugin guidelines`
   - `chore(deps): bump actions/checkout`

7. **OPEN PR** — fill PR template (purpose, files changed, validation notes).
   release-please creates release PRs automatically after merging.

**Branching strategy**: trunk-based — all work targets `main` via short-lived feature
branches. No long-lived develop/staging branches.

---

## 5. Build, Test & Validation

> This is a documentation/configuration repository. There is no build step at root level.
> All validation runs through CI scripts.

### Local Validation (mirrors CI exactly)

**Prerequisites**: `jq`, `shellcheck`, `markdownlint-cli2` installed.

```bash
# Install tools (Ubuntu/Debian)
sudo apt-get install jq shellcheck
npm install -g markdownlint-cli2

# macOS
brew install jq shellcheck
npm install -g markdownlint-cli2
```

| Command | Purpose | Common Error | Recovery |
|---------|---------|--------------|----------|
| `jq empty .claude-plugin/marketplace.json` | Validate root manifest JSON | Parse error at line N | Fix JSON syntax, check trailing commas |
| `jq empty plugins/<name>/.claude-plugin/plugin.json` | Validate plugin manifest | Same | Same |
| `jq empty plugins/<name>/hooks/hooks.json` | Validate hooks JSON | Same | Same |
| `bash plugins/plugin-dev/skills/hook-development/scripts/validate-hook-schema.sh plugins/<name>/hooks/hooks.json` | Validate hooks schema | `❌ Missing required field` | Add missing field per schema |
| `bash plugins/plugin-dev/skills/agent-development/scripts/validate-agent.sh plugins/<name>/agents/<name>.md` | Validate agent frontmatter | `❌` in output | Fix agent MD frontmatter |
| `shellcheck plugins/<name>/hooks/scripts/*.sh` | Lint hook shell scripts | SC2xxx warning | Follow shellcheck suggestion |
| `markdownlint-cli2 "plugins/<name>/**/README.md" "plugins/<name>/commands/**/*.md"` | Lint markdown | MD0xx violations | Fix per rule (most disabled, see `.markdownlint.json`) |

### Marketplace Sync Check

```bash
# Check plugins/ dirs vs marketplace.json entries
diff \
  <(find plugins -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | grep -v '^plugin-dev$' | sort) \
  <(jq -r '.plugins[].name' .claude-plugin/marketplace.json | sort)
```

No output = in sync. Any diff = CI will fail.

### Plugin-Studio (Node.js server, pnpm)

```bash
cd plugins/plugin-studio/server
node index.js          # Starts server; default port 3847 (auto-increments if busy)
# PLUGIN_STUDIO_SERVER_PORT env var overrides default port
# PID stored in server/.pid; delete stale file if server refuses to start
```

### CI Pipeline (`plugin-validation.yml`)

Runs on every push/PR to `main`. Steps in order:

| Step | Tool | What it checks |
|------|------|----------------|
| Required root files | bash | README.md, LICENSE, CONTRIBUTING.md, CODE_OF_CONDUCT.md, SECURITY.md, CHANGELOG.md, ROADMAP.md |
| JSON manifests | `jq empty` | marketplace.json + all plugin.json |
| Plugin README presence | bash | Every `plugins/<name>/` (excl. plugin-dev) has README.md |
| marketplace.json sync | bash | All plugin dirs listed; no orphan entries |
| hooks.json schema | validate-hook-schema.sh | Required fields, valid types, timeouts |
| Hook scripts lint | hook-linter.sh | Bash syntax + shellcheck |
| Agent files | validate-agent.sh | Agent MD frontmatter (❌ errors only; warnings suppressed) |
| Command frontmatter | parse-frontmatter.sh | `description:` present in all commands/*.md |
| Skill frontmatter | parse-frontmatter.sh | `name:` AND `description:` in all SKILL.md |
| shellcheck | shellcheck | All *.sh outside plugin-dev and examples |
| markdownlint | markdownlint-cli2 | READMEs, commands, skills, agents (excl. plugin-dev) |

---

## 6. Architecture & Key Components

### Component: Root Marketplace Manifest

- **Location:** `.claude-plugin/marketplace.json`
- **Responsibility:** Discovery index — lists all plugins with name, version, description,
  author, source path, and category. Used by Claude Code to find installable plugins.
- **Key Files:** `.claude-plugin/marketplace.json` (single file)
- **Constraints:** Must be valid JSON; must include every `plugins/<name>` dir (excl.
  `plugin-dev`); source paths must be relative (`./plugins/<name>`).
- **Common Changes:** Add/update entry when adding/versioning a plugin.

### Component: Plugin Dev Toolkit (`plugin-dev`)

- **Location:** `plugins/plugin-dev/`
- **Responsibility:** Internal CI tooling and development scaffolding — NOT a marketplace
  plugin. Contains all validator scripts used by CI and skills for plugin authoring.
- **Key Files:**
  - `skills/hook-development/scripts/validate-hook-schema.sh` — hooks.json validator
  - `skills/hook-development/scripts/hook-linter.sh` — hook script linter
  - `skills/agent-development/scripts/validate-agent.sh` — agent MD validator
  - `skills/plugin-settings/scripts/parse-frontmatter.sh` — YAML frontmatter parser
  - `commands/create-plugin.md` — guided plugin creation command
- **Constraints:** Never appears in marketplace.json. Excluded from markdownlint CI.
- **Common Changes:** Update validators when plugin schema evolves.

### Component: Plugin Manifest (`plugin.json`)

- **Location:** `plugins/<name>/.claude-plugin/plugin.json`
- **Responsibility:** Plugin identity and metadata for Claude Code.
- **Required Fields:** `name`, `version`, `description`, `author.name`, `author.email`
- **Constraints:** Valid JSON; version must follow semver; start new plugins at `0.1.0`.
- **Common Changes:** Version bump on release; description updates.

### Component: Hooks Configuration (`hooks.json`)

- **Location:** `plugins/<name>/hooks/hooks.json`
- **Responsibility:** Defines Claude Code event hooks (PreToolUse, Stop, SessionStart, etc.)
  that trigger commands or prompts automatically.
- **Constraints:**
  - `type: command` → `command` field is a **string scalar** (not object)
  - `type: prompt` → only for Stop, SubagentStop, UserPromptSubmit, PreToolUse
  - Use `${CLAUDE_PLUGIN_ROOT}` for all paths
  - Timeout: integer seconds; typical range 5–30
- **Common Changes:** Add new event hooks; update script paths.

### Component: Plugin Studio Server

- **Location:** `plugins/plugin-studio/server/`
- **Responsibility:** Node.js HTTP server (no external runtime deps) serving the
  React/Vite dashboard (`app/dist/`) and a filesystem REST API (`api/fs.js`).
- **Key Files:** `server/index.js` (entry), `server/api/fs.js` (FS routes),
  `server/.pid` (instance detection)
- **Constraints:** Default port 3847 (auto-increments up to +10 if busy). PID file
  must be cleaned up on stop. FS API must block path traversal (403 on `../`).
  AI CLI bridge must never interpolate user content in shell args.
- **Common Changes:** Active development — new API endpoints, frontend features.

---

## 7. Known Gotchas

❌ **Trap: `plugin-dev` included in marketplace.json**

- Symptom: CI passes locally but `marketplace.json sync` step fails → `Plugin 'X' in
  marketplace.json but directory missing` (or reverse).
- Root Cause: `plugin-dev` is the toolkit, not a product. It is hardcoded to be
  excluded in the CI sync check.
- Fix: Remove `plugin-dev` from `.plugins[]` in marketplace.json.
- Preventive: Never add `plugin-dev` to marketplace.json.

❌ **Trap: `((var++))` with `set -e` exits on first increment**

- Symptom: Bash script silently exits after first warning/error count increment when
  counter starts at 0.
- Root Cause: `((var++))` returns old value (0) which is falsy → `set -e` treats as
  failure.
- Fix: Replace `((var++))` with `var=$((var + 1))`.
- Preventive: Use arithmetic expansion form in all scripts with `set -e`.

❌ **Trap: Stale `server/.pid` file blocks Plugin Studio**

- Symptom: `check-server.sh` reports server is running but nothing responds on port
  3847; or server refuses to start.
- Root Cause: Previous server crashed without cleaning up `server/.pid`.
- Fix: `rm plugins/plugin-studio/server/.pid` then restart.
- Preventive: SessionStart hook (`check-server.sh`) detects stale PID and auto-deletes it.

❌ **Trap: Missing frontmatter breaks CI silently in local tests**

- Symptom: `markdownlint` passes locally but "Validate command/skill frontmatter" fails
  in CI with `❌ Missing 'description' frontmatter`.
- Root Cause: markdownlint does not check YAML frontmatter; frontmatter validation is
  a separate `parse-frontmatter.sh` step.
- Fix: Add `description:` to command `.md` files; add `name:` AND `description:` to
  every `SKILL.md`.
- Preventive: Run `parse-frontmatter.sh` locally before pushing.

❌ **Trap: `type: prompt` on SessionStart raises validator warning**

- Symptom: hooks.json validator warns about unsupported event+type combination.
- Root Cause: `type: prompt` is valid only for Stop/SubagentStop/UserPromptSubmit/
  PreToolUse. SessionStart only supports `type: command`.
- Fix: Change SessionStart hooks to `type: command`.
- Preventive: Check event/type combination before writing hooks.json.

❌ **Trap: Agent validator exits on first warning (not just errors)**

- Symptom: CI "Validate agent files" step exits non-zero even when only warnings are
  present (no ❌ errors).
- Root Cause: `validate-agent.sh` uses `((warning_count++))` with `set -e` internally
  (known bug). CI workaround captures output and checks for `❌` string only.
- Fix: Do not rely on exit code of `validate-agent.sh`; check for `❌` in output.
- Preventive: The CI wrapper already handles this; do not change the grep pattern.

❌ **Trap: Absolute paths in `hooks.json` break portability**

- Symptom: Hooks fail silently on other machines or after plugin reinstall.
- Root Cause: Plugin install path varies per user and machine.
- Fix: Replace absolute paths with `${CLAUDE_PLUGIN_ROOT}/scripts/...`.
- Preventive: Always use `${CLAUDE_PLUGIN_ROOT}` as path prefix in hook commands.

---

## 8. Troubleshooting & Recovery

### Scenario: CI "marketplace.json sync" fails

**Symptom:** `Plugin 'my-plugin' in plugins/ but NOT in marketplace.json`

**Diagnosis:**
1. `jq -r '.plugins[].name' .claude-plugin/marketplace.json | sort` — list registered plugins
2. `find plugins -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | grep -v plugin-dev | sort` — list actual dirs

**Recovery:**
- Add missing entry to `.plugins[]` in `marketplace.json` with correct `name`, `version`,
  `description`, `author`, `source` (`./plugins/<name>`), and `category`.
- Or remove the orphan directory if it was accidentally created.

**Prevention:** Always update `marketplace.json` immediately after creating `plugins/<name>/`.

---

### Scenario: CI "Validate hooks.json" fails

**Symptom:** `❌ Missing required field: type` or `❌ Invalid hook type`

**Diagnosis:**
1. `jq . plugins/<name>/hooks/hooks.json` — check structure
2. `bash plugins/plugin-dev/skills/hook-development/scripts/validate-hook-schema.sh plugins/<name>/hooks/hooks.json`

**Recovery:**
- For `type: command` hooks: ensure `command` is a string scalar (not object).
- For `type: prompt` hooks: only use on Stop, SubagentStop, UserPromptSubmit, PreToolUse.
- Add missing `timeout` (integer) and `description` fields.

**Prevention:** Run validator locally after every `hooks.json` change.

---

### Scenario: markdownlint fails on plugin markdown

**Symptom:** `MD0xx/rule-name: …` errors in CI

**Diagnosis:**
1. `markdownlint-cli2 "plugins/<name>/**/README.md"` — run locally
2. Check `.markdownlint.json` — many rules disabled (MD013, MD033, MD041, etc.)

**Recovery:**
- Fix the specific violation. Most common: heading levels, code fence language tags,
  bare URLs, duplicate headings.
- If rule is appropriate to disable globally, add it to `.markdownlint.json` and
  `.markdownlintrc` (both files must be kept identical).

**Prevention:** Run markdownlint locally before pushing; note that `plugins/plugin-dev/**`
is explicitly excluded — do not add it to CI lint scope.

---

### Scenario: Plugin Studio server won't start

**Symptom:** Port conflict or PID file error

**Diagnosis:**
1. `cat plugins/plugin-studio/server/.pid` — check if PID exists
2. `kill -0 <PID>` — check if process is actually alive

**Recovery:**
- If PID is stale: `rm plugins/plugin-studio/server/.pid`
- If port 3847 is genuinely in use: set `PLUGIN_STUDIO_SERVER_PORT=<other>` env var
- Server auto-increments port up to +10 from base port before failing

**Prevention:** Ensure clean shutdown via `kill $(cat server/.pid)` rather than force-killing.
