#!/usr/bin/env bash
#
# Template generation script with variable substitution
# Wrapper around Python implementation for complex Mustache logic
#
# Usage:
#   bash scripts/generate-template.sh --template X --output Y --vars "key=val,..."
#   bash scripts/generate-template.sh --template X --output Y --vars-file vars.json
#   bash scripts/generate-template.sh --help
#
# Exit codes:
#   0 - Success
#   1 - Error (missing template, invalid vars, etc.)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SCRIPT="$SCRIPT_DIR/generate-template.py"

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Parse arguments and pass to Python
args=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --template)
            args+=("--template" "$2")
            shift 2
            ;;
        --output)
            args+=("--output" "$2")
            shift 2
            ;;
        --vars)
            args+=("--vars" "$2")
            shift 2
            ;;
        --vars-file)
            args+=("--vars-file" "$2")
            shift 2
            ;;
        --prompt-missing)
            args+=("--prompt-missing")
            shift
            ;;
        --mock-vars)
            args+=("--mock-vars")
            shift
            ;;
        --strict)
            args+=("--strict")
            shift
            ;;
        --help|-h)
            echo "Usage: generate-template.sh [OPTIONS]"
            echo ""
            echo "Template rendering script with Mustache-style variable substitution"
            echo ""
            echo "Options:"
            echo "  --template FILE      Template file path (required)"
            echo "  --output FILE        Output file path (required)"
            echo "  --vars \"k=v,k=v\"    Comma-separated key=value pairs"
            echo "  --vars-file FILE     JSON file with variables"
            echo "  --prompt-missing     Prompt for missing variables"
            echo "  --mock-vars          Use mock values (bypass git config)"
            echo "  --strict             Fail on missing variables"
            echo "  --help               Show this help message"
            echo ""
            echo "Template Syntax:"
            echo "  {{VAR}}              Simple variable substitution"
            echo "  {{#COND}}...{{/COND}} Include if condition is truthy"
            echo "  {{^COND}}...{{/COND}} Include if condition is falsy"
            echo ""
            echo "Conditionals: PYTHON, JAVASCRIPT, TYPESCRIPT, GO, RUST, HAS_CI, HAS_TESTS, HAS_DOCKER, IS_LIBRARY, IS_CLI"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check if Python script exists
if [[ ! -f "$PYTHON_SCRIPT" ]]; then
    log_error "Python script not found: $PYTHON_SCRIPT"
    exit 1
fi

# Run Python script with all arguments
exec python3 "$PYTHON_SCRIPT" "${args[@]}"
