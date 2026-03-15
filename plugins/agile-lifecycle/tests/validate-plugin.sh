#!/bin/bash
#
# Integration testing suite for agile-lifecycle plugin
# Static analysis validation of plugin structure, format, and references
#
# Usage: bash plugins/agile-lifecycle/tests/validate-plugin.sh
# Exit code: 0 if all checks pass, 1 if any check fails
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Counters
PASS_COUNT=0
FAIL_COUNT=0
TOTAL_CHECKS=6

# Paths (relative to repo root)
PLUGIN_DIR="plugins/agile-lifecycle"
SKILLS_DIR="${PLUGIN_DIR}/skills"
AGENTS_DIR="${PLUGIN_DIR}/agents"
DOCS_DIR="${PLUGIN_DIR}/docs"
PLUGIN_JSON="${PLUGIN_DIR}/.claude-plugin/plugin.json"
MARKETPLACE_JSON=".claude-plugin/marketplace.json"

# Test counters for detailed reporting
SKILL_MISSING_NAME=0
SKILL_MISSING_DESC=0
AGENT_MISSING_PHASE_CONTRACT=0
AGENT_MISSING_TEMPLATES=0
AGENT_MISSING_ACTIVITIES=0
CRLF_FILES=0
BROKEN_REFS=0

echo "===================================================="
echo "Integration Testing Suite: agile-lifecycle plugin"
echo "===================================================="
echo

# Check 1: All SKILL.md files have frontmatter 'name:' and 'description:'
echo "Check 1: SKILL.md frontmatter validation"
echo "----------------------------------------"

while IFS= read -r skill_file; do
  if [ -z "$skill_file" ]; then
    continue
  fi

  # Check for name field
  if ! grep -q "^name:" "$skill_file"; then
    SKILL_MISSING_NAME=$((SKILL_MISSING_NAME + 1))
    echo -e "  ${RED}FAIL${NC}: $skill_file missing 'name:' field"
  fi

  # Check for description field
  if ! grep -q "^description:" "$skill_file"; then
    SKILL_MISSING_DESC=$((SKILL_MISSING_DESC + 1))
    echo -e "  ${RED}FAIL${NC}: $skill_file missing 'description:' field"
  fi
done < <(find "$SKILLS_DIR" -name "SKILL.md")

if [ $SKILL_MISSING_NAME -eq 0 ] && [ $SKILL_MISSING_DESC -eq 0 ]; then
  SKILL_COUNT=$(find "$SKILLS_DIR" -name "SKILL.md" | wc -l)
  echo -e "${GREEN}✓ PASS${NC}: All $SKILL_COUNT SKILL.md files have required frontmatter fields"
  PASS_COUNT=$((PASS_COUNT + 1))
else
  echo -e "${RED}✗ FAIL${NC}: SKILL.md validation errors ($SKILL_MISSING_NAME missing 'name:', $SKILL_MISSING_DESC missing 'description:')"
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi
echo

# Check 2: All agent .md files have sections: '## Phase Contract', '## Templates Available', '## Activities'
echo "Check 2: Agent .md sections validation"
echo "--------------------------------------"

while IFS= read -r agent_file; do
  if [ -z "$agent_file" ]; then
    continue
  fi

  # Check for Phase Contract section
  if ! grep -q "^## Phase Contract" "$agent_file"; then
    AGENT_MISSING_PHASE_CONTRACT=$((AGENT_MISSING_PHASE_CONTRACT + 1))
    echo -e "  ${RED}FAIL${NC}: $(basename "$agent_file") missing '## Phase Contract' section"
  fi

  # Check for Templates Available section
  if ! grep -q "^## Templates Available" "$agent_file"; then
    AGENT_MISSING_TEMPLATES=$((AGENT_MISSING_TEMPLATES + 1))
    echo -e "  ${RED}FAIL${NC}: $(basename "$agent_file") missing '## Templates Available' section"
  fi

  # Check for Activities section
  if ! grep -q "^## Activities" "$agent_file"; then
    AGENT_MISSING_ACTIVITIES=$((AGENT_MISSING_ACTIVITIES + 1))
    echo -e "  ${RED}FAIL${NC}: $(basename "$agent_file") missing '## Activities' section"
  fi
done < <(find "$AGENTS_DIR" -name "*.md")

if [ $AGENT_MISSING_PHASE_CONTRACT -eq 0 ] && [ $AGENT_MISSING_TEMPLATES -eq 0 ] && [ $AGENT_MISSING_ACTIVITIES -eq 0 ]; then
  AGENT_COUNT=$(find "$AGENTS_DIR" -name "*.md" | wc -l)
  echo -e "${GREEN}✓ PASS${NC}: All $AGENT_COUNT agent .md files have required sections"
  PASS_COUNT=$((PASS_COUNT + 1))
