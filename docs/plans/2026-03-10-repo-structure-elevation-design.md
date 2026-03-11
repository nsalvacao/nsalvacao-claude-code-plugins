# repo-structure v0.2.0 — Elevation Design

**Date:** 2026-03-10
**Author:** Nuno Salvação
**Status:** Approved
**Scope:** Domain elevation — bug fixes, P0.3 templates, CI debugging suite, PR respond, hooks upgrade, automation-validator

---

## Context

repo-structure v0.1.0 is 33% launch-ready (2/6 P0 blockers complete). Core scripts exist but have critical bugs. 8/10 templates missing. Several referenced scripts don't exist. This elevation completes Phase 0 and adds new capabilities in a single v0.2.0 release.

---

## Group A: Bug Fixes (4)

| ID | File | Bug | Fix |
|----|------|-----|-----|
| B1 | `scripts/calculate-score.py:403-407` | Coverage scored twice (4pts instead of 2pts) | Remove duplicate line |
| B2 | `hooks/scripts/validate-structure.sh` | Markdown regex detects valid links as broken | Replace with file-existence check |
| B3 | `scripts/generate-template.py` | HAS_COVERAGE, HAS_LINTER, HAS_CONFIG_FILE, HAS_DISCUSSIONS, HAS_ISSUES used in templates but no detection logic | Add detection functions |
| B4 | `scripts/detect-stack.sh` | jq hard dependency without fallback; confidence hardcoded at 85/90/100 | python3 fallback; dynamic confidence |

---

## Group B: P0.3 Templates (9)

All use existing Mustache system. New subdirs: `templates/configs/`, `templates/ci/`

| Template | Path | Key conditionals |
|----------|------|-----------------|
| CONTRIBUTING.md | `github/CONTRIBUTING.md.template` | HAS_ISSUES, PYTHON, JAVASCRIPT |
| SECURITY.md | `github/SECURITY.md.template` | SUPPORTED_VERSIONS, SECURITY_EMAIL |
| CODE_OF_CONDUCT.md | `github/CODE_OF_CONDUCT.md.template` | CONTACT_EMAIL (Contributor Covenant 2.1) |
| LICENSE.Apache-2.0 | `github/LICENSE.Apache-2.0.template` | YEAR, AUTHOR_NAME |
| .gitignore Python | `configs/.gitignore.python.template` | HAS_VENV, PYTEST |
| .gitignore Node | `configs/.gitignore.node.template` | TYPESCRIPT, NEXT_JS |
| .editorconfig | `configs/.editorconfig.template` | PYTHON, JAVASCRIPT, INDENT_SIZE |
| GitHub Actions Python CI | `ci/python-ci.yml.template` | PYTHON_VERSION, PYTEST, RUFF |
| GitHub Actions Node CI | `ci/node-ci.yml.template` | NODE_VERSION, TYPESCRIPT, TEST_COMMAND |

---

## Group C: CI Debugging Suite (new)

### Skill: ci-diagnostics
Pattern library for common GitHub Actions failures:
- bash -e + arithmetic `((n++))` → `n=$((n+1))`
- YAML indentation errors, missing `on:` key, invalid runner
- Missing permissions (contents: write, pull-requests: write)
- Missing secrets/env vars, not propagated to steps
- Matrix strategy with fail-fast vs isolated errors
- Checkout depth for tags/releases (fetch-depth: 0)
- Cache invalidation patterns
- Markdownlint config format issues

