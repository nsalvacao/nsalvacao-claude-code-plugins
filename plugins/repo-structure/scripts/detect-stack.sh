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
    if [[ -f "requirements.txt" || -f "pyproject.toml" || -f "setup.py" || -f "setup.cfg" || -f "Pipfile" || -f "Pipfile.lock" ]]; then
        local py_evidence=()
        [[ -f "requirements.txt" ]] && py_evidence+=("requirements.txt found")
        [[ -f "pyproject.toml" ]] && py_evidence+=("pyproject.toml found")
        [[ -f "setup.py" ]] && py_evidence+=("setup.py found")
        [[ -f "setup.cfg" ]] && py_evidence+=("setup.cfg found")
        [[ -f "Pipfile" ]] && py_evidence+=("Pipfile found")
        [[ -f "Pipfile.lock" ]] && py_evidence+=("Pipfile.lock found")
        local py_count=${#py_evidence[@]}
        local py_conf=$((60 + py_count * 10))
        [[ $py_conf -gt 95 ]] && py_conf=95
        local py_evidence_json
        py_evidence_json=$(printf '"%s",' "${py_evidence[@]}" | sed 's/,$//')
        languages+=("{\"name\":\"Python\",\"confidence\":${py_conf},\"evidence\":[${py_evidence_json}]}")

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
        local js_evidence=("package.json found")
        if [[ -f "tsconfig.json" ]]; then
            js_evidence+=("tsconfig.json found")
            local ts_conf=$((70 + ${#js_evidence[@]} * 10))
            [[ $ts_conf -gt 95 ]] && ts_conf=95
            languages+=("{\"name\":\"TypeScript\",\"confidence\":${ts_conf},\"evidence\":[$(printf '"%s",' "${js_evidence[@]}" | sed 's/,$//')]}")
        else
            local js_conf=$((60 + ${#js_evidence[@]} * 10))
            [[ $js_conf -gt 90 ]] && js_conf=90
            languages+=("{\"name\":\"JavaScript\",\"confidence\":${js_conf},\"evidence\":[\"package.json found\"]}")
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
        languages+=('{"name":"Go","confidence":85,"evidence":["go.mod found"]}')
    fi

    # Rust detection
    if [[ -f "Cargo.toml" ]]; then
        languages+=('{"name":"Rust","confidence":85,"evidence":["Cargo.toml found"]}')
    fi

    # Docker detection
    if [[ -f "Dockerfile" ]] || [[ -f "docker-compose.yml" ]]; then
        tools+=('{"name":"Docker","confidence":95,"evidence":["Dockerfile or docker-compose.yml found"]}')
    fi

    # CI/CD detection
    if [[ -d ".github/workflows" ]]; then
        tools+=('{"name":"GitHub Actions","type":"ci","confidence":95}')
    fi
    if [[ -f ".gitlab-ci.yml" ]]; then
        tools+=('{"name":"GitLab CI","type":"ci","confidence":95}')
    fi

    # Determine primary language (first detected with highest confidence)
    if [[ ${#languages[@]} -gt 0 ]]; then
        if command -v jq &>/dev/null; then
            primary_language=$(echo "${languages[0]}" | jq -r '.name')
        else
            primary_language=$(echo "${languages[0]}" | python3 -c "import sys,json; d=json.loads(sys.stdin.read()); print(d['name'])")
        fi
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
