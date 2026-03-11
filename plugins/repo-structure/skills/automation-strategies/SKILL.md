---
name: Automation Strategies
description: Use when the user asks to setup pre-commit hooks, configure CI/CD, install linters, add formatters, automate testing, or needs automation setup guidance for a specific tech stack.
version: 1.0.0
---

# Automation Strategies

Guide for setting up automation tools — pre-commit hooks, linters, formatters, and security scanning — adapted to the detected tech stack.

## Pre-commit Framework

Install and configure the `pre-commit` framework:

```bash
pip install pre-commit
pre-commit install
```

Or use the plugin's `install-hooks.sh` script which auto-detects stack and generates `.pre-commit-config.yaml`:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/install-hooks.sh
```

## Stack-Adaptive Configuration

### Python

Recommended tools: **black** (formatter), **ruff** (linter), **mypy** (types), **detect-secrets** (scanning).

Sample `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/psf/black
    rev: 23.12.1
    hooks:
      - id: black
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.1.9
    hooks:
      - id: ruff
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
```

### JavaScript / TypeScript

Recommended tools: **prettier** (formatter), **eslint** (linter), **husky** (hooks integration).

```yaml
repos:
  - repo: https://github.com/pre-commit/mirrors-prettier
    rev: v3.1.0
    hooks:
      - id: prettier
  - repo: https://github.com/pre-commit/mirrors-eslint
    rev: v8.56.0
    hooks:
      - id: eslint
        types: [javascript, jsx, ts, tsx]
```

### Go

Recommended tools: **gofmt** (formatter), **golangci-lint** (meta-linter).

```yaml
repos:
  - repo: https://github.com/dnephin/pre-commit-golang
    rev: v0.5.1
    hooks:
      - id: go-fmt
      - id: golangci-lint
```

### Rust

Recommended tools: **rustfmt** (formatter), **clippy** (linter).

```yaml
repos:
  - repo: local
    hooks:
      - id: rustfmt
        name: rustfmt
        entry: cargo fmt --
        language: system
        types: [rust]
      - id: clippy
        name: clippy
        entry: cargo clippy -- -D warnings
        language: system
        types: [rust]
        pass_filenames: false
```

## Universal Hooks (all stacks)

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-json
      - id: check-merge-conflict
      - id: check-added-large-files
```

## CI/CD Integration

Use the plugin's CI templates from `skills/repository-templates/templates/ci/`:

- `python-ci.yml.template` — Python CI with pytest, ruff, optional coverage
- `node-ci.yml.template` — Node.js CI with test and lint

Generate with:

```bash
python3 ${CLAUDE_PLUGIN_ROOT}/scripts/generate-template.py \
  --template ${CLAUDE_PLUGIN_ROOT}/skills/repository-templates/templates/ci/python-ci.yml.template \
  --output .github/workflows/ci.yml
```

## Git Hooks (Native, without pre-commit)

Commit-msg validation (conventional commits):

```bash
#!/usr/bin/env bash
# .git/hooks/commit-msg
pattern="^(feat|fix|chore|docs|refactor|test|ci|perf|revert)(\(.+\))?: .{1,72}"
if ! grep -qE "$pattern" "$1"; then
  echo "ERROR: Commit message must follow conventional commits format" >&2
  exit 1
fi
```
