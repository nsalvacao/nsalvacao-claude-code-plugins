# Copilot Instructions — nsalvacao-claude-code-plugins

> Complexity Mode: **complex** | Generated: 2026-03-04

---

## 1. Project Intent

Personal marketplace of Claude Code plugins: autonomous, self-contained components
installable by end users in Claude Code. Each plugin under `plugins/` is an independent
artifact (commands, agents, skills, hooks). `plugin-dev` is the **internal dev toolkit** —
it is NOT a marketplace plugin.

Contribution failures that block delivery: broken `marketplace.json` sync, invalid JSON
manifests, missing frontmatter, hook schema violations, markdownlint errors, shellcheck
failures in custom scripts.

---

## 2. Priority & Conflict Handling

1. Explicit session/task instruction (highest priority)
2. Path-scoped instructions (if present under `.github/copilot-instructions/`)
3. This file (repository-wide)
4. Personal/organization defaults (lowest priority)

Follow the most specific applicable rule.
If ambiguity remains, choose the safest minimal change and state assumptions.

---

## 3. Critical Rules (MUST / NEVER / SHOULD)

### MUST

- Every plugin directory under `plugins/` (except `plugin-dev`) MUST be listed in
  `.claude-plugin/marketplace.json` under `plugins[].name`.
- Every plugin MUST have `plugins/<name>/.claude-plugin/plugin.json` (valid JSON, `name` field in kebab-case).
- Every plugin MUST have `plugins/<name>/README.md`.
- Command files (`commands/*.md`) MUST contain YAML frontmatter with a non-empty `description` field.
- Skill files (`skills/*/SKILL.md`) MUST have frontmatter `name` and `description` fields.
- Agent files (`agents/*.md`) MUST have frontmatter: `name`, `description`, `model`, `color`.
- `hooks/hooks.json` MUST use only valid event names (see Section 5).
- Hook `command` field MUST be a plain string scalar (e.g., `"bash ${CLAUDE_PLUGIN_ROOT}/..."`).
- Commits MUST follow Conventional Commits: `feat|fix|docs|refactor|chore|plugin|update`.
- Counter increments in `set -e` bash scripts MUST use `var=$((var + 1))`, NOT `((var++))`.
- Hook scripts MUST use `${CLAUDE_PLUGIN_ROOT}` for portable paths.

### NEVER

- NEVER add `plugin-dev` to `marketplace.json` — it is the internal toolkit, excluded by CI.
- NEVER hardcode API keys, tokens, or passwords in any file.
- NEVER interpolate user-controlled content directly into shell arguments in hook scripts;
  use stdin or a tempfile.
- NEVER use `((var++))` under `set -e` when `var` may start at 0 — it exits with code 1.
- NEVER embed issue counts, sprint status, or transient plans in core plugin files.

### SHOULD

- Prefer `pnpm` over `npm` for Node.js operations in plugin-studio.
- Keep `SKILL.md` description ≥ 50 chars, third-person, with specific trigger phrases.
- Use HTTPS/WSS for MCP server URLs, not HTTP/WS.

### Emergency Recovery (3 Steps)

1. Re-run minimal local validation: `jq empty .claude-plugin/marketplace.json` +
   `validate-hook-schema.sh` on any changed hooks file.
2. Verify `marketplace.json` sync: every `plugins/<name>/` directory (except `plugin-dev`)
   appears as `plugins[].name` in `.claude-plugin/marketplace.json`.
3. If behavior is not locally reproducible, downgrade the affected command status to
   `[UNVERIFIED]` and reference the CI workflow as source of truth.

---

## 4. Repository Map (Where to Change What)

```
/
├── .claude-plugin/marketplace.json   ← MUST sync with plugins/ dirs (CI gate)
├── .github/workflows/
│   ├── plugin-validation.yml          ← Primary CI gate (all PRs/pushes)
│   ├── ai-review.yml                  ← AI quality review (needs MODELS_PAT secret)
│   ├── release.yml                    ← release-please automation
│   ├── docs-sync.yml                  ← Docs sync
│   ├── housekeeping.yml               ← Periodic maintenance
│   └── security.yml                   ← Security scanning
├── .markdownlint.json                 ← Markdownlint config (permissive; see rules)
├── release-please-config.json         ← Commit type → changelog section mapping
├── plugins/
│   ├── plugin-dev/                    ← INTERNAL TOOLKIT — not a marketplace plugin
│   │   └── skills/
│   │       ├── hook-development/scripts/  ← validate-hook-schema.sh, hook-linter.sh
│   │       ├── agent-development/scripts/ ← validate-agent.sh
│   │       └── plugin-settings/scripts/  ← parse-frontmatter.sh, validate-settings.sh
│   ├── <plugin-name>/
│   │   ├── .claude-plugin/plugin.json ← Manifest (MUST: `name` kebab-case, valid JSON)
│   │   ├── README.md                  ← Required (CI gate)
│   │   ├── commands/*.md              ← YAML frontmatter + `description` required
│   │   ├── agents/*.md                ← YAML frontmatter: name/description/model/color
│   │   ├── skills/<skill>/SKILL.md   ← YAML frontmatter: name/description required
│   │   └── hooks/hooks.json           ← Hook config (schema validated by plugin-dev)
└── docs/PLUGIN_GUIDELINES.md         ← Authoritative plugin authoring guidelines
```

