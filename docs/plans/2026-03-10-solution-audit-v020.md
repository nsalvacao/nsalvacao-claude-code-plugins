# solution-audit v0.2.0 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Elevate solution-audit from a concept-only plugin (v0.1.0) to a production-ready audit system with executable scripts, real automation hooks, parallel multi-agent blueprint review, and a new spec-gap-analysis dimension.

**Architecture:** All new components are additive (no breaking changes to existing commands/agents/skills). Scripts in `scripts/` are invoked by hooks and commands. Hooks use `$CLAUDE_PLUGIN_ROOT` for portable paths. The new `/blueprint-review` command spawns parallel agents via Task tool with explicit output contracts.

**Tech Stack:** Bash scripts (portable, WSL-compatible), JSON (hooks config), Markdown with YAML frontmatter (Claude plugin components), Python 3 (example validation in check-examples.sh)

**Design doc:** `docs/plans/2026-03-10-solution-audit-elevation-design.md`

---

## Pre-flight

Before starting, verify environment:

```bash
cd /mnt/d/GitHub/nsalvacao-claude-code-plugins
git status
git log --oneline -5
ls plugins/solution-audit/
```

Expected: clean working tree, `plugins/solution-audit/` contains `commands/`, `agents/`, `skills/`, `hooks/`.

---

### Task 1: Scripts directory + mark-stale.sh

**Files:**
- Create: `plugins/solution-audit/scripts/mark-stale.sh`

**Step 1: Create scripts directory**

```bash
mkdir -p /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/scripts
```

**Step 2: Write mark-stale.sh**

```bash
#!/bin/bash
# mark-stale.sh — marks affected audit dimensions as stale in .solution-audit-latest.json
# Called by PostToolUse hook after Write/Edit tool calls
# Reads tool_input JSON from stdin

set -euo pipefail

# Read tool input from stdin
TOOL_INPUT=$(cat)
FILE_PATH=$(echo "$TOOL_INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path', d.get('tool_input',{}).get('path','')))" 2>/dev/null || echo "")

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Map file paths to affected dimensions
STALE_DIMS=()

case "$FILE_PATH" in
  *README* | *readme*)
    STALE_DIMS+=("product-coherence" "documentation-quality")
    ;;
  *ARCHITECTURE* | *architecture* | *DESIGN* | *design*)
    STALE_DIMS+=("architecture-coherence" "product-coherence")
    ;;
  docs/* | */docs/*)
    STALE_DIMS+=("documentation-quality")
    ;;
  src/* | lib/* | */src/* | */lib/*)
    STALE_DIMS+=("architecture-coherence" "product-coherence")
    ;;
  *CONTRIBUTING* | *INSTALL* | *GETTING_STARTED* | *quickstart*)
    STALE_DIMS+=("onboarding-quality")
    ;;
  *.md)
    STALE_DIMS+=("documentation-quality")
    ;;
esac

if [ ${#STALE_DIMS[@]} -eq 0 ]; then
  exit 0
fi

# Find .solution-audit-latest.json in CWD or parent dirs (up to 3 levels)
AUDIT_FILE=""
for DIR in "." ".." "../.." "../../.."; do
  if [ -f "$DIR/.solution-audit-latest.json" ]; then
    AUDIT_FILE="$DIR/.solution-audit-latest.json"
    break
  fi
done

if [ -z "$AUDIT_FILE" ]; then
  exit 0  # No audit file yet — nothing to mark stale
fi

# Build JSON array of stale dimensions
STALE_JSON=$(printf '%s\n' "${STALE_DIMS[@]}" | python3 -c "
import sys, json
dims = [line.strip() for line in sys.stdin if line.strip()]
print(json.dumps(list(set(dims))))
")

# Update .solution-audit-latest.json with stale dimensions
python3 - "$AUDIT_FILE" "$STALE_JSON" << 'PYEOF'
import sys, json
audit_file, stale_json = sys.argv[1], sys.argv[2]
new_stale = json.loads(stale_json)
with open(audit_file) as f:
    data = json.load(f)
existing = data.get("stale", [])
merged = list(set(existing + new_stale))
data["stale"] = merged
with open(audit_file, "w") as f:
    json.dump(data, f, indent=2)
PYEOF

# Print stale notice (visible in Claude output)
DIMS_STR=$(IFS=", "; echo "${STALE_DIMS[*]}")
echo "⚠ Audit stale: $DIMS_STR — run /audit or specific audit command to refresh" >&2
```

**Step 3: Make executable**

```bash
chmod +x /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/scripts/mark-stale.sh
```

**Step 4: Validate (syntax check)**

```bash
bash -n /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/scripts/mark-stale.sh
echo "syntax OK"
```

Expected output: `syntax OK`

**Step 5: Test with mock input**

