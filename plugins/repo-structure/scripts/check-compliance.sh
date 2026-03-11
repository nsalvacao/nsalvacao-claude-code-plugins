#!/usr/bin/env bash
# check-compliance.sh — Check OpenSSF/CII compliance basics
# Usage: bash check-compliance.sh [--json]
set -euo pipefail

JSON_OUTPUT=false
[[ "${1:-}" == "--json" ]] && JSON_OUTPUT=true

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")"
cd "$ROOT"

# Use a temp file to collect notes across subshells
NOTES_FILE="$(mktemp)"
trap 'rm -f "$NOTES_FILE"' EXIT

# OpenSSF checks
check_openssf() {
    local total=0
    local max=0

    # SECURITY.md
    max=$((max+1))
    if [[ -f "SECURITY.md" || -f ".github/SECURITY.md" ]]; then
        total=$((total+1))
    else
        echo "openssf_security:Missing SECURITY.md" >> "$NOTES_FILE"
    fi

    # LICENSE
    max=$((max+1))
    if [[ -f "LICENSE" || -f "LICENSE.md" || -f "LICENSE.txt" ]]; then
        total=$((total+1))
    else
        echo "openssf_license:Missing LICENSE file" >> "$NOTES_FILE"
    fi

    # CONTRIBUTING
    max=$((max+1))
    if [[ -f "CONTRIBUTING.md" || -f ".github/CONTRIBUTING.md" ]]; then
        total=$((total+1))
    else
        echo "openssf_contributing:Missing CONTRIBUTING.md" >> "$NOTES_FILE"
    fi

    # CI present
    max=$((max+1))
    if [[ -d ".github/workflows" ]] && ls .github/workflows/*.yml 2>/dev/null | head -1 &>/dev/null; then
        total=$((total+1))
    else
        echo "openssf_ci:No GitHub Actions workflows found" >> "$NOTES_FILE"
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
        total=$((total+1))
    else
        echo "cii_readme:Missing README" >> "$NOTES_FILE"
    fi

    # LICENSE
    max=$((max+1))
    if [[ -f "LICENSE" || -f "LICENSE.md" ]]; then
        total=$((total+1))
    else
        echo "cii_license:Missing LICENSE" >> "$NOTES_FILE"
    fi

    # Tests
    max=$((max+1))
    local has_tests=false
    [[ -d "tests" || -d "test" || -d "spec" ]] && has_tests=true
    if ! $has_tests && find . -maxdepth 4 \( -name "test_*.py" -o -name "*_test.py" -o -name "*.test.js" \) 2>/dev/null | head -1 | grep -q .; then
        has_tests=true
    fi
    if $has_tests; then
        total=$((total+1))
    else
        echo "cii_tests:No test directory or test files found" >> "$NOTES_FILE"
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
    if [[ -s "$NOTES_FILE" ]]; then
        echo "Issues:"
        while IFS=: read -r key msg; do
            echo "  - [${key}] ${msg}"
        done < "$NOTES_FILE"
    else
        echo "No issues found."
    fi
fi