**High-frequency change paths per task:**

| Task | Files to edit |
|---|---|
| New plugin | New `plugins/<name>/` dir + `marketplace.json` entry |
| New command | `plugins/<name>/commands/<cmd>.md` |
| New agent | `plugins/<name>/agents/<agent>.md` |
| New skill | `plugins/<name>/skills/<skill>/SKILL.md` |
| New hook | `plugins/<name>/hooks/hooks.json` + optional script in `hooks/scripts/` |
| Plugin manifest update | `plugins/<name>/.claude-plugin/plugin.json` |

---

## 5. Internal Tooling & Approved Workflow Systems

### A. `plugins/plugin-dev` — Internal Dev Toolkit

| Attribute | Value |
|---|---|
| Role | `internal toolkit` + `validation gatekeeper` |
| Controls | All validation logic called by CI |
| Breaks if ignored | CI uses these scripts directly; changes here affect ALL plugin validation |
| Path | `plugins/plugin-dev/skills/*/scripts/` |
| Validate compliance | Run the scripts locally against your changed files |

Key scripts and what they enforce:

| Script | Enforces |
|---|---|
| `hook-development/scripts/validate-hook-schema.sh` | `hooks.json` structure, valid events, hook types, command scalar |
| `hook-development/scripts/hook-linter.sh` | shellcheck + best practices on hook scripts |
| `agent-development/scripts/validate-agent.sh` | Agent frontmatter: name/description/model/color + system prompt |
| `plugin-settings/scripts/parse-frontmatter.sh` | Extract frontmatter values (used by CI command/skill checks) |
| `plugin-settings/scripts/validate-settings.sh` | Plugin settings validation |

Valid hook event names: `PreToolUse`, `PostToolUse`, `UserPromptSubmit`, `Stop`,
`SubagentStop`, `SessionStart`, `SessionEnd`, `PreCompact`, `Notification`.

Hook `type: prompt` triggers a warning unless the event is one of:
`Stop`, `SubagentStop`, `UserPromptSubmit`, `PreToolUse`.

### B. `plugin-validation.yml` — CI Validation Gatekeeper

| Attribute | Value |
|---|---|
| Role | `validation gatekeeper` + `workflow orchestrator` |
| Controls | Mergeability of all PRs touching `plugins/` or root files |
| Breaks if ignored | PR will fail CI; merge blocked |
| Path | `.github/workflows/plugin-validation.yml` |
| Validate compliance | All checks must pass locally before pushing |

Checks run (in order):
1. Required root files (README.md, LICENSE, CONTRIBUTING.md, CODE_OF_CONDUCT.md, SECURITY.md, CHANGELOG.md, ROADMAP.md)
2. JSON manifest validity (`jq empty`)
3. Plugin README presence
4. `marketplace.json` ↔ `plugins/` directory sync
5. `hooks.json` schema validation (via `validate-hook-schema.sh`)
6. Hook script linting (via `hook-linter.sh` + shellcheck)
7. Agent frontmatter validation (via `validate-agent.sh`)
8. Command frontmatter (`description` field via `parse-frontmatter.sh`)
9. SKILL.md frontmatter (`name` + `description` via `parse-frontmatter.sh`)
10. Shellcheck on custom scripts (excluding `plugin-dev/` and `examples/`)
11. Markdownlint (README, commands, skills, agents; excludes `plugin-dev/`)

### C. `ai-review.yml` — AI Quality Review

| Attribute | Value |
|---|---|
| Role | `workflow orchestrator` |
| Controls | Automated PR quality feedback on plugin files (non-blocking if secret missing) |
| Breaks if ignored | Review skipped if `MODELS_PAT` secret absent — never blocks merge |
| Path | `.github/workflows/ai-review.yml` |

### D. `release-please` — Release Automation

