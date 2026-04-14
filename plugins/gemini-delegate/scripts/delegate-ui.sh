#!/usr/bin/env bash
# Delegate UI/frontend generation to Gemini.
# Uses gemini-2.5-pro for quality UI output.
# Usage: delegate-ui.sh <ui_type> "<spec>" [output_file]
#   ui_type: html | react | css
#   output_file: if provided, writes output directly to file
# Stdout: <gemini_output category="ui-TYPE">...</gemini_output>
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/_lib.sh"

UI_TYPE="${1:-html}"
SPEC="${2:-}"
OUTPUT_FILE="${3:-}"

if [[ -z "$SPEC" ]]; then
  log_error "Usage: delegate-ui.sh <ui_type> \"<spec>\" [output_file]"
  log_error "  ui_type: html | react | css"
  exit 1
fi

gemini_preflight

case "$UI_TYPE" in
  html)
    PROMPT="Generate a complete, self-contained HTML page for the following specification.
Requirements:
- Valid HTML5 with DOCTYPE declaration
- Responsive design using CSS (inline or in <style> tag)
- Accessible: semantic elements, aria labels where needed
- No external dependencies — all CSS/JS inline
- Return ONLY the HTML — no markdown fences, no explanation

Specification: ${SPEC}"
    ;;
  react)
    PROMPT="Generate a complete React component for the following specification.
Requirements:
- TypeScript with proper types and interfaces
- Functional component with hooks
- Include any required imports at the top
- Accessible: aria labels, semantic HTML
- No external UI libraries unless explicitly requested
- Return ONLY the TypeScript/React code — no markdown fences, no explanation

Specification: ${SPEC}"
    ;;
  css)
    PROMPT="Generate CSS for the following specification.
Requirements:
- Modern CSS (custom properties, flexbox/grid)
- Mobile-first responsive design
- Include comments for major sections
- Return ONLY the CSS — no markdown fences, no explanation

Specification: ${SPEC}"
    ;;
  *)
    log_error "Unknown UI type: '$UI_TYPE'. Valid: html | react | css"
    exit 1
    ;;
esac

gemini_invoke_with_retry "$GEMINI_DELEGATE_MAX_RETRIES" "$PROMPT" \
  "$GEMINI_DELEGATE_PRO_MODEL" "plan"
RESULT="$GEMINI_RESPONSE"

# Strip markdown fences if Gemini included them (first and last line only — avoids
# removing ``` that may appear inside template literals or embedded code examples)
RESULT=$(echo "$RESULT" | sed -e '1{/^```/d}' -e '${/^```$/d}')

# ---- Validators ----
case "$UI_TYPE" in
  html)
    # Validator 1: DOCTYPE present
    if ! echo "$RESULT" | grep -qi "<!DOCTYPE"; then
      log_warn "HTML missing DOCTYPE declaration. Retrying."
      RETRY_PROMPT="Previous HTML was missing DOCTYPE. Generate a complete valid HTML5 page with DOCTYPE for: ${SPEC}"
      gemini_invoke_with_retry 1 "$RETRY_PROMPT" "$GEMINI_DELEGATE_PRO_MODEL" "plan"
      RESULT="$GEMINI_RESPONSE"
      RESULT=$(echo "$RESULT" | sed -e '1{/^```/d}' -e '${/^```$/d}')
      if ! echo "$RESULT" | grep -qi "<!DOCTYPE"; then
        gemini_escalate "ui-html" "HTML missing DOCTYPE after retry" '{"doctype":"fail"}'
      fi
    fi
    log_pass "HTML DOCTYPE present"

    # Validator 2: closing tags
    if ! echo "$RESULT" | grep -qi "</html>"; then
      gemini_escalate "ui-html" "HTML missing closing </html> tag" '{"closing_tag":"fail"}'
    fi
    log_pass "HTML structure valid"
    ;;

  react)
    # Validator: contains 'export' and 'return' (basic React component checks)
    if ! echo "$RESULT" | grep -q "export"; then
      log_warn "React component missing export statement."
    fi
    if ! echo "$RESULT" | grep -q "return"; then
      gemini_escalate "ui-react" "React component missing return statement" '{"return":"fail"}'
    fi
    log_pass "React component structure valid"
    ;;

  css)
    # Validator: non-empty, contains at least one CSS rule
    if ! echo "$RESULT" | grep -q "{"; then
      gemini_escalate "ui-css" "CSS output contains no rule blocks" '{"rules":"fail"}'
    fi
    log_pass "CSS contains rule blocks"
    ;;
esac

# Optional: write to file if requested
if [[ -n "$OUTPUT_FILE" ]]; then
  log_warn "Output file requested: $OUTPUT_FILE — REVIEW BEFORE USE. Writing..."
  gemini_check_path_safe "$OUTPUT_FILE" || exit "${EXIT_PREFLIGHT_FAIL}"
  printf '%s\n' "$RESULT" > "$OUTPUT_FILE"
  log_info "Written to: $OUTPUT_FILE"
fi

gemini_present_output "$RESULT" "ui-${UI_TYPE}"
