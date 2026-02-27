#!/usr/bin/env bash
#
# Pre-commit validation hook for structure files
# Validates YAML, JSON, and Markdown syntax

set -euo pipefail

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Validation functions
validate_yaml() {
    local file="$1"
    if command -v yq &>/dev/null; then
        yq eval . "$file" >/dev/null 2>&1 || {
            echo -e "${RED}❌ Invalid YAML: $file${NC}" >&2
            return 1
        }
    elif command -v python3 &>/dev/null; then
        python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null || {
            echo -e "${RED}❌ Invalid YAML: $file${NC}" >&2
            return 1
        }
    fi
    return 0
}

validate_json() {
    local file="$1"
    if command -v jq &>/dev/null; then
        jq empty "$file" 2>&1 || {
            echo -e "${RED}❌ Invalid JSON: $file${NC}" >&2
            return 1
        }
    elif command -v python3 &>/dev/null; then
        python3 -c "import json; json.load(open('$file'))" 2>/dev/null || {
            echo -e "${RED}❌ Invalid JSON: $file${NC}" >&2
            return 1
        }
    fi
    return 0
}

validate_markdown() {
    local file="$1"
    # Basic markdown validation (check for common issues)
    if grep -q '\[.*\]([^)]*)$' "$file"; then
        echo -e "${YELLOW}⚠️ Potential broken link in: $file${NC}" >&2
    fi
    return 0
}

# Main validation logic
main() {
    local files_to_validate=()
    local errors=0

    # Collect files from git staging area if available
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        while IFS= read -r file; do
            [[ -f "$file" ]] && files_to_validate+=("$file")
        done < <(git diff --cached --name-only --diff-filter=ACM)
    fi

    # If no git or no staged files, validate common structure files
    if [[ ${#files_to_validate[@]} -eq 0 ]]; then
        [[ -f ".github/workflows/test.yml" ]] && files_to_validate+=(".github/workflows/test.yml")
        [[ -f ".pre-commit-config.yaml" ]] && files_to_validate+=(".pre-commit-config.yaml")
        [[ -f "package.json" ]] && files_to_validate+=("package.json")
        [[ -f "README.md" ]] && files_to_validate+=("README.md")
    fi

    # Validate each file
    for file in "${files_to_validate[@]}"; do
        case "$file" in
            *.yml|*.yaml)
                validate_yaml "$file" || ((errors++))
                ;;
            *.json)
                validate_json "$file" || ((errors++))
                ;;
            *.md)
                validate_markdown "$file" || ((errors++))
                ;;
        esac
    done

    # Report results
    if [[ $errors -eq 0 ]]; then
        echo -e "${GREEN}✅ Structure validation passed${NC}"
        return 0
    else
        echo -e "${RED}❌ Structure validation failed with $errors error(s)${NC}" >&2
        return 1
    fi
}

main "$@"
