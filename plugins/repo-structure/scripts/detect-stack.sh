#!/usr/bin/env bash
#
# Tech stack detection script
# Analyzes repository to identify languages, frameworks, and tools

set -euo pipefail

# Detect primary language and frameworks
detect_stack() {
    local project_dir="${1:-.}"
    cd "$project_dir" || exit 1

    # Initialize result
    local languages=()
    local frameworks=()
    local tools=()
    local primary_language=""

    # Python detection
    if [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]] || [[ -f "Pipfile" ]]; then
        languages+=('{"name":"Python","confidence":85,"evidence":["requirements.txt or pyproject.toml found"]}')

        # Framework detection
        if grep -q "django" requirements.txt pyproject.toml 2>/dev/null; then
            frameworks+=('{"name":"Django","type":"web","confidence":90}')
        fi
        if grep -q "fastapi" requirements.txt pyproject.toml 2>/dev/null; then
            frameworks+=('{"name":"FastAPI","type":"web","confidence":90}')
        fi
        if grep -q "flask" requirements.txt pyproject.toml 2>/dev/null; then
            frameworks+=('{"name":"Flask","type":"web","confidence":90}')
        fi
    fi

    # JavaScript/TypeScript detection
    if [[ -f "package.json" ]]; then
        if grep -q '"typescript"' package.json; then
            languages+=('{"name":"TypeScript","confidence":85,"evidence":["typescript in package.json"]}')
        else
            languages+=('{"name":"JavaScript","confidence":85,"evidence":["package.json found"]}')
        fi

        # Framework detection
        if grep -q '"react"' package.json; then
            frameworks+=('{"name":"React","type":"frontend","confidence":90}')
        fi
        if grep -q '"vue"' package.json; then
            frameworks+=('{"name":"Vue","type":"frontend","confidence":90}')
        fi
        if grep -q '"next"' package.json; then
            frameworks+=('{"name":"Next.js","type":"frontend","confidence":90}')
        fi
        if grep -q '"express"' package.json; then
            frameworks+=('{"name":"Express","type":"backend","confidence":90}')
        fi
    fi

    # Go detection
    if [[ -f "go.mod" ]]; then
        languages+=('{"name":"Go","confidence":90,"evidence":["go.mod found"]}')
    fi

    # Rust detection
    if [[ -f "Cargo.toml" ]]; then
        languages+=('{"name":"Rust","confidence":90,"evidence":["Cargo.toml found"]}')
    fi

    # Docker detection
    if [[ -f "Dockerfile" ]] || [[ -f "docker-compose.yml" ]]; then
        tools+=('{"name":"Docker","confidence":100,"evidence":["Dockerfile or docker-compose.yml found"]}')
    fi

    # CI/CD detection
    if [[ -d ".github/workflows" ]]; then
        tools+=('{"name":"GitHub Actions","type":"ci","confidence":100}')
    fi
    if [[ -f ".gitlab-ci.yml" ]]; then
        tools+=('{"name":"GitLab CI","type":"ci","confidence":100}')
    fi

    # Determine primary language (first detected with highest confidence)
    if [[ ${#languages[@]} -gt 0 ]]; then
        primary_language=$(echo "${languages[0]}" | jq -r '.name')
    else
        primary_language="Unknown"
    fi

    # Output JSON
    cat <<EOF
{
  "languages": [$(IFS=,; echo "${languages[*]}")],
  "frameworks": [$(IFS=,; echo "${frameworks[*]}")],
  "tools": [$(IFS=,; echo "${tools[*]}")],
  "primary_language": "$primary_language",
  "is_monorepo": false
}
EOF
}

detect_stack "$@"