```bash
# Create temp audit file
TMPDIR=$(mktemp -d)
echo '{"date":"2026-03-10","overall":75,"stale":[]}' > "$TMPDIR/.solution-audit-latest.json"

# Simulate hook call for README.md edit
echo '{"tool_input":{"file_path":"README.md"}}' \
  | bash /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/scripts/mark-stale.sh 2>&1 || true

echo "Test with audit file:"
cd "$TMPDIR"
echo '{"tool_input":{"file_path":"README.md"}}' \
  | bash /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/scripts/mark-stale.sh 2>&1 || true
cat .solution-audit-latest.json
cd -
rm -rf "$TMPDIR"
```

Expected: stderr shows `⚠ Audit stale: product-coherence, documentation-quality`, JSON updated with stale dims.

**Step 6: Commit**

```bash
cd /mnt/d/GitHub/nsalvacao-claude-code-plugins
git add plugins/solution-audit/scripts/mark-stale.sh
git commit -m "feat(solution-audit): add mark-stale.sh script for PostToolUse hook"
```

---

### Task 2: save-progress.sh

**Files:**
- Create: `plugins/solution-audit/scripts/save-progress.sh`

**Step 1: Write save-progress.sh**

```bash
#!/bin/bash
# save-progress.sh — appends session-end marker to WIP audit file
# Called by Stop hook when session ends

set -euo pipefail

TIMESTAMP=$(date '+%Y-%m-%d %H:%M')

# Find .solution-audit-wip.md in CWD or nearby
for DIR in "." ".." "../.." "../../.."; do
  if [ -f "$DIR/.solution-audit-wip.md" ]; then
    echo "" >> "$DIR/.solution-audit-wip.md"
    echo "---" >> "$DIR/.solution-audit-wip.md"
    echo "[SESSION ENDED: $TIMESTAMP]" >> "$DIR/.solution-audit-wip.md"
    echo "Audit WIP saved: $DIR/.solution-audit-wip.md" >&2
    exit 0
  fi
done

# No WIP file — nothing to do
exit 0
```

**Step 2: Make executable and validate**

```bash
chmod +x /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/scripts/save-progress.sh
bash -n /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/scripts/save-progress.sh
echo "syntax OK"
```

**Step 3: Test**

```bash
TMPDIR=$(mktemp -d)
echo "# WIP Audit\n\nSome in-progress findings..." > "$TMPDIR/.solution-audit-wip.md"
(cd "$TMPDIR" && bash /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/scripts/save-progress.sh 2>&1)
cat "$TMPDIR/.solution-audit-wip.md"
rm -rf "$TMPDIR"
```

Expected: file ends with `[SESSION ENDED: YYYY-MM-DD HH:MM]`

**Step 4: Commit**

```bash
cd /mnt/d/GitHub/nsalvacao-claude-code-plugins
git add plugins/solution-audit/scripts/save-progress.sh
git commit -m "feat(solution-audit): add save-progress.sh script for Stop hook"
```

---

### Task 3: check-links.sh

**Files:**
- Create: `plugins/solution-audit/scripts/check-links.sh`

**Step 1: Write check-links.sh**

