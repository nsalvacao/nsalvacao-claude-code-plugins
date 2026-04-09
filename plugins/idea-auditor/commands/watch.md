---
description: Shows the watch mode status — which files are being observed passively, what is stored in STATE/.snapshots/, and how to use diff_scorecards.py to compare scorecards and detect regressions. Watch mode is always active while the plugin is installed; it snapshots high-signal files (IDEA.*, BLUEPRINT.*, README.md, SECURITY.md, CHANGELOG.md) after every write without re-scoring automatically.
argument-hint: "[<path>]  — defaults to current directory"
allowed-tools: Bash, Read
---

Show watch mode status and recent snapshot activity for the idea-auditor plugin.

1. Identify the project path (default: current directory). Look for `IDEA.md`, `STATE/`, or `hooks/hooks.json`.
2. Confirm that `hooks/hooks.json` exists and contains a `PostToolUse` matcher for `Write|Edit`. If missing, warn the user that watch mode is not active.
3. Check `STATE/.snapshots/` for recent snapshot files. List the 5 most recent files with their entry count and timestamps.
4. Show the high-signal file patterns being observed: `IDEA.*`, `BLUEPRINT.*`, `README.md`, `SECURITY.md`, `CHANGELOG.md`.
5. If scorecard files exist in `STATE/`, suggest the diff command:
   ```
   python3 scripts/diff_scorecards.py --before STATE/<older>.json --after STATE/<newer>.json
   ```
6. Remind the user: watch mode records changes but does NOT re-score — use `/idea-auditor:score` for a full evaluation.
