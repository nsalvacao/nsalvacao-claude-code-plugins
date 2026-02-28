#!/usr/bin/env bash
# check-server.sh — SessionStart hook: check if Plugin Studio server is running
# Silently exits 0 in all cases (informational only, never blocks session start)

PID_FILE="${CLAUDE_PLUGIN_ROOT}/server/.pid"

if [ -f "$PID_FILE" ]; then
  pid=$(cat "$PID_FILE")
  if kill -0 "$pid" 2>/dev/null; then
    echo "ℹ Plugin Studio is running (PID $pid). Use /plugin-studio:open to open the dashboard."
  else
    rm -f "$PID_FILE"
  fi
fi

exit 0
