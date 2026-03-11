#!/usr/bin/env bash
# session-close.sh — Session summary reminder at Stop
# Checks if TASKS.md exists and suggests a session wrap-up

set -euo pipefail

TASKS_FILE="$(pwd)/TASKS.md"

if [[ ! -f "$TASKS_FILE" ]]; then
    exit 0
fi

# Count active tasks
ACTIVE_COUNT=0
IN_ACTIVE_SECTION=false

while IFS= read -r line; do
    if [[ "$line" == "## Active" ]]; then
        IN_ACTIVE_SECTION=true
        continue
    fi
    if [[ "$IN_ACTIVE_SECTION" == true ]] && [[ "$line" =~ ^##\  ]]; then
        break
    fi
    if [[ "$IN_ACTIVE_SECTION" == true ]] && [[ "$line" =~ ^\-\ \[\ \] ]]; then
        ACTIVE_COUNT=$((ACTIVE_COUNT + 1))
    fi
done < "$TASKS_FILE"

if [[ "$ACTIVE_COUNT" -gt 0 ]]; then
    echo ""
    echo "productivity: ${ACTIVE_COUNT} active task(s) in TASKS.md."
    echo "Run /productivity:update to sync tasks and close the session cleanly."
    echo ""
fi
