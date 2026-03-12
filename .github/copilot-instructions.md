# Copilot Instructions — nsalvacao-claude-code-plugins

> Complexity Mode: **complex** | Generated: 2026-03-12

---

## 1. Project Intent

Personal marketplace of Claude Code plugins: autonomous, self-contained components
installable by end users in Claude Code. Each plugin under `plugins/` is an independent
artifact (commands, agents, skills, hooks). `plugin-dev` is BOTH the **internal dev toolkit**
(validation scripts, skill templates, hook authoring) AND a registered marketplace plugin (v1.0.0)
that users can install to develop their own plugins.

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

### Mandatory Workflow Read (Repository Policy)

Before implementation and before any commit/PR action, agents MUST consult:

1. `AGENTS.md`
2. `docs/PLUGIN_GUIDELINES.md`
3. `.ideas/plugin-dev-roadmap.md` (when roadmap items are involved)
4. `CLAUDE.md`

Mandatory delivery sequence for each logical change (Atomic Loop):

1. Atomic commit (one logical objective only)
2. Push branch
3. Open Pull Request
4. Wait for online GitHub review
5. Do NOT merge as agent (merge is human-approved and human-executed)

Full governance loop with local validation gates: `.ideas/plugin-dev-roadmap.md` § "Governance & Implementation Workflow".

---

## 3. Critical Rules (MUST / NEVER / SHOULD)

### MUST

- Every plugin directory under `plugins/` MUST be listed in `.claude-plugin/marketplace.json`
  under `plugins[].name` — including `plugin-dev` (as of v1.0.0).
- Every plugin MUST have `plugins/<name>/.claude-plugin/plugin.json` (valid JSON, `name` field in kebab-case).
- Every plugin MUST have `plugins/<name>/README.md`.
- Command files (`commands/*.md`) MUST contain YAML frontmatter with a non-empty `description` field.
- Skill files (`skills/*/SKILL.md`) MUST have frontmatter `name` and `description` fields.
- Agent files (`agents/*.md`) MUST have frontmatter: `name`, `description`, `model`, `color`, plus a non-empty body (system prompt) after the closing `---`.
  - `model` valid values: `inherit` (uses parent model), `sonnet`, `opus`, `haiku`
  - `color` valid values: `blue`, `cyan`, `green`, `yellow`, `magenta`, `red`
  - Agent files MUST use LF line endings — CRLF causes `validate-agent.sh` frontmatter detection to fail (see G11).
- `hooks/hooks.json` MUST use the **wrapper format**: `{"hooks": {"PreToolUse": [...], ...}}`.
  The top-level key `hooks` is required — event types at root level will be rejected at runtime.
- Hook `command` field MUST be a plain string scalar (e.g., `"bash ${CLAUDE_PLUGIN_ROOT}/..."`).
- Commits MUST follow Conventional Commits: `feat|fix|docs|refactor|chore|plugin|update`.
- Counter increments in `set -e` bash scripts MUST use `var=$((var + 1))`, NOT `((var++))`.
- Hook scripts MUST use `${CLAUDE_PLUGIN_ROOT}` for portable paths.

### NEVER

- NEVER hardcode API keys, tokens, or passwords in any file.
- NEVER interpolate user-controlled content directly into shell arguments in hook scripts;
  use stdin or a tempfile.
- NEVER use `((var++))` under `set -e` when `var` may start at 0 — it exits with code 1.
- NEVER embed issue counts, sprint status, or transient plans in core plugin files.
- NEVER write `hooks/hooks.json` with event types at root level (direct format is rejected
  by Claude Code runtime; wrapper format `{"hooks":{...}}` is mandatory).

### SHOULD

- Prefer `pnpm` over `npm` for Node.js operations in plugin-studio.
- Keep `SKILL.md` description ≥ 50 chars, third-person, with specific trigger phrases.
- Use HTTPS/WSS for MCP server URLs, not HTTP/WS.

### Emergency Recovery (3 Steps)

1. Re-run minimal local validation: `jq empty .claude-plugin/marketplace.json` +
   `validate-hook-schema.sh` on any changed hooks file.
