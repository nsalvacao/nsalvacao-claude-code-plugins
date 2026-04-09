---
name: idea-auditor-watch
description: Explains the passive watch mode that automatically snapshots high-signal files (IDEA.*, BLUEPRINT.*, README.md, SECURITY.md, CHANGELOG.md) after every write. Shows which files are being observed, what is stored in STATE/.snapshots/, and how to use diff_scorecards.py to detect regressions between snapshots. Does NOT re-evaluate the scorecard automatically — full re-evaluations require explicit /score invocation.
---

# idea-auditor: Watch Mode

Trigger this skill when the user asks "what is watch mode", "how does snapshots work", "what files are being observed", "how do I detect regressions", "is watch active", or invokes `/idea-auditor:watch`.

## What Watch Mode Does

Watch mode is **passive**: it records the state of high-signal files automatically after every write (`Write` or `Edit` tool call), without re-scoring.

The hook (`hooks/hooks.json`) fires `hooks/scripts/snapshot.sh` after every tool write. The script:
1. Reads the PostToolUse event from stdin (tool name + file path)
2. Checks if the written file matches a **high-signal pattern** (see below)
3. If matched, appends a snapshot entry to `STATE/.snapshots/YYYYMMDD-HH.json`

**Watch mode is always on** while the plugin is installed. There is no toggle — the hook runs whenever a matching file is written.

> **Important**: Watch mode does NOT re-run the scoring pipeline automatically.
> Full re-evaluations require explicit `/idea-auditor:score` invocation.

## Observed File Patterns

| Pattern | Why it matters |
|---------|----------------|
| `IDEA.*` | Core idea document — most impactful changes |
| `BLUEPRINT.*` | Architecture / design decisions |
| `README.md` | Public framing changes |
| `SECURITY.md` | Trust posture changes |
| `CHANGELOG.md` | Milestone tracking |

Files that do **not** match these patterns are ignored (e.g., evidence JSONs, scorecard outputs, scripts).

## What Is Stored

Each hourly snapshot file (`STATE/.snapshots/YYYYMMDD-HH.json`) is a JSON array of entries:

```json
[
  {
    "ts": "2026-04-09T14:32:11Z",
    "file": "/path/to/project/IDEA.md",
    "basename": "IDEA.md",
    "content": "<full file content at time of write>"
  }
]
```

- **Hourly granularity**: all writes within the same UTC hour are appended to the same file.
- **Content capture**: files up to 64 KB are stored in full; larger files record `content_skipped: file_too_large`.
- **Append-only**: entries are never overwritten within the same hour.

## Detecting Regressions

Use `diff_scorecards.py` to compare any two scorecards — including those produced from snapshots — and surface regressions:

```bash
# Compare yesterday's scorecard with today's
python3 scripts/diff_scorecards.py \
  --before STATE/scorecard_20260408.json \
  --after  STATE/scorecard_20260409.json

# Output as JSON for automated pipelines
python3 scripts/diff_scorecards.py \
  --before STATE/scorecard_v1.json \
  --after  STATE/scorecard_v2.json \
  --format json
```

**Regression threshold**: a drop of more than **10 points** in `score_total` triggers a warning and exits with code 2.

### Typical Regression Workflow

1. Save a baseline: `cp STATE/scorecard.json STATE/scorecard_baseline.json`
2. Make changes to IDEA.md or evidence files
3. Re-score: `/idea-auditor:score`
4. Diff: `python3 scripts/diff_scorecards.py --before STATE/scorecard_baseline.json --after STATE/scorecard.json`
5. If regression detected — investigate which dimensions dropped before accepting the change

## Checking Watch Status

Watch mode has no runtime toggle. To verify it is active:

```bash
# Confirm hook is wired
cat hooks/hooks.json

# Check recent snapshots
ls -lt STATE/.snapshots/ | head -5

# Inspect the latest snapshot
python3 -c "
import json, pathlib, sys
files = sorted(pathlib.Path('STATE/.snapshots').glob('*.json'), reverse=True)
if not files: sys.exit('No snapshots yet')
data = json.loads(files[0].read_text())
print(f'{files[0].name}: {len(data)} entries')
for e in data: print(' ', e['ts'], e['basename'])
"
```

## What Watch Mode Does NOT Do

- It does **not** re-score automatically
- It does **not** alert on content changes — it only records them
- It does **not** run on evidence JSON writes (by design — evidence is updated via pipeline, not manually)
- It does **not** track deletions — only writes (Write/Edit tool calls)
