#!/usr/bin/env bash
# check-examples.sh — Validate fenced code blocks in .md files
# Usage: check-examples.sh [directory]

DIR="${1:-.}"

FILES_CHECKED=0
FILES_WITH_ERRORS=0

# --- Extract and validate code blocks via python3 ---
RESULTS="$(python3 - "$DIR" <<'PYEOF'
import sys, os, re, pathlib, subprocess, json, tempfile

directory = sys.argv[1]

files_checked = set()
files_with_errors = set()

FENCE_RE = re.compile(
    r'^```[ \t]*([a-zA-Z0-9_+-]*)[ \t]*\n(.*?)^```[ \t]*$',
    re.MULTILINE | re.DOTALL
)

for root, dirs, files in os.walk(directory):
    dirs[:] = [d for d in dirs if not d.startswith('.')]
    for fname in files:
        if not fname.endswith('.md'):
            continue
        fpath = pathlib.Path(root) / fname
        try:
            content = fpath.read_text(encoding='utf-8', errors='replace')
        except Exception:
            continue
        for m in FENCE_RE.finditer(content):
            lang = m.group(1).lower().strip()
            code = m.group(2)
            if lang not in ('bash', 'sh', 'shell', 'python', 'py', 'python3', 'json'):
                continue

            files_checked.add(str(fpath))

            if lang in ('bash', 'sh', 'shell'):
                # Validate with bash -n
                try:
                    result = subprocess.run(
                        ['bash', '-n'],
                        input=code, capture_output=True, text=True
                    )
                    if result.returncode != 0:
                        err = result.stderr.strip().replace('\n', '; ')
                        print(f"INVALID [bash] {fpath} → {err}")
                        files_with_errors.add(str(fpath))
                except Exception as e:
                    print(f"INVALID [bash] {fpath} → {e}")
                    files_with_errors.add(str(fpath))

            elif lang in ('python', 'py', 'python3'):
                # Validate with compile()
                try:
                    compile(code, '<string>', 'exec')
                except SyntaxError as e:
                    print(f"INVALID [python] {fpath} → {e}")
                    files_with_errors.add(str(fpath))
                except Exception as e:
                    print(f"INVALID [python] {fpath} → {e}")
                    files_with_errors.add(str(fpath))

            elif lang == 'json':
                try:
                    json.loads(code)
                except json.JSONDecodeError as e:
                    print(f"INVALID [json] {fpath} → {e}")
                    files_with_errors.add(str(fpath))

print(f"__STATS__:{len(files_checked)}:{len(files_with_errors)}")
PYEOF
)"

# --- Parse stats line ---
STATS_LINE="$(echo "$RESULTS" | grep '^__STATS__:')"
BODY="$(echo "$RESULTS" | grep -v '^__STATS__:')"

if [ -n "$BODY" ]; then
  echo "$BODY"
fi

if [ -n "$STATS_LINE" ]; then
  FILES_CHECKED="$(echo "$STATS_LINE" | cut -d: -f2)"
  FILES_WITH_ERRORS="$(echo "$STATS_LINE" | cut -d: -f3)"
fi

echo "Example check complete. Files checked: ${FILES_CHECKED} | Files with invalid examples: ${FILES_WITH_ERRORS}"

[ "${FILES_WITH_ERRORS:-0}" -gt 0 ] && exit 1
exit 0
