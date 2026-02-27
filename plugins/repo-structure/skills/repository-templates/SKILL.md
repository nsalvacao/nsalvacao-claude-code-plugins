---
name: Repository Templates
description: This skill should be used when the user asks to "create README", "add license", "setup contributing guide", "create security policy", "add code of conduct", "generate github templates", or mentions repository documentation files. Provides comprehensive professional templates for enterprise-grade repository structure.
version: 0.1.0
---

# Repository Templates

Professional, enterprise-grade templates for repository documentation and configuration files.

## Overview

This skill provides battle-tested templates that follow official standards and best practices:
- **GitHub community standards** (README, CONTRIBUTING, CODE_OF_CONDUCT, SECURITY)
- **Configuration files** (.editorconfig, .gitignore, linter configs)
- **CI/CD workflows** (GitHub Actions, GitLab CI, CircleCI)
- **Documentation sites** (MkDocs, Docusaurus configurations)

All templates support intelligent variable substitution and context-aware generation.

## Template Categories

### GitHub Documentation Templates

Located in `templates/github/`:

#### README.md
- Adaptive structure based on project type (library, CLI tool, web app, framework)
- Auto-generated badges (license, CI status, coverage, version)
- Standard sections: Features, Installation, Usage, Contributing, License
- Context-aware examples based on detected tech stack

**Variable substitution:**
```
{{PROJECT_NAME}}     - From git remote or directory name
{{DESCRIPTION}}      - From package.json/pyproject.toml or prompt
{{AUTHOR_NAME}}      - From git config or settings
{{LICENSE_TYPE}}     - From settings or prompt
{{TECH_STACK}}       - Detected stack (comma-separated)
{{CI_BADGE}}         - Appropriate CI badge markdown
{{COVERAGE_BADGE}}   - Coverage badge if tool detected
```

#### LICENSE
Support for top 5 OSI-approved licenses:
- **MIT** - Permissive, most popular for open source
- **Apache-2.0** - Permissive with patent grant
- **GPL-3.0** - Copyleft, requires derivative works to be open source
- **BSD-3-Clause** - Permissive with attribution
- **Unlicense** - Public domain dedication

**Selection logic:**
1. Check config file `defaults.license`
2. Detect from existing LICENSE file
3. Recommend MIT for open source
4. Prompt interactively if ambiguous

#### CONTRIBUTING.md
- Clear contribution workflow (fork, branch, commit, PR)
- Code style guidelines
- Testing requirements
- Review process expectations

#### CODE_OF_CONDUCT.md
Uses **Contributor Covenant 2.1** (most widely adopted):
- Clear community standards
- Scope of application
- Enforcement procedures
- Contact information placeholder

#### SECURITY.md
- Supported versions table
- Vulnerability reporting instructions
- Response timeline expectations
- Security update process

#### Issue/PR Templates
Located in `templates/github/.github/`:
- **ISSUE_TEMPLATE/bug_report.md** - Structured bug reports
- **ISSUE_TEMPLATE/feature_request.md** - Feature proposals
- **PULL_REQUEST_TEMPLATE.md** - PR checklist and description

### Configuration Templates

Located in `templates/configs/`:

#### .editorconfig
Universal editor configuration:
- Consistent indentation (2 spaces for YAML/JSON, 4 for Python)
- UTF-8 encoding
- LF line endings
- Trim trailing whitespace
- Final newline insertion

#### .gitignore
Stack-adaptive patterns:
- **Python**: `__pycache__/`, `*.pyc`, venv/, `.pytest_cache/`
- **Node.js**: `node_modules/`, `dist/`, `.env`, `*.log`
- **Go**: Binaries, `vendor/`
- **Rust**: `target/`, `Cargo.lock` (for binaries)
- **Universal**: `.DS_Store`, IDE files, OS artifacts

#### Linter Configs
- **Python**: `.flake8`, `pyproject.toml` (black, mypy)
- **JavaScript**: `.eslintrc.json`, `.prettierrc`
- **TypeScript**: `tsconfig.json`
- **Go**: `.golangci.yml`

### CI/CD Workflow Templates

Located in `templates/ci/`:

#### GitHub Actions
- **`test.yml`** - Run tests on push/PR
- **`lint.yml`** - Code quality checks
- **`release.yml`** - Automated releases on tags
- **`security.yml`** - CodeQL scanning, dependency review

**Stack-adaptive:**
- Python → pytest, coverage, black
- Node.js → npm test, eslint
- Go → go test, golangci-lint
- Rust → cargo test, clippy

#### GitLab CI
- `.gitlab-ci.yml` with stages: test, lint, build, deploy
- Cache configuration for dependencies
- Artifacts management

#### CircleCI
- `.circleci/config.yml` with workflows
- Docker layer caching
- Parallel test execution

**Provider detection:**
- Analyze git remote URL
- GitHub → Actions templates
- GitLab → CI templates
- Bitbucket → Pipelines templates
- Config override: `defaults.ci_provider`

### Documentation Site Templates

Located in `templates/docs/`:

#### MkDocs
- `mkdocs.yml` with Material theme
- Navigation structure
- Search configuration
- GitHub Pages deployment

#### Docusaurus
- `docusaurus.config.js`
- Sidebar configuration
- Blog setup
- API documentation integration

**Selection criteria:**
- Python projects → MkDocs
- JavaScript projects → Docusaurus
- API-heavy projects → Docusaurus (better API docs)

## Template Generation Workflow

### 1. Context Detection

Analyze repository to gather context:

```bash
# Detect tech stack
bash $CLAUDE_PLUGIN_ROOT/skills/tech-stack-detection/scripts/detect-stack.sh

# Read git config
git config user.name
git config user.email
git config remote.origin.url

# Parse package manifests
# package.json, pyproject.toml, Cargo.toml, go.mod
```

### 2. Variable Resolution

Resolve template variables with intelligent fallbacks:

```
{{PROJECT_NAME}}:
  1. Extract from git remote URL
  2. Use directory name
  3. Fallback: "my-project" + warning

{{AUTHOR_NAME}}:
  1. Config: author.name
  2. Git config: user.name
  3. Prompt interactively

{{DESCRIPTION}}:
  1. Parse from package.json/pyproject.toml
  2. Prompt interactively

{{LICENSE_TYPE}}:
  1. Config: defaults.license
  2. Detect from existing LICENSE
  3. Recommend: MIT
  4. Prompt if ambiguous
```

### 3. Template Rendering

Render template with resolved variables:

```bash
# Using the generation script
bash $CLAUDE_PLUGIN_ROOT/scripts/generate-template.sh \
  --template "github/README.md" \
  --output "./README.md" \
  --vars "project_name=my-project,author=Nuno"
```

### 4. Badge Generation

Generate appropriate badges based on available data:

**Always include:**
- License badge (if LICENSE exists)

**Conditional:**
- CI status (if CI configured)
- Coverage (if coverage tool detected)
- Version (if in package.json/pyproject.toml)
- Stars/Forks (if GitHub public repo)

**Using shields.io:**
```markdown
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![CI](https://github.com/{{USER}}/{{REPO}}/workflows/CI/badge.svg)
![Coverage](https://img.shields.io/codecov/c/github/{{USER}}/{{REPO}})
```

## Template Customization

### Custom Template Repository

Support for external template sources:

**Configuration:**
```yaml
templates:
  source: "custom"
  custom_repo_url: "https://github.com/org/templates"
  merge_strategy: "override"  # or "merge"
```

**Repository structure:**
```
custom-templates/
├── github/
│   ├── README.md.template
│   ├── CONTRIBUTING.md.template
│   └── ...
├── configs/
│   └── .gitignore.template
└── ci/
    └── github-actions/
        └── test.yml.template
```

**Loading order:**
1. Fetch custom templates
2. If `merge_strategy: "override"` → custom completely replaces embedded
3. If `merge_strategy: "merge"` → custom overrides only matching files

### Variable Syntax

Templates use Mustache-style syntax:

```markdown
# {{PROJECT_NAME}}

{{DESCRIPTION}}

## Installation

{{#PYTHON}}
```bash
pip install {{PROJECT_NAME}}
```
{{/PYTHON}}

{{#JAVASCRIPT}}
```bash
npm install {{PROJECT_NAME}}
```
{{/JAVASCRIPT}}

## License

Licensed under {{LICENSE_TYPE}}.
```

**Conditional blocks:**
- `{{#PYTHON}}...{{/PYTHON}}` - Include if Python detected
- `{{^TESTING}}...{{/TESTING}}` - Include if NOT testing
- `{{#HAS_CI}}...{{/HAS_CI}}` - Include if CI configured

## Template Quality Standards

All templates follow:

### Official Sources
- **Contributor Covenant** for CODE_OF_CONDUCT
- **OSI-approved** licenses
- **GitHub recommended** issue/PR templates
- **EditorConfig** official specification

### Best Practices
- Clear, professional language
- Actionable instructions
- No assumptions about tech stack
- Accessibility considerations (clear headings, alt text)

### Consistency
- Markdown formatting (ATX headings, fenced code blocks)
- Consistent variable naming
- Uniform badge placement
- Standard section ordering

## Usage Examples

### Generate Complete Documentation Set

```markdown
Create complete GitHub documentation:
1. README.md (adaptive to project type)
2. LICENSE (MIT)
3. CONTRIBUTING.md
4. CODE_OF_CONDUCT.md (Contributor Covenant 2.1)
5. SECURITY.md
6. .github/ISSUE_TEMPLATE/bug_report.md
7. .github/ISSUE_TEMPLATE/feature_request.md
8. .github/PULL_REQUEST_TEMPLATE.md
```

### Generate Stack-Specific Configs

```markdown
For Python project, create:
1. .editorconfig
2. .gitignore (Python patterns)
3. pyproject.toml (black, mypy configs)
4. .flake8
5. .github/workflows/test.yml (pytest, coverage)
```

### Generate CI/CD Workflows

```markdown
For Node.js project on GitHub:
1. Detect package.json (has test script, eslint config)
2. Create .github/workflows/test.yml (npm test, eslint)
3. Create .github/workflows/release.yml (semantic-release)
4. Add CI badge to README
```

## Additional Resources

### Reference Files

For complete template contents and patterns:
- **`references/template-library.md`** - All template contents
- **`references/variable-reference.md`** - Complete variable documentation
- **`references/badge-patterns.md`** - Badge generation patterns

### Template Files

Browse actual templates:
- **`templates/github/`** - GitHub documentation templates
- **`templates/configs/`** - Configuration file templates
- **`templates/ci/`** - CI/CD workflow templates
- **`templates/docs/`** - Documentation site templates

### Example Outputs

See generated examples:
- **`examples/python-project/`** - Complete Python project structure
- **`examples/nodejs-project/`** - Complete Node.js project structure
- **`examples/go-project/`** - Complete Go project structure

## Integration Points

This skill works with:
- **tech-stack-detection** skill for context-aware generation
- **quality-scoring** skill for template completeness validation
- **automation-strategies** skill for CI/CD template selection

Template generation is orchestrated by the `structure-architect` agent using this skill's knowledge and resources.