| Attribute | Value |
|---|---|
| Role | `workflow orchestrator` |
| Controls | Changelog generation (`CHANGELOG.md`) and version tags from Conventional Commits |
| Breaks if ignored | Non-conventional commits do not appear in changelog |
| Path | `release-please-config.json`, `.release-please-manifest.json` |
| How to validate | Commit type must match: `feat`, `fix`, `docs`, `refactor`, `chore`, `plugin`, `update` |

### E. `.markdownlint.json` — Markdown Style Gatekeeper

| Attribute | Value |
|---|---|
| Role | `validation gatekeeper` |
| Controls | Markdown lint rules for plugin docs (permissive ruleset, key exceptions listed) |
| Breaks if ignored | `markdownlint-cli2` CI step fails |
| Path | `.markdownlint.json` |
| Scope | Plugin READMEs, commands, skills, agents — NOT `plugin-dev/` |

---

## 6. Build, Test, Lint & CI Validation

No build step. Validation is entirely CI-driven via bash scripts and CLI tools.

### Prerequisite Tools

```bash
sudo apt-get install -y jq shellcheck    # or brew install jq shellcheck
npm install -g markdownlint-cli2
```

### Command Reference

| Command | Purpose | Preconditions | Expected Result | Common Failure | Recovery | Status | Portability | Last Validated | Evidence |
|---|---|---|---|---|---|---|---|---|---|
| `jq empty .claude-plugin/marketplace.json` | Validate marketplace JSON syntax | `jq` installed | Exit 0, no output | Invalid JSON | Fix syntax; use `jq .` to locate error | `[UNVERIFIED]` | Linux/macOS | unknown | `plugin-validation.yml` line "Validate JSON manifests" |
| `jq empty plugins/<name>/.claude-plugin/plugin.json` | Validate plugin manifest JSON | `jq` installed | Exit 0 | Invalid JSON | Fix with `jq .` | `[UNVERIFIED]` | Linux/macOS | unknown | `plugin-validation.yml` line "Validate JSON manifests" |
| `jq -r '.plugins[].name' .claude-plugin/marketplace.json \| sort` | List registered plugin names | `jq` installed | Sorted names matching `plugins/` dirs | Missing entry | Add plugin entry to marketplace.json | `[UNVERIFIED]` | Linux/macOS | unknown | `plugin-validation.yml` "marketplace.json sync" |
| `bash plugins/plugin-dev/skills/hook-development/scripts/validate-hook-schema.sh plugins/<name>/hooks/hooks.json` | Validate hooks.json schema | Script executable | `✅ All checks passed` | Invalid event / non-scalar command | See Section 8 Gotchas | `[UNVERIFIED]` | Linux/macOS | unknown | `plugin-validation.yml` "Validate hooks.json" |
| `bash plugins/plugin-dev/skills/hook-development/scripts/hook-linter.sh plugins/<name>/hooks/scripts/<script>.sh` | Lint hook shell scripts | shellcheck installed | `✅` output | shellcheck violation | Fix per shellcheck output | `[UNVERIFIED]` | Linux/macOS | unknown | `plugin-validation.yml` "Lint hook scripts" |
| `bash plugins/plugin-dev/skills/agent-development/scripts/validate-agent.sh plugins/<name>/agents/<agent>.md` | Validate agent frontmatter | Script executable | No `❌` in output | Missing frontmatter field | Add required fields; see Section 3 | `[UNVERIFIED]` | Linux/macOS | unknown | `plugin-validation.yml` "Validate agent files" |
| `bash plugins/plugin-dev/skills/plugin-settings/scripts/parse-frontmatter.sh plugins/<name>/commands/<cmd>.md description` | Check command has description | Script executable | Non-empty string | Empty/missing | Add `description:` to frontmatter | `[UNVERIFIED]` | Linux/macOS | unknown | `plugin-validation.yml` "Validate command frontmatter" |
| `bash plugins/plugin-dev/skills/plugin-settings/scripts/parse-frontmatter.sh plugins/<name>/skills/<skill>/SKILL.md name` | Check SKILL.md name field | Script executable | Non-empty string | Empty/missing | Add `name:` to frontmatter | `[UNVERIFIED]` | Linux/macOS | unknown | `plugin-validation.yml` "Validate skill frontmatter" |
| `shellcheck plugins/<name>/hooks/scripts/<script>.sh` | Lint custom hook script | shellcheck installed | Exit 0 | SC2086/SC2034 etc. | Fix per shellcheck suggestion | `[UNVERIFIED]` | Linux/macOS | unknown | `plugin-validation.yml` "Shellcheck custom bash scripts" |
| `markdownlint-cli2 "plugins/**/README.md" "plugins/**/commands/**/*.md" "plugins/**/skills/**/SKILL.md" "plugins/**/agents/*.md" "#plugins/plugin-dev/**"` | Lint markdown files | `markdownlint-cli2` installed | Exit 0 | MD013/line-length (disabled); usually MD0xx rules | Check `.markdownlint.json`; rule may be disabled | `[UNVERIFIED]` | Linux/macOS | unknown | `plugin-validation.yml` "Markdown lint" |