### Command: /ci-audit
- Reads ALL .github/workflows/*.yml before touching anything
- Applies ci-diagnostics skill to each
- Lists ALL issues (syntax, logic, permissions, known gotchas)
- Estimates impact per issue (blocker/warning/info)
- Diagnose-only by default; with --fix-plan generates ordered fix plan

### Command: /ci-fix
- Internally runs /ci-audit for complete issue list
- Applies all fixes in dependency order
- Validates each file with yamllint after edit
- One commit per workflow file
- --dry-run: shows what would be done

---

## Group D: /pr-respond Command (new)

```
/pr-respond [PR-number | --current] [--repo=owner/repo]
```

1. gh pr view --json reviewThreads to load all unresolved comments
2. Group by file and type (code change / question / nitpick / blocker)
3. Resolve each: apply fix (blockers), prepare text response (questions), apply if trivial (nitpicks)
4. Commit fixes with reference to comment
5. Summary: N resolved, N deferred with reasons
6. Optional: gh pr review --comment with summary

---

## Group E: Hooks Upgrade (5 hooks total, up from 2)

New scripts in `hooks/scripts/`:
- `shellcheck-hook.sh` — runs shellcheck on .sh files, graceful if not installed
- `yamllint-hook.sh` — yamllint with python3 yaml fallback
- `lf-check-hook.sh` — detects CRLF, warns on stderr
- `audit-reminder.sh` — Stop hook: suggests /repo-validate if files were created

Updated `hooks/hooks.json`:
- PreToolUse Write|Edit → validate-structure.sh (existing, fixed)
- PostToolUse Write|Edit *.sh → shellcheck-hook.sh
- PostToolUse Write|Edit *.yml|*.yaml → yamllint-hook.sh
- PostToolUse Write|Edit → lf-check-hook.sh
- Stop → audit-reminder.sh

---

## Group F: automation-validator Agent (new)

Validates health of all automation files in a repo:
- .github/workflows/*.yml — YAML valid, correct events, valid runners, adequate permissions
- .pre-commit-config.yaml — hooks exist, versions not stale, hooks executable
- Claude Code hooks — scripts exist, executable, syntax OK
- Makefile/package.json scripts/pyproject.toml taskipy — targets defined work
- GitHub Actions matrix coherence

Output: structured report with status per category (✓/⚠/✗) + actionable fixes list
Trigger: "validate automation", "check my hooks", "automation health check", /repo-validate --automation

---

## Group G: Missing Scripts (2)

### scripts/install-hooks.sh (~60 lines)
- Detects git repo
- Installs .pre-commit-config.yaml if missing (stack-based)
- Runs `pre-commit install` if available
- Dry-run validation via `pre-commit run --all-files`

### scripts/check-compliance.sh (~80 lines, basic)
- OpenSSF: SECURITY.md, dependabot config, branch protection (gh api), signed commits
- CII: README, LICENSE, CONTRIBUTING, CI present
- JSON output with scores per framework

---

## Group H: Reference Files (4)

| Skill | File | Content |
|-------|------|---------|
| quality-scoring | references/scoring-rubrics.md | Detailed rubrics per sub-item, 0/50/100% examples |
| quality-scoring | references/partial-credit-rules.md | When to award partial credit vs zero |
| tech-stack-detection | references/detection-patterns.json | Per-language patterns (files, keywords, extensions) |
| compliance-standards | references/compliance-mapping.md | OpenSSF/CII/OWASP mapping to 4 score categories |

---

## Files Changed Summary

```
repo-structure/
├── scripts/
│   ├── calculate-score.py          [FIX B1]
│   ├── generate-template.py        [FIX B3]
│   ├── detect-stack.sh             [FIX B4]
│   ├── install-hooks.sh            [NEW G1]
│   └── check-compliance.sh         [NEW G2]
├── hooks/
│   ├── hooks.json                  [UPDATE: 2→5 hooks]
│   └── scripts/
│       ├── validate-structure.sh   [FIX B2]
│       ├── shellcheck-hook.sh      [NEW E1]
│       ├── yamllint-hook.sh        [NEW E2]
│       ├── lf-check-hook.sh        [NEW E3]
│       └── audit-reminder.sh       [NEW E4]
├── commands/
│   ├── ci-audit.md                 [NEW C2]
│   ├── ci-fix.md                   [NEW C3]
│   └── pr-respond.md               [NEW D1]
├── agents/
│   └── automation-validator.md     [NEW F1]
├── skills/
│   ├── ci-diagnostics/SKILL.md     [NEW C1]
│   ├── quality-scoring/references/ [NEW H1, H2]
│   ├── tech-stack-detection/references/ [NEW H3]
│   └── compliance-standards/references/ [NEW H4]
└── skills/repository-templates/templates/
    ├── github/ [4 NEW templates B1-B4]
    ├── configs/ [NEW dir + 3 templates B5-B7]
    └── ci/ [NEW dir + 2 templates B8-B9]
```

**Total: ~29 components, version 0.1.0 → 0.2.0**
