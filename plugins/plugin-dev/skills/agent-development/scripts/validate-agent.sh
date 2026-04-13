#!/bin/bash
# Agent File Validator
# Validates agent markdown files for correct structure and practical quality signals.

set -euo pipefail

if [ $# -eq 0 ]; then
  echo "Usage: $0 <path/to/agent.md>"
  echo ""
  echo "Validates agent file for:"
  echo "  - YAML frontmatter structure"
  echo "  - Required fields (name, description)"
  echo "  - Optional field formats (model, color, tools)"
  echo "  - System prompt presence and practical quality signals"
  exit 1
fi

AGENT_FILE="$1"

echo "Validating agent file: $AGENT_FILE"
echo ""

if [ ! -f "$AGENT_FILE" ]; then
  echo "ERROR: File not found: $AGENT_FILE"
  exit 1
fi
echo "OK: File exists"

if ! python3 -c 'import yaml' >/dev/null 2>&1; then
  echo "ERROR: PyYAML is required for YAML frontmatter parsing"
  echo "Install it with: python3 -m pip install pyyaml"
  exit 1
fi

FIRST_LINE=$(head -1 "$AGENT_FILE")
if [ "$FIRST_LINE" != "---" ]; then
  echo "ERROR: File must start with YAML frontmatter (---)"
  exit 1
fi
echo "OK: Starts with frontmatter"

if ! tail -n +2 "$AGENT_FILE" | grep -q '^---$'; then
  echo "ERROR: Frontmatter not closed (missing second ---)"
  exit 1
fi
echo "OK: Frontmatter properly closed"

PARSED_JSON_FILE=$(mktemp)
trap 'rm -f "$PARSED_JSON_FILE"' EXIT

python3 - "$AGENT_FILE" > "$PARSED_JSON_FILE" <<'PY'
from pathlib import Path
import json
import sys

import yaml

path = Path(sys.argv[1])
content = path.read_text()
lines = content.splitlines()

if not lines or lines[0].strip() != "---":
    raise SystemExit("missing opening frontmatter delimiter")

end_idx = None
for idx, line in enumerate(lines[1:], start=1):
    if line.strip() == "---":
        end_idx = idx
        break

if end_idx is None:
    raise SystemExit("missing closing frontmatter delimiter")

frontmatter = yaml.safe_load("\n".join(lines[1:end_idx])) or {}
if not isinstance(frontmatter, dict):
    raise SystemExit("frontmatter must be a YAML mapping")

payload = {
    "frontmatter": frontmatter,
    "system_prompt": "\n".join(lines[end_idx + 1 :]).strip(),
}
print(json.dumps(payload))
PY

json_read() {
  python3 - "$PARSED_JSON_FILE" "$1" <<'PY'
import json
import sys

payload = json.loads(open(sys.argv[1]).read())
path = sys.argv[2].split(".")
value = payload
for part in path:
    if part == "":
        continue
    if isinstance(value, dict):
        value = value.get(part)
    else:
        value = None
        break

if value is None:
    print("")
elif isinstance(value, str):
    print(value)
else:
    print(json.dumps(value))
PY
}

error_count=0
warning_count=0
info_count=0

NAME=$(json_read "frontmatter.name")
DESCRIPTION=$(json_read "frontmatter.description")
MODEL=$(json_read "frontmatter.model")
COLOR=$(json_read "frontmatter.color")
TOOLS=$(json_read "frontmatter.tools")
MEMORY=$(json_read "frontmatter.memory")
SYSTEM_PROMPT=$(json_read "system_prompt")

echo ""
echo "Checking frontmatter..."

if [ -z "$NAME" ]; then
  echo "ERROR: Missing required field: name"
  error_count=$((error_count + 1))
else
  echo "OK: name: $NAME"
  if ! [[ "$NAME" =~ ^[a-z0-9][a-z0-9-]*[a-z0-9]$ ]]; then
    echo "ERROR: name must start/end with alphanumeric and use lowercase letters, numbers, and hyphens only"
    error_count=$((error_count + 1))
  fi
  name_length=${#NAME}
  if [ "$name_length" -lt 3 ] || [ "$name_length" -gt 50 ]; then
    echo "ERROR: name must be 3-50 characters"
    error_count=$((error_count + 1))
  fi
fi

if [ -z "$DESCRIPTION" ]; then
  echo "ERROR: Missing required field: description"
  error_count=$((error_count + 1))
else
  desc_length=${#DESCRIPTION}
  echo "OK: description: ${desc_length} characters"
  if [ "$desc_length" -lt 10 ]; then
    echo "WARNING: description is very short"
    warning_count=$((warning_count + 1))
  fi
  if ! printf "%s" "$DESCRIPTION" | grep -q '<example>'; then
    echo "WARNING: description should include <example> blocks"
    warning_count=$((warning_count + 1))
  fi
  if ! printf "%s" "$DESCRIPTION" | grep -qi 'use this agent when'; then
    echo "WARNING: description should begin with 'Use this agent when...'"
    warning_count=$((warning_count + 1))
  fi
  if ! printf "%s" "$DESCRIPTION" | grep -Eqi 'should not|do not use|not when|avoid using'; then
    echo "WARNING: description has no negative or near-miss guidance"
    warning_count=$((warning_count + 1))
  fi
fi

if [ -z "$MODEL" ]; then
  echo "INFO: model not specified (defaults to inherit)"
  info_count=$((info_count + 1))
else
  echo "OK: model: $MODEL"
  if ! [[ "$MODEL" =~ ^[A-Za-z0-9._-]+$ ]]; then
    echo "ERROR: model must be a simple alias or model id without spaces"
    error_count=$((error_count + 1))
  fi
fi

if [ -z "$COLOR" ]; then
  echo "INFO: color not specified (no explicit UI color)"
  info_count=$((info_count + 1))
else
  echo "OK: color: $COLOR"
  case "$COLOR" in
    red|blue|green|yellow|purple|orange|pink|cyan)
      ;;
    *)
      echo "ERROR: color must be one of: red, blue, green, yellow, purple, orange, pink, cyan"
      error_count=$((error_count + 1))
      ;;
  esac
fi

if [ -n "$TOOLS" ]; then
  echo "OK: tools: $TOOLS"
  if printf "%s" "$TOOLS" | grep -q '\*'; then
    echo "WARNING: tools grants broad access; prefer least privilege"
    warning_count=$((warning_count + 1))
  fi
  if printf "%s" "$TOOLS" | grep -Eqi 'bash.*write|write.*bash|edit.*bash|bash.*edit'; then
    echo "WARNING: tools includes broad edit and shell access; review least-privilege scope"
    warning_count=$((warning_count + 1))
  fi
else
  echo "WARNING: tools not specified (agent has broad default access)"
  warning_count=$((warning_count + 1))
fi

if [ -z "$MEMORY" ]; then
  echo "INFO: consider adding memory when cross-session learning would help"
  info_count=$((info_count + 1))
fi

echo ""
echo "Checking system prompt..."

if [ -z "$SYSTEM_PROMPT" ]; then
  echo "ERROR: System prompt is empty"
  error_count=$((error_count + 1))
else
  prompt_length=${#SYSTEM_PROMPT}
  echo "OK: System prompt: ${prompt_length} characters"

  if [ "$prompt_length" -lt 20 ]; then
    echo "ERROR: system prompt is too short"
    error_count=$((error_count + 1))
  fi

  if ! printf "%s" "$SYSTEM_PROMPT" | grep -Eqi '\bYou are\b|\bYou will\b|\bYour\b'; then
    echo "WARNING: system prompt should use second person"
    warning_count=$((warning_count + 1))
  fi

  if ! printf "%s" "$SYSTEM_PROMPT" | grep -Eqi 'responsibilities|process|steps'; then
    echo "WARNING: consider adding clear responsibilities or process steps"
    warning_count=$((warning_count + 1))
  fi

  if ! printf "%s" "$SYSTEM_PROMPT" | grep -Eqi 'output format|output|return'; then
    echo "WARNING: no output format defined in system prompt"
    warning_count=$((warning_count + 1))
  fi

  if ! printf "%s" "$SYSTEM_PROMPT" | grep -Eqi 'edge case|fallback|error|failure'; then
    echo "WARNING: no edge cases or fallback behavior described in system prompt"
    warning_count=$((warning_count + 1))
  fi

  if [ "$prompt_length" -gt 32000 ]; then
    echo "INFO: very long prompts (>~8,000 tokens) may cause registration issues"
    info_count=$((info_count + 1))
  fi
fi

echo ""
echo "----------------------------------------"

if [ "$error_count" -eq 0 ]; then
  echo "Validation passed"
  echo "Warnings: $warning_count | Info: $info_count"
  exit 0
fi

echo "Validation failed"
echo "Errors: $error_count | Warnings: $warning_count | Info: $info_count"
exit 1