```bash
#!/bin/bash
# check-links.sh — validate internal and external links in markdown files
# Usage: check-links.sh [--internal-only] [directory]
# Output: broken links with file:line references

set -uo pipefail

INTERNAL_ONLY=false
SEARCH_DIR="."

for arg in "$@"; do
  case "$arg" in
    --internal-only) INTERNAL_ONLY=true ;;
    *) SEARCH_DIR="$arg" ;;
  esac
done

BROKEN=0

echo "Checking internal links..."

# Check internal markdown links [text](path) and [text](path#anchor)
while IFS= read -r line; do
  FILE=$(echo "$line" | cut -d: -f1)
  LINENO=$(echo "$line" | cut -d: -f2)
  LINK=$(echo "$line" | grep -oP '\]\(([^)#]+)' | head -1 | sed 's/](//')

  if [ -z "$LINK" ]; then continue; fi
  # Skip external links
  if echo "$LINK" | grep -qE '^https?://'; then continue; fi
  # Skip anchors-only
  if echo "$LINK" | grep -qE '^#'; then continue; fi

  # Resolve relative to file's directory
  FILE_DIR=$(dirname "$FILE")
  RESOLVED="$FILE_DIR/$LINK"

  if [ ! -f "$RESOLVED" ] && [ ! -d "$RESOLVED" ]; then
    echo "BROKEN [internal] $FILE:$LINENO → $LINK"
    BROKEN=$((BROKEN + 1))
  fi
done < <(grep -rn --include="*.md" -oP '(?<=\[)[^\]]+(?=\]\([^)]+\))|\]\([^)]+\)' "$SEARCH_DIR" 2>/dev/null | grep -oP '.*\.md:\d+' | while read -r match; do echo "$match"; done)

# Simpler approach: find all [text](link) patterns
while IFS= read -r match; do
  FILE=$(echo "$match" | cut -d: -f1)
  LINENO=$(echo "$match" | cut -d: -f2)
  CONTENT=$(echo "$match" | cut -d: -f3-)
  LINK=$(echo "$CONTENT" | grep -oP '\(([^)]+)\)' | head -1 | tr -d '()')

  if [ -z "$LINK" ]; then continue; fi
  if echo "$LINK" | grep -qE '^https?://|^#|^mailto:'; then continue; fi

  FILE_DIR=$(dirname "$FILE")
  RESOLVED="$FILE_DIR/$LINK"
  if [ ! -f "$RESOLVED" ]; then
    echo "BROKEN [internal] $FILE:$LINENO → $LINK (resolved: $RESOLVED)"
    BROKEN=$((BROKEN + 1))
  fi
done < <(grep -rn --include="*.md" -E '\[.+\]\([^)]+\)' "$SEARCH_DIR" 2>/dev/null)

if [ "$INTERNAL_ONLY" = "true" ]; then
  echo "Internal link check complete. Broken: $BROKEN"
  exit $( [ "$BROKEN" -gt 0 ] && echo 1 || echo 0 )
fi

echo "Checking external links (may take a moment)..."

EXTERNAL_BROKEN=0
while IFS= read -r match; do
  FILE=$(echo "$match" | cut -d: -f1)
  LINENO=$(echo "$match" | cut -d: -f2)
  CONTENT=$(echo "$match" | cut -d: -f3-)
  URL=$(echo "$CONTENT" | grep -oP 'https?://[^\s)>"]+' | head -1)

  if [ -z "$URL" ]; then continue; fi

  HTTP_CODE=$(curl --head --silent --max-time 8 --write-out "%{http_code}" --output /dev/null "$URL" 2>/dev/null || echo "000")
  if [ "$HTTP_CODE" = "000" ] || [ "$HTTP_CODE" = "404" ] || [ "$HTTP_CODE" = "410" ]; then
    echo "BROKEN [external:$HTTP_CODE] $FILE:$LINENO → $URL"
    EXTERNAL_BROKEN=$((EXTERNAL_BROKEN + 1))
  fi
done < <(grep -rn --include="*.md" -E 'https?://' "$SEARCH_DIR" 2>/dev/null)

TOTAL=$((BROKEN + EXTERNAL_BROKEN))
echo "Link check complete. Internal broken: $BROKEN | External broken: $EXTERNAL_BROKEN | Total: $TOTAL"
exit $( [ "$TOTAL" -gt 0 ] && echo 1 || echo 0 )
```

**Step 2: Make executable and validate**

```bash
chmod +x /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/scripts/check-links.sh
bash -n /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/scripts/check-links.sh
echo "syntax OK"
```

**Step 3: Quick smoke test (internal only)**

```bash
cd /mnt/d/GitHub/nsalvacao-claude-code-plugins
bash plugins/solution-audit/scripts/check-links.sh --internal-only plugins/solution-audit/ 2>&1 | head -20
```

Expected: runs without error, reports some count.

**Step 4: Commit**

```bash
cd /mnt/d/GitHub/nsalvacao-claude-code-plugins
git add plugins/solution-audit/scripts/check-links.sh
git commit -m "feat(solution-audit): add check-links.sh for executable link validation"
```

---

### Task 4: check-examples.sh

**Files:**
- Create: `plugins/solution-audit/scripts/check-examples.sh`

**Step 1: Write check-examples.sh**

