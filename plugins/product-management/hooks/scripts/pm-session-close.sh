#!/usr/bin/env bash
# pm-session-close.sh — PM workflow reminder at session Stop
# Suggests review commands when spec or roadmap files were touched

set -euo pipefail

CWD="$(pwd)"

# Check if any PM-related files exist in the project
SPEC_FILES=0
ROADMAP_FILES=0

# Count spec files
if find "$CWD" -maxdepth 3 \
    \( -name "*-spec.md" -o -name "*-prd.md" -o -name "PRD*.md" \
    -o -name "SPEC*.md" -o -name "*-requirements.md" \) \
    2>/dev/null | head -1 | grep -q .; then
    SPEC_FILES=1
fi

# Check for roadmap files
if [[ -f "$CWD/ROADMAP.md" ]] || [[ -f "$CWD/roadmap.md" ]] || \
   find "$CWD/docs" -maxdepth 1 -name "roadmap*" 2>/dev/null | head -1 | grep -q .; then
    ROADMAP_FILES=1
fi

# Only show reminder if PM artifacts exist
if [[ "$SPEC_FILES" -eq 0 ]] && [[ "$ROADMAP_FILES" -eq 0 ]]; then
    exit 0
fi

echo ""
echo "product-management: PM artifacts detected in this project."
if [[ "$SPEC_FILES" -eq 1 ]]; then
    echo "  /product-management:write-spec — review or update specs"
fi
if [[ "$ROADMAP_FILES" -eq 1 ]]; then
    echo "  /product-management:roadmap-update — review or reprioritize roadmap"
fi
echo ""
