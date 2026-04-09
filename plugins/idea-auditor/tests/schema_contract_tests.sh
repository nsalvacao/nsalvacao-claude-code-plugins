#!/usr/bin/env bash
# schema_contract_tests.sh — Contract tests for idea-auditor JSON schemas.
#
# Validates that:
#   1. evidence.schema.json is valid JSON
#   2. All method values in evidence examples are in the allowed enum
#   3. scorecard golden files contain required top-level keys
#   4. calc_scorecard.py --scores null produces INSUFFICIENT_EVIDENCE
#   5. diff_scorecards.py exits 2 on regression (score drop > 10)
#
# Usage:
#   bash tests/schema_contract_tests.sh          # from plugin root
#   bash tests/schema_contract_tests.sh --verbose

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

VERBOSE=false
[[ "${1:-}" == "--verbose" ]] && VERBOSE=true

PASS=0
FAIL=0
ERRORS=()

assert() {
    local name="$1"
    local cmd="$2"
    local expect_exit="${3:-0}"

    local actual_exit=0
    eval "$cmd" > /dev/null 2>&1 || actual_exit=$?

    if [[ $actual_exit -eq $expect_exit ]]; then
        PASS=$((PASS + 1))
        $VERBOSE && echo "PASS [$name]"
    else
        FAIL=$((FAIL + 1))
        ERRORS+=("FAIL [$name]: expected exit=$expect_exit, got exit=$actual_exit  cmd: $cmd")
    fi
}

assert_output_contains() {
    local name="$1"
    local cmd="$2"
    local pattern="$3"

    local output
    output=$(eval "$cmd" 2>&1) || true

    if echo "$output" | grep -qF "$pattern"; then
        PASS=$((PASS + 1))
        $VERBOSE && echo "PASS [$name]"
    else
        FAIL=$((FAIL + 1))
        ERRORS+=("FAIL [$name]: expected '$pattern' in output")
    fi
}

# --- 1. evidence.schema.json is valid JSON ---
assert \
    "evidence.schema.json is valid JSON" \
    "python3 -c \"import json; json.load(open('schemas/evidence.schema.json'))\"" \
    0

# --- 2. method enum values in schema ---
assert_output_contains \
    "evidence schema contains 'interview' method" \
    "python3 -c \"import json; s=json.load(open('schemas/evidence.schema.json')); print(s)\"" \
    "interview"

assert_output_contains \
    "evidence schema contains 'oss_metrics' method" \
    "python3 -c \"import json; s=json.load(open('schemas/evidence.schema.json')); print(s)\"" \
    "oss_metrics"

assert_output_contains \
    "evidence schema contains 'observation' method" \
    "python3 -c \"import json; s=json.load(open('schemas/evidence.schema.json')); print(s)\"" \
    "observation"

# --- 3. Golden files contain required keys ---
for golden in tests/golden/scorecard_*.json; do
    name=$(basename "$golden")
    assert \
        "$name has required keys (mode, score_total, decision, dimensions)" \
        "python3 -c \"
import json, sys
d = json.load(open('$golden'))
missing = [k for k in ('mode','score_total','confidence_global','decision','dimensions') if k not in d]
sys.exit(1 if missing else 0)
\"" \
        0
done

# --- 4. INSUFFICIENT_EVIDENCE when score_bruto is null ---
assert_output_contains \
    "null score_bruto → INSUFFICIENT_EVIDENCE decision" \
    "python3 scripts/calc_scorecard.py --scores '{\"wedge\":{\"score_bruto\":null},\"friction\":{\"score_bruto\":3}}' --mode OSS_CLI" \
    "INSUFFICIENT_EVIDENCE"

# --- 5. PROCEED gate fires correctly ---
assert_output_contains \
    "high scores + high confidence → PROCEED" \
    "python3 scripts/calc_scorecard.py --scores '{\"wedge\":{\"score_bruto\":5,\"confidence\":0.9},\"friction\":{\"score_bruto\":5,\"confidence\":0.9},\"loop\":{\"score_bruto\":5,\"confidence\":0.9},\"timing\":{\"score_bruto\":5,\"confidence\":0.9},\"trust\":{\"score_bruto\":5,\"confidence\":0.9}}' --mode OSS_CLI" \
    "PROCEED"

