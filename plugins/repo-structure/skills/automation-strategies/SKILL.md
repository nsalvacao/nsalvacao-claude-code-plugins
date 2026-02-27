---
name: Automation Strategies
description: This skill should be used when the user asks to "setup pre-commit hooks", "configure CI/CD", "install linters", "add formatters", "automate testing", or needs automation setup for code quality, testing, and deployment workflows.
version: 0.1.0
---

# Automation Strategies

Automation setup for pre-commit hooks, linters, formatters, security scanning, and CI/CD workflows with stack-adaptive configuration.

## Pre-Commit Hooks

**Framework:** `pre-commit` (recommended)

**Installation:**
```bash
bash scripts/install-hooks.sh
```

**Stack-adaptive hooks:**

### Python
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/psf/black
    rev: 23.11.0
    hooks:
      - id: black
  - repo: https://github.com/PyCQA/flake8
    rev: 6.1.0
    hooks:
      - id: flake8
  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.7.0
    hooks:
      - id: mypy
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
```

### JavaScript/TypeScript
```yaml
repos:
  - repo: https://github.com/pre-commit/mirrors-prettier
    rev: v3.1.0
    hooks:
      - id: prettier
  - repo: https://github.com/pre-commit/mirrors-eslint
    rev: v8.54.0
    hooks:
      - id: eslint
```

### Go
```yaml
repos:
  - repo: https://github.com/dnephin/pre-commit-golang
    rev: v0.5.1
    hooks:
      - id: go-fmt
      - id: go-lint
      - id: go-imports
```

### Universal Hooks
```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-merge-conflict
      - id: check-added-large-files
```

## Linter Configs

### Python (.flake8)
```ini
[flake8]
max-line-length = 88
extend-ignore = E203, W503
exclude = .git,__pycache__,venv
```

### JavaScript (.eslintrc.json)
```json
{
  "extends": ["eslint:recommended", "prettier"],
  "env": {"node": true, "es6": true},
  "rules": {"no-console": "warn"}
}
```

### TypeScript (tsconfig.json)
```json
{
  "compilerOptions": {
    "strict": true,
    "esModuleInterop": true
  }
}
```

## Formatter Configs

### Python (pyproject.toml)
```toml
[tool.black]
line-length = 88
target-version = ['py38', 'py39', 'py310']
```

### JavaScript (.prettierrc)
```json
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2
}
```

## CI/CD Workflows

### GitHub Actions (Python)
```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      - run: pip install -r requirements-dev.txt
      - run: pytest --cov
      - run: black --check .
      - run: flake8
```

### Security Scanning
```yaml
# .github/workflows/security.yml
name: Security
on: [push, pull_request]
jobs:
  codeql:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: github/codeql-action/init@v2
      - uses: github/codeql-action/analyze@v2
```

## Usage

**Install all automation:**
```bash
bash scripts/install-hooks.sh --stack=python
```

**Selective install:**
```bash
bash scripts/install-hooks.sh --hooks-only
bash scripts/install-hooks.sh --ci-only
```

## Integration

- Detects stack via `tech-stack-detection`
- Validates setup via `quality-scoring`
- Templates in `templates/` directory

See: `references/` for complete configs and `scripts/` for installers.