```bash
#!/bin/bash
# check-examples.sh — validate code blocks in markdown files
# Usage: check-examples.sh [directory]
# Checks: bash (syntax), python (compile), json (parse)

set -uo pipefail

SEARCH_DIR="${1:-.}"
INVALID=0
CHECKED=0

echo "Checking code examples in $SEARCH_DIR..."

# Process each markdown file
while IFS= read -r md_file; do
  # Extract code blocks with language tags using python3
  python3 - "$md_file" << 'PYEOF'
import sys, re, subprocess, tempfile, os

md_file = sys.argv[1]
with open(md_file) as f:
    content = f.read()

# Find all fenced code blocks
pattern = re.compile(r'```(\w+)\n(.*?)```', re.DOTALL)
blocks = pattern.findall(content)

invalid = 0
checked = 0

for lang, code in blocks:
    lang = lang.lower().strip()
    code = code.strip()
    if not code:
        continue

    if lang in ('bash', 'sh', 'shell'):
        result = subprocess.run(['bash', '-n'], input=code, capture_output=True, text=True)
        checked += 1
        if result.returncode != 0:
            print(f"INVALID [{lang}] in {md_file}: {result.stderr.strip()[:100]}")
            invalid += 1

    elif lang in ('python', 'python3', 'py'):
        try:
            compile(code, '<string>', 'exec')
            checked += 1
        except SyntaxError as e:
            print(f"INVALID [{lang}] in {md_file}: SyntaxError line {e.lineno}: {e.msg}")
            invalid += 1
            checked += 1

    elif lang == 'json':
        import json
        try:
            json.loads(code)
            checked += 1
        except json.JSONDecodeError as e:
            print(f"INVALID [json] in {md_file}: {e}")
            invalid += 1
            checked += 1

if invalid > 0:
    sys.exit(1)
PYEOF
  STATUS=$?
  if [ "$STATUS" -ne 0 ]; then
    INVALID=$((INVALID + 1))
  fi
  CHECKED=$((CHECKED + 1))
done < <(find "$SEARCH_DIR" -name "*.md" -type f 2>/dev/null)

echo "Example check complete. Files checked: $CHECKED | Files with invalid examples: $INVALID"
exit $( [ "$INVALID" -gt 0 ] && echo 1 || echo 0 )
```

**Step 2: Make executable and validate**

```bash
chmod +x /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/scripts/check-examples.sh
bash -n /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/scripts/check-examples.sh
echo "syntax OK"
```

**Step 3: Smoke test**

```bash
cd /mnt/d/GitHub/nsalvacao-claude-code-plugins
bash plugins/solution-audit/scripts/check-examples.sh plugins/solution-audit/ 2>&1 | tail -5
```

Expected: runs, reports count without crashing.

**Step 4: Commit**

```bash
cd /mnt/d/GitHub/nsalvacao-claude-code-plugins
git add plugins/solution-audit/scripts/check-examples.sh
git commit -m "feat(solution-audit): add check-examples.sh for code block validation"
```

---

### Task 5: Update hooks/hooks.json

**Files:**
- Modify: `plugins/solution-audit/hooks/hooks.json`

**Step 1: Read current hooks.json**

```bash
cat /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/hooks/hooks.json
```

**Step 2: Write updated hooks.json**

Replace entire content with:

```json
{
  "SessionStart": [
    {
      "matcher": ".*",
      "hooks": [
        {
          "type": "prompt",
          "prompt": "Check if .solution-audit-latest.json exists in the current project root. If it exists, read it and:\n1. If 'stale' array is non-empty, display: '⚠ Audit stale: [dimension names] — files changed since last audit. Run /audit or relevant /audit-* command to refresh.'\n2. Display a brief (2-3 line) reminder of the top 3 unresolved findings by severity. Format: 'Solution Audit: [N] pending findings — top: [brief description of top 1-3 items]'\n3. If .solution-audit-wip.md exists in project root, display: '📋 WIP audit in progress: .solution-audit-wip.md'\nIf the file does not exist, output nothing."
        }
      ]
    }
  ],
  "PostToolUse": [
    {
      "matcher": "Write|Edit",
      "hooks": [
        {
          "type": "command",
          "command": "bash $CLAUDE_PLUGIN_ROOT/scripts/mark-stale.sh",
          "timeout": 10
        }
      ]
    }
  ],
  "Stop": [
    {
      "matcher": ".*",
      "hooks": [
        {
          "type": "command",
          "command": "bash $CLAUDE_PLUGIN_ROOT/scripts/save-progress.sh",
          "timeout": 10
        }
      ]
    }
  ]
}
```

**Step 3: Validate JSON**

```bash
python3 -m json.tool /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/hooks/hooks.json > /dev/null
echo "JSON valid"
```

Expected: `JSON valid`

**Step 4: Commit**

```bash
cd /mnt/d/GitHub/nsalvacao-claude-code-plugins
git add plugins/solution-audit/hooks/hooks.json
git commit -m "feat(solution-audit): add PostToolUse stale-marking and Stop WIP hooks"
```

---

### Task 6: Reference files for 4 skills

**Files:**
- Create: `plugins/solution-audit/skills/onboarding-quality/references/assessment-criteria.md`
- Create: `plugins/solution-audit/skills/cli-ux/references/ergonomics-patterns.md`
- Create: `plugins/solution-audit/skills/textual-ux/references/tone-patterns.md`
- Create: `plugins/solution-audit/skills/learnability-workflow/references/friction-patterns.md`

**Step 1: Create directories**

```bash
mkdir -p /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/skills/onboarding-quality/references
mkdir -p /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/skills/cli-ux/references
mkdir -p /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/skills/textual-ux/references
mkdir -p /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/skills/learnability-workflow/references
```

**Step 2: Write assessment-criteria.md (onboarding-quality)**

