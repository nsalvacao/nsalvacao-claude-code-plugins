#!/usr/bin/env bash
# render-template.sh — Render a .md.template file replacing {{key}} placeholders.
# Usage: ./render-template.sh <template-file> <context-json> [output-file]
# context-json: JSON file with key-value pairs matching {{key}} placeholders
# output-file: defaults to template name without .template extension
set -euo pipefail

usage() {
  echo "Usage: $(basename "$0") <template-file> <context-json> [output-file]"
  echo ""
  echo "Render a template file by replacing {{key}} placeholders with values."
  echo ""
  echo "Arguments:"
  echo "  template-file   Path to the .md.template file"
  echo "  context-json    Path to JSON file with key-value replacement pairs"
  echo "  output-file     Optional: output path (default: template without .template)"
  echo ""
  echo "Examples:"
  echo "  $(basename "$0") phase-report.md.template context.json"
  echo "  $(basename "$0") phase-report.md.template context.json output/report.md"
}

if [[ $# -lt 2 ]]; then
  usage
  exit 0
fi

TEMPLATE_FILE="$1"
CONTEXT_JSON="$2"
OUTPUT_FILE="${3:-}"

if [[ ! -f "$TEMPLATE_FILE" ]]; then
  echo "ERROR: template file not found: $TEMPLATE_FILE" >&2
  exit 1
fi

if [[ ! -f "$CONTEXT_JSON" ]]; then
  echo "ERROR: context JSON file not found: $CONTEXT_JSON" >&2
  exit 1
fi

# Validate context JSON syntax
if ! python3 -c "import json; json.load(open('$CONTEXT_JSON'))" 2>/dev/null; then
  echo "ERROR: $CONTEXT_JSON contains invalid JSON" >&2
  exit 1
fi

# Resolve output file
if [[ -z "$OUTPUT_FILE" ]]; then
  OUTPUT_FILE="${TEMPLATE_FILE%.template}"
  if [[ "$OUTPUT_FILE" == "$TEMPLATE_FILE" ]]; then
    echo "ERROR: template file does not end in .template and no output-file specified" >&2
    exit 1
  fi
fi

# Ensure output directory exists
OUTPUT_DIR="$(dirname "$OUTPUT_FILE")"
if [[ ! -d "$OUTPUT_DIR" ]]; then
  mkdir -p "$OUTPUT_DIR"
fi

# Render template using python3
python3 - "$TEMPLATE_FILE" "$CONTEXT_JSON" "$OUTPUT_FILE" <<'PYEOF'
import json, re, sys

template_file = sys.argv[1]
context_file = sys.argv[2]
output_file = sys.argv[3]

context = json.load(open(context_file))
content = open(template_file).read()

for k, v in context.items():
    content = content.replace('{{' + k + '}}', str(v))

remaining = re.findall(r'\{\{[^}]+\}\}', content)
if remaining:
    print(f"WARN: unreplaced placeholders: {remaining}", file=sys.stderr)

with open(output_file, 'w') as f:
    f.write(content)
PYEOF

echo "Rendered: $OUTPUT_FILE"
