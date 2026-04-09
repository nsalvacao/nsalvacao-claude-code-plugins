#!/usr/bin/env bash
# run_e2e_tests.sh — End-to-end integration tests for idea-auditor scripts.
#
# Tests 6 scenarios offline (no MCP, no Claude API):
#   1. Valid scores → scorecard JSON produced with a decision gate
#   2. Null score_bruto → INSUFFICIENT_EVIDENCE decision
#   3. grade_evidence.py → graded evidence JSON with conf_dim per dimension
#   4. build_report.py → markdown report with decision, dimensions, blockers
#   5. validate_inputs.py → accepts valid IDEA.md
#   6. normalize_interviews.py → round-trip to valid evidence JSON
#
# Usage:
#   bash tests/run_e2e_tests.sh          # from plugin root
#   bash tests/run_e2e_tests.sh --verbose

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

VERBOSE=false
[[ "${1:-}" == "--verbose" ]] && VERBOSE=true

PASS=0
FAIL=0
ERRORS=()

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

assert_exit() {
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

    local output actual_exit=0
    output=$(eval "$cmd" 2>&1) || actual_exit=$?

    if [[ $actual_exit -ne 0 ]]; then
        FAIL=$((FAIL + 1))
        ERRORS+=("FAIL [$name]: command exited $actual_exit (expected 0)  cmd: $cmd")
    elif echo "$output" | grep -qF "$pattern"; then
        PASS=$((PASS + 1))
        $VERBOSE && echo "PASS [$name]"
    else
        FAIL=$((FAIL + 1))
        ERRORS+=("FAIL [$name]: pattern '$pattern' not found in output")
    fi
}

assert_json_field() {
    local name="$1"
    local json_file="$2"
    local field="$3"   # python expression, e.g. d['decision']
    local expect="$4"  # expected value as string

    # Write the python snippet to a temp file to avoid heredoc-inside-subshell warnings
    local _py_tmp
    _py_tmp=$(mktemp "${TMPDIR:-/tmp}/idea-auditor-ajf.XXXXXX.py") || {
        FAIL=$((FAIL + 1))
        ERRORS+=("FAIL [$name]: mktemp failed")
        return
    }
    printf 'import json, sys\nd = json.load(open(sys.argv[1]))\nprint(%s)\n' "$field" > "$_py_tmp"

    local actual actual_exit=0
    actual=$(python3 "$_py_tmp" "$json_file" 2>&1) || actual_exit=$?
    rm -f "$_py_tmp"

    if [[ $actual_exit -ne 0 ]]; then
        FAIL=$((FAIL + 1))
        ERRORS+=("FAIL [$name]: python extraction failed: $actual")
    elif [[ "$actual" == "$expect" ]]; then
        PASS=$((PASS + 1))
        $VERBOSE && echo "PASS [$name]"
    else
        FAIL=$((FAIL + 1))
        ERRORS+=("FAIL [$name]: expected '$expect', got '$actual'  file: $json_file  field: $field")
    fi
}

# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------

_TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/idea-auditor-e2e.XXXXXX") || {
    echo "ERROR: mktemp failed"
    exit 1
}
trap 'rm -rf "$_TMP_DIR"' EXIT

IDEA_MD="$_TMP_DIR/IDEA.md"
STATE_DIR="$_TMP_DIR/STATE"
REPORTS_DIR="$_TMP_DIR/REPORTS"
mkdir -p "$STATE_DIR" "$REPORTS_DIR"

# Minimal IDEA.md fixture — all keywords required by validate_inputs.py:
#   ICP, JTBD, pain, current_alternative, promise, mode
cat > "$IDEA_MD" <<'IDEAEOF'
# IDEA — E2E Test Fixture

## Metadata
- **mode:** OSS_CLI

## ICP (Ideal Customer Profile)
- **Role:** Developer
- **Context:** Building tools and wanting to validate demand
- **Trigger event:** Built a tool and wants to validate demand

## JTBD (Job to Be Done)
"When I have a tool, I want to know if it solves a real pain."

**Job statement:** Validate tool demand before scaling investment.

## Pain
Developers spend hours on ad-hoc research without structure or reproducibility.

## Current_alternative
Manual market research — unstructured, inconsistent, hard to repeat.

## Promise
A structured, evidence-driven scorecard that tells you PROCEED, ITERATE, or KILL.

## Assumptions
- Pain is real
- Developers want a structured approach

## Risks
- Market may be too small
IDEAEOF

