#!/usr/bin/env bash
# check-release-readiness.sh — Checks release readiness criteria.
# Usage: ./check-release-readiness.sh <release-readiness-json>
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <release-readiness-json>" >&2
  exit 1
fi

READINESS_FILE="$1"

if [[ ! -f "$READINESS_FILE" ]]; then
  echo "ERROR: Release readiness file not found: $READINESS_FILE" >&2
  exit 1
fi

if ! python3 -c "import json, sys; json.load(open(sys.argv[1]))" "$READINESS_FILE" 2>/dev/null; then
  echo "ERROR: $READINESS_FILE is not valid JSON" >&2
  exit 1
fi

echo "=== Release Readiness Check: $READINESS_FILE ==="
echo ""

python3 - "$READINESS_FILE" <<'PYEOF'
import json
import sys

readiness_file = sys.argv[1]
with open(readiness_file) as f:
    data = json.load(f)

REQUIRED_CHECKS = [
    ("tests_passed", "All automated tests passing"),
    ("regression_suite_passed", "Regression suite passed"),
    ("documentation_complete", "Documentation complete"),
    ("deployment_runbook_reviewed", "Deployment runbook reviewed"),
    ("rollback_plan_documented", "Rollback plan documented"),
    ("stakeholder_signoff", "Stakeholder sign-off obtained"),
    ("security_review_done", "Security review completed"),
    ("performance_baseline_met", "Performance baseline met"),
]

WARN_CHECKS = [
    ("load_test_done", "Load/stress test completed"),
    ("accessibility_review_done", "Accessibility review completed"),
    ("ai_red_team_done", "AI red-team exercise completed (if AI product)"),
]

fail_count = 0
warn_count = 0
pass_count = 0

print("Required checks:")
for key, label in REQUIRED_CHECKS:
    value = data.get(key)
    if value is True:
        print(f"  OK:   {label}")
        pass_count += 1
    elif value is False:
        print(f"  FAIL: {label}")
        fail_count += 1
    else:
        print(f"  SKIP: {label} — not evaluated")

print("\nAdvisory checks:")
for key, label in WARN_CHECKS:
    value = data.get(key)
    if value is True:
        print(f"  OK:   {label}")
    elif value is False:
        print(f"  WARN: {label}")
        warn_count += 1
    else:
        print(f"  SKIP: {label} — not evaluated")

print(f"\nPassed: {pass_count} | Failed: {fail_count} | Warnings: {warn_count}")

if fail_count > 0:
    print(f"\nRelease readiness: NOT READY — {fail_count} required check(s) failed")
    sys.exit(1)
elif warn_count > 0:
    print("\nRelease readiness: CONDITIONAL — advisory checks outstanding")
else:
    print("\nRelease readiness: READY")
PYEOF
