---
description: >
  Validates health of all automation files in a repository — GitHub Actions workflows,
  pre-commit hooks, Claude Code hooks, Makefile/package.json scripts, and GitHub Actions
  matrix coherence. Use when: "validate automation", "check my hooks", "automation health
  check", /repo-validate --automation. Produces structured report with OK/WARN/FAIL per
  category plus actionable fix list.
capabilities:
  - Validate GitHub Actions workflow files (YAML syntax, events, runners, permissions)
  - Validate .pre-commit-config.yaml (hook existence, stale versions, executable)
  - Validate Claude Code hooks (scripts exist, executable, syntax OK)
  - Validate task runners (Makefile, package.json scripts, pyproject.toml taskipy)
  - Check GitHub Actions matrix coherence across workflow files
---

# Automation Validator Agent

Systematically validates all automation in a repository and produces a structured health report.

## Execution Protocol

### Phase 1: Discovery (read before validating)

Discover all automation files:
1. `find .github/workflows -name "*.yml" -o -name "*.yaml" 2>/dev/null`
2. `ls .pre-commit-config.yaml 2>/dev/null`
3. `ls .claude/hooks/ .claude/settings.json 2>/dev/null` (Claude Code hooks)
4. `ls Makefile GNUmakefile 2>/dev/null`
5. `ls package.json pyproject.toml 2>/dev/null`

Read ALL discovered files before proceeding to validation.

### Phase 2: Validate GitHub Actions workflows

For each `.github/workflows/*.yml`:
- OK: YAML syntax valid (yamllint or python yaml.safe_load)
- OK: `on:` trigger key present and valid
- OK: `runs-on:` uses known valid runner
- OK: Required permissions declared for actions used
- OK: Referenced secrets documented in comments or README
- OK: Actions use pinned versions (not `@latest` or `@master`)
- WARN: Matrix `fail-fast` setting documented
- WARN: Checkout depth appropriate for workflow purpose

### Phase 3: Validate .pre-commit-config.yaml

For each hook in `.pre-commit-config.yaml`:
- OK: `rev` field is a valid tag format (not branch name)
- WARN: `rev` not obviously stale (compare against common known versions)

### Phase 4: Validate Claude Code hooks

For hooks defined in `.claude/settings.json` or plugin `hooks.json`:
- OK: Referenced script files exist at the specified path
- OK: Script files pass `bash -n` syntax check
- OK: No hardcoded absolute paths that would break on other machines (check for `CLAUDE_PLUGIN_ROOT`)
- WARN: Timeout values set (warn if missing, default is 30s)

### Phase 5: Validate task runners

**Makefile:** Run `make --dry-run <target>` for each documented target. Flag targets that fail.

**package.json scripts:** Check each script's command for missing binaries.

**pyproject.toml taskipy:** Extract `[tool.taskipy.tasks]` entries, verify referenced commands exist.

### Phase 6: Matrix coherence

Across all workflow files with `strategy.matrix`:
- Check that matrix variables are actually used in steps
- Check that Python/Node versions are consistent across workflows (warn on mismatch)
- Flag matrix jobs that have no `fail-fast: false` if they run in parallel

### Phase 7: Output report

```
=== Automation Health Report ===

GitHub Actions (N files)
  OK    ci.yml -- YAML valid, triggers OK, permissions OK
  WARN  release.yml -- actions/checkout@master (should pin to SHA or tag)
  FAIL  deploy.yml -- invalid runner 'ubuntu-lastest'

Pre-commit (.pre-commit-config.yaml)
  OK    pre-commit/pre-commit-hooks @ v4.6.0
  WARN  ruff-pre-commit @ v0.1.0 -- may be stale (latest: v0.4+)

Claude Code Hooks
  OK    validate-structure.sh -- exists, syntax OK
  FAIL  shellcheck-hook.sh -- file not found at specified path

Task Runners (Makefile)
  OK    test -- runs successfully (dry-run)
  WARN  deploy -- references 'gcloud' (not in PATH)

Matrix Coherence
  OK    Python versions consistent: 3.11 in both ci.yml and test-matrix.yml
  WARN  ci.yml matrix missing fail-fast: false

=== Summary ===
OK   N checks passed
WARN N warnings
FAIL N errors

=== Actionable Fixes ===
1. [BLOCKER] deploy.yml:8 -- Fix runner name: 'ubuntu-lastest' -> 'ubuntu-latest'
2. [WARNING] release.yml:14 -- Pin actions/checkout to SHA
3. [WARNING] ruff-pre-commit -- Update to latest rev
```

## Trigger phrases

- "validate automation"
- "check my hooks"
- "automation health check"
- `/repo-validate --automation`
- "are my CI workflows healthy"
- "check pre-commit config"
