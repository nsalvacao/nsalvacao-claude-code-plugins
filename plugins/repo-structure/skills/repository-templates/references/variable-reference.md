# Template Variable Reference

Complete documentation of all template variables supported in repo-structure templates.

## Standard Variables

### Project Identification

#### `{{PROJECT_NAME}}`
**Type:** String
**Resolution order:**
1. Extract from git remote URL (`git config remote.origin.url`)
   - `https://github.com/user/my-project.git` → `my-project`
   - `git@github.com:user/my-project.git` → `my-project`
2. Use current directory name
3. Fallback: `"my-project"` + emit warning

**Usage:**
```markdown
# {{PROJECT_NAME}}

Install {{PROJECT_NAME}} using pip.
```

---

#### `{{DESCRIPTION}}`
**Type:** String (1-2 sentences)
**Resolution order:**
1. Parse from `package.json` → `description` field
2. Parse from `pyproject.toml` → `[project].description`
3. Parse from `Cargo.toml` → `[package].description`
4. Parse from `go.mod` → first comment line
5. Prompt user interactively

**Usage:**
```markdown
{{DESCRIPTION}}

## Features
```

---

### Author Information

#### `{{AUTHOR_NAME}}`
**Type:** String
**Resolution order:**
1. Config file: `author.name`
2. Git config: `git config user.name`
3. Prompt user interactively

**Usage:**
```markdown
## Author

**{{AUTHOR_NAME}}** - [GitHub](https://github.com/{{GITHUB_USERNAME}})
```

---

#### `{{AUTHOR_EMAIL}}`
**Type:** String (email format)
**Resolution order:**
1. Config file: `author.email`
2. Git config: `git config user.email`
3. Prompt user interactively

**Usage:**
```markdown
For questions, contact {{AUTHOR_EMAIL}}.
```

---

#### `{{GITHUB_USERNAME}}`
**Type:** String
**Resolution order:**
1. Config file: `author.github_username`
2. Extract from git remote URL
   - `https://github.com/username/repo` → `username`
3. Prompt user interactively (optional)

**Usage:**
```markdown
[![GitHub](https://img.shields.io/github/followers/{{GITHUB_USERNAME}}?style=social)]
```

---

### Licensing

#### `{{LICENSE_TYPE}}`
**Type:** String (SPDX identifier)
**Supported values:** `MIT`, `Apache-2.0`, `GPL-3.0`, `BSD-3-Clause`, `Unlicense`
**Resolution order:**
1. Config file: `defaults.license`
2. Detect from existing `LICENSE` file (parse header)
3. Recommend `MIT` for open source
4. Prompt user with recommendation

**Usage:**
```markdown
## License

This project is licensed under the {{LICENSE_TYPE}} License.
```

---

#### `{{YEAR}}`
**Type:** String (4-digit year)
**Resolution:** Always current year from system clock

**Usage:**
```
Copyright (c) {{YEAR}} {{AUTHOR_NAME}}
```

---

### Technical Context

#### `{{TECH_STACK}}`
**Type:** String (comma-separated)
**Resolution:** Output from `detect-stack.sh` script
**Format:** `Python, FastAPI, PostgreSQL, Docker`

**Usage:**
```markdown
## Tech Stack

Built with: {{TECH_STACK}}
```

---

#### `{{PRIMARY_LANGUAGE}}`
**Type:** String
**Resolution:** Highest confidence language from stack detection
**Values:** `Python`, `JavaScript`, `TypeScript`, `Go`, `Rust`, `Java`, `Ruby`, `PHP`, etc.

**Usage:**
```markdown
![Language](https://img.shields.io/badge/language-{{PRIMARY_LANGUAGE}}-blue)
```

---

### CI/CD Context

#### `{{CI_PROVIDER}}`
**Type:** String
**Resolution order:**
1. Config: `defaults.ci_provider` (if not `"auto"`)
2. Detect from git remote:
   - `github.com` → `github-actions`
   - `gitlab.com` → `gitlab-ci`
   - `bitbucket.org` → `bitbucket-pipelines`
3. Default: `github-actions`

**Values:** `github-actions`, `gitlab-ci`, `circleci`, `bitbucket-pipelines`, `none`

---

#### `{{CI_BADGE}}`
**Type:** Markdown string (badge image)
**Resolution:** Generate based on `{{CI_PROVIDER}}` and repo info
**Conditional:** Only include if CI configured

**Format:**
```markdown
![CI](https://github.com/{{GITHUB_USERNAME}}/{{PROJECT_NAME}}/workflows/CI/badge.svg)
```

---

#### `{{COVERAGE_BADGE}}`
**Type:** Markdown string (badge image)
**Resolution:** Generate if coverage tool detected
**Conditional:** Only include if coverage configured

**Detection:**
- Python: `pytest-cov` in requirements
- JavaScript: `nyc` or `jest` with coverage
- Go: `go test -cover`

**Format:**
```markdown
![Coverage](https://img.shields.io/codecov/c/github/{{GITHUB_USERNAME}}/{{PROJECT_NAME}})
```