2. Verify `marketplace.json` sync: every `plugins/<name>/` directory appears as
   `plugins[].name` in `.claude-plugin/marketplace.json` (exact directory name match).
3. If behavior is not locally reproducible, downgrade the affected command status to
   `[UNVERIFIED]` and reference the CI workflow as source of truth.

---

## 4. Repository Map (Where to Change What)

```
/
├── .claude-plugin/marketplace.json   ← MUST sync with ALL plugins/ dirs (CI gate)
├── .github/workflows/
│   ├── plugin-validation.yml          ← Primary CI gate (all PRs/pushes)
│   ├── ai-review.yml                  ← AI quality review (needs MODELS_PAT secret)
│   ├── release.yml                    ← release-please automation
│   ├── docs-sync.yml                  ← Docs sync
│   ├── housekeeping.yml               ← Periodic maintenance
│   └── security.yml                   ← Security scanning
├── .ideas/plugin-dev-roadmap.md       ← Active roadmap + governance workflow (read before work)
├── TASKS.md                           ← Task backlog (sync with roadmap)
├── AGENTS.md                          ← Mandatory agent rules (read before work)
├── CLAUDE.md                          ← Project memory and workflow preferences
├── .markdownlint.json                 ← Markdownlint config (permissive; see rules)
├── release-please-config.json         ← Commit type → changelog section mapping
├── plugins/
│   ├── plugin-dev/                    ← INTERNAL TOOLKIT + marketplace plugin v1.0.0
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
│   │   └── hooks/hooks.json           ← Hook config — wrapper format MANDATORY
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
| Roadmap progress | `.ideas/plugin-dev-roadmap.md` (update `[DONE]` labels) |

---

## 5. Internal Tooling & Approved Workflow Systems

### A. `plugins/plugin-dev` — Internal Dev Toolkit + Marketplace Plugin

| Attribute | Value |
|---|---|
| Role | `internal toolkit` + `validation gatekeeper` + `delivery artifact` |
| Controls | All validation logic called by CI; skill/hook/agent authoring guidance |
| Breaks if ignored | CI uses these scripts directly; changes affect ALL plugin validation |
| Path | `plugins/plugin-dev/skills/*/scripts/` |
| Validate compliance | Run scripts locally against changed files before commit |

Key scripts and what they enforce:

| Script | Enforces |
|---|---|
| `hook-development/scripts/validate-hook-schema.sh` | `hooks.json` wrapper format, valid events, hook types, command scalar |
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
3. Plugin README presence — all plugins including `plugin-dev`
4. `marketplace.json` ↔ `plugins/` directory sync — all plugins including `plugin-dev`
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
| Controls | Markdown lint rules for plugin docs (permissive ruleset) |
| Breaks if ignored | `markdownlint-cli2` CI step fails |
| Path | `.markdownlint.json` |
| Scope | Plugin READMEs, commands, skills, agents — NOT `plugin-dev/` |

### F. `.ideas/plugin-dev-roadmap.md` — Governance Workflow

| Attribute | Value |
|---|---|
| Role | `reference-only` |
| Controls | Implementation loop, atomic commit policy, local validation gates, done criteria |
| Breaks if ignored | Work may not meet quality standards; CI may catch issues preventable locally |
| Path | `.ideas/plugin-dev-roadmap.md` |
| How to validate | Follow the 10-step Atomic Loop in § "Governance & Implementation Workflow" |

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
| `jq empty .claude-plugin/marketplace.json` | Validate marketplace JSON syntax | `jq` installed | Exit 0, no output | Invalid JSON | Fix syntax; use `jq .` to locate error | `[UNVERIFIED]` | Linux/macOS | unknown | `plugin-validation.yml` "Validate JSON manifests" |
| `jq empty plugins/<name>/.claude-plugin/plugin.json` | Validate plugin manifest JSON | `jq` installed | Exit 0 | Invalid JSON | Fix with `jq .` | `[UNVERIFIED]` | Linux/macOS | unknown | `plugin-validation.yml` "Validate JSON manifests" |
| `jq -r '.plugins[].name' .claude-plugin/marketplace.json \| sort` | List registered plugin names | `jq` installed | Sorted names matching all `plugins/` dirs | Missing entry | Add plugin entry to marketplace.json | `[UNVERIFIED]` | Linux/macOS | unknown | `plugin-validation.yml` "marketplace.json sync" |
| `bash plugins/plugin-dev/skills/hook-development/scripts/validate-hook-schema.sh plugins/<name>/hooks/hooks.json` | Validate hooks.json schema + wrapper format | Script executable | `✅ All checks passed` | Invalid event / missing wrapper / non-scalar command | See Section 8 Gotchas | `VERIFIED` | Linux | 2026-03-12 | Executed during CI fix session; wrapper detection added |
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
| `hooks/hooks.json` (any plugin) | Hook config | 🟡 MEDIUM | Schema strictly validated; wrapper format required; command must be string scalar |
| `agents/*.md` (any plugin) | Agent config | 🟡 MEDIUM | Known arithmetic bug in validate-agent.sh; CI works around it |
| `commands/*.md` / `skills/*/SKILL.md` | Frontmatter | 🟡 MEDIUM | Missing fields → CI fail |
| `plugin-studio/server/` | Node.js server | 🟡 MEDIUM | PID file detection; pnpm required |
| Root required files | Compliance | 🟢 LOW | Rarely change; deletion would fail CI immediately |

### High-Risk Change Patterns

- **Modifying `validate-hook-schema.sh`**: breaks hook validation for ALL plugins across CI.
- **Adding a plugin directory without updating `marketplace.json`**: instant CI failure.
- **Using `((var++))` in bash under `set -e`**: silent exit when counter starts at 0.
- **Changing frontmatter field names in templates**: breaks `parse-frontmatter.sh` extraction.
- **Writing hooks.json in direct format** (events at root): rejected at Claude Code runtime.

---

## 8. Known Gotchas & Recovery

### G1 — `((var++))` exits 1 under `set -e` when var=0

**Symptom**: Script exits silently mid-run on first iteration.
**Cause**: `((expr))` with result 0 returns exit code 1 in bash.
**Fix**: Replace `((var++))` with `var=$((var + 1))`.
**Applies to**: All bash scripts in `plugin-dev/` scripts and any custom hook scripts.

### G2 — `plugin-dev` MUST appear in `marketplace.json` (as of v1.0.0)

**Symptom**: CI "marketplace.json sync" step fails — `plugin-dev` directory exists but is not listed.
**Cause**: `plugin-dev` is now a first-class marketplace plugin; CI checks ALL plugin directories.
**Fix**: Ensure `marketplace.json` contains `{"name": "plugin-dev", ...}` entry.
**Note**: Prior to 2026-03-12, `plugin-dev` was excluded from both the CI sync check and marketplace.json.
  That exclusion has been removed. The old "NEVER add plugin-dev to marketplace.json" rule is obsolete.

### G3 — Hook `command` must be a string scalar

**Symptom**: `validate-hook-schema.sh` fails with jq type error.
**Cause**: Script reads `command` with `jq -r` expecting a plain string.
  Objects or arrays cause jq to return `null` or error.
**Fix**: Use `"command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/my-script.sh"`.

### G4 — `hooks/hooks.json` must use wrapper format

**Symptom**: Claude Code runtime error: "Invalid input: expected record, received undefined" at path ["hooks"].
**Cause**: Direct format (event types at root level) is not accepted by Claude Code runtime.
**Fix**: Wrap all event arrays: `{"hooks": {"PreToolUse": [...], "Stop": [...]}}`
**Validation**: `validate-hook-schema.sh` detects wrapper format and unwraps before validation.

### G5 — `type: prompt` on SessionStart triggers a validator warning

**Symptom**: `validate-hook-schema.sh` emits a warning for `type: prompt` on `SessionStart`.
**Cause**: Prompt-type hooks are only appropriate for Stop/SubagentStop/UserPromptSubmit/PreToolUse.
**Fix**: Use `type: command` for SessionStart hooks, or accept warning (it does not fail CI).

### G6 — `validate-agent.sh` arithmetic bug — two failure modes

**Root cause**: `((n++))` under `set -e` exits with code 1 when `n=0` (post-increment returns old value 0 → falsy). Both `((error_count++))` and `((warning_count++))` in the script have this bug.

**Failure mode A — warnings silently swallowed**: First `((warning_count++))` call when no prior errors exist exits the script before subsequent checks run. Fields after the first warning trigger may appear valid locally. CI workaround (capture + grep `❌`) prevents false negatives here.

**Failure mode B — errors silently swallowed (higher risk)**: Agents that pass frontmatter format checks but are missing required fields (`name`, `model`, `color`) reach `echo "❌ ..."` and then `((error_count++))` exits — BUT because `echo "❌"` runs first, the CI grep catches it correctly. Exception: if the missing field is not printed before the crash, CI sees no `❌` and incorrectly marks the agent as passing.

**Practical result**: Agents using `description: >` multiline format without `name:` may silently pass CI even though fields are missing. Do not assume a CI PASS means the agent is fully valid.

**CI workaround in place**: `out=$(bash "$SCRIPT" "$f" 2>&1 || true); if echo "$out" | grep -q '❌'; then ...`
**Fix**: Script bug is tracked in roadmap v1.1. Local workaround: `out=$(bash validate-agent.sh "$f" 2>&1 || true); echo "$out"` — then grep for `❌` manually.

### G7 — `marketplace.json` sync is directory-based, not manifest-based

**Symptom**: CI fails even though `plugin.json` exists and is valid.
**Cause**: CI compares directory names under `plugins/` against `marketplace.json` `plugins[].name` values.
  Name mismatch (case, typo, extra dash) fails the sync check.
**Fix**: Ensure `plugins[].name` in `marketplace.json` exactly matches the directory name.

### G8 — markdownlint excludes `plugin-dev` but catches all other plugins

**Symptom**: `plugin-dev` docs pass lint silently; other plugins fail on same content.
**Cause**: `#plugins/plugin-dev/**` exclusion is explicit in CI markdownlint command.
**Fix**: When copying docs patterns from `plugin-dev`, validate with markdownlint manually.

