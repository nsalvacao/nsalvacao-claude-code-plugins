#!/usr/bin/env bash
# render-template.sh — Renders a .md.template file by replacing {{variable}} placeholders.
# Usage: ./render-template.sh <template-file> <output-file> [key=value ...]
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <template-file> <output-file> [key=value ...]" >&2
  echo "Example: $0 templates/phase-1/opportunity-statement.md.template out.md project_name='My Project'" >&2
  exit 1
fi

TEMPLATE_FILE="$1"
OUTPUT_FILE="$2"
shift 2

if [[ ! -f "$TEMPLATE_FILE" ]]; then
  echo "ERROR: Template file not found: $TEMPLATE_FILE" >&2
  exit 1
fi

# Copy template to output
cp "$TEMPLATE_FILE" "$OUTPUT_FILE"

# Replace each key=value pair
for pair in "$@"; do
  if [[ "$pair" != *"="* ]]; then
    echo "WARNING: Skipping malformed argument (expected key=value): $pair" >&2
    continue
  fi
  key="${pair%%=*}"
  value="${pair#*=}"
  # Use Python for replacement: safe for any value (handles &, |, backslashes, newlines),
  # portable across macOS/BSD and Linux without sed -i quirks.
  python3 - "$key" "$value" "$OUTPUT_FILE" <<'PYEOF'
import sys
k, v, fp = sys.argv[1], sys.argv[2], sys.argv[3]
content = open(fp, encoding='utf-8').read()
open(fp, 'w', encoding='utf-8').write(content.replace('{{' + k + '}}', v))
PYEOF
done

# Report any remaining unfilled placeholders
remaining=$(grep -oE '\{\{[a-zA-Z_][a-zA-Z0-9_]*\}\}' "$OUTPUT_FILE" 2>/dev/null || true)
if [[ -n "$remaining" ]]; then
  echo "WARNING: Unfilled placeholders in $OUTPUT_FILE:" >&2
  echo "$remaining" | sort -u | while IFS= read -r ph; do
    echo "  $ph" >&2
  done
fi

echo "Rendered: $OUTPUT_FILE"
