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

## Plugin Architecture & Validation Requirements

Each plugin lives under `plugins/<plugin-name>/` and must contain a `.claude-plugin/plugin.json` manifest plus one or more component types (commands, skills, agents, hooks, MCP). This section covers manifest requirements, component formats, and quality standards for all plugin files.

**Important:** `plugins/plugin-dev/` is a development toolkit, **not** a marketplace plugin. It provides validation scripts, linters, and scaffolding used by CI and other plugins. It is excluded from marketplace sync checks.

### Plugin Manifest (plugin.json)

Each plugin MUST include a `.claude-plugin/plugin.json` manifest at the plugin root with the following structure:

**Required fields:**
- `name` (string): kebab-case identifier, lowercase, alphanumeric + hyphens only, globally unique
- `version` (string): Semantic versioning (MAJOR.MINOR.PATCH); initialize new plugins at `0.1.0`
- `description` (string): Clear problem statement or plugin purpose, under 150 characters
- `author` (object): Must contain `name` (string) and `email` (string) fields

**Recommended fields:**
- `homepage` (string): URL to plugin documentation or website
- `repository` (string): URL to source version control (e.g., GitHub repository)
- `license` (string): SPDX identifier (e.g., `"MIT"`, `"Apache-2.0"`)
- `keywords` (array of strings): 3–5 terms for marketplace discoverability

**Example:**
```json
{
  "name": "strategy-toolkit",
  "version": "0.1.0",
  "description": "Strategic ideation and execution planning toolkit with reproducible frameworks",
  "author": {
    "name": "Nuno Salvacao",
    "email": "nuno.salvacao@gmail.com"
  },
  "homepage": "https://github.com/nsalvacao/nsalvacao-claude-code-plugins/tree/main/plugins/strategy-toolkit",
  "repository": "https://github.com/nsalvacao/nsalvacao-claude-code-plugins",
  "license": "MIT",
  "keywords": ["strategy", "ideation", "planning", "frameworks"]
}
```

### Component Format Requirements

#### Commands (commands/*.md)

**File naming:** kebab-case.md (e.g., `write-spec.md`, `brainstorm.md`, `repo-validate.md`)

**Frontmatter (YAML) — Required & Optional fields:**
```yaml
---
description: Create a detailed competitive analysis report comparing features and positioning
name: competitive-brief  # optional; if omitted, derives from filename
argument-hint: "[repo-path] [competitors]"  # optional
allowed-tools: [find_files, read_file]  # optional; restricts tool access
model: sonnet  # optional; overrides default model; values: inherit|sonnet|opus|haiku
disable-model-invocation: false  # optional; boolean
---
```

- **`description`** (REQUIRED): 1–2 sentence command purpose, visible in `/help` (aim for <60 characters); should be an action directive (e.g., "Create...", "Validate...", "Write...")
- **`name`** (OPTIONAL): if omitted, command name derives from filename; if provided, must match filename exactly
- **Other fields** (OPTIONAL): see plugin-dev/skills/command-development for advanced use cases

**Purpose:** Commands are instructions FOR Claude, not messages TO users. They shape Claude's behavior when invoked via `/plugin-name:command-name [args]`.

**Example:**
```markdown
---
description: Validate plugin structure conformance against quality standards
name: plugin-validate
---

## Purpose
Check a plugin directory for structural integrity and guideline compliance...

[Markdown body with template, examples, and validation criteria]
```

#### Skills (skills/skill-name/SKILL.md)

**Directory structure:**
```
skills/
  strategic-analysis/
    SKILL.md              # Required: metadata + description
    scripts/              # Optional: executable utilities
    references/           # Optional: large reference documents
    assets/               # Optional: templates or boilerplate files
```

**SKILL.md frontmatter (YAML) — Required fields:**
```yaml
---
name: strategic-analysis
description: |
  Use this skill when the user asks to analyze market opportunities, competitive positioning, or strategic risks.
  Large reference guides available: grep "Feature:" in references/competitor-matrix.md
---
```

- **`name`** (REQUIRED): skill identifier, lowercase + hyphens, no spaces
- **`description`** (REQUIRED): trigger conditions and usage context; if bundling large reference files, include grep patterns to help Claude index content

**Guidelines:**
- Keep SKILL.md body under 5,000 words; reference large docs via `references/` subdirectory
- `scripts/` contains deterministic, repeatable code (parsing, validation, formatting, tree traversal)
- `assets/` contains template files, boilerplate code, or snippets users might copy-paste
- Use markdown headers and examples liberally for clarity

#### Agents (agents/*.md) — CRITICAL: Description Format

**File naming:** kebab-case.md (e.g., `structure-architect.md`, `coherence-analyzer.md`)

