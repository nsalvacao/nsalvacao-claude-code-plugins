# solution-audit v0.2.0 — Elevation Design

**Date:** 2026-03-10
**Author:** Nuno Salvação
**Status:** Approved
**Scope:** Domain elevation of solution-audit plugin — new components, executable scripts, automation hooks

---

## Context

The solution-audit plugin is conceptually mature (7 audit dimensions, 6 commands, 3 agents) but has zero executable code — all logic lives in agent descriptions. Key workflows used repeatedly in practice are not automated:
- Multi-agent parallel blueprint/spec review with output contracts
- Spec-vs-implementation gap detection (missing as a dimension)
- Progress saving during long analysis sessions (rate-limit resilience)
- Hooks that react to file changes (stale audit signaling)

This design elevates v0.1.0 to v0.2.0 with production-ready automation.

---

## New Components

### 1. Command: `/blueprint-review`

**File:** `commands/blueprint-review.md`

**Purpose:** Orchestrates parallel multi-agent review of a blueprint or spec document with explicit output contracts per agent and rate-limit resilience.

**Usage:**
```
/blueprint-review docs/blueprint.md
/blueprint-review --all        # scans docs/, blueprints/, specs/
```

**Behavior:**
1. Locates target file(s) — argument or auto-scan of `docs/`, `blueprints/`, `specs/`
2. Reads the file before spawning any agent
3. Spawns 3 parallel agents via Task tool, each with explicit output file:
   - `spec-reviewer` → `audit-reports/YYYY-MM-DD-spec-gap.md`
   - `coherence-analyzer` → `audit-reports/YYYY-MM-DD-feasibility.md`
   - `ux-reviewer` → `audit-reports/YYYY-MM-DD-ux-risks.md`
4. Each agent writes **incrementally** (per section, not at end) for rate-limit resilience
5. Each agent writes `[IN PROGRESS]` header at start, `[COMPLETE]` or `[PARTIAL - rate limited]` at end
6. Coordinator merges into `audit-reports/YYYY-MM-DD-blueprint-review.md` with:
   - Executive summary
   - Priority-ranked issues table (cross-agent)
   - Per-agent detailed sections
   - Clearly marks any incomplete sections

**Rate-limit resilience:** Partial results preserved in individual files even if coordinator never runs.

---

### 2. Skill: `spec-gap-analysis`

**Files:** `skills/spec-gap-analysis/SKILL.md`

**Purpose:** 8th audit dimension — structured comparison of spec/blueprint documents against actual implementation.

**Methodology:**
1. Detect spec documents: scan `specs/`, `blueprints/`, `ADRs/`, `docs/` for files containing "MUST", "SHALL", "requirements", "capabilities", "features"
2. Extract **claims**: features, APIs, behaviors, constraints, integrations
3. Map each claim against real code (Grep + Read)
4. Classify each claim:
   - `IMPLEMENTED` — present and functional
   - `PARTIAL` — exists but incomplete vs. spec
   - `MISSING` — documented, not implemented (ghost feature) → **−15 pts**
   - `EXTRA` — implemented, not documented (invisible feature) → **−5 pts**
   - `PARTIAL` → **−7 pts**
5. Score: starts at 100, subtracts per finding (floor: 0)

**Integrations:** Invoked by `/blueprint-review`, `/audit`, and directly via `/audit spec-gap`.

---

### 3. Agent: `spec-reviewer`

**File:** `agents/spec-reviewer.md`

**Purpose:** Specialized agent for spec-vs-implementation comparison. Deep expertise in detecting drift between documented promises and actual code.

**Trigger phrases:** "review this spec", "check spec against code", "find gaps in implementation", "spec drift"

**Used by:** `/blueprint-review` (as one of 3 parallel agents), also standalone.

**Tools:** Read, Grep, Glob, Bash, Skill

---

### 4. Scripts (new `scripts/` directory)

#### `scripts/check-links.sh`
- Internal links: grep-based extraction + file existence check
- External links: `curl --head --silent --max-time 5` per URL
- Output: list of broken links with `file:line`
- Invoked by `audit-docs --check-links` (replaces LLM-only approach)
- ~80 lines bash

