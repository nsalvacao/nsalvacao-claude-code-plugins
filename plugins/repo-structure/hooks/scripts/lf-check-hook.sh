#!/usr/bin/env bash
# lf-check-hook.sh — Detect CRLF line endings in written files (warning only)
set -euo pipefail

input=$(head -c 65536 /dev/stdin 2>/dev/null || echo "{}")
file_path=$(echo "$input" | python3 -c "import sys,json; d=json.loads(sys.stdin.read()); print(d.get('file_path',''))" 2>/dev/null || echo "")

[[ -f "$file_path" ]] || exit 0

# Skip binary files
file "$file_path" 2>/dev/null | grep -q "text" || exit 0

if file "$file_path" 2>/dev/null | grep -q "CRLF"; then
    echo "CRLF line endings detected in: $file_path" >&2
    echo "    Fix with: dos2unix \"$file_path\"" >&2
fi
# Always exit 0 -- CRLF is a warning, not a blocker
exit 0
