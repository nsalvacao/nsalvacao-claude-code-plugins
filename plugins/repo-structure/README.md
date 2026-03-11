# Repo-Structure Plugin

Enterprise-grade repository structure analyzer, validator, and scaffolder with intelligent automation for Claude Code.

## Overview

**Repo-Structure** transforms repositories into professional, compliant, production-ready projects through intelligent analysis, automated scaffolding, and continuous quality monitoring.

### Key Features

- 🔍 **Smart Detection**: Automatically identifies tech stack, frameworks, and project type
- 🏗️ **Intelligent Scaffolding**: Creates comprehensive structure (docs, configs, CI/CD, compliance)
- 📊 **Quality Scoring**: Quantitative assessment across Documentation, Security, CI/CD, and Community
- ✅ **Compliance Validation**: OpenSSF Scorecard, CII Best Practices, OWASP, SOC2
- 🤖 **Autonomous Agents**: Self-guided analysis, validation, and improvement workflows
- 🎯 **Template Intelligence**: Context-aware templates with automatic variable substitution
- 🔧 **Automation Toolkit**: Pre-commit hooks, linters, formatters, security scanning

## Use Cases

1. **New Repositories**: Bootstrap professional structure from day one
2. **Existing Projects**: Audit and upgrade legacy repos to modern standards
3. **Continuous Quality**: Periodic audits to maintain excellence
4. **Compliance**: Ensure adherence to industry standards (OpenSSF, CII, SOC2)

## Installation

### From Marketplace

```bash
cc plugin install repo-structure
```

### From Source

```bash
git clone https://github.com/nsalvacao/nsalvacao-claude-code-plugins
cc --plugin-dir ./nsalvacao-claude-code-plugins/plugins/repo-structure
```

## Prerequisites

### Required
- Git 2.x+
- Python 3.8+
- Bash 4.x+

### Recommended
- `gh` CLI (for GitHub API integration)
- `jq` (for JSON parsing)
- `pre-commit` framework (for hooks automation)

### Optional
- `yq` (for YAML validation)
- Language-specific tools (npm, pip, cargo, etc.)

## Configuration

Create `.claude/repo-structure.config.yaml` in your project root:

```yaml
# Author Information
author:
  name: "Your Name"
  email: "your@email.com"
  github_username: "yourusername"

# Project Defaults
defaults:
  license: "MIT"
  code_of_conduct: "contributor-covenant-2.1"
  ci_provider: "auto"

# Template Source
templates:
  source: "embedded"
  custom_repo_url: ""
  merge_strategy: "override"

# Quality Scoring
scoring:
  enabled_categories:
    - documentation
    - security
    - ci_cd
    - community
  weights:
    documentation: 25
    security: 25
    ci_cd: 25
    community: 25
  threshold_warnings: 70
  threshold_critical: 50

# Validation
validation:
  validate_links: "smart"
  pre_commit_strictness: "warnings"
  check_ci_status: true

# Automation
automation:
  auto_approve_mode: false
  create_branch: true
  branch_prefix: "feat/repo-structure"
  hooks_installer: "pre-commit"

# Compliance Frameworks
compliance:
  enabled_frameworks:
    - openssf-scorecard
    - cii-best-practices
  auto_detect_type: true

# Advanced
advanced:
  parallel_validation: true
  cache_github_api: true
  historical_tracking: true
  generate_badges: true
```

**Note**: All fields are optional. The plugin works with sensible defaults and reads from `git config` when available.

## Commands

### `/repo-setup`

Main orchestration command for complete repository setup.

**Usage:**
```bash
/repo-setup
/repo-setup --mode=new
/repo-setup --mode=existing
/repo-setup --mode=audit
/repo-setup --dry-run
/repo-setup --auto-approve
```

**Behavior:**
1. Detects project type and tech stack
2. Analyzes current structure
3. Proposes improvements by category
4. Requests approval
5. Executes changes in new branch
6. Validates results

**Arguments:**
- `--mode=[new|existing|audit]`: Override auto-detection
- `--dry-run`: Preview changes without applying
- `--auto-approve`: Skip approval prompts (use with caution)

---

### `/repo-audit`

Non-destructive quality check with detailed scoring.

**Usage:**
```bash
/repo-audit
/repo-audit --format=json
/repo-audit --format=markdown
/repo-audit --categories=security,ci
```

**Output:**
- Terminal colorized report
- Saved markdown file (`.repo-audit-YYYY-MM-DD.md`)
- Quality score (0-100) with category breakdown
- Specific issues with severity and point impact

**Arguments:**
- `--format=[json|markdown|terminal]`: Output format
- `--categories=[all|security|docs|ci|community]`: Filter categories

---

### `/repo-improve`

Targeted improvements for specific categories.