### CI Trigger

`plugin-validation.yml` runs on: `push` to `main`, `pull_request` to `main`.
All steps must pass — no partial merges.

---

## 7. Architecture & High-Risk Areas

### Component Map

| Component | Type | Risk Level | Why |
|---|---|---|---|
| `plugin-dev/skills/*/scripts/` | Internal toolkit | 🔴 HIGH | Changes affect ALL plugin validation in CI |
| `.claude-plugin/marketplace.json` | Index | 🔴 HIGH | Out-of-sync → CI fails on every PR |
| `hooks/hooks.json` (any plugin) | Hook config | 🟡 MEDIUM | Schema strictly validated; command must be string scalar |
| `agents/*.md` (any plugin) | Agent config | 🟡 MEDIUM | Known arithmetic bug in validate-agent.sh; CI works around it |
| `commands/*.md` / `skills/*/SKILL.md` | Frontmatter | 🟡 MEDIUM | Missing fields → CI fail |
| `plugin-studio/server/` | Node.js server | 🟡 MEDIUM | PID file detection; pnpm required |
| Root required files | Compliance | 🟢 LOW | Rarely change; deletion would fail CI immediately |

### High-Risk Change Patterns

- **Modifying `validate-hook-schema.sh`**: breaks hook validation for ALL plugins across CI.
- **Adding a plugin directory without updating `marketplace.json`**: instant CI failure.
- **Using `((var++))` in bash under `set -e`**: silent exit when counter starts at 0.
- **Changing frontmatter field names in templates**: breaks `parse-frontmatter.sh` extraction.

---

## 8. Known Gotchas & Recovery

### G1 — `((var++))` exits 1 under `set -e` when var=0

**Symptom**: Script exits silently mid-run on first iteration.
**Cause**: `((expr))` with result 0 returns exit code 1 in bash.
**Fix**: Replace `((var++))` with `var=$((var + 1))`.
**Applies to**: All bash scripts in `plugin-dev/` scripts and any custom hook scripts.

### G2 — `plugin-dev` must NOT appear in `marketplace.json`

**Symptom**: CI "marketplace.json sync" step fails with unexpected plugin mismatch.
**Cause**: `plugin-dev` is excluded from the sync check by CI (`grep -v '^plugin-dev$'`).
  If manually added to `marketplace.json`, it will create an orphaned entry.
**Fix**: Never add `plugin-dev` to `marketplace.json`.

### G3 — Hook `command` must be a string scalar

**Symptom**: `validate-hook-schema.sh` fails with jq type error.
**Cause**: Script reads `command` with `jq -r` expecting a plain string.
  Objects or arrays cause jq to return `null` or error.
**Fix**: Use `"command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/my-script.sh"`.

### G4 — `type: prompt` on SessionStart triggers a validator warning

**Symptom**: `validate-hook-schema.sh` emits a warning for `type: prompt` on `SessionStart`.
**Cause**: Prompt-type hooks are only appropriate for Stop/SubagentStop/UserPromptSubmit/PreToolUse.
**Fix**: Use `type: command` for SessionStart hooks, or accept warning (it does not fail CI).

### G5 — `validate-agent.sh` arithmetic bug — CI workaround active

**Symptom**: `validate-agent.sh` exits 1 on the first warning even when there are no errors.
**Cause**: Known `((warning_count++))` bug in the script.
**CI workaround**: CI captures full output and only fails if it contains `❌`.
  Running the script locally may show false premature exits.
**Fix locally**: Capture output — `out=$(bash validate-agent.sh "$f" 2>&1 || true); echo "$out"` — then grep for `❌`.

### G6 — `marketplace.json` sync is directory-based, not manifest-based

**Symptom**: CI fails even though `plugin.json` exists and is valid.
**Cause**: CI compares directory names under `plugins/` against `marketplace.json` `plugins[].name` values.
  Name mismatch (case, typo, extra dash) fails the sync check.
**Fix**: Ensure `plugins[].name` in `marketplace.json` exactly matches the directory name.

