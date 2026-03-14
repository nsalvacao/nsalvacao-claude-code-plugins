#!/usr/bin/env bash
# track-artefacts.sh — Shows artefact production status for a lifecycle phase.
# Usage: ./track-artefacts.sh [phase-number]
set -euo pipefail

PHASE="${1:-}"

# Determine project root by looking for .agile-lifecycle
find_lifecycle_dir() {
  local dir
  dir="$(pwd)"
  while [[ "$dir" != "/" ]]; do
    if [[ -d "${dir}/.agile-lifecycle" ]]; then
      echo "${dir}/.agile-lifecycle"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

LIFECYCLE_DIR=""
if ! LIFECYCLE_DIR="$(find_lifecycle_dir)"; then
  echo "ERROR: .agile-lifecycle not found in current directory or any parent." >&2
  echo "Run /agile-init first." >&2
  exit 1
fi

ARTEFACTS_DIR="${LIFECYCLE_DIR}/artefacts"
STATE_FILE="${LIFECYCLE_DIR}/lifecycle-state.json"

# Determine active phase from lifecycle-state.json if not provided
if [[ -z "$PHASE" ]]; then
  if [[ -f "$STATE_FILE" ]] && command -v python3 >/dev/null 2>&1; then
    PHASE=$(python3 -c "
import json
data = json.load(open('$STATE_FILE'))
for ph, info in data.get('phases', {}).items():
    if info.get('status') == 'in_progress':
        print(ph)
        break
" 2>/dev/null || echo "")
  fi
  if [[ -z "$PHASE" ]]; then
    echo "Usage: $0 [phase-number]" >&2
    echo "Could not detect active phase from lifecycle-state.json." >&2
    exit 1
  fi
  echo "Active phase detected: Phase $PHASE"
fi

if ! [[ "$PHASE" =~ ^[1-7]$ ]]; then
  echo "ERROR: Invalid phase number: $PHASE (must be 1-7)" >&2
  exit 1
fi

PHASE_DIR="${ARTEFACTS_DIR}/phase-${PHASE}"
echo "=== Artefact Tracking — Phase $PHASE ==="
echo "Directory: $PHASE_DIR"
echo ""

if [[ ! -d "$PHASE_DIR" ]]; then
  echo "WARNING: Phase directory does not exist: $PHASE_DIR"
  echo "No artefacts produced yet."
  exit 0
fi

file_count=0
echo "Produced artefacts:"
while IFS= read -r -d '' f; do
  fname="$(basename "$f")"
  echo "  + $fname"
  file_count=$((file_count + 1))
done < <(find "$PHASE_DIR" -maxdepth 1 -type f -print0 2>/dev/null)

if [[ $file_count -eq 0 ]]; then
  echo "  (none)"
fi

echo ""
echo "Total produced: $file_count"
echo ""
echo "Tip: Run /agile-gate-review to see which artefacts are still required."
