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
    if [[ -d ".github/workflows" ]] && find ".github/workflows" -maxdepth 1 \( -name "*.yml" -o -name "*.yaml" \) -print -quit 2>/dev/null | grep -q .; then
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
    OPENSSF_SCORE="$openssf_score" CII_SCORE="$cii_score" NOTES_FILE="$NOTES_FILE" \
    python3 - <<'PY'
import json, os

notes_file = os.environ.get('NOTES_FILE', '')
scores = {
    'openssf': {'score': os.environ.get('OPENSSF_SCORE', ''), 'issues': []},
    'cii': {'score': os.environ.get('CII_SCORE', ''), 'issues': []},
}

if notes_file:
    try:
        with open(notes_file, encoding='utf-8') as fh:
            for line in fh:
                line = line.strip()
                if ':' not in line:
                    continue
                key, msg = line.split(':', 1)
                if key.startswith('openssf_'):
                    scores['openssf']['issues'].append({'key': key[len('openssf_'):], 'message': msg})
                elif key.startswith('cii_'):
                    scores['cii']['issues'].append({'key': key[len('cii_'):], 'message': msg})
    except (OSError, UnicodeDecodeError):
        pass

print(json.dumps(scores, indent=2))
PY
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