### G7 — markdownlint excludes `plugin-dev` but catches all other plugins

**Symptom**: `plugin-dev` docs pass lint silently; other plugins fail on same content.
**Cause**: `#plugins/plugin-dev/**` exclusion is explicit in CI markdownlint command.
**Fix**: When copying docs patterns from `plugin-dev`, validate with markdownlint manually.

### G8 — AI review silently skipped without `MODELS_PAT` secret

**Symptom**: No AI review comment appears on a PR.
**Cause**: `ai-review.yml` skips the review job if `MODELS_PAT` is not configured.
  This is non-blocking — CI still passes.
**Fix**: Configure the secret if AI review is desired; otherwise, no action needed.

### G9 — Plugin Studio PID file detection

**Symptom**: SessionStart hook reports a running server that is not actually running.
**Cause**: `plugins/plugin-studio/server/.pid` contains a stale PID from a previous session.
**Fix**: `check-server.sh` deletes the stale PID file automatically. If not, delete manually:
  `rm -f plugins/plugin-studio/server/.pid`.

---

## 9. Fast-Path: Common Contribution Flow

### Adding a new plugin

```bash
# 1. Create structure
mkdir -p plugins/<name>/{.claude-plugin,commands,skills,agents,hooks}

# 2. Create manifest (kebab-case name)
echo '{"name":"<name>","version":"0.1.0","description":"...","author":{"name":"..."}}' \
  | jq . > plugins/<name>/.claude-plugin/plugin.json

# 3. Add README
touch plugins/<name>/README.md

# 4. Register in marketplace
# Edit .claude-plugin/marketplace.json — add entry to plugins[] array

# 5. Validate locally
jq empty .claude-plugin/marketplace.json
jq empty plugins/<name>/.claude-plugin/plugin.json

# 6. Commit
git add . && git commit -m "plugin: add <name> plugin"
```

### Modifying an existing plugin

```bash
# Edit component files
# Validate relevant checks:
bash plugins/plugin-dev/skills/hook-development/scripts/validate-hook-schema.sh \
  plugins/<name>/hooks/hooks.json  # if hooks changed

markdownlint-cli2 "plugins/<name>/README.md"  # if markdown changed

# Commit
git commit -m "feat(<name>): describe the change"
```

---

## 10. Sources of Truth

| Resource | URL / Path | What it governs |
|---|---|---|
| Plugin authoring guidelines | `docs/PLUGIN_GUIDELINES.md` | Canonical plugin structure and quality standards |
| Plugin Validation CI | `.github/workflows/plugin-validation.yml` | All merge-blocking checks |
| Marketplace index | `.claude-plugin/marketplace.json` | Registered plugins |
| Hook validator | `plugins/plugin-dev/skills/hook-development/scripts/validate-hook-schema.sh` | Hook schema rules |
| Agent validator | `plugins/plugin-dev/skills/agent-development/scripts/validate-agent.sh` | Agent frontmatter rules |
| Markdownlint config | `.markdownlint.json` | Markdown rule exceptions |
| Release config | `release-please-config.json` | Commit types and changelog sections |
| Plugin Studio memory | `memory/projects/plugin-studio.md` | Plugin Studio project context |

---

## 11. Validation Metadata

- **Complexity Mode**: complex
- **Generated On**: 2026-03-04
- **Verification Coverage**: 0 VERIFIED / 10 [UNVERIFIED] / 0 NOT-RUN
- **Internal Systems Coverage**: 5 detected / 5 documented
  (`plugin-dev`, `plugin-validation.yml`, `ai-review.yml`, `release-please`, `.markdownlint.json`)
- **Staleness Check**: PASS

**Known Gaps**:
- All commands are `[UNVERIFIED]` — sourced from CI workflow files, not executed locally.
- `validate-agent.sh` arithmetic bug (G5) documented but not confirmed as unfixed upstream.
- `strategy-toolkit` plugin structure not fully inspected (excluded from detailed discovery).

**How to close gaps**:
- Run each command locally against a test plugin and upgrade status to `VERIFIED`.
- Check if `validate-agent.sh` has been patched upstream before relying on workaround.

**Top-5 Conformance Checks**:
1. All mandatory sections present and in order: PASS
2. Command table includes all required columns: PASS
3. Tri-state statuses used correctly (no synthetic VERIFIED): PASS
4. Every command row includes Evidence column: PASS
5. `Internal Tooling & Approved Workflow Systems` present and non-empty: PASS

---

> "Trust this guide first. Search only when information is missing, outdated,
> or proven incorrect during execution."
