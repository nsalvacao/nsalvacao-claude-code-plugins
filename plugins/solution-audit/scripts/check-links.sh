#!/usr/bin/env bash
# check-links.sh — Validate internal and external links in .md files
# Usage: check-links.sh [--internal-only] [directory]

INTERNAL_ONLY=0
DIR=""

for arg in "$@"; do
  case "$arg" in
    --internal-only) INTERNAL_ONLY=1 ;;
    *) DIR="$arg" ;;
  esac
done

DIR="${DIR:-.}"

BROKEN_INTERNAL=0
BROKEN_EXTERNAL=0

# --- Internal link check via python3 ---
INTERNAL_RESULTS="$(python3 - "$DIR" <<'PYEOF'
import sys, os, re, pathlib

directory = sys.argv[1]
broken = []

for root, dirs, files in os.walk(directory):
    # Skip hidden dirs
    dirs[:] = [d for d in dirs if not d.startswith('.')]
    for fname in files:
        if not fname.endswith('.md'):
            continue
        fpath = pathlib.Path(root) / fname
        try:
            lines = fpath.read_text(encoding='utf-8', errors='replace').splitlines()
        except Exception:
            continue
        for lineno, line in enumerate(lines, 1):
            # Extract [text](path) — skip http/https/#/mailto
            for m in re.finditer(r'\[([^\]]*)\]\(([^)]+)\)', line):
                link = m.group(2).strip()
                # Skip anchors, external URLs, mailto
                if link.startswith(('#', 'http://', 'https://', 'mailto:')):
                    continue
                # Strip anchor from path
                link_path = link.split('#')[0]
                if not link_path:
                    continue
                target = (fpath.parent / link_path).resolve()
                if not target.exists():
                    rel = str(fpath)
                    print(f"BROKEN [internal] {rel}:{lineno} → {link}")
                    broken.append(1)

sys.exit(0)
PYEOF
)"

if [ -n "$INTERNAL_RESULTS" ]; then
  echo "$INTERNAL_RESULTS"
  BROKEN_INTERNAL=$(echo "$INTERNAL_RESULTS" | wc -l)
fi

# --- External link check ---
if [ "$INTERNAL_ONLY" -eq 0 ]; then
  # Extract external URLs via python3
  EXT_LIST="$(python3 - "$DIR" <<'PYEOF'
import sys, os, re, pathlib

directory = sys.argv[1]

for root, dirs, files in os.walk(directory):
    dirs[:] = [d for d in dirs if not d.startswith('.')]
    for fname in files:
        if not fname.endswith('.md'):
            continue
        fpath = pathlib.Path(root) / fname
        try:
            lines = fpath.read_text(encoding='utf-8', errors='replace').splitlines()
        except Exception:
            continue
        for lineno, line in enumerate(lines, 1):
            for m in re.finditer(r'https?://[^\s\)\]"\'<>]+', line):
                url = m.group(0).rstrip('.,;:')
                print(f"{fpath}:{lineno}:{url}")
PYEOF
)"

  while IFS=: read -r file line url; do
    [ -z "$url" ] && continue
    HTTP_CODE="$(curl --head --silent --max-time 8 --location \
      --write-out '%{http_code}' --output /dev/null "$url" 2>/dev/null)"
    case "$HTTP_CODE" in
      000|404|410)
        echo "BROKEN [external:${HTTP_CODE}] ${file}:${line} → ${url}"
        BROKEN_EXTERNAL=$((BROKEN_EXTERNAL + 1))
        ;;
    esac
  done <<< "$EXT_LIST"
fi

# --- Summary ---
TOTAL=$((BROKEN_INTERNAL + BROKEN_EXTERNAL))
echo "Link check complete. Internal broken: ${BROKEN_INTERNAL} | External broken: ${BROKEN_EXTERNAL} | Total: ${TOTAL}"

[ "$TOTAL" -gt 0 ] && exit 1
exit 0
