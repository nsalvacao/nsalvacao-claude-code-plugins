---
name: Tech Stack Detection
description: This skill should be used when the user asks to "detect technology stack", "identify frameworks", "analyze project languages", "what stack is this", or needs automatic detection of programming languages, frameworks, and tools in a repository.
version: 0.1.0
---

# Tech Stack Detection

Intelligent detection of programming languages, frameworks, tools, and project type through file pattern analysis and dependency inspection.

## Overview

Automatically identifies the complete technical stack of a repository to enable:
- Context-aware template generation
- Stack-specific configuration
- Appropriate CI/CD workflow selection
- Accurate README documentation

Detection uses multiple signals with confidence scoring to handle polyglot projects and ambiguous cases.

## Detection Methods

### 1. File Pattern Matching

Identify languages by characteristic files:

**Python:**
- `requirements.txt`, `Pipfile`, `pyproject.toml`, `setup.py`
- `*.py` files

**JavaScript/TypeScript:**
- `package.json`, `yarn.lock`, `pnpm-lock.yaml`
- `*.js`, `*.jsx`, `*.ts`, `*.tsx` files

**Go:**
- `go.mod`, `go.sum`
- `*.go` files

**Rust:**
- `Cargo.toml`, `Cargo.lock`
- `*.rs` files

**Java:**
- `pom.xml`, `build.gradle`, `build.gradle.kts`
- `*.java` files

**Complete patterns in:** `references/detection-patterns.json`

### 2. Dependency Analysis

Parse package manifests to identify frameworks:

**Python frameworks:**
```python
# Parse requirements.txt or pyproject.toml
django → Django web framework
fastapi → FastAPI
flask → Flask
pytest → Testing framework
```

**JavaScript frameworks:**
```json
// Parse package.json dependencies
"react": "..." → React
"vue": "..." → Vue
"next": "..." → Next.js
"express": "..." → Express
```

**Complete framework patterns in:** `references/detection-patterns.json`

### 3. Extension Frequency Analysis

Count file extensions to determine primary language:

```bash
# Example: Mixed repo
.py files: 45 (confidence: 75%)
.js files: 20 (confidence: 25%)
→ Primary: Python, Secondary: JavaScript
```

### 4. Confidence Scoring

Each detection method contributes to confidence score:

```
File patterns:        +40 pts
Dependency analysis:  +30 pts
Extension count:      +20 pts
Build config:         +10 pts
----------------------------
Total:               100 pts

Threshold:
- High confidence:    80+ pts
- Medium confidence:  50-79 pts
- Low confidence:     <50 pts
```

## Detection Script

Main detection implemented in: `scripts/detect-stack.sh`

**Usage:**
```bash
cd /path/to/project
bash $CLAUDE_PLUGIN_ROOT/skills/tech-stack-detection/scripts/detect-stack.sh
```

**Output format (JSON):**
```json
{
  "languages": [
    {
      "name": "Python",
      "confidence": 85,
      "evidence": [
        "requirements.txt found",
        "45 .py files",
        "pyproject.toml with [project]"
      ]
    },
    {
      "name": "JavaScript",
      "confidence": 60,
      "evidence": [
        "package.json found",
        "20 .js files"
      ]
    }
  ],
  "frameworks": [
    {
      "name": "FastAPI",
      "type": "web",
      "confidence": 90,
      "evidence": ["fastapi in requirements.txt", "main.py with FastAPI import"]
    },
    {
      "name": "React",
      "type": "frontend",
      "confidence": 75,
      "evidence": ["react in package.json", ".jsx files present"]
    }
  ],
  "tools": [
    {
      "name": "Docker",
      "confidence": 100,
      "evidence": ["Dockerfile found", "docker-compose.yml found"]
    },
    {
      "name": "pytest",
      "type": "testing",
      "confidence": 90,
      "evidence": ["pytest in requirements.txt", "tests/ directory with test_*.py"]
    }
  ],
  "project_type": "web-application",
  "primary_language": "Python",
  "is_monorepo": false
}
```

## Project Type Detection

Classify project purpose:

**Library:**
- Python: `setup.py` or `[project]` in `pyproject.toml`
- JavaScript: `"type": "module"` or `"main"` in `package.json`
- Go: No `func main()` in root
- Rust: `[lib]` section in `Cargo.toml`

**CLI Tool:**
- Python: `console_scripts` in setup.py
- JavaScript: `"bin"` in package.json
- Go: `func main()` in `cmd/` directory
- Rust: `[[bin]]` in Cargo.toml

**Web Application:**
- Web framework detected (Django, FastAPI, Express, Rails)
- Frontend framework detected (React, Vue, Angular)
- Server files (server.js, app.py, main.go)

**Framework/Starter:**
- Template structure
- Multiple example files
- Boilerplate patterns

## Monorepo Detection

Identify monorepo structure:

