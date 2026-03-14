#!/usr/bin/env bash
# validate-coherence.sh — Validates coherence between agents, schemas, templates, and references.
# Usage: ./validate-coherence.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Coherence Validation: agile-lifecycle plugin ==="
echo "Plugin dir: $PLUGIN_DIR"
echo ""

warn_count=0
fail_count=0
pass_count=0

warn() { echo "  WARN: $*"; warn_count=$((warn_count + 1)); }
fail() { echo "  FAIL: $*"; fail_count=$((fail_count + 1)); }
pass() { echo "  OK:   $*"; pass_count=$((pass_count + 1)); }

echo "--- Schemas: JSON validity ---"
if [[ -d "${PLUGIN_DIR}/schemas" ]]; then
  schema_count=0
  while IFS= read -r -d '' schema_file; do
    fname="$(basename "$schema_file")"
    if python3 -c "import json, sys; json.load(open(sys.argv[1]))" "$schema_file" 2>/dev/null; then
      pass "$fname — valid JSON"
    else
      fail "$fname — invalid JSON"
    fi
    schema_count=$((schema_count + 1))
  done < <(find "${PLUGIN_DIR}/schemas" -name "*.json" -print0 2>/dev/null)
  [[ $schema_count -eq 0 ]] && warn "No schema files found in schemas/"
else
  warn "schemas/ directory not found"
fi

echo ""
echo "--- Agents: frontmatter required fields ---"
if [[ -d "${PLUGIN_DIR}/agents" ]]; then
  agent_count=0
  while IFS= read -r -d '' agent_file; do
    fname="$(basename "$agent_file")"
    missing_fields=""
    for field in name description model color; do
      if ! grep -q "^${field}:" "$agent_file" 2>/dev/null; then
        missing_fields="${missing_fields} ${field}"
      fi
    done
    if [[ -n "$missing_fields" ]]; then
      warn "$fname — missing frontmatter fields:${missing_fields}"
    else
      pass "$fname — frontmatter OK"
    fi
    agent_count=$((agent_count + 1))
  done < <(find "${PLUGIN_DIR}/agents" -name "*.md" -print0 2>/dev/null)
  [[ $agent_count -eq 0 ]] && warn "No agent files found in agents/"
else
  warn "agents/ directory not found"
fi

echo ""
echo "--- Skills: SKILL.md frontmatter ---"
if [[ -d "${PLUGIN_DIR}/skills" ]]; then
  skill_count=0
  while IFS= read -r -d '' skill_file; do
    fname="$(dirname "$skill_file" | xargs basename)/$(basename "$skill_file")"
    if ! grep -q "^name:" "$skill_file" 2>/dev/null; then
      fail "$fname — missing 'name' in frontmatter"
    elif ! grep -q "^description:" "$skill_file" 2>/dev/null; then
      fail "$fname — missing 'description' in frontmatter"
    else
      pass "$fname — frontmatter OK"
    fi
    skill_count=$((skill_count + 1))
  done < <(find "${PLUGIN_DIR}/skills" -name "SKILL.md" -print0 2>/dev/null)
  [[ $skill_count -eq 0 ]] && warn "No SKILL.md files found in skills/"
else
  warn "skills/ directory not found"
fi

echo ""
echo "--- Templates: placeholder format ---"
if [[ -d "${PLUGIN_DIR}/templates" ]]; then
  template_count=0
  while IFS= read -r -d '' tmpl_file; do
    fname="$(basename "$tmpl_file")"
    if grep -qE '\{\{[a-zA-Z_][a-zA-Z0-9_]*\}\}' "$tmpl_file" 2>/dev/null; then
      pass "$fname — has {{placeholder}} syntax"
    else
      warn "$fname — no {{placeholder}} variables found"
    fi
    template_count=$((template_count + 1))
  done < <(find "${PLUGIN_DIR}/templates" -name "*.template" -print0 2>/dev/null)
  [[ $template_count -eq 0 ]] && warn "No .template files found in templates/"
else
  warn "templates/ directory not found"
fi

echo ""
echo "--- Commands: frontmatter required fields ---"
if [[ -d "${PLUGIN_DIR}/commands" ]]; then
  cmd_count=0
  while IFS= read -r -d '' cmd_file; do
    fname="$(basename "$cmd_file")"
    if ! grep -q "^name:" "$cmd_file" 2>/dev/null; then
      fail "$fname — missing 'name' in frontmatter"
    elif ! grep -q "^description:" "$cmd_file" 2>/dev/null; then
      fail "$fname — missing 'description' in frontmatter"
    else
      pass "$fname — frontmatter OK"
    fi
    cmd_count=$((cmd_count + 1))
  done < <(find "${PLUGIN_DIR}/commands" -name "*.md" -print0 2>/dev/null)
  [[ $cmd_count -eq 0 ]] && warn "No command files found in commands/"
else
  warn "commands/ directory not found"
fi

echo ""
echo "--- hooks/hooks.json: wrapper format ---"
HOOKS_FILE="${PLUGIN_DIR}/hooks/hooks.json"
if [[ -f "$HOOKS_FILE" ]]; then
  if python3 -c "
import json, sys
data = json.load(open(sys.argv[1]))
assert 'hooks' in data, 'missing top-level hooks key'
" "$HOOKS_FILE" 2>/dev/null; then
    pass "hooks.json — wrapper format OK"
  else
    fail "hooks.json — invalid or missing wrapper format"
  fi
else
  fail "hooks/hooks.json — not found"
fi

echo ""
echo "--- LF line endings: scripts ---"
if [[ -d "${PLUGIN_DIR}/scripts" ]]; then
  while IFS= read -r -d '' sh_file; do
    fname="$(basename "$sh_file")"
    if file "$sh_file" | grep -q "CRLF"; then
      fail "$fname — CRLF line endings detected (run dos2unix)"
    else
      pass "$fname — LF OK"
    fi
  done < <(find "${PLUGIN_DIR}/scripts" -name "*.sh" -print0 2>/dev/null)
fi

echo ""
echo "=== Summary ==="
echo "  Passed:   $pass_count"
echo "  Warnings: $warn_count"
echo "  Failures: $fail_count"
echo ""

if [[ $fail_count -gt 0 ]]; then
  echo "Result: FAIL — fix errors before proceeding"
  exit 1
elif [[ $warn_count -gt 0 ]]; then
  echo "Result: PASS WITH WARNINGS"
else
  echo "Result: PASS"
fi