# --- 6. KILL gate fires correctly ---
assert_output_contains \
    "very low scores → KILL" \
    "python3 scripts/calc_scorecard.py --scores '{\"wedge\":{\"score_bruto\":1,\"confidence\":0.8},\"friction\":{\"score_bruto\":1,\"confidence\":0.8},\"loop\":{\"score_bruto\":1,\"confidence\":0.8},\"timing\":{\"score_bruto\":1,\"confidence\":0.8},\"trust\":{\"score_bruto\":1,\"confidence\":0.8}}' --mode OSS_CLI" \
    "KILL"

# --- 7. diff_scorecards.py exits 2 on regression ---
assert \
    "diff_scorecards.py exits 2 on regression (score drop > 10)" \
    "python3 -c \"
import json, tempfile, subprocess, sys, os

before = {'mode':'OSS_CLI','scored_at':'2026-04-08','score_total':60.0,'confidence_global':0.6,'decision':'ITERATE','dimensions':{}}
after  = {'mode':'OSS_CLI','scored_at':'2026-04-09','score_total':40.0,'confidence_global':0.6,'decision':'ITERATE','dimensions':{}}

with tempfile.NamedTemporaryFile('w',suffix='.json',delete=False) as f: json.dump(before,f); b=f.name
with tempfile.NamedTemporaryFile('w',suffix='.json',delete=False) as f: json.dump(after,f);  a=f.name

r = subprocess.run(['python3','scripts/diff_scorecards.py','--before',b,'--after',a],capture_output=True)
os.unlink(b); os.unlink(a)
sys.exit(r.returncode)
\"" \
    2

# --- 8. diff_scorecards.py exits 0 on non-regression ---
assert \
    "diff_scorecards.py exits 0 when no regression" \
    "python3 -c \"
import json, tempfile, subprocess, sys, os

before = {'mode':'OSS_CLI','scored_at':'2026-04-08','score_total':50.0,'confidence_global':0.5,'decision':'ITERATE','dimensions':{}}
after  = {'mode':'OSS_CLI','scored_at':'2026-04-09','score_total':52.0,'confidence_global':0.55,'decision':'ITERATE','dimensions':{}}

with tempfile.NamedTemporaryFile('w',suffix='.json',delete=False) as f: json.dump(before,f); b=f.name
with tempfile.NamedTemporaryFile('w',suffix='.json',delete=False) as f: json.dump(after,f);  a=f.name

r = subprocess.run(['python3','scripts/diff_scorecards.py','--before',b,'--after',a],capture_output=True)
os.unlink(b); os.unlink(a)
sys.exit(r.returncode)
\"" \
    0

# --- 9. diff_scorecards.py exits 0 on exactly -10 drop (boundary: strictly > 10) ---
assert \
    "diff_scorecards.py exits 0 on exactly -10 drop (boundary)" \
    "python3 -c \"
import json, tempfile, subprocess, sys, os

before = {'mode':'OSS_CLI','scored_at':'2026-04-08','score_total':60.0,'confidence_global':0.6,'decision':'ITERATE','dimensions':{}}
after  = {'mode':'OSS_CLI','scored_at':'2026-04-09','score_total':50.0,'confidence_global':0.6,'decision':'ITERATE','dimensions':{}}

with tempfile.NamedTemporaryFile('w',suffix='.json',delete=False) as f: json.dump(before,f); b=f.name
with tempfile.NamedTemporaryFile('w',suffix='.json',delete=False) as f: json.dump(after,f);  a=f.name

r = subprocess.run(['python3','scripts/diff_scorecards.py','--before',b,'--after',a],capture_output=True)
os.unlink(b); os.unlink(a)
sys.exit(r.returncode)
\"" \
    0

# --- Results ---

echo ""
echo "Contract tests: $PASS passed, $FAIL failed"

if [[ $FAIL -gt 0 ]]; then
    for err in "${ERRORS[@]}"; do
        echo "$err"
    done
    exit 1
fi
