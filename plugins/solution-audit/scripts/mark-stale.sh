#!/usr/bin/env bash
# mark-stale.sh — PostToolUse hook: mark audit dimensions stale after Write/Edit
# Called with tool_input JSON on stdin. Exits 0 in all non-error cases.

# --- Read stdin (may be empty) ---
INPUT="$(cat)"
if [ -z "$INPUT" ]; then
  exit 0
fi

# --- Extract file path via python3 (stdin passed via env to avoid injection) ---
FILE_PATH="$(HOOK_INPUT="$INPUT" python3 - <<'PYEOF'
import json, os, sys
raw = os.environ.get("HOOK_INPUT", "")
try:
    data = json.loads(raw)
except Exception:
    sys.exit(0)
ti = data.get("tool_input") if isinstance(data.get("tool_input"), dict) else data
fp = (ti or {}).get("file_path") or (ti or {}).get("path") or ""
print(fp)
PYEOF
)"

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# --- Map file path to stale dimensions ---
STALE_DIMS="$(HOOK_FP="$FILE_PATH" python3 - <<'PYEOF'
import re, os, sys
fp = os.environ.get("HOOK_FP", "")
base = fp.split("/")[-1]
dims = set()

if re.match(r"(?i)readme", base):
    dims.update(["product-coherence", "documentation-quality"])
if re.match(r"(?i)(architecture|design)", base):
    dims.update(["architecture-coherence", "product-coherence"])
if re.search(r"(?:^|/)docs/", fp):
    dims.add("documentation-quality")
if re.search(r"(?:^|/)(src|lib)/", fp):
    dims.update(["architecture-coherence", "product-coherence"])
if re.match(r"(?i)(contributing|install|getting_started|quickstart)", base):
    dims.add("onboarding-quality")
if base.endswith(".md") and not dims:
    dims.add("documentation-quality")

print("\n".join(sorted(dims)))
PYEOF
)"

if [ -z "$STALE_DIMS" ]; then
  exit 0
fi

# --- Find .solution-audit-latest.json (CWD + up to 3 parents) ---
AUDIT_FILE=""
SEARCH_DIR="$(pwd)"
for _ in 0 1 2 3; do
  CANDIDATE="$SEARCH_DIR/.solution-audit-latest.json"
  if [ -f "$CANDIDATE" ]; then
    AUDIT_FILE="$CANDIDATE"
    break
  fi
  PARENT="$(dirname "$SEARCH_DIR")"
  [ "$PARENT" = "$SEARCH_DIR" ] && break
  SEARCH_DIR="$PARENT"
done

if [ -z "$AUDIT_FILE" ]; then
  exit 0
fi

# --- Merge stale dims into audit JSON ---
HOOK_AUDIT="$AUDIT_FILE" HOOK_DIMS="$STALE_DIMS" python3 - <<'PYEOF'
import json, os, sys
audit_path = os.environ["HOOK_AUDIT"]
new_dims = [d for d in os.environ.get("HOOK_DIMS", "").split("\n") if d]

with open(audit_path, "r") as f:
    data = json.load(f)

existing = data.get("stale", [])
merged = sorted(set(existing) | set(new_dims))
data["stale"] = merged

with open(audit_path, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PYEOF

# --- Report to stderr ---
DIMS_DISPLAY="$(echo "$STALE_DIMS" | tr '\n' ',' | sed 's/,$//' | sed 's/,/, /g')"
echo "⚠ Audit stale: [$DIMS_DISPLAY] — run /audit or relevant /audit-* command to refresh" >&2

exit 0
