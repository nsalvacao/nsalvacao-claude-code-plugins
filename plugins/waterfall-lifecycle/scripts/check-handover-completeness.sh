#!/usr/bin/env bash
# check-handover-completeness.sh — Validate Gate C handover completeness for waterfall lifecycle Phase 3.
# Usage: ./check-handover-completeness.sh <artefacts-dir> [--strict]
# Returns exit 0 if all checks pass, exit 1 if one or more checks fail.
set -euo pipefail

usage() {
  echo "Usage: $(basename "$0") <artefacts-dir> [--strict]"
  echo ""
  echo "Validate Gate C handover completeness — all 8 mandatory artefacts present,"
  echo "no unfilled {{variable}} placeholder tokens, open items reported."
  echo ""
  echo "Arguments:"
  echo "  artefacts-dir   Path to the directory containing Phase 3 artefacts"
  echo "  --strict        Also check for placeholder tokens in all artefacts and"
  echo "                  verify design-approval-pack sign-off section is complete"
  echo ""
  echo "Checks:"
  echo "  - artefacts-dir exists and is a directory"
  echo "  - All 8 Gate C mandatory artefacts present"
  echo "  - adr-set/ directory exists and contains at least 1 ADR file"
  echo "  - In strict mode: no {{variable}} placeholder tokens in any artefact"
  echo "  - In strict mode: design-approval-pack.md sign-off section has no placeholders"
  echo ""
  echo "Exit codes:"
  echo "  0  All checks pass"
  echo "  1  One or more checks fail"
}

if [[ $# -eq 0 ]]; then
  usage
  exit 0
fi

ARTEFACTS_DIR="$1"
STRICT=false

if [[ $# -ge 2 && "$2" == "--strict" ]]; then
  STRICT=true
fi

pass_count=0
fail_count=0

pass() {
  echo "  ✓ $1"
  pass_count=$((pass_count + 1))
}

fail() {
  echo "  ✗ $1"
  fail_count=$((fail_count + 1))
}

warn() {
  echo "  ! $1"
}

echo "Checking Gate C artefacts in: $ARTEFACTS_DIR"
echo ""
echo "Check                                    Status"
echo "─────────────────────────────────────────────────────"

if [[ ! -d "$ARTEFACTS_DIR" ]]; then
  echo "ERROR: artefacts directory not found: $ARTEFACTS_DIR" >&2
  exit 1
fi
pass "Artefacts directory exists"

check_artefact() {
  local name="$1"
  if [[ -f "$ARTEFACTS_DIR/$name" ]]; then
    pass "Gate C artefact present: $name"
  else
    fail "Gate C artefact missing: $name"
  fi
}

check_artefact "hld.md"
check_artefact "lld.md"
check_artefact "interface-specifications.md"
check_artefact "control-matrix.md"
check_artefact "test-design-package.md"
check_artefact "ai-control-design-note.md"
check_artefact "design-approval-pack.md"

# Check adr-set directory
if [[ -d "$ARTEFACTS_DIR/adr-set" ]]; then
  ADR_COUNT=$(find "$ARTEFACTS_DIR/adr-set" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l) || ADR_COUNT=0
  if [[ "$ADR_COUNT" -gt 0 ]]; then
    pass "Gate C artefact present: adr-set/ ($ADR_COUNT ADR file(s))"
  else
    fail "Gate C artefact incomplete: adr-set/ exists but contains no .md files"
  fi
else
  fail "Gate C artefact missing: adr-set/"
fi

if [[ "$STRICT" == "true" ]]; then
  echo ""
  echo "Strict mode — placeholder and sign-off checks:"
  echo "─────────────────────────────────────────────────────"

  # Count placeholder tokens across all artefacts
  PLACEHOLDER_COUNT=0
  for f in "$ARTEFACTS_DIR"/*.md; do
    [[ -f "$f" ]] || continue
    count=$(grep -c "{{[a-zA-Z_][a-zA-Z0-9_]*}}" "$f" 2>/dev/null) || count=0
    PLACEHOLDER_COUNT=$((PLACEHOLDER_COUNT + count))
  done

  # Also check adr-set
  if [[ -d "$ARTEFACTS_DIR/adr-set" ]]; then
    for f in "$ARTEFACTS_DIR/adr-set"/*.md; do
      [[ -f "$f" ]] || continue
      count=$(grep -c "{{[a-zA-Z_][a-zA-Z0-9_]*}}" "$f" 2>/dev/null) || count=0
      PLACEHOLDER_COUNT=$((PLACEHOLDER_COUNT + count))
    done
  fi

  if [[ "$PLACEHOLDER_COUNT" -eq 0 ]]; then
    pass "No unfilled placeholder tokens found"
  else
    fail "Unfilled placeholder tokens found: $PLACEHOLDER_COUNT occurrence(s) across artefacts"
  fi

  # Check design-approval-pack sign-off section
  APPROVAL_PACK="$ARTEFACTS_DIR/design-approval-pack.md"
  if [[ -f "$APPROVAL_PACK" ]]; then
    if grep -q "Sign-off" "$APPROVAL_PACK"; then
      SIGNOFF_PLACEHOLDERS=$(grep -c "{{[a-zA-Z_][a-zA-Z0-9_]*}}" "$APPROVAL_PACK" 2>/dev/null) || SIGNOFF_PLACEHOLDERS=0
      if [[ "$SIGNOFF_PLACEHOLDERS" -eq 0 ]]; then
        pass "design-approval-pack.md sign-off section: no placeholders"
      else
        fail "design-approval-pack.md sign-off section: $SIGNOFF_PLACEHOLDERS placeholder(s) remain"
      fi
    else
      warn "design-approval-pack.md: Sign-off section not found"
    fi
  fi
fi

echo "─────────────────────────────────────────────────────"
echo ""

TOTAL=$((pass_count + fail_count))
echo "Results: $pass_count/$TOTAL checks OK"
echo ""

if [[ "$fail_count" -gt 0 ]]; then
  echo "FAIL: Gate C handover validation has $fail_count issue(s)"
  exit 1
else
  echo "OK: Gate C handover validation complete"
  exit 0
fi