Content covers:
- Steps-to-first-success rubric (ideal: ≤5 steps, acceptable: ≤10, poor: >10)
- Cognitive load taxonomy (concepts needed before first productive use)
- Prerequisite clarity patterns (stated vs unstated prerequisites)
- First-run experience evaluation (what happens on `tool --help`, `tool init`, etc.)
- Error recovery assessment (documented paths for common failures)
- Progressive disclosure check (complexity introduction gradient)

(Claude: write full content for this reference file — 80-120 lines of actionable criteria)

**Step 3: Write ergonomics-patterns.md (cli-ux)**

Content covers:
- POSIX/GNU flag conventions (short `-f`, long `--flag`, value `--flag=value` vs `--flag value`)
- Help text quality rubric (description, usage, examples, see-also)
- Argument naming patterns (consistent pluralization, verb forms, boolean flags)
- Subcommand organization patterns (flat vs nested, alias conventions)
- Error handling patterns (non-zero exits, stderr vs stdout, error codes)
- Output formatting (human vs machine readable, `--json`, `--quiet`, `--verbose`)
- Scripting friendliness (idempotency, exit codes, piping)

(Claude: write full content — 100-130 lines)

**Step 4: Write tone-patterns.md (textual-ux)**

Content covers:
- Tone taxonomy (friendly, neutral, technical, formal) with appropriate contexts
- Jargon detection patterns (internal terms exposed to users, unexplained acronyms)
- Error message anatomy (what happened + why + what to do → never just "Error: failed")
- Verbosity calibration (normal, `--verbose`, `--quiet` tiers)
- Consistency patterns (same term for same concept throughout)
- Affirmation patterns (success messages, progress indicators)
- Pluralization and grammar patterns common failure modes

(Claude: write full content — 80-100 lines)

**Step 5: Write friction-patterns.md (learnability-workflow)**