---

### Version Information

#### `{{VERSION}}`
**Type:** String (semver format)
**Resolution order:**
1. Parse from `package.json` → `version`
2. Parse from `pyproject.toml` → `[project].version`
3. Parse from `Cargo.toml` → `[package].version`
4. Git tag (latest): `git describe --tags --abbrev=0`
5. Default: `0.1.0`

**Usage:**
```markdown
## Installation

Install version {{VERSION}}:
```

---

#### `{{VERSION_BADGE}}`
**Type:** Markdown string (badge image)
**Resolution:** Generate if version available
**Conditional:** Only include if version in manifest

**Format:**
```markdown
![Version](https://img.shields.io/badge/version-{{VERSION}}-blue)
```

---

## Conditional Blocks

### Language Conditionals

#### `{{#PYTHON}}...{{/PYTHON}}`
**Condition:** Primary language is Python
**Usage:**
```markdown
{{#PYTHON}}
## Installation

```bash
pip install {{PROJECT_NAME}}
```
{{/PYTHON}}
```

---

#### `{{#JAVASCRIPT}}...{{/JAVASCRIPT}}`
**Condition:** Primary language is JavaScript
**Usage:**
```markdown
{{#JAVASCRIPT}}
```bash
npm install {{PROJECT_NAME}}
```
{{/JAVASCRIPT}}
```

**Also available:**
- `{{#TYPESCRIPT}}...{{/TYPESCRIPT}}`
- `{{#GO}}...{{/GO}}`
- `{{#RUST}}...{{/RUST}}`
- `{{#JAVA}}...{{/JAVA}}`

---

### Feature Conditionals

#### `{{#HAS_CI}}...{{/HAS_CI}}`
**Condition:** CI/CD configured
**Detection:** CI workflow files exist

**Usage:**
```markdown
{{#HAS_CI}}
![CI Status]({{CI_BADGE}})
{{/HAS_CI}}
```

---

#### `{{#HAS_TESTS}}...{{/HAS_TESTS}}`
**Condition:** Test framework detected
**Detection:**
- Python: `pytest`, `unittest`
- JavaScript: `jest`, `mocha`
- Go: `*_test.go` files
- Rust: `#[test]` in code

**Usage:**
```markdown
{{#HAS_TESTS}}
## Testing

Run tests:
```bash
{{TEST_COMMAND}}
```
{{/HAS_TESTS}}
```

---

#### `{{#HAS_DOCKER}}...{{/HAS_DOCKER}}`
**Condition:** Dockerfile exists
**Usage:**
```markdown
{{#HAS_DOCKER}}
## Docker

```bash
docker build -t {{PROJECT_NAME}} .
docker run {{PROJECT_NAME}}
```
{{/HAS_DOCKER}}
```

---

#### `{{#IS_LIBRARY}}...{{/IS_LIBRARY}}`
**Condition:** Project is a library (not application)
**Detection:**
- Python: `setup.py` or `pyproject.toml` with `[project]`
- JavaScript: `package.json` with `"type": "module"` or `"main"`
- Go: No `func main()`
- Rust: `[lib]` in `Cargo.toml`

---

#### `{{#IS_CLI}}...{{/IS_CLI}}`
**Condition:** Project is a CLI tool
**Detection:**
- Python: `console_scripts` in setup.py
- JavaScript: `"bin"` in package.json
- Go: `func main()` in `cmd/`
- Rust: `[[bin]]` in Cargo.toml

---

### Negation Conditionals

#### `{{^HAS_CI}}...{{/HAS_CI}}`
**Condition:** CI **NOT** configured (inverted)

**Usage:**
```markdown
{{^HAS_CI}}
⚠️ **Note:** No CI configured. Consider adding automated testing.
{{/HAS_CI}}
```

**Also available:**
- `{{^HAS_TESTS}}...{{/HAS_TESTS}}`
- `{{^HAS_LICENSE}}...{{/HAS_LICENSE}}`
- `{{^HAS_CONTRIBUTING}}...{{/HAS_CONTRIBUTING}}`

---

## Derived Variables

### `{{TEST_COMMAND}}`
**Type:** String (shell command)
**Resolution:** Based on detected test framework
**Values:**
- Python: `pytest` or `python -m unittest`
- JavaScript: `npm test`
- Go: `go test ./...`
- Rust: `cargo test`

---

### `{{LINT_COMMAND}}`
**Type:** String (shell command)
**Resolution:** Based on detected linter
**Values:**
- Python: `flake8` or `pylint`
- JavaScript: `npm run lint`
- Go: `golangci-lint run`
- Rust: `cargo clippy`

---

### `{{FORMAT_COMMAND}}`
**Type:** String (shell command)
**Resolution:** Based on detected formatter
**Values:**
- Python: `black .`
- JavaScript: `npm run format` or `prettier --write .`
- Go: `gofmt -w .`
- Rust: `cargo fmt`

---

## Badge Variables

### GitHub-specific Badges