**Frontmatter (YAML) — Required fields:**
```yaml
---
name: coherence-analyzer
description: |
  Use this agent when reviewing a plugin's architecture or cross-component consistency.
  
  <example>
  Context: New plugin with inconsistent command naming (some use brainstorm, others use ideate).
  User: Check plugin structure for consistency issues
  Assistant: Identifies mixed naming patterns, recommends standardization to kebab-case.
  <commentary>Triggered because naming consistency impacts discoverability and usability.</commentary>
  </example>

  <example>
  Context: Plugin has valid structure but unclear skill descriptions that don't indicate triggering conditions.
  User: Audit skill descriptions for clarity
  Assistant: Reviews descriptions, suggests improvements to make Claude recognize when skills are needed.
  <commentary>Triggered to improve Claude's decision-making about skill applicability.</commentary>
  </example>
model: inherit
color: blue
tools: [read_file, grep_search]  # optional
---
```

**Required fields:**
- **`name`** (REQUIRED): 3–50 characters, lowercase + hyphens, must start/end with alphanumeric; avoid generic names like `helper` or `validator`
- **`description`** (REQUIRED & CRITICAL): 
  - Opens with clear triggering condition: "Use this agent when [specific context/problem]"
  - Includes 2+ `<example>` blocks showing when agent should be invoked
  - Each example has: Context (situation), User (request), Assistant (response), <commentary> (why agent triggered)
  - Examples teach Claude the context + expected behavior; without them, agents may never be invoked
- **`model`** (REQUIRED): `inherit` (recommended), `sonnet`, `opus`, or `haiku`
- **`color`** (REQUIRED): `blue`, `cyan`, `green`, `yellow`, `magenta`, or `red` (use distinct colors if multiple agents in same plugin)
- **`tools`** (OPTIONAL): array of allowed tools to restrict access

**Why this matters:** Claude uses agent descriptions to decide IF agent should be invoked. Clear triggering conditions + concrete examples are the only mechanism Claude has to recognize when an agent is relevant. Vague descriptions = agents that never get used.

#### Hooks (hooks/hooks.json)

**Format (canonical — direct format preferred):**

```json
{
  "SessionStart": [
    {
      "matcher": "pattern_or_*_for_all",
      "hooks": [
        {
          "type": "command",
          "command": ["bash", "${CLAUDE_PLUGIN_ROOT}/scripts/setup.sh"],
          "timeout": 10,
          "description": "Initialize workspace on session start"
        }
      ]
    }
  ],
  "PreToolUse": [
    {
      "matcher": "Write|Edit",
      "hooks": [
        {
          "type": "prompt",
          "prompt": "Validate this write operation: $TOOL_INPUT",
          "timeout": 30
        }
      ]
    }
  ]
}
```

**Key points:**
- Each hook event (SessionStart, PreToolUse, Stop, etc.) is a **top-level key** containing an array of hook objects
- **Direct format (above) is canonical and preferred** for new plugins
- Use `${CLAUDE_PLUGIN_ROOT}` (with braces) for portability across Windows/WSL/Linux
- Paths are relative to plugin root; NEVER use absolute paths or hardcoded user directories
- `timeout`: optional, numeric seconds (recommended 5–600s range)
- **Supported events:** PreToolUse, PostToolUse, UserPromptSubmit, Stop, SubagentStop, SessionStart, SessionEnd, PreCompact, Notification
- **Legacy note:** Older documentation referenced a wrapper format `{"hooks": {...}}`. The direct format (shown above) is now canonical.

#### MCP Server Configuration (mcp-template.json)

**Important distinction:**
- `mcp-template.json` is a REFERENCE TEMPLATE showing server configuration patterns — it is NOT operational configuration
- Users must follow the plugin's `MCP-SETUP.md` documentation to configure their own servers with actual credentials
- Should be version-controlled as documentation; users will create `.mcp.json` locally with their credentials (never committed)

**MCP servers can be configured as:**
1. **stdio** (local executable): `command`, `args`, `env` (for local tools, databases)
2. **sse** (Server-Sent Events): `url`, auth headers (hosted services with OAuth)
3. **http** (REST API): `url`, headers with auth tokens (REST-based tools like Slack, Notion)
4. **websocket**: `url`, auth flow (real-time collaboration tools)

**Best practices:**
- Document setup instructions in plugin's `MCP-SETUP.md` (include OAuth flow if applicable)
- Use environment variables for secrets; document required `.env` variables
- Include example server URIs in templates, but NEVER include real credentials or API keys
- Test that plugin functions without MCP server present (graceful degradation)
- Avoid committing `.mcp.json` files; add to `.gitignore`

**Example template structure:**
```json
{
  "notion-integration": {
    "type": "http",
    "url": "https://api.notion.com/v1/",
    "headers": {
      "Authorization": "Bearer ${NOTION_API_KEY}"
    }
  },
  "local-database": {
    "type": "stdio",
    "command": "python",
    "args": ["${CLAUDE_PLUGIN_ROOT}/mcp/server.py"]
  }
}
```

### File Quality Standards

All plugin files MUST conform to the following standards:

| Aspect | Standard | Enforcement |
|--------|----------|-------------|
| **Encoding** | UTF-8 | .editorconfig + git config core.safecrlf |
| **Line endings** | LF (Unix) | .gitattributes, .editorconfig |
| **Indentation** | 2 spaces | .editorconfig (JSON, YAML, Markdown nested lists) |
| **Final newline** | Required on ALL files | .editorconfig + pre-commit hooks |
| **Markdown lint** | markdownlint-cli2 per .markdownlintrc | CI workflow (plugin-validation.yml) |
| **JSON syntax** | Valid JSON, validated with `jq empty` | CI workflow |
| **YAML syntax** | Valid YAML; consistent field naming per component type | Manual review + plugin-dev validators |
| **Shell scripts** | Validated with shellcheck; use `set -euo pipefail` | CI workflow; arithmetic with `var=$((var + 1))` not `((var++))` |

**Key rules:**
- Markdown: line-length (MD013) disabled; HTML tags allowed; all other linting rules enforced
- YAML: consistent field naming (kebab-case for file names, camelCase for YAML fields, lowercase for enum values)
- Bash: under `set -e`, arithmetic expressions must use `var=$((var + 1))` syntax, NOT `((var++))` (evaluates to 0 when count is 0, causing exit)

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

### Common Validation Failures & Troubleshooting

**Plugin Validation workflow fails? Quick reference:**

| Failure Message | Root Cause | Solution |
|-----------------|-----------|----------|
| `parse error` (jq) | Malformed JSON in plugin.json or marketplace.json | Run `jq . < plugins/name/.claude-plugin/plugin.json` to see parse error details |
| `description field is required` | Command or skill missing required frontmatter field | Ensure YAML frontmatter has `description:` key with non-empty value |
| `Agent description missing examples` | Agent description lacks `<example>` blocks OR name doesn't match filename | Add 2+ `<example>` blocks with Context/User/Assistant/<commentary> structure; verify agent filename |
| `Invalid hook event name` | hooks.json uses unrecognized event (typo) | Use only: PreToolUse, PostToolUse, Stop, SubagentStop, SessionStart, SessionEnd, UserPromptSubmit, PreCompact, Notification |
| `hooks.json validate fails` | Invalid JSON syntax OR matcher/hooks structure incorrect | Validate JSON with `jq empty plugins/name/hooks/hooks.json`; check that hook structure matches example above |
| `markdown lint fails` | Line too long OR disallowed HTML | Check .markdownlintrc; MD013 is disabled (long lines OK), HTML is allowed; likely a different rule — run local markdownlint to see which |
| Agent never triggered in Claude Code | Agent description lacks clear triggering context OR no working examples | Review description format section above; Claude needs examples showing WHEN to use agent. Generic descriptions = no invocation. |

**Pre-commit validation checklist:**
```bash
# JSON manifests
jq empty .claude-plugin/marketplace.json
jq empty plugins/your-plugin/.claude-plugin/plugin.json

# Agent descriptions
bash plugins/plugin-dev/skills/agent-development/scripts/validate-agent.sh \
  plugins/your-plugin/agents/your-agent.md

# Hooks
bash plugins/plugin-dev/skills/hook-development/scripts/validate-hook-schema.sh \
  plugins/your-plugin/hooks/hooks.json 2>/dev/null && echo "Valid" || echo "Invalid"

# All Markdown files
markdownlint-cli2 "plugins/your-plugin/**/*.md"
```

### Known CI Issues & Workarounds

**Plugin Validation workflow — bash arithmetic in validate-hook-schema.sh:**

Root cause: `((warning_count++))` expression evaluates to 0 (falsy) when `warning_count` is initially 0. Under `set -euo pipefail`, this causes the script to exit with code 1 even though the finding is only a warning.

**Workaround:** If you need to modify `validate-hook-schema.sh` or write similar bash scripts, replace arithmetic increment syntax:
- ❌ `((warning_count++))` — fails under set -e when var is 0
- ✅ `warning_count=$((warning_count + 1))` — works correctly

Apply the same fix to `error_count` and any new bash scripts using arithmetic under `set -euo pipefail`.

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

### Frontmatter Fields Checklist

Quick reference for required vs optional frontmatter fields:

**Commands (commands/*.md)**
- [ ] `description` — REQUIRED (visible in /help)
- [ ] `name` — optional (derives from filename if omitted)
- [ ] `argument-hint` — optional
- [ ] `allowed-tools` — optional
- [ ] `model` — optional
- [ ] `disable-model-invocation` — optional

**Skills (skills/NAME/SKILL.md)**
- [ ] `name` — REQUIRED
- [ ] `description` — REQUIRED (trigger conditions, usage context)

**Agents (agents/*.md)**
- [ ] `name` — REQUIRED (3-50 chars, no generic names)
- [ ] `description` — REQUIRED with 2+ `<example>` blocks (triggering context is critical)
- [ ] `model` — REQUIRED (inherit | sonnet | opus | haiku)
- [ ] `color` — REQUIRED (blue | cyan | green | yellow | magenta | red)
- [ ] `tools` — optional (array of tool names)

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