Content covers:
- Friction taxonomy: cognitive load, context switches, ambiguity, dead ends, irreversibility
- Progressive disclosure patterns (onion model: basics → advanced)
- Mental model alignment (does the tool match user's existing mental model?)
- Escape hatch patterns (undo, dry-run, --help at any point, cancel)
- Feedback loop quality (confirmation of actions taken, status during long ops)
- Workflow step analysis template (step → user intent → friction type → severity)
- Common friction anti-patterns: required reading before first use, magic invocations, silent failures

(Claude: write full content — 90-120 lines)

**Step 6: Validate all 4 files exist and are non-empty**

```bash
for f in \
  "plugins/solution-audit/skills/onboarding-quality/references/assessment-criteria.md" \
  "plugins/solution-audit/skills/cli-ux/references/ergonomics-patterns.md" \
  "plugins/solution-audit/skills/textual-ux/references/tone-patterns.md" \
  "plugins/solution-audit/skills/learnability-workflow/references/friction-patterns.md"; do
  wc -l "/mnt/d/GitHub/nsalvacao-claude-code-plugins/$f"
done
```

Expected: all files >50 lines.

**Step 7: Commit**

```bash
cd /mnt/d/GitHub/nsalvacao-claude-code-plugins
git add plugins/solution-audit/skills/onboarding-quality/references/
git add plugins/solution-audit/skills/cli-ux/references/
git add plugins/solution-audit/skills/textual-ux/references/
git add plugins/solution-audit/skills/learnability-workflow/references/
git commit -m "feat(solution-audit): add reference files for 4 skills missing assessment criteria"
```

---

### Task 7: New skill — spec-gap-analysis

**Files:**
- Create: `plugins/solution-audit/skills/spec-gap-analysis/SKILL.md`

**Step 1: Write SKILL.md**

YAML frontmatter:
```yaml
---
name: Spec Gap Analysis
description: >
  Use when comparing spec/blueprint documents against actual implementation.
  Detects MISSING features (documented but not implemented), PARTIAL features
  (incomplete vs spec), EXTRA features (implemented but undocumented), and
  IMPLEMENTED features. Scores from 0-100. Trigger when user asks to "check
  spec vs code", "find implementation gaps", "spec drift", "blueprint review",
  or runs /blueprint-review.
version: 1.0.0
---
```

Body covers:
1. **Spec Document Detection** — where to find specs: `specs/`, `blueprints/`, `ADRs/`, `docs/`, files matching patterns `MUST|SHALL|requirements|capabilities|features|acceptance criteria`
2. **Claim Extraction** — how to extract structured claims from specs: feature descriptions, API contracts, behavioral requirements, integration points, constraints
3. **Implementation Mapping** — for each claim, how to search code (function names, class names, CLI commands, API routes, config keys)
4. **Classification System**:
   - `IMPLEMENTED` — found and matches spec intent
   - `PARTIAL` — exists but missing parts described in spec (−7 pts)
   - `MISSING` — documented claim with no implementation evidence (−15 pts)
   - `EXTRA` — implemented capability not mentioned in spec (−5 pts)
5. **Output Format** — table with Claim | Status | Evidence | File:line
6. **Scoring** — starts at 100, deducts per classification, floor 0
7. **Integration notes** — this skill is the 8th dimension, invoked by `/audit` and `/blueprint-review`

(Claude: write full SKILL.md — 120-150 lines of methodology)

**Step 2: Validate file**

```bash
wc -l /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/skills/spec-gap-analysis/SKILL.md
head -10 /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/skills/spec-gap-analysis/SKILL.md
```

Expected: >80 lines, YAML frontmatter present.

**Step 3: Commit**

```bash
cd /mnt/d/GitHub/nsalvacao-claude-code-plugins
git add plugins/solution-audit/skills/spec-gap-analysis/
git commit -m "feat(solution-audit): add spec-gap-analysis as 8th audit dimension"
```

---

### Task 8: New agent — spec-reviewer

**Files:**
- Create: `plugins/solution-audit/agents/spec-reviewer.md`

**Step 1: Write spec-reviewer.md**

YAML frontmatter:
```yaml
---
name: spec-reviewer
description: |
  Specialized agent for comparing spec/blueprint documents against actual
  implementation. Detects implementation drift, ghost features, and undocumented
  capabilities. Use when comparing a spec to code, reviewing a blueprint for
  gaps, or running /blueprint-review.

  <example>
  Context: User wants to verify implementation matches spec
  user: "Check if our implementation matches the spec in docs/spec.md"
  assistant: "I'll use the spec-reviewer agent to compare the spec against the current implementation."
  </example>
  <example>
  Context: Blueprint review session
  user: "Review this blueprint for gaps"
  assistant: "I'll use the spec-reviewer agent for spec gap analysis."
  </example>
model: inherit
color: orange
tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Skill
---
```

Body (execution protocol):
1. Read the spec/blueprint file completely before any analysis
2. Extract all claims systematically (use spec-gap-analysis skill)
3. For each claim, search code using Grep + Read — document evidence or absence
4. Classify each claim (IMPLEMENTED/PARTIAL/MISSING/EXTRA)
5. Write findings incrementally to output file (if invoked by /blueprint-review)
6. Update output file status from `[IN PROGRESS]` to `[COMPLETE]` when done
7. Include: executive summary, claim table, score, top 5 gaps by severity

(Claude: write full agent body — 80-100 lines of execution protocol)

**Step 2: Validate**

```bash
head -20 /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/agents/spec-reviewer.md
```

Expected: YAML frontmatter with name, description, model, tools.

**Step 3: Commit**

```bash
cd /mnt/d/GitHub/nsalvacao-claude-code-plugins
git add plugins/solution-audit/agents/spec-reviewer.md
git commit -m "feat(solution-audit): add spec-reviewer agent for spec-vs-implementation analysis"
```

---

### Task 9: New command — /blueprint-review

**Files:**
- Create: `plugins/solution-audit/commands/blueprint-review.md`

**Step 1: Write blueprint-review.md**

YAML frontmatter:
```yaml
---
name: blueprint-review
description: Parallel multi-agent review of a blueprint or spec document with output contracts
argument-hint: "<file-path> | --all [--output-dir=audit-reports/]"
allowed-tools:
  - Read
  - Glob
  - Task
  - Write
  - Bash
---
```

Body covers:

**Arguments:**
- `<file-path>` — specific blueprint/spec file to review
- `--all` — auto-scan `docs/`, `blueprints/`, `specs/` for spec documents
- `--output-dir` — where to write per-agent and merged output (default: `audit-reports/`)

**Behavior:**
1. Locate target file(s) — resolve argument or scan directories
2. Read the file completely (never spawn agents without reading first)
3. Create output directory: `audit-reports/` (or specified)
4. Spawn 3 agents in parallel via Task tool:
   - `spec-reviewer` → `audit-reports/YYYY-MM-DD-spec-gap.md` (spec vs implementation)
   - `coherence-analyzer` → `audit-reports/YYYY-MM-DD-feasibility.md` (technical feasibility + architecture)
   - `ux-reviewer` → `audit-reports/YYYY-MM-DD-ux-risks.md` (UX risks and workflow friction)
5. Each agent: writes `[IN PROGRESS: YYYY-MM-DD HH:MM]` header immediately, writes incrementally per section, writes `[COMPLETE]` or `[PARTIAL - interrupted]` at end
6. Wait for all 3 agents to complete (or timeout after reasonable period)
7. Read all 3 output files
8. Produce merged report: `audit-reports/YYYY-MM-DD-blueprint-review.md` containing:
   - Executive summary (2-3 paragraphs)
   - Priority-ranked issues table (cross-agent, sorted by severity)
   - Per-agent detailed sections (inline or linked)
   - Completion status for each agent
9. If any agent partial: clearly mark incomplete sections, note what's missing

**Rate-limit resilience note in command:** "If this session hits a rate limit, partial results are preserved in individual agent output files in `audit-reports/`. Run `/blueprint-review` again or read individual files directly."

**Output format** (merged report structure):
```
# Blueprint Review: [filename]
Date: YYYY-MM-DD
Agents: spec-reviewer [✓/⚠], coherence-analyzer [✓/⚠], ux-reviewer [✓/⚠]

## Executive Summary
[2-3 paragraphs synthesizing key findings across all agents]

## Priority Issues
| Priority | Issue | Dimension | Severity | Source |
|----------|-------|-----------|----------|--------|
| 1 | ... | spec-gap | CRITICAL | spec-reviewer |

## Spec Gap Analysis
[from spec-reviewer output]

## Technical Feasibility
[from coherence-analyzer output]

## UX Risk Assessment
[from ux-reviewer output]
```

(Claude: write full command body — 100-130 lines)

**Step 2: Validate**

```bash
head -15 /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/commands/blueprint-review.md
```

Expected: YAML frontmatter present with name, argument-hint, allowed-tools.

**Step 3: Commit**

```bash
cd /mnt/d/GitHub/nsalvacao-claude-code-plugins
git add plugins/solution-audit/commands/blueprint-review.md
git commit -m "feat(solution-audit): add /blueprint-review parallel multi-agent command"
```

---

### Task 10: Update audit command to include spec-gap-analysis (8th dimension)

**Files:**
- Modify: `plugins/solution-audit/commands/audit.md`

**Step 1: Read current audit.md**

```bash
cat /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/commands/audit.md
```

**Step 2: Add spec-gap-analysis as 8th dimension**

In the "Execute dimensions" step (step 3 of Behavior), add after `learnability-workflow`:
```
   - `spec-gap-analysis` — spec/blueprint vs implementation comparison (skip if no spec docs found)
```

In the Output Format scorecard table, add row:
```
| Spec Gap Analysis      | XX    | [G]   | N        | N       | N    |
```

In the README-visible description (if the command has one), update "7 dimensions" to "8 dimensions".

**Step 3: Validate edit**

```bash
grep -n "spec-gap" /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/commands/audit.md
```

Expected: 2+ matches confirming the edit landed.

**Step 4: Commit**

```bash
cd /mnt/d/GitHub/nsalvacao-claude-code-plugins
git add plugins/solution-audit/commands/audit.md
git commit -m "feat(solution-audit): include spec-gap-analysis as 8th dimension in /audit"
```

---

### Task 11: Update audit-docs to use check-links.sh and check-examples.sh

**Files:**
- Modify: `plugins/solution-audit/commands/audit-docs.md`

**Step 1: Read current audit-docs.md**

```bash
cat /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/commands/audit-docs.md
```

**Step 2: Add script invocation for --check-links and --check-examples**

In the Behavior section, replace the LLM-only link check step with:
```
5. **Link checking** (with --check-links): Run `bash $CLAUDE_PLUGIN_ROOT/scripts/check-links.sh [directory]` — parse output for BROKEN entries; supplement with LLM analysis for context
6. **Example validation** (with --check-examples): Run `bash $CLAUDE_PLUGIN_ROOT/scripts/check-examples.sh [directory]` — parse output for INVALID entries; report with file context
```

**Step 3: Validate**

```bash
grep -n "check-links\|check-examples\|CLAUDE_PLUGIN_ROOT" \
  /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/commands/audit-docs.md
```

Expected: 2+ matches.

**Step 4: Commit**

```bash
cd /mnt/d/GitHub/nsalvacao-claude-code-plugins
git add plugins/solution-audit/commands/audit-docs.md
git commit -m "feat(solution-audit): wire check-links.sh and check-examples.sh into audit-docs"
```

---

### Task 12: Update solution-auditor agent (8th dimension + WIP saving)

**Files:**
- Modify: `plugins/solution-audit/agents/solution-auditor.md`

**Step 1: Read current solution-auditor.md**

```bash
cat /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/agents/solution-auditor.md
```

**Step 2: Add two updates**

A) In the "Dimension Analysis" phase, add after learnability-workflow:
```
8. **Spec Gap Analysis** (`spec-gap-analysis` skill) — spec/blueprint vs implementation comparison (skip if no spec docs found in docs/, blueprints/, specs/)
```

