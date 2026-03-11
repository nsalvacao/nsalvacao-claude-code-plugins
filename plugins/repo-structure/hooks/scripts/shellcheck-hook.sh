#!/usr/bin/env bash
# Hook: run shellcheck on modified .sh files (graceful if not installed)
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
        echo "shellcheck found issues in $file_path" >&2
        exit 1
    }
fi