### G9 — AI review silently skipped without `MODELS_PAT` secret

**Symptom**: No AI review comment appears on a PR.
**Cause**: `ai-review.yml` skips the review job if `MODELS_PAT` is not configured.
  This is non-blocking — CI still passes.
**Fix**: Configure the secret if AI review is desired; otherwise, no action needed.

### G11 — CRLF line endings break agent frontmatter detection

**Symptom**: `validate-agent.sh` reports `❌ Frontmatter not closed (missing second ---)` on a file that visually has correct frontmatter.
**Cause**: Agent files on NTFS mounts (`/mnt/d/`) edited with Windows tools get CRLF line endings. The validator uses `grep '^---$'` which does not match `---\r` (CRLF). The frontmatter block is never found.
**Affected agents (as of 2026-03-12)**: `repo-structure/agents/structure-architect.md`, `repo-structure/agents/automation-validator.md`, `solution-audit/agents/coherence-analyzer.md`, `solution-audit/agents/solution-auditor.md`, `solution-audit/agents/spec-reviewer.md`, `strategy-toolkit/agents/strategic-analyst.md` — all fail CI with this error.
**Fix**: `dos2unix plugins/<plugin>/agents/<agent>.md` or ensure all agent files are written/saved with LF. The Write tool always produces LF. Avoid editing these files directly with Windows-native editors.
**Prevention**: Use `file <agent>.md` to check — should show "ASCII text", not "with CRLF line terminators".

