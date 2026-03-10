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
    local has_tests=false
    [[ -d "tests" || -d "test" || -d "spec" ]] && has_tests=true
    if ! $has_tests && find . -maxdepth 4 \( -name "test_*.py" -o -name "*_test.py" -o -name "*.test.js" \) 2>/dev/null | head -1 | grep -q .; then
        has_tests=true
    fi
    if $has_tests; then
        scores["cii_tests"]=1
        total=$((total+1))
    else
        scores["cii_tests"]=0
        notes["cii_tests"]="No test directory or test files found"
    fi

    echo "$total/$max"
}

if [[ "$JSON_OUTPUT" == "true" ]]; then
    openssf_score=$(check_openssf)
    cii_score=$(check_cii)
    python3 -c "
import json, sys
scores = {
    'openssf': {'score': '$openssf_score'},
    'cii': {'score': '$cii_score'},
}
print(json.dumps(scores, indent=2))
"
else
    echo "=== Compliance Check ==="
    echo
    printf "OpenSSF: %s\n" "$(check_openssf)"
    printf "CII:     %s\n" "$(check_cii)"
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