else
  TOTAL_ISSUES=$((AGENT_MISSING_PHASE_CONTRACT + AGENT_MISSING_TEMPLATES + AGENT_MISSING_ACTIVITIES))
  echo -e "${RED}✗ FAIL${NC}: Agent section validation errors ($TOTAL_ISSUES issues found)"
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi
echo

# Check 3: All Markdown files have LF endings (no CRLF)
echo "Check 3: Line ending validation (LF only)"
echo "-----------------------------------------"

while IFS= read -r md_file; do
  if file "$md_file" | grep -q "CRLF"; then
    CRLF_FILES=$((CRLF_FILES + 1))
    echo -e "  ${RED}FAIL${NC}: $(basename "$md_file") has CRLF line endings"
  fi
done < <(find "$PLUGIN_DIR" -type f \( -name "*.md" -o -name "*.template" \))

if [ $CRLF_FILES -eq 0 ]; then
  TOTAL_MD=$(find "$PLUGIN_DIR" -type f \( -name "*.md" -o -name "*.template" \) | wc -l)
  echo -e "${GREEN}✓ PASS${NC}: All $TOTAL_MD Markdown files use LF line endings"
  PASS_COUNT=$((PASS_COUNT + 1))
else
  echo -e "${RED}✗ FAIL${NC}: $CRLF_FILES Markdown files have CRLF line endings"
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi
echo

# Check 4: Template references in docs/ point to existing files
echo "Check 4: Template reference validation"
echo "--------------------------------------"

# Extract all template references from docs
TEMP_REFS=$(grep -rho "templates/[a-z0-9/_-]*\.template" "$DOCS_DIR" 2>/dev/null || true)

while IFS= read -r ref; do
  [ -z "$ref" ] && continue
  template_file="${PLUGIN_DIR}/${ref}"
  if [ ! -f "$template_file" ]; then
    BROKEN_REFS=$((BROKEN_REFS + 1))
    echo -e "  ${RED}FAIL${NC}: Broken reference in docs: ${ref} (file not found)"
  fi
done <<< "$TEMP_REFS"

if [ $BROKEN_REFS -eq 0 ]; then
  UNIQUE_REFS=$(echo "$TEMP_REFS" | sort | uniq | wc -l)
  echo -e "${GREEN}✓ PASS${NC}: All template references in docs are valid ($UNIQUE_REFS unique references)"
  PASS_COUNT=$((PASS_COUNT + 1))
else
  echo -e "${RED}✗ FAIL${NC}: $BROKEN_REFS broken template references found"
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi
echo

# Check 5: plugin.json is valid JSON
echo "Check 5: plugin.json validation"
echo "-------------------------------"

if jq empty "$PLUGIN_JSON" 2>/dev/null; then
  echo -e "${GREEN}✓ PASS${NC}: $PLUGIN_JSON is valid JSON"
  PASS_COUNT=$((PASS_COUNT + 1))
else
  echo -e "${RED}✗ FAIL${NC}: $PLUGIN_JSON contains invalid JSON"
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi
echo

# Check 6: marketplace.json is valid JSON and contains agile-lifecycle entry
echo "Check 6: marketplace.json validation"
echo "------------------------------------"

if ! jq empty "$MARKETPLACE_JSON" 2>/dev/null; then
  echo -e "${RED}✗ FAIL${NC}: $MARKETPLACE_JSON contains invalid JSON"
  FAIL_COUNT=$((FAIL_COUNT + 1))
elif ! jq '.[] | select(.name == "agile-lifecycle")' "$MARKETPLACE_JSON" 2>/dev/null | jq empty 2>/dev/null; then
  echo -e "${RED}✗ FAIL${NC}: agile-lifecycle entry not found in $MARKETPLACE_JSON"
  FAIL_COUNT=$((FAIL_COUNT + 1))
else
  echo -e "${GREEN}✓ PASS${NC}: $MARKETPLACE_JSON is valid JSON and contains agile-lifecycle entry"
  PASS_COUNT=$((PASS_COUNT + 1))
fi
echo

# Summary
echo "===================================================="
echo "Test Summary"
echo "===================================================="
echo "Passed: $PASS_COUNT/$TOTAL_CHECKS"
echo "Failed: $FAIL_COUNT/$TOTAL_CHECKS"
echo

if [ $FAIL_COUNT -eq 0 ]; then
  echo -e "${GREEN}✓ All checks passed!${NC}"
  exit 0
else
  echo -e "${RED}✗ Some checks failed. Review output above.${NC}"
  exit 1
fi
