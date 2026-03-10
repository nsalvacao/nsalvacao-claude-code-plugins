#!/usr/bin/env bash
# audit-reminder.sh — Stop hook: suggest /repo-validate if new untracked files exist
set -euo pipefail

if git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
    new_files=$(git status --porcelain 2>/dev/null | grep -c "^??" || true)
    if [[ "$new_files" -gt 0 ]]; then
        echo "$new_files new untracked file(s) detected. Consider running /repo-validate to check repository structure." >&2
    fi
fi
exit 0
