#!/usr/bin/env bash
# yamllint-hook.sh — Lint modified .yml/.yaml files (python3 yaml fallback)
set -euo pipefail

input=$(head -c 65536 /dev/stdin 2>/dev/null || echo "{}")
file_path=$(echo "$input" | python3 -c "import sys,json; d=json.loads(sys.stdin.read()); ti=d.get('tool_input',{}); print(ti.get('file_path','') or d.get('file_path',''))" 2>/dev/null || echo "")

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
    # Fallback: python3 yaml parse — only if PyYAML is available
    if python3 - <<'PY' >/dev/null 2>&1
import importlib.util, sys
sys.exit(0 if importlib.util.find_spec("yaml") is not None else 1)
PY
    then
        python3 - "$file_path" <<'PY' 2>&1 || exit 1
import sys, yaml
try:
    with open(sys.argv[1], encoding='utf-8') as fh:
        yaml.safe_load(fh)
except yaml.YAMLError as e:
    print('YAML error in ' + sys.argv[1] + ': ' + str(e), file=sys.stderr)
    sys.exit(1)
PY
    else
        echo "Skipping YAML lint for $file_path: neither 'yamllint' nor PyYAML available." >&2
        echo "Install 'yamllint' or 'pip install pyyaml' to enable YAML validation." >&2
    fi
fi