#### `scripts/check-examples.sh`
- Extracts code blocks from markdown (```python, ```bash, etc.)
- bash blocks: `bash -n` (syntax check)
- python blocks: `python3 -c "compile(...)"`
- Output: list of invalid examples with context
- ~60 lines bash

#### `scripts/mark-stale.sh`
- Reads edited file path from stdin (tool_input.file_path)
- Maps to affected audit dimensions:
  - `README.md` → product-coherence, documentation-quality
  - `docs/**` → documentation-quality
  - `src/**`, `lib/**` → architecture-coherence, product-coherence
  - `CONTRIBUTING.md`, `INSTALL.md` → onboarding-quality
- Updates `.solution-audit-latest.json` with `"stale": [dimension-names]`
- ~40 lines bash

#### `scripts/save-progress.sh`
- Checks if `.solution-audit-wip.md` exists
- Appends footer: `[SESSION ENDED: YYYY-MM-DD HH:MM]`
- ~30 lines bash

---

### 5. Hooks (improved `hooks/hooks.json`)

#### SessionStart (improved)
Current: shows top 3 pending findings.
New: shows pending findings + stale dimensions + WIP indicator.

```
Solution Audit: [N] pending findings — top: [...]
Stale dimensions: product-coherence, documentation-quality (files changed since last audit)
⚠ WIP in progress: audit-reports/2026-03-09-blueprint-review.md [PARTIAL]
```

#### PostToolUse: Write|Edit → mark stale
```json
{
  "matcher": "Write|Edit",
  "hooks": [{
    "type": "command",
    "command": "bash $CLAUDE_PLUGIN_ROOT/scripts/mark-stale.sh",
    "timeout": 10
  }]
}
```

#### Stop → save WIP
```json
{
  "hooks": [{
    "type": "command",
    "command": "bash $CLAUDE_PLUGIN_ROOT/scripts/save-progress.sh",
    "timeout": 10
  }]
}
```

---

### 6. Reference Files (4 skills missing them)

| Skill | File | Content |
|-------|------|---------|
| `onboarding-quality` | `references/assessment-criteria.md` | Steps-to-first-success rubrics, cognitive load taxonomy, prerequisite clarity patterns |
| `cli-ux` | `references/ergonomics-patterns.md` | Good/bad flag patterns, help format standards, error message design, POSIX conventions |
| `textual-ux` | `references/tone-patterns.md` | Tone consistency taxonomy, jargon detection patterns, error message anatomy |
| `learnability-workflow` | `references/friction-patterns.md` | Friction taxonomy, progressive disclosure patterns, escape hatch design |

---

## Files Changed

```
solution-audit/
├── .claude-plugin/
│   └── plugin.json                          [UPDATE: version 0.1.0 → 0.2.0]
├── commands/
│   └── blueprint-review.md                  [NEW]
├── agents/
│   └── spec-reviewer.md                     [NEW]
├── skills/
│   ├── spec-gap-analysis/
│   │   └── SKILL.md                         [NEW]
│   ├── onboarding-quality/
│   │   └── references/
│   │       └── assessment-criteria.md       [NEW]
│   ├── cli-ux/
│   │   └── references/
│   │       └── ergonomics-patterns.md       [NEW]
│   ├── textual-ux/
│   │   └── references/
│   │       └── tone-patterns.md             [NEW]
│   └── learnability-workflow/
│       └── references/
│           └── friction-patterns.md         [NEW]
├── hooks/
│   └── hooks.json                           [UPDATE: add PostToolUse + Stop, improve SessionStart]
└── scripts/                                 [NEW DIRECTORY]
    ├── check-links.sh                       [NEW]
    ├── check-examples.sh                    [NEW]
    ├── mark-stale.sh                        [NEW]
    └── save-progress.sh                     [NEW]
```

**Total:** 2 new components (command + agent), 1 new skill, 4 new reference files, 4 new scripts, 2 new hooks, 3 updated files.

---

## Version

`0.1.0 → 0.2.0` — minor version bump (additive, non-breaking)
