#!/usr/bin/env bash
# Delegate large file analysis to Gemini using its 1M token context window.
# Ideal for: reading entire codebases, large logs, lengthy documents.
# Uses gemini-2.5-pro for analysis quality.
# Usage: delegate-analyze.sh "<question>" [file_or_dir...]
# Stdin: if no files given, reads from stdin
# Stdout: <gemini_output category="analysis">...</gemini_output>
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/_lib.sh"

QUESTION="${1:-}"
shift || true
FILES=("$@")

if [[ -z "$QUESTION" ]]; then
  log_error "Usage: delegate-analyze.sh \"<question>\" [file_or_dir...]"
  log_error "       or: cat large_file.txt | delegate-analyze.sh \"<question>\""
  exit 1
fi

gemini_preflight

# Build content: read files or stdin
CONTENT=""
if (( ${#FILES[@]} > 0 )); then
  for f in "${FILES[@]}"; do
    gemini_check_path_safe "$f" || exit "${EXIT_PREFLIGHT_FAIL}"
    if [[ -f "$f" ]]; then
      FSIZE=$(wc -c < "$f" | tr -d ' ')
      log_info "Including file: $f ($FSIZE bytes)"
      CONTENT="${CONTENT}
=== FILE: $f ===
$(cat "$f")
=== END: $f ===
"
    elif [[ -d "$f" ]]; then
      log_info "Including directory: $f"
      while IFS= read -r -d '' file; do
        gemini_check_path_safe "$file" || continue
        CONTENT="${CONTENT}
=== FILE: $file ===
$(cat "$file")
=== END: $file ===
"
      done < <(find "$f" -type f \( -name "*.py" -o -name "*.ts" -o -name "*.js" -o -name "*.sh" -o -name "*.md" -o -name "*.json" -o -name "*.yaml" -o -name "*.yml" \) -print0 2>/dev/null)
    fi
  done
else
  CONTENT=$(cat)
fi

if [[ -z "${CONTENT:-}" ]]; then
  log_error "No content to analyze. Provide file paths or pipe content via stdin."
  exit 1
fi

CHAR_COUNT=${#CONTENT}
log_info "Total content size: $CHAR_COUNT characters"

PROMPT="Analyze the following content and answer this question:

${QUESTION}

---

${CONTENT}

---

Provide a clear, structured answer. Use bullet points, code snippets, or tables where helpful."

gemini_invoke_with_retry "$GEMINI_DELEGATE_MAX_RETRIES" "$PROMPT" \
  "$GEMINI_DELEGATE_PRO_MODEL" "plan"
RESULT="$GEMINI_RESPONSE"

# Validator: non-empty response
WORD_COUNT=$(echo "$RESULT" | wc -w | tr -d ' ')
if (( WORD_COUNT < 10 )); then
  gemini_escalate "analysis" \
    "response suspiciously short ($WORD_COUNT words) for content of $CHAR_COUNT characters" \
    '{"word_count":"fail"}'
fi
log_pass "Analysis: $WORD_COUNT words"

gemini_present_output "$RESULT" "analysis"
