#!/usr/bin/env bash
# run_golden_tests.sh — Verify that calc_scorecard.py reproduces golden baseline outputs.
#
# For each golden file, re-runs calc_scorecard.py with the same inputs and compares
# the key numeric fields (score_total, confidence_global, decision, score_efetivo per dim).
# Differences in non-deterministic fields (scored_at, idea_path) are ignored.
#
# Usage:
#   bash tests/run_golden_tests.sh          # from plugin root
#   bash tests/run_golden_tests.sh --verbose

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

VERBOSE=false
[[ "${1:-}" == "--verbose" ]] && VERBOSE=true

PASS=0
FAIL=0
ERRORS=()

run_test() {
    local name="$1"
    local golden_file="$2"
    local mode="$3"
    local scores_json="$4"

    # Run calc_scorecard.py and capture output
    local actual
    local _tmp_actual
    _tmp_actual=$(mktemp "${TMPDIR:-/tmp}/idea-auditor-golden.XXXXXX") || {
        FAIL=$((FAIL + 1))
        ERRORS+=("FAIL [$name]: mktemp failed")
        return
    }

    python3 scripts/calc_scorecard.py \
        --scores "$scores_json" \
        --mode "$mode" > "$_tmp_actual" 2>&1 || {
        FAIL=$((FAIL + 1))
        ERRORS+=("FAIL [$name]: calc_scorecard.py exited with error")
        rm -f "$_tmp_actual"
        return
    }

    # Compare key fields using Python, reading actual output from temp file
    local result
    result=$(python3 - "$_tmp_actual" "$golden_file" <<'PYEOF' 2>&1
import json, sys

actual_path, golden_path = sys.argv[1], sys.argv[2]

with open(golden_path, 'r') as f:
    golden = json.load(f)

try:
    with open(actual_path, 'r') as f:
        actual = json.load(f)
except json.JSONDecodeError as e:
    print(f"PARSE_ERROR: {e}")
    sys.exit(1)

errors = []

# Check top-level numeric fields
for field in ("score_total", "confidence_global"):
    g = golden.get(field)
    a = actual.get(field)
    if g is None and a is None:
        continue
    if g is None or a is None or abs(g - a) > 0.01:
        errors.append(f"  {field}: golden={g}, actual={a}")

# Check decision
if golden.get("decision") != actual.get("decision"):
    errors.append(f"  decision: golden={golden.get('decision')}, actual={actual.get('decision')}")

# Check mode
if golden.get("mode") != actual.get("mode"):
    errors.append(f"  mode: golden={golden.get('mode')}, actual={actual.get('mode')}")

# Check per-dimension score_efetivo
g_dims = golden.get("dimensions", {})
a_dims = actual.get("dimensions", {})
for dim in g_dims:
    g_se = (g_dims[dim] or {}).get("score_efetivo")
    a_se = (a_dims.get(dim) or {}).get("score_efetivo")
    if g_se is None and a_se is None:
        continue
    if g_se is None or a_se is None or abs(g_se - a_se) > 0.001:
        errors.append(f"  {dim}.score_efetivo: golden={g_se}, actual={a_se}")

if errors:
    for e in errors:
        print(e)
    sys.exit(1)
PYEOF
    )

    rm -f "$_tmp_actual"
    local exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        PASS=$((PASS + 1))
        $VERBOSE && echo "PASS [$name]"
    else
        FAIL=$((FAIL + 1))
        ERRORS+=("FAIL [$name]:"$'\n'"$result")
    fi
}

# --- Test cases ---

run_test "OSS_CLI baseline" \
    "tests/golden/scorecard_oss_cli_baseline.json" \
    "OSS_CLI" \
    '{"wedge":{"score_bruto":3.5,"confidence":0.65},"friction":{"score_bruto":3.0,"confidence":0.5},"loop":{"score_bruto":2.5,"confidence":0.45},"timing":{"score_bruto":3.5,"confidence":0.6},"trust":{"score_bruto":4.0,"confidence":0.7}}'

run_test "B2B_SaaS baseline" \
    "tests/golden/scorecard_b2b_saas_baseline.json" \
    "B2B_SaaS" \
    '{"wedge":{"score_bruto":4.0,"confidence":0.7},"friction":{"score_bruto":3.5,"confidence":0.65},"loop":{"score_bruto":2.0,"confidence":0.5},"timing":{"score_bruto":3.0,"confidence":0.6},"trust":{"score_bruto":3.5,"confidence":0.65}}'

# --- Results ---

echo ""
echo "Golden tests: $PASS passed, $FAIL failed"

if [[ $FAIL -gt 0 ]]; then
    for err in "${ERRORS[@]}"; do
        echo "$err"
    done
    exit 1
fi