# Evidence fixture for scenario 3
cat > "$STATE_DIR/wedge_interviews.json" <<'EVIDEOF'
[
  {
    "claim": "Spent 3 hours manually validating idea assumptions last week",
    "source": "Alice, Senior Engineer",
    "method": "interview",
    "collected_at": "2026-04-01",
    "quality_tier": "stated",
    "dimension": "wedge",
    "raw": "Alice told us she manually validates ideas every sprint",
    "normalized": "frequency: weekly; severity: 3/5"
  },
  {
    "claim": "Signed up for waitlist immediately after seeing the tool",
    "source": "Bob, Product Manager",
    "method": "interview",
    "collected_at": "2026-04-02",
    "quality_tier": "commitment",
    "dimension": "wedge",
    "raw": "Bob signed up without prompting",
    "normalized": "quality_tier: commitment"
  }
]
EVIDEOF

# Fixed scorecard JSON for build_report scenario
SCORECARD_JSON="$_TMP_DIR/scorecard.json"
cat > "$SCORECARD_JSON" <<'SCEOF'
{
  "mode": "OSS_CLI",
  "scored_at": "2026-04-09",
  "score_total": 55.0,
  "confidence_global": 0.62,
  "decision": "ITERATE",
  "blockers": ["wedge commitment evidence weak", "loop K-factor unmeasured"],
  "next_tests": ["Run JTBD interviews with deposit ask"],
  "dimensions": {
    "wedge": {"score_bruto": 3.0, "confidence": 0.7, "score_efetivo": 2.1, "needs_experiment": false},
    "friction": {"score_bruto": 2.5, "confidence": 0.55, "score_efetivo": 1.375, "needs_experiment": true},
    "loop": {"score_bruto": 2.0, "confidence": 0.5, "score_efetivo": 1.0, "needs_experiment": true},
    "timing": {"score_bruto": 3.0, "confidence": 0.65, "score_efetivo": 1.95, "needs_experiment": false},
    "trust": {"score_bruto": 3.5, "confidence": 0.7, "score_efetivo": 2.45, "needs_experiment": false}
  }
}
SCEOF

# ---------------------------------------------------------------------------
# Scenario 1 — Valid scores → scorecard with decision gate
# ---------------------------------------------------------------------------

SCORECARD_OUT="$_TMP_DIR/scorecard_out.json"

assert_exit \
    "S1: calc_scorecard.py exits 0 with valid scores" \
    "python3 scripts/calc_scorecard.py \
        --scores '{\"wedge\":{\"score_bruto\":3.5,\"confidence\":0.65},\"friction\":{\"score_bruto\":3.0,\"confidence\":0.5},\"loop\":{\"score_bruto\":2.5,\"confidence\":0.45},\"timing\":{\"score_bruto\":3.5,\"confidence\":0.6},\"trust\":{\"score_bruto\":4.0,\"confidence\":0.7}}' \
        --mode OSS_CLI \
        > '$SCORECARD_OUT'"

assert_json_field \
    "S1: scorecard has decision field (ITERATE, PROCEED, or KILL)" \
    "$SCORECARD_OUT" \
    "d['decision'] in ('ITERATE','PROCEED','KILL','INSUFFICIENT_EVIDENCE')" \
    "True"

assert_json_field \
    "S1: scorecard has score_total > 0" \
    "$SCORECARD_OUT" \
    "d['score_total'] > 0" \
    "True"

assert_json_field \
    "S1: scorecard has 5 dimensions" \
    "$SCORECARD_OUT" \
    "len(d.get('dimensions', {}))" \
    "5"

# ---------------------------------------------------------------------------
# Scenario 2 — Null score_bruto → INSUFFICIENT_EVIDENCE
# ---------------------------------------------------------------------------

NULL_SCORECARD_OUT="$_TMP_DIR/scorecard_null.json"

assert_exit \
    "S2: calc_scorecard.py exits 0 with null score" \
    "python3 scripts/calc_scorecard.py \
        --scores '{\"wedge\":{\"score_bruto\":null},\"friction\":{\"score_bruto\":3.0}}' \
        --mode OSS_CLI \
        > '$NULL_SCORECARD_OUT'"

assert_json_field \
    "S2: null score → INSUFFICIENT_EVIDENCE decision" \
    "$NULL_SCORECARD_OUT" \
    "d['decision']" \
    "INSUFFICIENT_EVIDENCE"

# ---------------------------------------------------------------------------
# Scenario 3 — grade_evidence.py → graded evidence with conf_dim
# ---------------------------------------------------------------------------

GRADED_OUT="$_TMP_DIR/graded_evidence.json"

assert_exit \
    "S3: grade_evidence.py exits 0 with valid evidence" \
    "python3 scripts/grade_evidence.py \
        --evidence '$STATE_DIR/wedge_interviews.json' \
        --out '$GRADED_OUT'"