### G12 — Plugin Studio PID file detection

**Symptom**: SessionStart hook reports a running server that is not actually running.
**Cause**: `plugins/plugin-studio/server/.pid` contains a stale PID from a previous session.
**Fix**: `check-server.sh` deletes the stale PID file automatically. If not, delete manually:
  `rm -f plugins/plugin-studio/server/.pid`.

---

## 9. Fast-Path: Common Contribution Flow

### Adding a new plugin

```bash
# 1. Create structure
mkdir -p plugins/<name>/{.claude-plugin,commands,skills,agents,hooks/scripts}

# 2. Create manifest (kebab-case name)
echo '{"name":"<name>","version":"0.1.0","description":"...","author":{"name":"..."}}' \
  | jq . > plugins/<name>/.claude-plugin/plugin.json

# 3. Add README
touch plugins/<name>/README.md

# 4. Register in marketplace
# Edit .claude-plugin/marketplace.json — add entry to plugins[] array

# 5. If adding hooks — use wrapper format
# {"hooks": {"PreToolUse": [{"matcher": "Bash", "hooks": [{"type": "command", "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/validate.sh"}]}]}}

# 6. Validate locally
jq empty .claude-plugin/marketplace.json
jq empty plugins/<name>/.claude-plugin/plugin.json
bash plugins/plugin-dev/skills/hook-development/scripts/validate-hook-schema.sh \
  plugins/<name>/hooks/hooks.json  # if hooks.json present

# 7. Commit
git add plugins/<name>/ .claude-plugin/marketplace.json
git commit -m "plugin: add <name> plugin"
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

| Resource | Path | What it governs |
|---|---|---|
| Plugin authoring guidelines | `docs/PLUGIN_GUIDELINES.md` | Canonical plugin structure and quality standards |
| Plugin Validation CI | `.github/workflows/plugin-validation.yml` | All merge-blocking checks |
| Governance & atomic loop | `.ideas/plugin-dev-roadmap.md` | Implementation workflow, local gates, done criteria |
| Agent rules | `AGENTS.md` | Mandatory agent commit/PR/merge rules |
| Marketplace index | `.claude-plugin/marketplace.json` | Registered plugins |
| Hook validator | `plugins/plugin-dev/skills/hook-development/scripts/validate-hook-schema.sh` | Hook schema rules |
| Agent validator | `plugins/plugin-dev/skills/agent-development/scripts/validate-agent.sh` | Agent frontmatter rules |
| Markdownlint config | `.markdownlint.json` | Markdown rule exceptions |
| Release config | `release-please-config.json` | Commit types and changelog sections |

---

## 11. Validation Metadata

- **Complexity Mode**: complex
- **Generated On**: 2026-03-12
- **Verification Coverage**: 1 VERIFIED / 9 [UNVERIFIED] / 0 NOT-RUN
- **Internal Systems Coverage**: 6 detected / 6 documented
  (`plugin-dev`, `plugin-validation.yml`, `ai-review.yml`, `release-please`, `.markdownlint.json`, `.ideas/plugin-dev-roadmap.md`)
- **Staleness Check**: PASS

**Known Gaps**:
- 9 of 10 commands are `[UNVERIFIED]` — sourced from CI workflow files, not executed locally.
- `validate-agent.sh` arithmetic bug (G6) is documented and known; fix pending in roadmap v1.1.
- **6 agents currently failing CI** (CRLF line endings, G11): `structure-architect.md`, `automation-validator.md`, `coherence-analyzer.md`, `solution-auditor.md`, `spec-reviewer.md`, `strategic-analyst.md`. Fix: `dos2unix` each file.
- `ux-reviewer.md` fails CI — missing opening `---` frontmatter.
- `pm-assistant.md`, `productivity-assistant.md` pass CI incorrectly — missing `name`/`model`/`color` but arithmetic bug masks the error.
- New CC 2.1.74 hook events (TeammateIdle, TaskCompleted, WorktreeCreate, etc.) not yet in validator; roadmap v1.2 tracks this.

**How to close gaps**:
- Run `dos2unix` on all 6 CRLF-affected agent files and add missing `name`/`model`/`color` frontmatter.
- Fix `pm-assistant.md` and `productivity-assistant.md` missing agent frontmatter fields.
- Run each command locally against a test plugin and upgrade status to `VERIFIED`.

**Top-5 Conformance Checks**:
1. All mandatory sections present and in order: PASS
2. Command table includes all required columns: PASS
3. Tri-state statuses used correctly (1 VERIFIED with evidence): PASS
4. Every command row includes Evidence column: PASS
5. `Internal Tooling & Approved Workflow Systems` present and non-empty: PASS

---

> "Trust this guide first. Search only when information is missing, outdated,
> or proven incorrect during execution."
