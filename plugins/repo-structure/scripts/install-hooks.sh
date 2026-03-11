#!/usr/bin/env bash
# install-hooks.sh — Install pre-commit configuration and hooks
# Usage: bash install-hooks.sh [--dry-run]
set -euo pipefail

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "")"

if [[ -z "$ROOT" ]]; then
    echo "ERROR: Not inside a git repository" >&2
    exit 1
fi

cd "$ROOT"

echo "=== install-hooks.sh ==="
echo "Repository root: $ROOT"
echo "Dry run: $DRY_RUN"
echo

# Detect stack for appropriate pre-commit config
STACK="generic"
[[ -f "requirements.txt" || -f "pyproject.toml" ]] && STACK="python"
[[ -f "package.json" ]] && STACK="node"

echo "Detected stack: $STACK"

# Install .pre-commit-config.yaml if missing
if [[ ! -f ".pre-commit-config.yaml" ]]; then
    echo "No .pre-commit-config.yaml found. Generating one..."
    if [[ "$DRY_RUN" == "false" ]]; then
        case "$STACK" in
            python)
                cat > .pre-commit-config.yaml << 'PRECOMMIT'
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.6.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.4.1
    hooks:
      - id: ruff
      - id: ruff-format
PRECOMMIT
                ;;
            node)
                cat > .pre-commit-config.yaml << 'PRECOMMIT'
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.6.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-json
      - id: check-added-large-files
PRECOMMIT
                ;;
            *)
                cat > .pre-commit-config.yaml << 'PRECOMMIT'
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.6.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-added-large-files
PRECOMMIT
                ;;
        esac
        echo "Created .pre-commit-config.yaml for $STACK stack"
    else
        echo "[DRY RUN] Would create .pre-commit-config.yaml for $STACK stack"
    fi
else
    echo ".pre-commit-config.yaml already exists -- skipping"
fi

# Install pre-commit hooks
if command -v pre-commit &>/dev/null; then
    if [[ "$DRY_RUN" == "false" ]]; then
        echo "Running: pre-commit install"
        pre-commit install
        echo "Running: pre-commit run --all-files (dry-run validation)"
        pre-commit run --all-files || echo "Some hooks failed -- review output above"
    else
        echo "[DRY RUN] Would run: pre-commit install"
        echo "[DRY RUN] Would run: pre-commit run --all-files"
    fi
else
    echo "pre-commit not installed. Install with: pip install pre-commit"
    echo "Then run: pre-commit install"
fi

echo
echo "=== Done ==="