assert_exit \
    "S3: graded evidence is valid JSON" \
    "python3 -c \"import json; json.load(open('$GRADED_OUT'))\""

assert_output_contains \
    "S3: graded evidence contains conf_dim field" \
    "python3 -c \"import json; d=json.load(open('$GRADED_OUT')); print(str(d))\"" \
    "conf_dim"

assert_output_contains \
    "S3: graded evidence contains wedge dimension" \
    "python3 -c \"import json; d=json.load(open('$GRADED_OUT')); print(str(d))\"" \
    "wedge"

# ---------------------------------------------------------------------------
# Scenario 4 — build_report.py → markdown report with expected sections
# ---------------------------------------------------------------------------

REPORT_OUT="$_TMP_DIR/report.md"

assert_exit \
    "S4: build_report.py exits 0 with scorecard" \
    "python3 scripts/build_report.py \
        --scorecard '$SCORECARD_JSON' \
        --out '$REPORT_OUT'"

assert_exit \
    "S4: report markdown file exists" \
    "test -f '$REPORT_OUT'"

assert_output_contains \
    "S4: report contains decision" \
    "cat '$REPORT_OUT'" \
    "ITERATE"

assert_output_contains \
    "S4: report contains dimensions section" \
    "cat '$REPORT_OUT'" \
    "wedge"

assert_output_contains \
    "S4: report contains blockers section" \
    "cat '$REPORT_OUT'" \
    "locker"

# ---------------------------------------------------------------------------
# Scenario 5 — validate_inputs.py accepts valid IDEA.md
# ---------------------------------------------------------------------------

assert_exit \
    "S5: validate_inputs.py exits 0 with valid IDEA.md" \
    "python3 scripts/validate_inputs.py --idea '$IDEA_MD' --state '$STATE_DIR'"

# ---------------------------------------------------------------------------
# Scenario 6 — normalize_interviews.py round-trip
# ---------------------------------------------------------------------------

NORMALIZED_OUT="$_TMP_DIR/normalized.json"
INTERVIEW_MD="$_TMP_DIR/interviews.md"

cat > "$INTERVIEW_MD" <<'INTEOF'
## Interview 1
Interviewee: Carol Davis
Role: Engineering Manager
Date: 2026-04-05
Dimension: wedge
Pain: I waste 2 hours per week on tool evaluation without a framework.
Severity: 4/5
Frequency: weekly
Commitment: Pre-signed up for the beta and introduced 2 colleagues
INTEOF

assert_exit \
    "S6: normalize_interviews.py exits 0" \
    "python3 scripts/normalize_interviews.py --input '$INTERVIEW_MD' --output '$NORMALIZED_OUT'"

assert_exit \
    "S6: normalized output is valid JSON" \
    "python3 -c \"import json; json.load(open('$NORMALIZED_OUT'))\""

assert_output_contains \
    "S6: normalized output has quality_tier commitment" \
    "python3 -c \"import json; d=json.load(open('$NORMALIZED_OUT')); print(str(d))\"" \
    "commitment"

# ---------------------------------------------------------------------------
# Scenario 7 — evidence-harvester server.py structural checks (no network)
# ---------------------------------------------------------------------------

SERVER_PY="mcp/servers/evidence-harvester/server.py"

assert_exit \
    "S7: server.py is valid Python AST" \
    "python3 -c \"import ast; ast.parse(open('$SERVER_PY').read())\""

assert_output_contains \
    "S7: _fetch_trend_snapshot is async with client param" \
    "python3 -c \"import ast, sys; tree=ast.parse(open('$SERVER_PY').read()); fns=[n for n in ast.walk(tree) if isinstance(n,ast.AsyncFunctionDef) and n.name=='_fetch_trend_snapshot']; f=fns[0] if fns else None; print('async='+str(bool(fns))+' client='+str(any(a.arg=='client' for a in (f.args.args if f else [])))+'')\"" \
    "async=True client=True"

assert_output_contains \
    "S7: trend_snapshot result has github_trending_weekly key" \
    "python3 -c \"
import ast, types as _t
src = open('$SERVER_PY').read()
tree = ast.parse(src)
fns = [n for n in ast.walk(tree) if isinstance(n, (ast.FunctionDef,ast.AsyncFunctionDef)) and n.name=='_fetch_trend_snapshot']
print('found='+str(len(fns)))
\"" \
    "found=1"

# ---------------------------------------------------------------------------
# Results
# ---------------------------------------------------------------------------

echo ""
echo "E2E tests: $PASS passed, $FAIL failed"

if [[ $FAIL -gt 0 ]]; then
    for err in "${ERRORS[@]}"; do
        echo "$err"
    done
    exit 1
fi