B) Add a new phase after Phase 1 (Project Discovery), before Phase 2:
```
### Phase 1b: WIP File Init (for long audits)

Before starting dimension analysis, create `.solution-audit-wip.md` in the project root:
```
# Solution Audit — Work In Progress
Date: YYYY-MM-DD
Status: IN PROGRESS

## Completed Dimensions
(updated as each dimension finishes)
```
Update this file after each dimension completes. This ensures progress is preserved if the session ends early.
```

**Step 3: Validate**

```bash
grep -n "spec-gap\|WIP\|wip" \
  /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/agents/solution-auditor.md
```

Expected: 3+ matches.

**Step 4: Commit**

```bash
cd /mnt/d/GitHub/nsalvacao-claude-code-plugins
git add plugins/solution-audit/agents/solution-auditor.md
git commit -m "feat(solution-audit): add 8th dimension and WIP persistence to solution-auditor"
```

---

### Task 13: Version bump + README update

**Files:**
- Modify: `plugins/solution-audit/.claude-plugin/plugin.json`
- Modify: `plugins/solution-audit/README.md`

**Step 1: Bump version in plugin.json**

Change `"version": "0.1.0"` to `"version": "0.2.0"`.

Add keywords: `"spec-gap"`, `"blueprint-review"`, `"multi-agent"`.