**Usage:**
```bash
/repo-improve --category=security
/repo-improve --category=docs
/repo-improve --aggressive
```

**Behavior:**
- Interactive: Presents menu if no category specified
- Proposes targeted fixes
- Requests approval before applying
- Reports score improvement

**Arguments:**
- `--category=[security|docs|ci|community]`: Focus area
- `--aggressive`: Apply opinionated configs without prompts

---

### `/repo-validate`

Fast validation of repository structure.

**Usage:**
```bash
/repo-validate
/repo-validate --fix
/repo-validate --strict
```

**Behavior:**
- Checks completeness of created structure
- Validates file formats (YAML, JSON, Markdown)
- Verifies links and badges (if configured)
- Reports issues with fix suggestions

**Arguments:**
- `--fix`: Automatically fix issues where possible
- `--strict`: Enforce stricter validation rules

## Agents

### `structure-architect`

Autonomous agent for repository analysis and scaffolding.

**Triggers:**
- Proactively when `/repo-setup` invoked
- User mentions "setup repository structure", "create project structure"

**Capabilities:**
- Tech stack detection (monorepo-aware)
- Context-aware template generation
- Multi-category planning and execution
- Git branch management

**Model**: Sonnet 4.5 (requires reasoning for intelligent decisions)

---

### `structure-validator`

Fast validation agent for quality assurance.

**Triggers:**
- Proactively after Write/Edit in repo root
- Explicit invocation via `/repo-validate`

**Capabilities:**
- Structure completeness checks
- Format validation (YAML, JSON, Markdown)
- Link and badge verification
- CI status checking (via GitHub API)

**Model**: Haiku 4.5 (optimized for fast validation)

---

### `template-customizer`

Intelligent template adaptation agent.

**Triggers:**
- User requests "customize template", "improve README", "adjust docs"

**Capabilities:**
- Context-aware template modifications
- Badge generation based on available data
- Section reordering for clarity
- Content enhancement suggestions

**Model**: Sonnet 4.5 (requires contextual understanding)

## Skills

### `repository-templates/`

Complete template library for professional repositories.

**Included Templates:**
- **GitHub**: README, CONTRIBUTING, CODE_OF_CONDUCT, SECURITY, issue/PR templates
- **Configs**: .editorconfig, .gitignore, .prettierrc, .eslintrc, linter configs
- **CI/CD**: GitHub Actions, GitLab CI, CircleCI workflows
- **Docs**: mkdocs.yml, docusaurus configs, API doc templates

**Variable Substitution:**
- `{{PROJECT_NAME}}`, `{{AUTHOR_NAME}}`, `{{LICENSE_TYPE}}`, `{{YEAR}}`, etc.

---

### `tech-stack-detection/`

Intelligent detection of languages, frameworks, and tools.

**Detection Methods:**
- File pattern matching (package.json → Node.js, requirements.txt → Python)
- Dependency analysis (lockfiles, manifests)
- Extension frequency (.py → Python, .go → Go)
- Confidence scoring for ambiguous cases

**Supported Stacks:**
- Languages: Python, JavaScript/TypeScript, Go, Rust, Java, C/C++, Ruby, PHP
- Frameworks: React, Vue, Django, FastAPI, Express, Rails, Laravel
- Tools: Docker, Kubernetes, Terraform, CI/CD systems

---

### `quality-scoring/`

Quantitative quality assessment engine.

**Scoring Categories:**
- **Documentation** (25 pts): README completeness, API docs, inline comments
- **Security** (25 pts): SECURITY.md, dependabot, scanning, vulnerability management
- **CI/CD** (25 pts): Automated tests, linting, releases, code coverage
- **Community** (25 pts): LICENSE, CODE_OF_CONDUCT, contributing guidelines, issue templates

**Features:**
- Weighted scoring by importance
- Historical tracking (`.repo-quality-history.json`)
- Threshold alerts (critical < 50, warnings < 70)
- Actionable recommendations

---

### `compliance-standards/`

Industry standards validation and compliance checking.

**Supported Frameworks:**
- **OpenSSF Scorecard**: Security best practices for open-source
- **CII Best Practices**: Core Infrastructure Initiative badge criteria
- **OWASP Top 10**: Web application security standards
- **SOC2**: Enterprise security and availability (Type I/II)

**Features:**
- Auto-detection of relevant frameworks (public → OpenSSF, private → SOC2)
- Percentage compliance reporting
- Gap analysis with actionable items
- Official documentation links

---

### `automation-strategies/`

Automation setup and configuration toolkit.

**Capabilities:**
- Pre-commit hooks installation (`pre-commit` framework)
- Language-specific linting/formatting (black, prettier, gofmt, etc.)
- Security scanning (detect-secrets, bandit, gosec)
- CI/CD workflow generation
- Git hooks (commit-msg validation, branch naming)

