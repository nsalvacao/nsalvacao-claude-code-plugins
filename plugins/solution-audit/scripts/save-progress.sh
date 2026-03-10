#!/usr/bin/env bash
# save-progress.sh — Stop hook: append session-end marker to WIP audit file
# Called when a Claude Code session ends. Exits 0 in all cases.

# --- Find .solution-audit-wip.md (CWD + up to 3 parents) ---
WIP_FILE=""
SEARCH_DIR="$(pwd)"
for _ in 0 1 2 3; do
  CANDIDATE="$SEARCH_DIR/.solution-audit-wip.md"
  if [ -f "$CANDIDATE" ]; then
    WIP_FILE="$CANDIDATE"
    break
  fi
  PARENT="$(dirname "$SEARCH_DIR")"
  [ "$PARENT" = "$SEARCH_DIR" ] && break
  SEARCH_DIR="$PARENT"
done

if [ -z "$WIP_FILE" ]; then
  exit 0
fi

# --- Append separator + timestamp ---
TIMESTAMP="$(date '+%Y-%m-%d %H:%M')"
printf '\n---\n[SESSION ENDED: %s]\n' "$TIMESTAMP" >> "$WIP_FILE"

exit 0
