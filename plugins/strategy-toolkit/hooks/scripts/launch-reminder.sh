#!/usr/bin/env bash
# launch-reminder.sh — Remind to run /strategic-review before launching
# Triggered at session Stop when strategic work was done in the session

set -euo pipefail

# Check if strategic output files exist in .ideas/
# (existence check only — does not track whether files were written in this session)
IDEAS_DIR="$(pwd)/.ideas"

if [[ ! -d "$IDEAS_DIR" ]]; then
    exit 0
fi

# Check for brainstorm or execution-plan files without a corresponding evaluation
RECENT_FILES=0
if [[ -f "$IDEAS_DIR/brainstorm-expansion.md" ]] || \
   [[ -f "$IDEAS_DIR/execution-plan.md" ]]; then
    RECENT_FILES=1
fi

if [[ "$RECENT_FILES" -eq 0 ]]; then
    exit 0
fi

# Check if evaluation has already been done
if [[ -f "$IDEAS_DIR/evaluation-results.md" ]]; then
    exit 0
fi

echo ""
echo "strategy-toolkit: strategic documents found in .ideas/ but no evaluation yet."
echo "Consider running /strategic-review before sharing or launching this project."
echo "  /strategic-review — systematic pre-launch quality check"
echo ""