**Stack-Adaptive:**
- Python → black, flake8, mypy, bandit
- JavaScript → prettier, eslint, husky
- Go → gofmt, golangci-lint
- Rust → rustfmt, clippy

## Quality Score Interpretation

| Score | Grade | Meaning |
|-------|-------|---------|
| 95-100 | ⭐ Outstanding | Production-ready, exemplary quality |
| 85-94 | ✅ Excellent | Minor polish opportunities |
| 70-84 | ⚠️ Good | Some areas need attention |
| 50-69 | 🔶 Poor | Significant improvements needed |
| 0-49 | 🚨 Critical | Immediate action required |

## Workflow Examples

### 1. New Repository

```bash
# Initialize git and setup structure
cd my-new-project
git init
/repo-setup --mode=new

# Agent prompts for:
# - Project name (from git remote or dir name)
# - License type (default: MIT)
# - Description

# Agent creates:
# ✅ README.md with badges
# ✅ LICENSE (MIT)
# ✅ CONTRIBUTING.md
# ✅ CODE_OF_CONDUCT.md
# ✅ .github/ workflows
# ✅ Pre-commit hooks
# ✅ Linter configs
# ✅ .gitignore

# Validation runs automatically
# Score: 100/100 ⭐

# Changes committed to: feat/repo-structure-setup
```

### 2. Existing Project

```bash
cd existing-project
/repo-setup --mode=existing

# Agent analyzes:
# - Current structure: 45/100 🔶
# - Missing: LICENSE, CONTRIBUTING, CI/CD
# - Incomplete: README (no Usage section)

# Agent proposes improvements by category:
# 1. Documentation (+20 pts)
# 2. Security (+15 pts)
# 3. CI/CD (+20 pts)
# 4. Community (+15 pts)

# User approves categories 1, 3, 4
# Agent applies changes
# New score: 87/100 ✅

# Before/after report saved
```

### 3. Periodic Audit

```bash
/repo-audit

# Output:
# Quality Score: 82/100 ⚠️
#
# Category Breakdown:
# - Documentation: 22/25 (88%)
# - Security: 18/25 (72%) ⚠️
#   - Missing: Dependabot configuration (-5 pts)
#   - Missing: Security scanning workflow (-2 pts)
# - CI/CD: 25/25 (100%) ✅
# - Community: 17/25 (68%) ⚠️
#   - CODE_OF_CONDUCT outdated (-3 pts)
#
# Recommendations:
# 1. Enable Dependabot in .github/dependabot.yml
# 2. Add CodeQL scanning workflow
# 3. Update CODE_OF_CONDUCT to Contributor Covenant 2.1
#
# Report saved: .repo-audit-2024-02-09.md
```

## Hooks

The plugin includes two event hooks:

### Pre-Commit Validation

Validates structure files before allowing commit.

**Checks:**
- YAML/JSON syntax
- Markdown formatting
- Required file presence
- Link validity (if configured)

**Configuration:**
```yaml
validation:
  pre_commit_strictness: "warnings"  # strict|warnings|info
```

### Post-Setup Verification

Automatically validates after structure creation.

**Behavior:**
- Triggers after batch Write operations
- Runs `structure-validator` agent
- Reports issues immediately
- Suggests fixes if validation fails

## Troubleshooting

### "Template variable not resolved"

**Cause**: Missing git config or settings.

**Fix:**
```bash
git config user.name "Your Name"
git config user.email "your@email.com"
```

Or add to `.claude/repo-structure.config.yaml`:
```yaml
author:
  name: "Your Name"
  email: "your@email.com"
```

---

### "GitHub API rate limit exceeded"

**Cause**: Too many unauthenticated API calls.

**Fix:**
```bash
gh auth login
```

Or configure caching:
```yaml
advanced:
  cache_github_api: true
```

---

### "Pre-commit hooks not installing"

**Cause**: `pre-commit` framework not installed.

**Fix:**
```bash
pip install pre-commit
```

Or use native hooks:
```yaml
automation:
  hooks_installer: "native"
```

---

### "Stack detection fails for monorepo"

**Expected**: Plugin detects multiple stacks with confidence scores.

**Verify** with:
```bash
cd /path/to/project
bash plugins/repo-structure/scripts/detect-stack.sh
```

## Contributing

Contributions welcome! Please:

1. Follow existing patterns and conventions
2. Add tests for new features
3. Update documentation
4. Run validation before submitting PR

## License

MIT License - see LICENSE file for details.

## Support

- Issues: https://github.com/nsalvacao/nsalvacao-claude-code-plugins/issues
- Discussions: https://github.com/nsalvacao/nsalvacao-claude-code-plugins/discussions

---

**Built with ❤️ for professional software engineering**