**Indicators:**
- Multiple `package.json` / `pyproject.toml` in subdirectories
- Workspace configuration (npm workspaces, Lerna, Turborepo, Poetry)
- Distinct `apps/`, `packages/`, `services/` directories

**Monorepo tools:**
- npm workspaces: `"workspaces"` in root package.json
- Lerna: `lerna.json` present
- Turborepo: `turbo.json` present
- Poetry: `[tool.poetry.workspace]` in pyproject.toml
- Go modules: Multiple `go.mod` files

**Monorepo output:**
```json
{
  "is_monorepo": true,
  "monorepo_tool": "npm-workspaces",
  "packages": [
    {
      "path": "packages/frontend",
      "language": "TypeScript",
      "frameworks": ["React", "Vite"]
    },
    {
      "path": "packages/backend",
      "language": "Python",
      "frameworks": ["FastAPI"]
    }
  ]
}
```

## Handling Ambiguity

### Multiple Primary Languages

When multiple languages have high confidence:

```json
{
  "languages": [
    {"name": "Python", "confidence": 85},
    {"name": "JavaScript", "confidence": 80}
  ],
  "primary_language": "Python",
  "secondary_languages": ["JavaScript"],
  "recommendation": "Polyglot project - consider monorepo structure"
}
```

**Selection criteria for primary:**
1. Higher confidence score
2. More entry point files (main.py, index.js)
3. Larger codebase (LOC)
4. User configuration override

### Unknown Patterns

If detection confidence is low:

```json
{
  "languages": [
    {"name": "Unknown", "confidence": 30}
  ],
  "fallback": "generic",
  "recommendation": "Manual specification required"
}
```

**Fallback behavior:**
- Use generic templates
- Prompt user for clarification
- Skip stack-specific configurations

## Integration with Template Generation

Detection results feed into template variable resolution:

```bash
# 1. Detect stack
STACK_JSON=$(bash detect-stack.sh)

# 2. Extract variables
PRIMARY_LANG=$(echo $STACK_JSON | jq -r '.primary_language')
FRAMEWORKS=$(echo $STACK_JSON | jq -r '.frameworks[].name' | paste -sd, -)

# 3. Pass to template generation
bash generate-template.sh \
  --template "README.md" \
  --var "PRIMARY_LANGUAGE=$PRIMARY_LANG" \
  --var "TECH_STACK=$FRAMEWORKS"
```

## Detection Patterns

Complete detection patterns defined in: `references/detection-patterns.json`

**Structure:**
```json
{
  "languages": {
    "python": {
      "files": ["requirements.txt", "pyproject.toml", "setup.py", "Pipfile"],
      "extensions": [".py"],
      "confidence_weights": {
        "files": 40,
        "extensions": 20,
        "imports": 30,
        "build_config": 10
      }
    }
  },
  "frameworks": {
    "django": {
      "language": "python",
      "indicators": [
        {"pattern": "django", "file": "requirements.txt", "weight": 40},
        {"pattern": "manage.py", "file": "root", "weight": 30},
        {"pattern": "settings.py", "file": "*/settings.py", "weight": 20}
      ]
    }
  }
}
```

## Version Detection

Detect language/framework versions:

**Python:**
```bash
# From pyproject.toml
requires-python = ">=3.8"

# From runtime files
.python-version → 3.11.5
```

**Node.js:**
```bash
# From package.json
"engines": {"node": ">=18.0.0"}

# From runtime files
.nvmrc → 18.16.0
```

**Output:**
```json
{
  "languages": [
    {
      "name": "Python",
      "version": "3.11",
      "version_constraint": ">=3.8"
    }
  ]
}
```

## Testing Detection

Verify detection accuracy:

```bash
# Test on known projects
bash scripts/detect-stack.sh /path/to/django-project
# Expected: Python, Django, pytest

bash scripts/detect-stack.sh /path/to/nextjs-project
# Expected: TypeScript, Next.js, React

# Validate against test corpus
bash scripts/validate-detection.sh
```

Test corpus in: `examples/test-projects/`

## Additional Resources

### Reference Files

- **`references/detection-patterns.json`** - Complete detection rules
- **`references/framework-catalog.md`** - Supported frameworks documentation
- **`references/version-detection.md`** - Version detection strategies

### Scripts

- **`scripts/detect-stack.sh`** - Main detection script
- **`scripts/lib/detect-language.sh`** - Language detection functions
- **`scripts/lib/detect-framework.sh`** - Framework detection functions
- **`scripts/validate-detection.sh`** - Test detection accuracy

### Examples

- **`examples/detection-output.json`** - Sample detection output
- **`examples/test-projects/`** - Test corpus for validation

## Integration Points

This skill integrates with:
- **repository-templates** - Provides variables for template rendering
- **quality-scoring** - Validates appropriate configs for detected stack
- **automation-strategies** - Selects stack-specific hooks and linters

Detection is orchestrated by `structure-architect` agent as the first step in repository analysis.