**Step 2: Validate JSON**

```bash
python3 -m json.tool \
  /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/.claude-plugin/plugin.json \
  > /dev/null && echo "JSON valid"
```

**Step 3: Update README.md**

Changes:
- "7 dimensions" → "8 dimensions" in heading and table (add Spec Gap Analysis row)
- Add `/blueprint-review` to Commands table
- Add `spec-reviewer` to Agents table
- Update Scripts section listing the 4 new scripts
- Update Quick Start with `/blueprint-review` example

**Step 4: Validate README structure**

```bash
grep -n "blueprint-review\|spec-gap\|0.2.0\|8 dimensions" \
  /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/README.md
```

Expected: 4+ matches across the 4 patterns.

**Step 5: Commit**

```bash
cd /mnt/d/GitHub/nsalvacao-claude-code-plugins
git add plugins/solution-audit/.claude-plugin/plugin.json
git add plugins/solution-audit/README.md
git commit -m "chore(solution-audit): bump to v0.2.0, update README with new components"
```

---

### Task 14: Final validation

**Step 1: Verify all files exist**

```bash
echo "=== scripts ===" && ls /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/scripts/
echo "=== commands ===" && ls /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/commands/
echo "=== agents ===" && ls /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/agents/
echo "=== skills ===" && ls /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/skills/
```

Expected:
- scripts: 4 files (check-links.sh, check-examples.sh, mark-stale.sh, save-progress.sh)
- commands: 7 files (6 existing + blueprint-review.md)
- agents: 4 files (3 existing + spec-reviewer.md)
- skills: 8 directories (7 existing + spec-gap-analysis)

**Step 2: Verify all scripts are executable**

```bash
ls -la /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/scripts/
```

Expected: all .sh files have `x` bit.

**Step 3: Validate JSON files**

```bash
for f in \
  "plugins/solution-audit/.claude-plugin/plugin.json" \
  "plugins/solution-audit/hooks/hooks.json"; do
  python3 -m json.tool "/mnt/d/GitHub/nsalvacao-claude-code-plugins/$f" > /dev/null \
    && echo "OK: $f" || echo "FAIL: $f"
done
```

Expected: both `OK`.

**Step 4: Validate bash scripts syntax**

```bash
for f in /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/solution-audit/scripts/*.sh; do
  bash -n "$f" && echo "OK: $(basename $f)" || echo "FAIL: $(basename $f)"
done
```

Expected: all `OK`.

**Step 5: Check git log**

```bash
cd /mnt/d/GitHub/nsalvacao-claude-code-plugins
git log --oneline -15
```

Expected: 12-14 commits from this implementation.

**Step 6: Final commit if any uncommitted changes remain**

```bash
cd /mnt/d/GitHub/nsalvacao-claude-code-plugins
git status
```

If clean: done. If not: `git add -p` and commit remaining changes.

---

## Summary

| Task | Component | Type | Status |
|------|-----------|------|--------|
| 1 | mark-stale.sh | Script | [ ] |
| 2 | save-progress.sh | Script | [ ] |
| 3 | check-links.sh | Script | [ ] |
| 4 | check-examples.sh | Script | [ ] |
| 5 | hooks/hooks.json | Config | [ ] |
| 6 | 4× reference files | Docs | [ ] |
| 7 | spec-gap-analysis SKILL.md | Skill | [ ] |
| 8 | spec-reviewer agent | Agent | [ ] |
| 9 | blueprint-review command | Command | [ ] |
| 10 | audit.md (8th dim) | Update | [ ] |
| 11 | audit-docs.md (scripts) | Update | [ ] |
| 12 | solution-auditor.md (WIP+8th) | Update | [ ] |
| 13 | version bump + README | Chore | [ ] |
| 14 | Final validation | QA | [ ] |
