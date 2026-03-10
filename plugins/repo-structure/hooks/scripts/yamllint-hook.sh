#!/usr/bin/env bash
# yamllint-hook.sh — Lint modified .yml/.yaml files (python3 yaml fallback)
set -euo pipefail

input=$(head -c 65536 /dev/stdin 2>/dev/null || echo "{}")
file_path=$(echo "$input" | python3 -c "import sys,json; d=json.loads(sys.stdin.read()); print(d.get('file_path',''))" 2>/dev/null || echo "")

# Only process yaml files
case "$file_path" in
    *.yml|*.yaml) ;;
    *) exit 0 ;;
esac

[[ -f "$file_path" ]] || exit 0

if command -v yamllint &>/dev/null; then
    yamllint "$file_path" 2>&1 || {
        echo "yamllint found issues in $file_path" >&2
        exit 1
    }
else
    # Fallback: python3 yaml parse
    python3 -c "
import sys, yaml
try:
    yaml.safe_load(open(sys.argv[1]))
except yaml.YAMLError as e:
    print('YAML error in ' + sys.argv[1] + ': ' + str(e), file=sys.stderr)
    sys.exit(1)
" "$file_path" 2>&1 || exit 1
fi
