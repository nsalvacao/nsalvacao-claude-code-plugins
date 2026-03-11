# repo-structure v0.2.0 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Elevate repo-structure from 33% launch-ready to v0.2.0 by fixing 4 critical bugs, adding 9 missing P0.3 templates, a CI debugging suite, /pr-respond command, 4 new hooks, automation-validator agent, 2 missing scripts, and 4 reference files (~29 components total).

**Architecture:** All changes are additive within the existing plugin structure at `plugins/repo-structure/`. Scripts use bash (hook scripts) and Python (scoring/template generation). New templates use the existing Mustache-style rendering system already present in `scripts/generate-template.py`. New skills/commands/agents follow the existing `.md` file pattern.

**Tech Stack:** Bash 5+, Python 3.8+, Mustache-style templates ({{VAR}}, {{#COND}}...{{/COND}}), Claude Code plugin conventions (commands/.md, agents/.md, skills/*/SKILL.md, hooks/hooks.json)

**Root path:** `/mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure`

**WSL/NTFS rules:** Always LF line endings. Never CRLF. Use `n=$((n+1))` not `((n++))` with `set -e`. Use `$CLAUDE_PLUGIN_ROOT` for hook paths.

---

### Task 1: Group A — Bug Fixes (4 bugs)

**Files:**
- Modify: `scripts/calculate-score.py` (lines ~403-407)
- Modify: `hooks/scripts/validate-structure.sh` (line ~50)
- Modify: `scripts/generate-template.py` (add detection functions)
- Modify: `scripts/detect-stack.sh` (jq fallback + dynamic confidence)

**Step 1: Fix B1 — duplicate coverage scoring in calculate-score.py**

Read `scripts/calculate-score.py` lines 395–420. Find the block:
```python
if coverage_found:
    scores["automated_testing"] += 2

# Coverage >90% (additional 2 pts) - heuristic
if coverage_found:
    scores["automated_testing"] += 2
```
Remove the first `if coverage_found: scores["automated_testing"] += 2` block (the non-commented one that appears before the "heuristic" comment). The second block (with the "Coverage >90%" comment) is the intended heuristic and should remain.

**Step 2: Verify B1**
```bash
grep -n "automated_testing.*+= 2" /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure/scripts/calculate-score.py
```
Expected: Only ONE line matching `automated_testing.*+= 2` in the coverage section.

**Step 3: Fix B2 — markdown regex false positives in validate-structure.sh**

Read `hooks/scripts/validate-structure.sh`. Find `validate_markdown()` function with:
```bash
if grep -q '\[.*\]([^)]*)$' "$file"; then
```
Replace the entire body of `validate_markdown()` with a file-existence check approach. Replace the false-positive regex with:
```bash
validate_markdown() {
    local file="$1"
    # Check for markdown links with local file references and verify files exist
    local broken=0
    while IFS= read -r line; do
        # Extract local file links: [text](./path) or [text](path.md) — skip http/https/anchors
        while [[ "$line" =~ \[([^]]*)\]\(([^)]*)\) ]]; do
            local link="${BASH_REMATCH[2]}"
            line="${line#*](*}"
            # Skip external URLs and anchors
            [[ "$link" =~ ^https?:// ]] && continue
            [[ "$link" =~ ^# ]] && continue
            [[ -z "$link" ]] && continue
            # Strip anchor fragment
            local filepath="${link%%#*}"
            [[ -z "$filepath" ]] && continue
            # Check relative to file's directory
            local dir
            dir="$(dirname "$file")"
            if [[ ! -f "$dir/$filepath" && ! -f "$filepath" ]]; then
                echo -e "${YELLOW}⚠️ Broken local link '$filepath' in: $file${NC}" >&2
                broken=$((broken+1))
            fi
        done
    done < "$file"
    return $broken
}
```

**Step 4: Verify B2**
```bash
# Create a test file with a valid link and check no false positive
echo "See [README](README.md) for details." > /tmp/test_link.md
bash /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure/hooks/scripts/validate-structure.sh /tmp/test_link.md 2>&1 | grep -i "broken" || echo "PASS: no false positive"
rm /tmp/test_link.md
```
Expected: "PASS: no false positive"

**Step 5: Fix B3 — missing detection functions in generate-template.py**

Read `scripts/generate-template.py` in full. Find the `detect_*` functions section. After the existing detection functions, add these 5 new detection functions before the `generate_context()` function:

```python
def detect_has_coverage() -> bool:
    """Detect if project has coverage tooling configured."""
    coverage_indicators = [
        ".coveragerc",
        "coverage.xml",
        ".coverage",
    ]
    for f in coverage_indicators:
        if os.path.exists(f):
            return True
    # Check pyproject.toml or setup.cfg for coverage config
    for cfg in ["pyproject.toml", "setup.cfg", "tox.ini"]:
        if os.path.exists(cfg):
            with open(cfg) as fh:
                content = fh.read()
            if "[tool.coverage" in content or "[coverage:" in content:
                return True
    # Check package.json for istanbul/c8/nyc
    if os.path.exists("package.json"):
        with open("package.json") as fh:
            content = fh.read()
        if any(t in content for t in ["istanbul", "nyc", "c8", "@vitest/coverage"]):
            return True
    return False


def detect_has_linter() -> bool:
    """Detect if project has a linter configured."""
    linter_files = [
        ".eslintrc", ".eslintrc.js", ".eslintrc.json", ".eslintrc.yml",
        ".pylintrc", "pylintrc",
        ".flake8", "setup.cfg",
        "ruff.toml", ".ruff.toml",
        ".rubocop.yml",
        ".golangci.yml",
    ]
    for f in linter_files:
        if os.path.exists(f):
            return True
    if os.path.exists("pyproject.toml"):
        with open("pyproject.toml") as fh:
            content = fh.read()
        if "[tool.ruff" in content or "[tool.pylint" in content or "[tool.flake8" in content:
            return True
    if os.path.exists("package.json"):
        with open("package.json") as fh:
            content = fh.read()
        if "eslint" in content or "tslint" in content:
            return True
    return False


def detect_has_config_file() -> bool:
    """Detect if project has a meaningful config file."""
    config_files = [
        ".env.example", ".env.sample",
        "config.yaml", "config.yml", "config.json", "config.toml",
        "app.config.js", "app.config.ts",
        "settings.py", "settings.yaml",
    ]
    return any(os.path.exists(f) for f in config_files)


def detect_has_discussions() -> bool:
    """Detect if GitHub Discussions is referenced in project files."""
    for fname in ["README.md", ".github/CONTRIBUTING.md", "CONTRIBUTING.md"]:
        if os.path.exists(fname):
            with open(fname) as fh:
                content = fh.read().lower()
            if "discussion" in content or "github.com/" in content and "/discussions" in content:
                return True
    return False


def detect_has_issues() -> bool:
    """Detect if GitHub Issues is enabled (presence of issue templates or references)."""
    if os.path.isdir(".github/ISSUE_TEMPLATE"):
        return True
    for fname in [".github/ISSUE_TEMPLATE.md", "README.md", "CONTRIBUTING.md"]:
        if os.path.exists(fname):
            with open(fname) as fh:
                content = fh.read().lower()
            if "issue" in content:
                return True
    return False
```

Then update `generate_context()` to include these new variables. Find where the context dict is built and add:
```python
    context["HAS_COVERAGE"] = detect_has_coverage()
    context["HAS_LINTER"] = detect_has_linter()
    context["HAS_CONFIG_FILE"] = detect_has_config_file()
    context["HAS_DISCUSSIONS"] = detect_has_discussions()
    context["HAS_ISSUES"] = detect_has_issues()
```

**Step 6: Verify B3**
```bash
cd /tmp && python3 /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure/scripts/generate-template.py --help 2>&1 | head -5 || echo "FAIL"
python3 -c "
import sys; sys.path.insert(0, '/mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure/scripts')
import generate_template as g
print('HAS_COVERAGE:', g.detect_has_coverage())
print('HAS_LINTER:', g.detect_has_linter())
print('HAS_CONFIG_FILE:', g.detect_has_config_file())
print('HAS_DISCUSSIONS:', g.detect_has_discussions())
print('HAS_ISSUES:', g.detect_has_issues())
print('PASS')
"
```
Expected: All 5 functions print a bool without errors, "PASS" at end.

**Step 7: Fix B4 — jq hard dependency in detect-stack.sh**

Read `scripts/detect-stack.sh` in full. Find where `jq` is used to extract the primary language name:
```bash
primary_language=$(echo "${languages[0]}" | jq -r '.name')
```
Replace with a python3 fallback:
```bash
if command -v jq &>/dev/null; then
    primary_language=$(echo "${languages[0]}" | jq -r '.name')
else
    primary_language=$(echo "${languages[0]}" | python3 -c "import sys,json; d=json.loads(sys.stdin.read()); print(d['name'])")
fi
```

Also fix hardcoded confidence values. For each language/framework detection block, replace the hardcoded confidence values with dynamic ones based on evidence count. For example, Python detection:

Before:
```bash
languages+=('{"name":"Python","confidence":85,"evidence":["requirements.txt or pyproject.toml found"]}')
```

After (count how many Python files exist for dynamic confidence):
```bash
py_evidence=()
[[ -f "requirements.txt" ]] && py_evidence+=("requirements.txt found")
[[ -f "pyproject.toml" ]] && py_evidence+=("pyproject.toml found")
[[ -f "setup.py" ]] && py_evidence+=("setup.py found")
[[ -f "setup.cfg" ]] && py_evidence+=("setup.cfg found")
py_count=${#py_evidence[@]}
py_conf=$(( 60 + py_count * 10 ))
[[ $py_conf -gt 95 ]] && py_conf=95
py_evidence_json=$(printf '"%s",' "${py_evidence[@]}" | sed 's/,$//')
languages+=("{\"name\":\"Python\",\"confidence\":${py_conf},\"evidence\":[${py_evidence_json}]}")
```

Apply similar dynamic confidence logic to JavaScript/TypeScript, Go, Rust. For tools (Docker, GitHub Actions, GitLab CI) that have single definitive file presence, keep confidence at 95 (not 100 — no heuristic is 100%).

**Step 8: Verify B4**
```bash
cd /tmp && bash /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure/scripts/detect-stack.sh 2>&1 | head -10 || echo "exit code: $?"
# Test python fallback explicitly
bash -c 'PATH="" && python3 -c "import json; d={\"name\":\"Python\",\"confidence\":75,\"evidence\":[\"a\"]}; print(d[\"name\"])"'
```
Expected: Script runs without "command not found: jq" error; Python fallback works.

**Step 9: Commit**
```bash
cd /mnt/d/GitHub/nsalvacao-claude-code-plugins
git add plugins/repo-structure/scripts/calculate-score.py \
        plugins/repo-structure/hooks/scripts/validate-structure.sh \
        plugins/repo-structure/scripts/generate-template.py \
        plugins/repo-structure/scripts/detect-stack.sh
git commit -m "fix(repo-structure): B1-B4 bug fixes — scoring, link regex, missing detection, jq fallback"
```

---

### Task 2: Group H — Reference Files (4 skills)

**Files:**
- Create: `skills/quality-scoring/references/scoring-rubrics.md`
- Create: `skills/quality-scoring/references/partial-credit-rules.md`
- Create: `skills/tech-stack-detection/references/detection-patterns.json`
- Create: `skills/compliance-standards/references/compliance-mapping.md`

**Step 1: Create scoring-rubrics.md**

File: `skills/quality-scoring/references/scoring-rubrics.md`

Content: A reference document explaining what earns 0%, 50%, and 100% for each sub-item in the 4 scoring categories (Documentation, CI/CD, Testing, Community). Include:
- Documentation (30 pts): README rubric (0=missing/placeholder, 50=basic info but no quickstart, 100=full quickstart+badges+examples), CONTRIBUTING rubric, CHANGELOG rubric, API docs rubric, badges rubric.
- CI/CD (25 pts): Workflow presence rubric, multi-job rubric, security scanning rubric, deployment rubric.
- Testing (25 pts): Test presence rubric, coverage config rubric, coverage >80% heuristic rubric, multi-environment rubric.
- Community (20 pts): LICENSE rubric, CODE_OF_CONDUCT rubric, SECURITY.md rubric, issue templates rubric, CODEOWNERS rubric.

Format as a Markdown table per category with columns: Sub-item | Max pts | 0% criteria | 50% criteria | 100% criteria.

**Step 2: Create partial-credit-rules.md**

File: `skills/quality-scoring/references/partial-credit-rules.md`

Content: Rules for when to award partial credit vs zero:
- When 50% credit applies: file exists but is placeholder/template-only, feature present but misconfigured, present in wrong location per convention.
- When 0% applies: file completely missing, file exists but is empty or <10 meaningful lines, content is clearly auto-generated boilerplate with no customization.
- Rounding: always round individual sub-item scores to nearest integer; total always floored to 0 minimum.
- Edge cases: monorepos (check all packages, score highest), forks (check original vs fork differentiation), private repos (skip public badge checks).

**Step 3: Create detection-patterns.json**

File: `skills/tech-stack-detection/references/detection-patterns.json`

Content: JSON object with per-language detection patterns:
```json
{
  "languages": {
    "Python": {
      "definitive_files": ["requirements.txt", "pyproject.toml", "setup.py", "Pipfile"],
      "extensions": [".py"],
      "keywords_in_files": {"pyproject.toml": ["[tool.poetry", "[build-system"]},
      "confidence_base": 60,
      "confidence_per_evidence": 10,
      "confidence_max": 95
    },
    "JavaScript": {
      "definitive_files": ["package.json"],
      "extensions": [".js", ".mjs"],
      "exclude_if": ["typescript"],
      "confidence_base": 60,
      "confidence_per_evidence": 10,
      "confidence_max": 90
    },
    "TypeScript": {
      "definitive_files": ["tsconfig.json", "tsconfig.base.json"],
      "extensions": [".ts", ".tsx"],
      "confidence_base": 70,
      "confidence_per_evidence": 10,
      "confidence_max": 95
    },
    "Go": {
      "definitive_files": ["go.mod", "go.sum"],
      "extensions": [".go"],
      "confidence_base": 80,
      "confidence_per_evidence": 10,
      "confidence_max": 95
    },
    "Rust": {
      "definitive_files": ["Cargo.toml", "Cargo.lock"],
      "extensions": [".rs"],
      "confidence_base": 80,
      "confidence_per_evidence": 10,
      "confidence_max": 95
    },
    "Java": {
      "definitive_files": ["pom.xml", "build.gradle", "build.gradle.kts"],
      "extensions": [".java"],
      "confidence_base": 75,
      "confidence_per_evidence": 10,
      "confidence_max": 95
    },
    "Ruby": {
      "definitive_files": ["Gemfile", "Gemfile.lock", ".ruby-version"],
      "extensions": [".rb"],
      "confidence_base": 70,
      "confidence_per_evidence": 10,
      "confidence_max": 95
    }
  },
  "frameworks": {
    "Django": {"parent": "Python", "indicators": ["django", "manage.py"]},
    "FastAPI": {"parent": "Python", "indicators": ["fastapi"]},
    "Flask": {"parent": "Python", "indicators": ["flask"]},
    "React": {"parent": ["JavaScript", "TypeScript"], "indicators": ["react", "react-dom"]},
    "Vue": {"parent": ["JavaScript", "TypeScript"], "indicators": ["vue"]},
    "Next.js": {"parent": ["JavaScript", "TypeScript"], "indicators": ["next"]},
    "Express": {"parent": "JavaScript", "indicators": ["express"]}
  },
  "tools": {
    "Docker": {"definitive_files": ["Dockerfile", "docker-compose.yml", "docker-compose.yaml"]},
    "GitHub Actions": {"definitive_dirs": [".github/workflows"]},
    "GitLab CI": {"definitive_files": [".gitlab-ci.yml"]},
    "pre-commit": {"definitive_files": [".pre-commit-config.yaml"]}
  }
}
```

**Step 4: Create compliance-mapping.md**

File: `skills/compliance-standards/references/compliance-mapping.md`

Content: Mapping of OpenSSF/CII/OWASP requirements to the 4 repo quality score categories:

```markdown
# Compliance Standards Mapping

## OpenSSF Best Practices → Score Categories

| OpenSSF Requirement | Score Category | Sub-item |
|---------------------|----------------|----------|
| FLOSS license | Community | LICENSE |
| Website (README) | Documentation | README |
| Description | Documentation | README |
| How to contribute (CONTRIBUTING) | Community | CONTRIBUTING |
| Bug reporting (issue tracker) | Community | Issue templates |
| Vulnerability reporting (SECURITY.md) | Community | SECURITY.md |
| Automated tests | Testing | Test presence |
| CI for tests | CI/CD | Workflow presence |
| HTTPS enforced (badge/config) | Documentation | Badges |

## CII Best Practices → Score Categories

| CII Requirement | Score Category | Sub-item |
|-----------------|----------------|----------|
| README present | Documentation | README |
| OSS LICENSE | Community | LICENSE |
| CONTRIBUTING present | Community | CONTRIBUTING |
| CI configured | CI/CD | Workflow presence |
| Tests exist | Testing | Test presence |
| Coverage >80% | Testing | Coverage config |

## Score Category to Compliance Matrix

| Category | OpenSSF items | CII items | OWASP items |
|----------|---------------|-----------|-------------|
| Documentation (30 pts) | 4 | 1 | 2 |
| CI/CD (25 pts) | 2 | 2 | 3 |
| Testing (25 pts) | 2 | 2 | 1 |
| Community (20 pts) | 5 | 3 | 1 |

A score ≥ 70 typically satisfies CII Passing badge prerequisites.
A score ≥ 85 covers most OpenSSF Silver requirements for documentation/testing.
```

**Step 5: Verify reference files**
```bash
python3 -m json.tool /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure/skills/tech-stack-detection/references/detection-patterns.json > /dev/null && echo "JSON valid"
wc -l /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure/skills/quality-scoring/references/scoring-rubrics.md
wc -l /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure/skills/quality-scoring/references/partial-credit-rules.md
wc -l /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure/skills/compliance-standards/references/compliance-mapping.md
```
Expected: JSON valid, all files have >10 lines.

**Step 6: Commit**
```bash
cd /mnt/d/GitHub/nsalvacao-claude-code-plugins
git add plugins/repo-structure/skills/quality-scoring/references/ \
        plugins/repo-structure/skills/tech-stack-detection/references/detection-patterns.json \
        plugins/repo-structure/skills/compliance-standards/references/compliance-mapping.md
git commit -m "docs(repo-structure): add H1-H4 reference files for quality-scoring, tech-stack-detection, compliance-standards"
```

---

### Task 3: Group B — github/ Templates (4 templates)

**Files:**
- Create: `skills/repository-templates/templates/github/CONTRIBUTING.md.template`
- Create: `skills/repository-templates/templates/github/SECURITY.md.template`
- Create: `skills/repository-templates/templates/github/CODE_OF_CONDUCT.md.template`
- Create: `skills/repository-templates/templates/github/LICENSE.Apache-2.0.template`

These use the Mustache-style rendering: `{{VAR}}`, `{{#COND}}content{{/COND}}`, `{{^COND}}content{{/COND}}`.

**Step 1: Create CONTRIBUTING.md.template**

```markdown
# Contributing to {{PROJECT_NAME}}

Thank you for your interest in contributing!

## Getting Started

{{#HAS_ISSUES}}
- Check existing [issues](../../issues) before opening a new one
- For bugs: open an issue describing the problem and how to reproduce it
- For features: open an issue to discuss before implementing
{{/HAS_ISSUES}}
{{^HAS_ISSUES}}
- Review the project README before contributing
- Discuss major changes with maintainers before starting work
{{/HAS_ISSUES}}

## Development Setup

```bash
git clone https://github.com/{{GITHUB_USERNAME}}/{{REPO_NAME}}
cd {{REPO_NAME}}
```

{{#PYTHON}}
```bash
pip install -e ".[dev]"
```
{{/PYTHON}}
{{#JAVASCRIPT}}
```bash
npm install
```
{{/JAVASCRIPT}}

## Pull Request Process

1. Fork the repository and create a feature branch
2. Make your changes with clear, focused commits
3. Update documentation if behaviour changes
4. Ensure all tests pass
5. Open a pull request with a clear description

## Code Style

{{#PYTHON}}
This project uses Ruff for linting. Run `ruff check .` before submitting.
{{/PYTHON}}
{{#JAVASCRIPT}}
This project uses ESLint. Run `npm run lint` before submitting.
{{/JAVASCRIPT}}

## Questions

{{#HAS_DISCUSSIONS}}
Use [GitHub Discussions](../../discussions) for questions and ideas.
{{/HAS_DISCUSSIONS}}
{{^HAS_DISCUSSIONS}}
Open an issue with the `question` label.
{{/HAS_DISCUSSIONS}}
```

**Step 2: Create SECURITY.md.template**

```markdown
# Security Policy

## Supported Versions

{{SUPPORTED_VERSIONS}}

| Version | Supported |
|---------|-----------|
| latest  | ✅ |

## Reporting a Vulnerability

**Do not open public issues for security vulnerabilities.**

{{#SECURITY_EMAIL}}
Email: {{SECURITY_EMAIL}}
{{/SECURITY_EMAIL}}
{{^SECURITY_EMAIL}}
Use [GitHub's private vulnerability reporting](../../security/advisories/new).
{{/SECURITY_EMAIL}}

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

You will receive a response within 48 hours. We aim to release patches within 14 days for critical vulnerabilities.
```

**Step 3: Create CODE_OF_CONDUCT.md.template**

Use Contributor Covenant 2.1 with `{{CONTACT_EMAIL}}` placeholder:

```markdown
# Contributor Covenant Code of Conduct

## Our Pledge

We as members, contributors, and leaders pledge to make participation in our community a harassment-free experience for everyone, regardless of age, body size, visible or invisible disability, ethnicity, sex characteristics, gender identity and expression, level of experience, education, socio-economic status, nationality, personal appearance, race, caste, color, religion, or sexual identity and orientation.

We pledge to act and interact in ways that contribute to an open, welcoming, diverse, inclusive, and healthy community.

## Our Standards

Examples of behavior that contributes to a positive environment:

* Demonstrating empathy and kindness toward other people
* Being respectful of differing opinions, viewpoints, and experiences
* Giving and gracefully accepting constructive feedback
* Accepting responsibility and apologizing to those affected by our mistakes
* Focusing on what is best not just for us as individuals, but for the overall community

Examples of unacceptable behavior:

* The use of sexualized language or imagery, and sexual attention or advances of any kind
* Trolling, insulting or derogatory comments, and personal or political attacks
* Public or private harassment
* Publishing others' private information without explicit permission
* Other conduct which could reasonably be considered inappropriate

## Enforcement Responsibilities

Community leaders are responsible for clarifying and enforcing our standards of acceptable behavior and will take appropriate and fair corrective action in response to any behavior that they deem inappropriate, threatening, offensive, or harmful.

## Scope

This Code of Conduct applies within all community spaces, and also applies when an individual is officially representing the community in public spaces.

## Enforcement

Instances of abusive, harassing, or otherwise unacceptable behavior may be reported to the community leaders responsible for enforcement at {{CONTACT_EMAIL}}.

All complaints will be reviewed and investigated promptly and fairly.

## Attribution

This Code of Conduct is adapted from the [Contributor Covenant](https://www.contributor-covenant.org), version 2.1.
```

**Step 4: Create LICENSE.Apache-2.0.template**

```
                                 Apache License
                           Version 2.0, January 2004
                        http://www.apache.org/licenses/

   Copyright {{YEAR}} {{AUTHOR_NAME}}

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
```

**Step 5: Verify templates**
```bash
ls /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure/skills/repository-templates/templates/github/
```
Expected: 4 files: `CONTRIBUTING.md.template`, `SECURITY.md.template`, `CODE_OF_CONDUCT.md.template`, `LICENSE.Apache-2.0.template` (plus existing `LICENSE.MIT.template`, `README.md.template`)

Check each has correct Mustache syntax (no unclosed braces):
```bash
for f in /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure/skills/repository-templates/templates/github/*.template; do
    echo -n "$f: "
    python3 -c "
import re, sys
content = open('$f').read()
opens = len(re.findall(r'\\{\\{#', content))
closes = len(re.findall(r'\\{\\{/', content))
if opens == closes:
    print('OK (opens=%d closes=%d)' % (opens, closes))
else:
    print('MISMATCH opens=%d closes=%d' % (opens, closes))
    sys.exit(1)
"
done
```
Expected: All files print OK.

**Step 6: Commit**
```bash
cd /mnt/d/GitHub/nsalvacao-claude-code-plugins
git add plugins/repo-structure/skills/repository-templates/templates/github/
git commit -m "feat(repo-structure): add B1-B4 github/ templates — CONTRIBUTING, SECURITY, CODE_OF_CONDUCT, LICENSE.Apache-2.0"
```

---

### Task 4: Group B — configs/ and ci/ Templates (5 templates)

**Files:**
- Create dir: `skills/repository-templates/templates/configs/`
- Create: `skills/repository-templates/templates/configs/.gitignore.python.template`
- Create: `skills/repository-templates/templates/configs/.gitignore.node.template`
- Create: `skills/repository-templates/templates/configs/.editorconfig.template`
- Create dir: `skills/repository-templates/templates/ci/`
- Create: `skills/repository-templates/templates/ci/python-ci.yml.template`
- Create: `skills/repository-templates/templates/ci/node-ci.yml.template`

**Step 1: Create .gitignore.python.template**

```
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
*.egg
*.egg-info/
dist/
build/
eggs/
parts/
var/
sdist/
develop-eggs/
.installed.cfg
lib/
lib64/

{{#HAS_VENV}}
# Virtual environments
venv/
.venv/
env/
.env/
ENV/
{{/HAS_VENV}}

{{#PYTEST}}
# pytest
.pytest_cache/
.cache/
{{/PYTEST}}

# Coverage
.coverage
.coverage.*
htmlcov/
coverage.xml
*.cover

# Distribution
*.egg-info/
.eggs/

# MyPy
.mypy_cache/
.dmypy.json
dmypy.json

# Ruff
.ruff_cache/

# Environments
.env
.env.*
!.env.example

# IDEs
.idea/
.vscode/
*.swp
*.swo
```

**Step 2: Create .gitignore.node.template**

```
# Dependencies
node_modules/
.pnp
.pnp.js

# Build outputs
dist/
build/
out/
.next/
{{#NEXT_JS}}
.next/
out/
{{/NEXT_JS}}

{{#TYPESCRIPT}}
# TypeScript
*.tsbuildinfo
next-env.d.ts
{{/TYPESCRIPT}}

# Testing
coverage/
.nyc_output/

# Environments
.env
.env.*
!.env.example
.env.local
.env.development.local
.env.test.local
.env.production.local

# Logs
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*

# OS
.DS_Store
Thumbs.db

# IDEs
.idea/
.vscode/
*.swp
```

**Step 3: Create .editorconfig.template**

```ini
root = true

[*]
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
charset = utf-8

{{#PYTHON}}
[*.py]
indent_style = space
indent_size = {{INDENT_SIZE}}
max_line_length = 88
{{/PYTHON}}

{{#JAVASCRIPT}}
[*.{js,jsx,ts,tsx,json}]
indent_style = space
indent_size = {{INDENT_SIZE}}
{{/JAVASCRIPT}}

[*.md]
trim_trailing_whitespace = false

[*.yml]
indent_style = space
indent_size = 2

[Makefile]
indent_style = tab
```

**Step 4: Create python-ci.yml.template**

```yaml
name: CI

on:
  push:
    branches: [main, master]
  pull_request:
    branches: [main, master]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["{{PYTHON_VERSION}}"]

    steps:
      - uses: actions/checkout@v4

      - name: Set up Python ${{ matrix.python-version }}
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -e ".[dev]"

      {{#PYTEST}}
      - name: Run tests
        run: {{TEST_COMMAND}}
      {{/PYTEST}}
      {{^PYTEST}}
      - name: Run tests
        run: python -m pytest
      {{/PYTEST}}

      {{#RUFF}}
      - name: Lint with Ruff
        run: ruff check .
      {{/RUFF}}
```

**Step 5: Create node-ci.yml.template**

```yaml
name: CI

on:
  push:
    branches: [main, master]
  pull_request:
    branches: [main, master]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: ["{{NODE_VERSION}}"]

    steps:
      - uses: actions/checkout@v4

      - name: Set up Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      {{#TYPESCRIPT}}
      - name: Type check
        run: npx tsc --noEmit
      {{/TYPESCRIPT}}

      - name: Run tests
        run: {{TEST_COMMAND}}
```

**Step 6: Verify templates**
```bash
ls /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure/skills/repository-templates/templates/configs/ && echo "---" && ls /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure/skills/repository-templates/templates/ci/
```
Expected: 3 files in configs/, 2 files in ci/

**Step 7: Commit**
```bash
cd /mnt/d/GitHub/nsalvacao-claude-code-plugins
git add plugins/repo-structure/skills/repository-templates/templates/configs/ \
        plugins/repo-structure/skills/repository-templates/templates/ci/
git commit -m "feat(repo-structure): add B5-B9 configs/ and ci/ templates — gitignore, editorconfig, GitHub Actions CI"
```

---

### Task 5: Group G — Missing Scripts

**Files:**
- Create: `scripts/install-hooks.sh`
- Create: `scripts/check-compliance.sh`

**Step 1: Create install-hooks.sh (~60 lines)**

```bash
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
    echo ".pre-commit-config.yaml already exists — skipping"
fi

# Install pre-commit hooks
if command -v pre-commit &>/dev/null; then
    if [[ "$DRY_RUN" == "false" ]]; then
        echo "Running: pre-commit install"
        pre-commit install
        echo "Running: pre-commit run --all-files (dry-run validation)"
        pre-commit run --all-files || echo "Some hooks failed — review output above"
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
```

**Step 2: Create check-compliance.sh (~80 lines)**

```bash
#!/usr/bin/env bash
# check-compliance.sh — Check OpenSSF/CII compliance basics
# Usage: bash check-compliance.sh [--json]
set -euo pipefail

JSON_OUTPUT=false
[[ "${1:-}" == "--json" ]] && JSON_OUTPUT=true

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")"
cd "$ROOT"

declare -A scores
declare -A notes

# OpenSSF checks
check_openssf() {
    local total=0
    local max=0

    # SECURITY.md
    max=$((max+1))
    if [[ -f "SECURITY.md" || -f ".github/SECURITY.md" ]]; then
        scores["openssf_security"]=1
        total=$((total+1))
    else
        scores["openssf_security"]=0
        notes["openssf_security"]="Missing SECURITY.md"
    fi

    # LICENSE
    max=$((max+1))
    if [[ -f "LICENSE" || -f "LICENSE.md" || -f "LICENSE.txt" ]]; then
        scores["openssf_license"]=1
        total=$((total+1))
    else
        scores["openssf_license"]=0
        notes["openssf_license"]="Missing LICENSE file"
    fi

    # CONTRIBUTING
    max=$((max+1))
    if [[ -f "CONTRIBUTING.md" || -f ".github/CONTRIBUTING.md" ]]; then
        scores["openssf_contributing"]=1
        total=$((total+1))
    else
        scores["openssf_contributing"]=0
        notes["openssf_contributing"]="Missing CONTRIBUTING.md"
    fi

    # CI present
    max=$((max+1))
    if [[ -d ".github/workflows" ]] && ls .github/workflows/*.yml 2>/dev/null | head -1 &>/dev/null; then
        scores["openssf_ci"]=1
        total=$((total+1))
    else
        scores["openssf_ci"]=0
        notes["openssf_ci"]="No GitHub Actions workflows found"
    fi

    echo "$total/$max"
}

# CII checks
check_cii() {
    local total=0
    local max=0

    # README
    max=$((max+1))
    if [[ -f "README.md" || -f "README.rst" || -f "README" ]]; then
        scores["cii_readme"]=1
        total=$((total+1))
    else
        scores["cii_readme"]=0
        notes["cii_readme"]="Missing README"
    fi

    # LICENSE
    max=$((max+1))
    if [[ -f "LICENSE" || -f "LICENSE.md" ]]; then
        scores["cii_license"]=1
        total=$((total+1))
    else
        scores["cii_license"]=0
        notes["cii_license"]="Missing LICENSE"
    fi

    # Tests
    max=$((max+1))
    if [[ -d "tests" || -d "test" || -d "spec" ]] || find . -name "test_*.py" -o -name "*_test.py" -o -name "*.test.js" 2>/dev/null | head -1 | grep -q .; then
        scores["cii_tests"]=1
        total=$((total+1))
    else
        scores["cii_tests"]=0
        notes["cii_tests"]="No test directory or test files found"
    fi

    echo "$total/$max"
}

if [[ "$JSON_OUTPUT" == "true" ]]; then
    openssf=$(check_openssf)
    cii=$(check_cii)
    echo "{"
    echo "  \"openssf\": {"
    echo "    \"score\": \"$openssf\","
    for key in "${!notes[@]}"; do
        [[ "$key" == openssf_* ]] && echo "    \"${key#openssf_}_note\": \"${notes[$key]}\","
    done
    echo "    \"_end\": null"
    echo "  },"
    echo "  \"cii\": {"
    echo "    \"score\": \"$cii\""
    echo "  }"
    echo "}"
else
    echo "=== Compliance Check ==="
    echo
    echo "OpenSSF: $(check_openssf)"
    echo "CII:     $(check_cii)"
    echo
    if [[ ${#notes[@]} -gt 0 ]]; then
        echo "Issues:"
        for key in "${!notes[@]}"; do
            echo "  - [${key}] ${notes[$key]}"
        done
    else
        echo "No issues found."
    fi
fi
```

**Step 3: Make scripts executable and verify syntax**
```bash
chmod +x /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure/scripts/install-hooks.sh
chmod +x /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure/scripts/check-compliance.sh
bash -n /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure/scripts/install-hooks.sh && echo "install-hooks: syntax OK"
bash -n /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure/scripts/check-compliance.sh && echo "check-compliance: syntax OK"
```
Expected: Both print "syntax OK"

**Step 4: Test dry-run of install-hooks.sh**
```bash
cd /tmp && git init test-hooks-repo && cd test-hooks-repo && bash /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure/scripts/install-hooks.sh --dry-run 2>&1 && cd /tmp && rm -rf test-hooks-repo
```
Expected: Prints "DRY RUN" lines, no errors, exits 0.

**Step 5: Test check-compliance.sh**
```bash
cd /tmp && mkdir test-compliance && cd test-compliance && git init && bash /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure/scripts/check-compliance.sh 2>&1 && cd /tmp && rm -rf test-compliance
```
Expected: Prints OpenSSF and CII scores, exits 0.

**Step 6: Commit**
```bash
cd /mnt/d/GitHub/nsalvacao-claude-code-plugins
git add plugins/repo-structure/scripts/install-hooks.sh \
        plugins/repo-structure/scripts/check-compliance.sh
git commit -m "feat(repo-structure): add G1-G2 missing scripts — install-hooks.sh, check-compliance.sh"
```

---

### Task 6: Group E — Hooks Upgrade (4 new scripts + updated hooks.json)

**Files:**
- Create: `hooks/scripts/shellcheck-hook.sh`
- Create: `hooks/scripts/yamllint-hook.sh`
- Create: `hooks/scripts/lf-check-hook.sh`
- Create: `hooks/scripts/audit-reminder.sh`
- Modify: `hooks/hooks.json`

**Step 1: Create shellcheck-hook.sh**

```bash
#!/usr/bin/env bash
# shellcheck-hook.sh — Run shellcheck on modified .sh files (graceful if not installed)
set -euo pipefail

# Read tool_input from stdin
input=$(head -c 65536 /dev/stdin 2>/dev/null || echo "{}")
file_path=$(echo "$input" | python3 -c "import sys,json; d=json.loads(sys.stdin.read()); print(d.get('file_path',''))" 2>/dev/null || echo "")

# Only process .sh files
[[ "$file_path" == *.sh ]] || exit 0

# Graceful if shellcheck not installed
if ! command -v shellcheck &>/dev/null; then
    exit 0
fi

if [[ -f "$file_path" ]]; then
    shellcheck "$file_path" 2>&1 || {
        echo "⚠️ shellcheck found issues in $file_path" >&2
        exit 1
    }
fi
```

**Step 2: Create yamllint-hook.sh**

```bash
#!/usr/bin/env bash
# yamllint-hook.sh — Run yamllint on modified .yml/.yaml files (python3 yaml fallback)
set -euo pipefail

input=$(head -c 65536 /dev/stdin 2>/dev/null || echo "{}")
file_path=$(echo "$input" | python3 -c "import sys,json; d=json.loads(sys.stdin.read()); print(d.get('file_path',''))" 2>/dev/null || echo "")

# Only process yaml files
case "$file_path" in
    *.yml|*.yaml) ;;
    *) exit 0 ;;
esac

[[ -f "$file_path" ]] || exit 0

if command -v yamllint &>/dev/null; then
    yamllint "$file_path" 2>&1 || {
        echo "⚠️ yamllint found issues in $file_path" >&2
        exit 1
    }
else
    # Fallback: python3 yaml parse
    python3 -c "
import sys, yaml
try:
    yaml.safe_load(open('$file_path'))
    print('YAML valid: $file_path')
except yaml.YAMLError as e:
    print('YAML error in $file_path: ' + str(e), file=sys.stderr)
    sys.exit(1)
" 2>&1 || exit 1
fi
```

**Step 3: Create lf-check-hook.sh**

```bash
#!/usr/bin/env bash
# lf-check-hook.sh — Detect CRLF line endings in written files
set -euo pipefail

input=$(head -c 65536 /dev/stdin 2>/dev/null || echo "{}")
file_path=$(echo "$input" | python3 -c "import sys,json; d=json.loads(sys.stdin.read()); print(d.get('file_path',''))" 2>/dev/null || echo "")

[[ -f "$file_path" ]] || exit 0

# Skip binary files
file "$file_path" | grep -q "text" || exit 0

if file "$file_path" | grep -q "CRLF"; then
    echo "⚠️ CRLF line endings detected in: $file_path" >&2
    echo "    Fix with: dos2unix \"$file_path\"" >&2
    # Warn only, do not block
fi
# Always exit 0 — CRLF is a warning, not a blocker
exit 0
```

**Step 4: Create audit-reminder.sh**

```bash
#!/usr/bin/env bash
# audit-reminder.sh — Stop hook: suggest /repo-validate if files were created
set -euo pipefail

# Check if any new files exist that haven't been validated
# We use git status to detect newly created files
if git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
    new_files=$(git status --porcelain 2>/dev/null | grep "^??" | wc -l)
    if [[ $new_files -gt 0 ]]; then
        echo "💡 $new_files new untracked file(s) detected. Consider running /repo-validate to check repository structure." >&2
    fi
fi
exit 0
```

**Step 5: Update hooks/hooks.json**

Read current `hooks/hooks.json` and replace entirely with:
```json
{
  "PreToolUse": [
    {
      "matcher": "Write|Edit",
      "hooks": [
        {
          "type": "command",
          "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/validate-structure.sh",
          "timeout": 10,
          "description": "Validate structure files before writing"
        }
      ]
    }
  ],
  "PostToolUse": [
    {
      "matcher": "Write|Edit",
      "hooks": [
        {
          "type": "command",
          "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/lf-check-hook.sh",
          "timeout": 10,
          "description": "Warn on CRLF line endings"
        }
      ]
    },
    {
      "matcher": "Write|Edit",
      "hooks": [
        {
          "type": "command",
          "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/shellcheck-hook.sh",
          "timeout": 15,
          "description": "Lint .sh files with shellcheck"
        }
      ]
    },
    {
      "matcher": "Write|Edit",
      "hooks": [
        {
          "type": "command",
          "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/yamllint-hook.sh",
          "timeout": 15,
          "description": "Lint .yml/.yaml files"
        }
      ]
    }
  ],
  "Stop": [
    {
      "matcher": ".*",
      "hooks": [
        {
          "type": "command",
          "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/audit-reminder.sh",
          "timeout": 10,
          "description": "Suggest /repo-validate if new files were created"
        }
      ]
    }
  ]
}
```

**Step 6: Verify hooks**
```bash
for f in shellcheck-hook.sh yamllint-hook.sh lf-check-hook.sh audit-reminder.sh; do
    bash -n /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure/hooks/scripts/$f && echo "$f: syntax OK"
done
python3 -m json.tool /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure/hooks/hooks.json > /dev/null && echo "hooks.json: valid JSON"
```
Expected: All 4 scripts "syntax OK", hooks.json "valid JSON"

**Step 7: Commit**
```bash
cd /mnt/d/GitHub/nsalvacao-claude-code-plugins
git add plugins/repo-structure/hooks/scripts/ \
        plugins/repo-structure/hooks/hooks.json
git commit -m "feat(repo-structure): E1-E4 hooks upgrade — shellcheck, yamllint, lf-check, audit-reminder + hooks.json update"
```

---

### Task 7: Group C — CI Debugging Suite

**Files:**
- Create: `skills/ci-diagnostics/SKILL.md`
- Create: `commands/ci-audit.md`
- Create: `commands/ci-fix.md`

**Step 1: Create skills/ci-diagnostics/SKILL.md**

```markdown
---
name: CI Diagnostics
description: >
  Pattern library for diagnosing GitHub Actions CI failures.
  Use when reviewing workflow files, debugging CI errors, or auditing automation.
  Activated by: "CI is failing", "workflow error", "GitHub Actions issue", /ci-audit, /ci-fix.
version: 1.0.0
---

# CI Diagnostics Skill

Pattern library for common GitHub Actions failures. Apply these patterns when reading workflow files or CI logs.

## Pattern 1: bash -e Arithmetic Trap

**Symptom:** Step fails with exit code 1 on arithmetic expression.
**Cause:** `((n++))` returns exit code 1 when `n=0` because `((0))` is falsy in bash.
**Fix:** Replace `((n++))` with `n=$((n+1))`. Replace `((n--))` with `n=$((n-1))`.
**Detection:** Grep for `((\w*\+\+))` or `((\w*--))` in scripts run under bash with `set -e` or `shell: bash`.

## Pattern 2: YAML Indentation Errors

**Symptom:** "Invalid workflow file" or "YAML parse error" in Actions tab.
**Cause:** Mixed tabs/spaces, wrong indentation level for `run:` multi-line block.
**Fix:** Use 2-space indent throughout. Multi-line `run:` blocks must use `|` and indent content by 2 more spaces.
**Detection:** Run `yamllint` on all `.github/workflows/*.yml`. Check for tabs with `grep -P "\t" file.yml`.

## Pattern 3: Missing `on:` key

**Symptom:** Workflow never triggers.
**Cause:** Missing or invalid `on:` key, or using `true` as a YAML boolean instead of quoted string.
**Fix:** Every workflow must have an `on:` key. Avoid unquoted `on` at start of line (YAML parses as boolean `true`).
**Detection:** Check `grep -n "^on:" workflow.yml` — must appear exactly once near top.

## Pattern 4: Missing Permissions

**Symptom:** "Resource not accessible by integration" or 403 errors in steps.
**Cause:** Workflow needs `permissions: contents: write` or `pull-requests: write` but doesn't declare them.
**Fix:** Add `permissions:` block at job or workflow level with minimum required permissions.
**Common cases:**
- Creating releases → `contents: write`
- Commenting on PRs → `pull-requests: write`
- Pushing to branch → `contents: write`
- Reading packages → `packages: read`

## Pattern 5: Missing Secrets/Env Vars

**Symptom:** Step fails with "empty string" or "undefined variable" or authentication error.
**Cause:** Secret not propagated to step via `env:` or `${{ secrets.X }}` not set in repo.
**Fix:** Check `env:` block at step level; verify secret exists in repo/org settings.
**Detection:** Grep for `${{ secrets.` in workflow, verify each is documented.

## Pattern 6: Matrix Strategy and fail-fast

**Symptom:** One matrix job fails and cancels all others, making root cause hard to find.
**Cause:** Default `fail-fast: true` cancels siblings on first failure.
**Fix:** Add `fail-fast: false` to matrix strategy when debugging or when jobs are independent.

## Pattern 7: Checkout Depth for Tags

**Symptom:** `git describe` fails, version detection broken, tag not found.
**Cause:** Default `fetch-depth: 1` shallow clone — no tags or history.
**Fix:** Add `fetch-depth: 0` to `actions/checkout` step when tags or full history needed.

## Pattern 8: Cache Invalidation

**Symptom:** Cached dependencies cause test failures after dep updates.
**Cause:** Cache key not including lockfile hash.
**Fix:** Use `${{ hashFiles('**/package-lock.json') }}` or equivalent in cache key.
**Pattern:**
```yaml
- uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
    restore-keys: ${{ runner.os }}-node-
```

## Pattern 9: Markdownlint Config Format

**Symptom:** markdownlint-cli2 fails with "config file not found" or ignores rules.
**Cause:** Using `.markdownlintrc` (JSON only) instead of `.markdownlint.yml` / `.markdownlint.json`.
**Fix:** Use `.markdownlint.yml` (YAML) or `.markdownlint.json` (JSON) for markdownlint-cli2. Verify config key names match the linter version.

## Pattern 10: Invalid Runner

**Symptom:** "The job was not picked up by any runner" or immediate failure.
**Cause:** Typo in `runs-on` value (e.g., `ubuntu-lastest` instead of `ubuntu-latest`).
**Valid runners:** `ubuntu-latest`, `ubuntu-22.04`, `ubuntu-24.04`, `windows-latest`, `macos-latest`, `macos-14`.
**Detection:** Grep `runs-on:` in all workflows and validate against known values.

## Severity Classification

| Severity | Meaning |
|----------|---------|
| **BLOCKER** | Workflow will never succeed until fixed |
| **WARNING** | May cause intermittent failures or poor DX |
| **INFO** | Improvement opportunity, not currently breaking |

Examples:
- Invalid `runs-on` → BLOCKER
- Missing `on:` → BLOCKER
- Missing permissions (403) → BLOCKER
- `((n++))` with set -e → BLOCKER (when n=0)
- `fail-fast: true` → WARNING
- Shallow clone without tags needed → WARNING (silent failure)
- Cache key without lockfile hash → WARNING
```

**Step 2: Create commands/ci-audit.md**

```markdown
---
name: ci-audit
description: Audit all GitHub Actions workflows for syntax errors, logic issues, permissions, and known failure patterns
---

# /ci-audit

Audit all `.github/workflows/*.yml` files and report every issue found.

## Usage

```
/ci-audit [--fix-plan]
```

- Default: diagnose-only — lists all issues without changing files
- `--fix-plan`: generate an ordered fix plan after diagnosis

## Protocol

**REQUIRED SKILL:** Load the `ci-diagnostics` skill before starting.

### Step 1: Discover workflows

Read ALL files matching `.github/workflows/*.yml` and `.github/workflows/*.yaml`. Do not skip any.

### Step 2: Apply ci-diagnostics patterns to each file

For each workflow file, check all 10 patterns from the ci-diagnostics skill:

1. bash -e arithmetic trap (`((n++))`)
2. YAML indentation errors
3. Missing or invalid `on:` key
4. Missing permissions (contents/pull-requests/packages)
5. Missing or undocumented secrets/env vars
6. Matrix strategy fail-fast setting
7. Checkout depth for tag/release workflows
8. Cache key missing lockfile hash
9. Markdownlint config format
10. Invalid runner name

### Step 3: Output structured report

For each issue found, report:
```
[SEVERITY] filename.yml:line — Pattern N: <description>
  Found: <exact problematic text>
  Fix: <what to change>
```

Severity levels: BLOCKER | WARNING | INFO

### Step 4: Summary table

```
| File | BLOCKERs | WARNINGs | INFOs |
|------|----------|----------|-------|
| ci.yml | 2 | 1 | 0 |
| release.yml | 0 | 1 | 2 |
```

### Step 5 (with --fix-plan): Generate ordered fix plan

Order: BLOCKERs first, then WARNINGs, then INFOs.
Within each severity, order by dependency (fix syntax before logic).
Output as numbered list: `N. Fix [pattern] in [file]:[line]`

## Important

- Read all workflow files BEFORE reporting any issues
- Do not modify any files unless --fix-plan is combined with /ci-fix
- If no `.github/workflows/` directory exists, report "No workflows found"
```

**Step 3: Create commands/ci-fix.md**

```markdown
---
name: ci-fix
description: Fix all GitHub Actions workflow issues — runs ci-audit internally then applies fixes in order
---

# /ci-fix

Fix all identified issues in `.github/workflows/*.yml` files.

## Usage

```
/ci-fix [--dry-run]
```

- Default: applies all fixes, validates each file, commits one per workflow file
- `--dry-run`: shows what would be done without modifying files

## Protocol

**REQUIRED SKILL:** Load the `ci-diagnostics` skill before starting.

### Step 1: Internal audit

Run the full /ci-audit protocol internally. Build complete issue list across all workflow files. Do not output the audit report (it will be included in the summary at the end).

### Step 2: Apply fixes in dependency order

Order: BLOCKERs first, then WARNINGs.
Within each file, fix from top to bottom (line order).

For each fix:
1. Read the current file content
2. Apply the specific fix (targeted Edit, not full rewrite)
3. Validate with yamllint (or python3 yaml fallback) immediately after
4. If validation fails: revert the edit and mark as "FAILED — manual review needed"
5. Continue to next fix

### Step 3: Commit (one commit per workflow file)

For each modified workflow file:
```bash
git add .github/workflows/<filename>.yml
git commit -m "fix(ci): <summary of fixes> in <filename>.yml"
```

### Step 4: Final summary

```
CI Fix Summary
==============
Files modified: N
Fixes applied: N
Fixes skipped (manual): N

Fixed:
  ✅ ci.yml — [BLOCKER] bash arithmetic trap (line 45)
  ✅ ci.yml — [WARNING] fail-fast not disabled (line 12)

Skipped (manual review needed):
  ⚠️ release.yml — [BLOCKER] complex permissions issue
```

### Dry-run output format

```
[DRY RUN] Would fix in ci.yml:
  Line 45: ((errors++)) → errors=$((errors+1))
  Line 12: add fail-fast: false to matrix strategy
```

## Important

- Always run internal /ci-audit first — never fix without full diagnosis
- Never use --no-verify on git commits
- If yamllint validation fails after a fix, revert and mark for manual review
- Do not fix INFO-level items by default (too opinionated)
```

**Step 4: Verify new skill and commands**
```bash
ls /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure/skills/ci-diagnostics/
ls /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure/commands/
```
Expected: `ci-diagnostics/SKILL.md` exists; `ci-audit.md` and `ci-fix.md` in commands/

**Step 5: Commit**
```bash
cd /mnt/d/GitHub/nsalvacao-claude-code-plugins
git add plugins/repo-structure/skills/ci-diagnostics/ \
        plugins/repo-structure/commands/ci-audit.md \
        plugins/repo-structure/commands/ci-fix.md
git commit -m "feat(repo-structure): C1-C3 CI debugging suite — ci-diagnostics skill, /ci-audit, /ci-fix commands"
```

---

### Task 8: Group D — /pr-respond Command

**Files:**
- Create: `commands/pr-respond.md`

**Step 1: Create commands/pr-respond.md**

```markdown
---
name: pr-respond
description: Respond to all unresolved PR review comments — apply code fixes, prepare text responses, commit and summarize
---

# /pr-respond

Respond to all unresolved review comments on a pull request.

## Usage

```
/pr-respond [PR-number | --current] [--repo=owner/repo]
```

- `PR-number`: explicit PR number
- `--current`: detect from current branch (`gh pr view --json number`)
- `--repo=owner/repo`: override repository (default: current repo)

## Protocol

### Step 1: Load all unresolved comments

```bash
gh pr view <PR-number> --json reviewThreads --jq '.reviewThreads[] | select(.isResolved == false)'
```

Read the full output. Never proceed without reading all comments first.

### Step 2: Group by type

Classify each comment as:
- **BLOCKER** — reviewer explicitly blocks merge: "must fix", "needs to change", "blocking"
- **QUESTION** — reviewer asks for clarification: "why", "what does", "can you explain"
- **NITPICK** — style/preference: "nit:", "minor:", optional suggestion
- **CODE_CHANGE** — explicit change request without blocking language

Group by file for efficient editing.

### Step 3: Resolve each comment

**BLOCKERs:** Read the referenced file, apply the fix, validate the change is correct.

**QUESTIONS:** Prepare a text response explaining the reasoning. Do not change code unless the question reveals a bug.

**NITPICKS:** Apply if trivial (rename, whitespace, obvious improvement). Defer if opinion-based.

**CODE_CHANGE:** Apply the suggested change. If the change conflicts with other code, note the conflict.

### Step 4: Commit fixes

For each file with applied fixes:
```bash
git add <file>
git commit -m "fix: address PR review comments in <file>

Resolves comments from: <reviewer> re: <brief description>"
```

### Step 5: Post summary comment (optional)

If `--comment` flag provided:
```bash
gh pr review <PR-number> --comment --body "<summary>"
```

Summary format:
```
## PR Review Response

**Resolved (N):**
- ✅ `file.py:45` — Fixed null check (BLOCKER from @reviewer)
- ✅ `README.md:12` — Clarified installation step (NITPICK)

**Deferred (N):**
- ⏸️ `api.py:89` — Style preference, keeping original approach (NITPICK from @reviewer)

**Responses to questions:**
- `config.py:34` — The timeout is set to 30s to match upstream API limits
```

### Step 6: Output summary to terminal

Always print the full summary regardless of --comment flag.

## Important

- Read ALL comments before making ANY changes
- Never push to remote (user will review and push)
- If a fix would break other functionality, note it in the deferred section
- Deferred items always include a reason
```

**Step 2: Verify**
```bash
ls /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure/commands/
```
Expected: `ci-audit.md`, `ci-fix.md`, `pr-respond.md` plus existing commands.

**Step 3: Commit**
```bash
cd /mnt/d/GitHub/nsalvacao-claude-code-plugins
git add plugins/repo-structure/commands/pr-respond.md
git commit -m "feat(repo-structure): D1 /pr-respond command — resolve PR review comments with classify-fix-commit flow"
```

---

### Task 9: Group F — automation-validator Agent

**Files:**
- Create: `agents/automation-validator.md`

**Step 1: Create agents/automation-validator.md**

```markdown
---
description: >
  Validates health of all automation files in a repository — GitHub Actions workflows,
  pre-commit hooks, Claude Code hooks, Makefile/package.json scripts, and GitHub Actions
  matrix coherence. Use when: "validate automation", "check my hooks", "automation health
  check", /repo-validate --automation. Produces structured report with ✓/⚠/✗ per category
  plus actionable fix list.
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
- ✓ YAML syntax valid (yamllint or python yaml.safe_load)
- ✓ `on:` trigger key present and valid
- ✓ `runs-on:` uses known valid runner
- ✓ Required permissions declared for actions used
- ✓ Referenced secrets documented in comments or README
- ✓ Actions use pinned versions (not `@latest` or `@master`)
- ⚠ Matrix `fail-fast` setting documented
- ⚠ Checkout depth appropriate for workflow purpose

### Phase 3: Validate .pre-commit-config.yaml

For each hook in `.pre-commit-config.yaml`:
- ✓ Repository URL reachable (skip check if offline)
- ✓ `rev` field is a valid tag format (not branch name)
- ✓ Hooks listed in the repo's `.pre-commit-hooks.yaml`
- ⚠ `rev` not obviously stale (compare against common known versions)

### Phase 4: Validate Claude Code hooks

For hooks defined in `.claude/settings.json` or plugin `hooks.json`:
- ✓ Referenced script files exist at the specified path
- ✓ Script files pass `bash -n` syntax check
- ✓ No hardcoded absolute paths that would break on other machines (check for `CLAUDE_PLUGIN_ROOT`)
- ⚠ Timeout values set (warn if missing, default is 30s)

### Phase 5: Validate task runners

**Makefile:** Run `make --dry-run <target>` for each documented target. Flag targets that fail.

**package.json scripts:** Check `npm run <script> --dry-run` for each script. Flag missing dependencies.

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
  ✓ ci.yml — YAML valid, triggers OK, permissions OK
  ⚠ release.yml — actions/checkout@master (should pin to SHA or tag)
  ✗ deploy.yml — invalid runner 'ubuntu-lastest'

Pre-commit (.pre-commit-config.yaml)
  ✓ pre-commit/pre-commit-hooks @ v4.6.0 — OK
  ⚠ ruff-pre-commit @ v0.1.0 — may be stale (latest: v0.4+)

Claude Code Hooks
  ✓ validate-structure.sh — exists, syntax OK
  ✗ shellcheck-hook.sh — file not found at specified path

Task Runners (Makefile)
  ✓ test — runs successfully (dry-run)
  ⚠ deploy — references 'gcloud' (not in PATH)

Matrix Coherence
  ✓ Python versions consistent: 3.11 in both ci.yml and test-matrix.yml
  ⚠ ci.yml matrix missing fail-fast: false

=== Summary ===
✓ N checks passed
⚠ N warnings
✗ N errors

=== Actionable Fixes ===
1. [BLOCKER] deploy.yml:8 — Fix runner name: 'ubuntu-lastest' → 'ubuntu-latest'
2. [WARNING] release.yml:14 — Pin actions/checkout to SHA: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683
3. [WARNING] ruff-pre-commit — Update to latest rev
```

## Trigger phrases

- "validate automation"
- "check my hooks"
- "automation health check"
- `/repo-validate --automation`
- "are my CI workflows healthy"
- "check pre-commit config"
```

**Step 2: Verify**
```bash
ls /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure/agents/
```
Expected: `automation-validator.md` alongside existing agents.

**Step 3: Commit**
```bash
cd /mnt/d/GitHub/nsalvacao-claude-code-plugins
git add plugins/repo-structure/agents/automation-validator.md
git commit -m "feat(repo-structure): F1 automation-validator agent — validates workflows, hooks, pre-commit, task runners"
```

---

### Task 10: Finalization — plugin.json version bump + README update

**Files:**
- Modify: `.claude-plugin/plugin.json`
- Modify: `README.md`

**Step 1: Read current plugin.json and README**

Read both files before editing.

**Step 2: Bump version in plugin.json**

Find `"version": "0.1.0"` and change to `"version": "0.2.0"`.

Also update `keywords` to include new capabilities: add `"ci-debugging"`, `"pr-automation"`, `"hooks"`, `"automation-validator"` if not already present.

**Step 3: Update README.md**

The README needs to reflect v0.2.0 additions. Find and update:

1. **Version badge or header**: `0.1.0` → `0.2.0`
2. **Commands section**: Add `/ci-audit`, `/ci-fix`, `/pr-respond`
3. **Agents section**: Add `automation-validator`
4. **Skills section**: Add `ci-diagnostics`
5. **Scripts section**: Add `install-hooks.sh`, `check-compliance.sh`
6. **Templates section**: List all 9 new templates (4 github/, 3 configs/, 2 ci/)
7. **Hooks section**: Update from 2 to 5 hooks

**Step 4: Verify plugin.json**
```bash
python3 -m json.tool /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure/.claude-plugin/plugin.json > /dev/null && echo "plugin.json: valid JSON"
grep '"version"' /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure/.claude-plugin/plugin.json
```
Expected: valid JSON, version shows 0.2.0

**Step 5: Final component count verification**
```bash
echo "=== Component counts ==="
echo "Commands:" && ls /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure/commands/*.md | wc -l
echo "Agents:" && ls /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure/agents/*.md | wc -l
echo "Skills:" && ls -d /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure/skills/*/ | wc -l
echo "Hook scripts:" && ls /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure/hooks/scripts/*.sh | wc -l
echo "Scripts:" && ls /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure/scripts/*.{py,sh} 2>/dev/null | wc -l
echo "github/ templates:" && ls /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure/skills/repository-templates/templates/github/*.template | wc -l
echo "configs/ templates:" && ls /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure/skills/repository-templates/templates/configs/ | wc -l
echo "ci/ templates:" && ls /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure/skills/repository-templates/templates/ci/ | wc -l
```
Expected (v0.2.0 targets):
- Commands: 7 (4 existing + ci-audit, ci-fix, pr-respond)
- Agents: 4 (3 existing + automation-validator)
- Skills: 6 (5 existing + ci-diagnostics)
- Hook scripts: 5 (validate-structure + 4 new)
- Scripts: 6+ (calculate-score, detect-stack, generate-template, generate-template.sh + install-hooks, check-compliance)
- github/ templates: 6 (README, MIT + 4 new)
- configs/ templates: 3 new
- ci/ templates: 2 new

**Step 6: Final commit**
```bash
cd /mnt/d/GitHub/nsalvacao-claude-code-plugins
git add plugins/repo-structure/.claude-plugin/plugin.json \
        plugins/repo-structure/README.md
git commit -m "chore(repo-structure): bump version 0.1.0→0.2.0, update README with v0.2.0 components"
```

**Step 7: Push and create PR**
```bash
cd /mnt/d/GitHub/nsalvacao-claude-code-plugins
git push
gh pr create \
  --title "feat(repo-structure): v0.2.0 elevation — bug fixes, 9 templates, CI suite, hooks upgrade, automation-validator" \
  --body "$(cat <<'EOF'
## Summary

- **Group A (4 bugs fixed):** duplicate coverage scoring, false-positive link regex, missing detection functions, jq dependency without fallback
- **Group B (9 templates):** CONTRIBUTING, SECURITY, CODE_OF_CONDUCT, LICENSE.Apache-2.0, .gitignore Python/Node, .editorconfig, GitHub Actions Python/Node CI
- **Group C (CI debugging suite):** ci-diagnostics skill (10 patterns), /ci-audit command, /ci-fix command
- **Group D (/pr-respond):** Classify-fix-commit flow for PR review comments
- **Group E (hooks upgrade):** shellcheck, yamllint, lf-check, audit-reminder hooks (2→5 hooks)
- **Group F (automation-validator):** New agent — validates workflows, pre-commit, Claude hooks, task runners
- **Group G (2 scripts):** install-hooks.sh, check-compliance.sh
- **Group H (4 reference files):** scoring-rubrics, partial-credit-rules, detection-patterns, compliance-mapping

**~29 components, version 0.1.0 → 0.2.0**

## Test plan

- [ ] calculate-score.py: coverage scored once (2pts not 4pts)
- [ ] validate-structure.sh: valid markdown links not flagged as broken
- [ ] generate-template.py: all 5 new detection functions return bool
- [ ] detect-stack.sh: runs without jq installed
- [ ] All 4 bash hook scripts pass `bash -n` syntax check
- [ ] hooks.json: valid JSON with 5 hooks
- [ ] All 9 templates: balanced Mustache open/close braces
- [ ] detection-patterns.json: valid JSON
- [ ] install-hooks.sh --dry-run: runs without error in git repo
- [ ] check-compliance.sh: runs without error, outputs scores
- [ ] plugin.json: version 0.2.0

🤖 Generated with Claude Code
EOF
)"
```

---

## Quick Reference: Files Changed

```
plugins/repo-structure/
├── .claude-plugin/plugin.json              [UPDATE: 0.1.0→0.2.0]
├── scripts/
│   ├── calculate-score.py                  [FIX B1]
│   ├── generate-template.py                [FIX B3]
│   ├── detect-stack.sh                     [FIX B4]
│   ├── install-hooks.sh                    [NEW G1]
│   └── check-compliance.sh                 [NEW G2]
├── hooks/
│   ├── hooks.json                          [UPDATE: 2→5 hooks]
│   └── scripts/
│       ├── validate-structure.sh           [FIX B2]
│       ├── shellcheck-hook.sh              [NEW E1]
│       ├── yamllint-hook.sh                [NEW E2]
│       ├── lf-check-hook.sh                [NEW E3]
│       └── audit-reminder.sh              [NEW E4]
├── commands/
│   ├── ci-audit.md                         [NEW C2]
│   ├── ci-fix.md                           [NEW C3]
│   └── pr-respond.md                       [NEW D1]
├── agents/
│   └── automation-validator.md             [NEW F1]
├── skills/
│   ├── ci-diagnostics/SKILL.md             [NEW C1]
│   ├── quality-scoring/references/
│   │   ├── scoring-rubrics.md              [NEW H1]
│   │   └── partial-credit-rules.md         [NEW H2]
│   ├── tech-stack-detection/references/
│   │   └── detection-patterns.json         [NEW H3]
│   ├── compliance-standards/references/
│   │   └── compliance-mapping.md           [NEW H4]
│   └── repository-templates/templates/
│       ├── github/
│       │   ├── CONTRIBUTING.md.template    [NEW B1]
│       │   ├── SECURITY.md.template        [NEW B2]
│       │   ├── CODE_OF_CONDUCT.md.template [NEW B3]
│       │   └── LICENSE.Apache-2.0.template [NEW B4]
│       ├── configs/
│       │   ├── .gitignore.python.template  [NEW B5]
│       │   ├── .gitignore.node.template    [NEW B6]
│       │   └── .editorconfig.template      [NEW B7]
│       └── ci/
│           ├── python-ci.yml.template      [NEW B8]
│           └── node-ci.yml.template        [NEW B9]
└── README.md                               [UPDATE]
```

**Total: 29 components, version 0.1.0 → 0.2.0 (10 tasks, ~15 commits)**