```markdown
{{LICENSE_BADGE}}
![License](https://img.shields.io/badge/license-{{LICENSE_TYPE}}-blue.svg)

{{STARS_BADGE}}
![Stars](https://img.shields.io/github/stars/{{GITHUB_USERNAME}}/{{PROJECT_NAME}}?style=social)

{{FORKS_BADGE}}
![Forks](https://img.shields.io/github/forks/{{GITHUB_USERNAME}}/{{PROJECT_NAME}}?style=social)

{{ISSUES_BADGE}}
![Issues](https://img.shields.io/github/issues/{{GITHUB_USERNAME}}/{{PROJECT_NAME}})

{{LAST_COMMIT_BADGE}}
![Last Commit](https://img.shields.io/github/last-commit/{{GITHUB_USERNAME}}/{{PROJECT_NAME}})
```

**Conditional inclusion:** Only for public GitHub repos

---

### Package Registry Badges

#### PyPI (Python)
```markdown
{{#PYPI_PACKAGE}}
![PyPI](https://img.shields.io/pypi/v/{{PROJECT_NAME}})
![Python Version](https://img.shields.io/pypi/pyversions/{{PROJECT_NAME}})
![Downloads](https://img.shields.io/pypi/dm/{{PROJECT_NAME}})
{{/PYPI_PACKAGE}}
```

#### npm (JavaScript)
```markdown
{{#NPM_PACKAGE}}
![npm](https://img.shields.io/npm/v/{{PROJECT_NAME}})
![Downloads](https://img.shields.io/npm/dm/{{PROJECT_NAME}})
{{/NPM_PACKAGE}}
```

#### crates.io (Rust)
```markdown
{{#CRATES_PACKAGE}}
![Crates.io](https://img.shields.io/crates/v/{{PROJECT_NAME}})
![Downloads](https://img.shields.io/crates/d/{{PROJECT_NAME}})
{{/CRATES_PACKAGE}}
```

---

## Custom Variables

Users can define custom variables in config:

```yaml
templates:
  custom_variables:
    COMPANY_NAME: "Acme Corp"
    SUPPORT_EMAIL: "support@acme.com"
    SLACK_CHANNEL: "#dev-support"
```

**Usage in templates:**
```markdown
For enterprise support, contact {{COMPANY_NAME}} at {{SUPPORT_EMAIL}}.
```

---

## Variable Resolution Flow

```
1. Check custom_variables in config
2. Check standard resolution order (git config, package manifests, etc.)
3. Apply conditional logic (language detection, feature detection)
4. Generate derived variables (commands, badges)
5. Prompt for missing required variables
6. Emit warnings for unresolved optional variables
7. Render template with resolved variables
```

---

## Error Handling

### Missing Required Variables

If a required variable cannot be resolved:
1. **Prompt user interactively** (if terminal available)
2. **Use placeholder** + emit warning (if non-interactive)
3. **Fail validation** (if `--strict` mode)

**Example:**
```
⚠️  Warning: Could not resolve {{PROJECT_NAME}}
Using placeholder "my-project" - please update manually
```

### Invalid Variable Values

If a variable has invalid format:
1. **Validate format** (email, URL, semver)
2. **Emit error** with expected format
3. **Re-prompt** or use fallback

**Example:**
```
❌ Error: {{AUTHOR_EMAIL}} has invalid format: "not-an-email"
Expected: valid email address (e.g., user@example.com)
```

---

## Testing Variables

For testing template generation without actual project context:

```bash
# Dry-run mode with mock variables
bash scripts/generate-template.sh \
  --template "github/README.md" \
  --output "/tmp/test-README.md" \
  --mock-vars \
  --vars "project_name=test-project,author=Test User"
```

Mock variables bypass resolution and use provided values directly.

---

## Advanced Usage

### Variable Transformation

Apply transformations to variables:

```markdown
{{PROJECT_NAME_UPPER}}     # MY-PROJECT
{{PROJECT_NAME_SNAKE}}     # my_project
{{PROJECT_NAME_PASCAL}}    # MyProject
{{PROJECT_NAME_KEBAB}}     # my-project (original)
```

### Variable Concatenation

```markdown
{{GITHUB_REPO_URL}}        # https://github.com/{{GITHUB_USERNAME}}/{{PROJECT_NAME}}
{{NPM_INSTALL_COMMAND}}    # npm install {{PROJECT_NAME}}
{{PYPI_INSTALL_COMMAND}}   # pip install {{PROJECT_NAME}}
```

### Date Variables

```markdown
{{YEAR}}           # 2024
{{DATE}}           # 2024-02-09
{{DATETIME}}       # 2024-02-09T10:30:00Z
{{MONTH}}          # February
{{MONTH_NUM}}      # 02
```

---

## Reference Implementation

Variable resolution is implemented in:
- **`scripts/generate-template.sh`** - Main template rendering
- **`scripts/lib/variables.sh`** - Variable resolution functions
- **`scripts/lib/detection.sh`** - Context detection helpers

See these scripts for complete resolution logic and fallback handling.
