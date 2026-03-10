---
name: Spec Gap Analysis
description: >
  Use when comparing spec, blueprint, or requirements documents against actual
  implementation. Detects MISSING features (documented but not implemented),
  PARTIAL features (incomplete vs spec), EXTRA features (implemented but
  undocumented), and IMPLEMENTED features. Scores 0-100. Invoke when the user
  asks to "check spec vs code", "find implementation gaps", "spec drift",
  "blueprint review", or runs /blueprint-review. Also invoked as the 8th
  dimension by /audit when spec documents are found.
version: 1.0.0
---

# Spec Gap Analysis

Compare spec, blueprint, or requirements documents against actual implementation to detect drift between what was planned and what exists.

## 1. Spec Document Detection

Before any analysis, locate spec documents in the project.

**Search directories (in priority order):**
- `specs/` — dedicated specifications directory
- `blueprints/` — blueprint documents
- `ADRs/` or `adr/` — Architecture Decision Records
- `docs/` — general documentation directory
- Project root — top-level spec files

**Filename patterns to match:**
- `*-spec.md`, `*-specification.md`
- `*-blueprint.md`
- `*-requirements.md`, `*-requirements.txt`
- `*-design.md`, `*-design-doc.md`
- `ADR-*.md`, `adr-*.md`
- `SPEC.md`, `BLUEPRINT.md`, `REQUIREMENTS.md`

**Content signals (grep for these strings):**
- `MUST`, `SHALL`, `SHOULD` — RFC-style requirement language
- `requirements:`, `acceptance criteria:` — structured requirement blocks
- `capabilities:`, `features:` — feature list declarations
- `## Features`, `## Requirements`, `## Capabilities` — section headings
- Numbered lists of capabilities (e.g., `1. The system shall...`)

**If no spec documents found:**
Skip this dimension entirely. Log: "No spec documents found — skipping spec-gap-analysis". This is not an error — many projects do not maintain formal specs.

## 2. Claim Extraction

Parse each spec document and extract structured claims. Every checkable assertion about what the system does, supports, or provides is a claim.

**Feature claims** — statements about supported behaviors or capabilities:
- `"The system SHALL/MUST support X"`
- `"Feature: X"` headers or bullets
- Numbered capability lists: `1. Users can...`, `2. The CLI supports...`
- Acceptance criteria: `Given/When/Then` patterns

**API contracts** — precise interface definitions:
- Endpoint definitions: `GET /api/v1/users`, `POST /upload`
- Function signatures or method names with documented parameters
- CLI commands: `mycli init`, `mycli audit --flag`
- Event names, message types, or hook names

**Behavioral requirements** — conditional behavior specifications:
- `"When X happens, Y shall occur"`
- Error handling promises: `"Shall return 404 if not found"`
- State machine transitions: `"After step A, the system moves to state B"`

**Integration points** — external dependencies declared in spec:
- `"integrates with GitHub"`, `"connects to PostgreSQL"`
- `"supports OAuth 2.0"`, `"compatible with Docker"`

**Configuration options** — documented config keys and environment variables:
- Explicit key names: `DATABASE_URL`, `config.timeout`, `--max-retries`
- Config file formats: `"accepts YAML config at .myapp.yml"`

**Constraints** — limits and non-functional requirements:
- Performance: `"SHALL respond in under 200ms"`
- Compatibility: `"supports Python 3.9+"`
- Limits: `"maximum 100 items per request"`

**Output:** A numbered list of claims with type labels. Example:
```
1. [Feature]     CLI supports `audit` command with --dimensions flag
2. [API]         GET /health endpoint returns 200 with status object
3. [Behavioral]  Invalid config causes exit code 1 with error message
4. [Integration] Connects to GitHub API via token authentication
5. [Config]      DATABASE_URL environment variable is required
6. [Constraint]  Processes files up to 50MB
```

## 3. Implementation Search

For each extracted claim, search for implementation evidence. A grep match alone is not sufficient — always verify context.

**CLI commands:**
1. Grep for the command string in argument parser files (`argparse`, `click`, `commander.js`, `cobra`, `clap`)
2. Check `--help` output by running the CLI if possible
3. Verify the handler/action function exists and is non-trivial

**API endpoints:**
1. Grep for route definitions: `app.get(`, `router.post(`, `@app.route(`, `router.add_api_route(`, `http.HandleFunc(`
2. Match the path string exactly: `"/api/v1/users"` or a parametric equivalent
3. Read the handler to confirm it does what the spec describes

**Features and functions:**
1. Derive 2-3 keyword variants from the feature name (e.g., "user authentication" → `authenticate`, `login`, `auth`)
2. Grep for each variant across source directories
3. Read surrounding code to confirm it implements the claimed behavior — not just shares a name

**Config keys and environment variables:**
1. Grep for the exact key string in config loading code (`os.environ`, `process.env`, `config.get(`, `viper.Get(`)
2. Verify the key is actually consumed, not just referenced in a comment

**Integration points:**
1. Grep for the integration library name (e.g., `github`, `boto3`, `psycopg2`)
2. Check `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml` for the dependency
3. Confirm it is used in production code, not just in tests

**Behavioral requirements:**
1. Find the code path that triggers when condition X occurs
2. Trace to verify outcome Y is produced
3. Check error handling and exit codes explicitly

**Evidence record:** For each claim, note:
- Search terms used
- Files searched
- Match found (file:line) or "no matches"
- Whether context confirms the claim

## 4. Classification System

Classify each claim after verification:

**IMPLEMENTED** — 0 points deducted
Claim is fully verified in code. Implementation matches the spec description in all key aspects. Evidence is concrete (file:line reference with context confirming behavior).

**PARTIAL** — 7 points deducted
Implementation exists but is incomplete relative to the spec. Examples: endpoint exists but ignores documented query parameters; CLI command exists but undocumented flags are absent; feature works for the happy path but error handling described in spec is missing.

**MISSING** — 15 points deducted
No implementation evidence found despite searching with multiple keyword variants. This is a "ghost feature" — documented but not built. Must have searched at least 3 keyword variants before classifying as MISSING.

**EXTRA** — 5 points deducted
Significant capability found in code with no corresponding spec documentation. These are "invisible features" — implemented but undocumented. Only flag capabilities with user-visible impact (exported functions, CLI commands, API endpoints, config options). Do not flag internal helpers.

**Scoring:**
- Start at 100
- Subtract per finding: MISSING (-15), PARTIAL (-7), EXTRA (-5)
- Floor at 0
- IMPLEMENTED findings do not affect score

**Grade thresholds:**
- 90-100: Outstanding — spec and implementation are tightly aligned
- 80-89: Good — minor gaps, addressable
- 65-79: Needs Attention — significant drift present
- 50-64: Poor — substantial features missing or undocumented
- 0-49: Critical — spec and implementation are severely misaligned

## 5. Output Format

```
Spec Gap Analysis: [spec file name]
Score: XX/100 [Grade]

Claims assessed: N
  IMPLEMENTED: N
  PARTIAL: N
  MISSING: N (ghost features)
  EXTRA: N (invisible features)

| # | Claim | Type | Status | Evidence / Gap |
|---|-------|------|--------|----------------|
| 1 | CLI supports `audit --dimensions` flag | Feature | IMPLEMENTED | src/cli.py:42 — argument registered, handler confirmed |
| 2 | GET /health returns status object | API | MISSING | Searched: "health", "/health", "healthcheck" in src/ — no route definitions found |
| 3 | DATABASE_URL env var required | Config | PARTIAL | src/config.py:18 reads DATABASE_URL but no validation or error on missing value |
| 4 | (undocumented) --verbose flag | Feature | EXTRA | src/cli.py:67 — verbose flag implemented, no mention in spec |

Top gaps (MISSING + PARTIAL):
  1. [MISSING] GET /health endpoint — searched "health", "/health", "healthcheck" in src/, routes/, app/ — no matches
  2. [PARTIAL] DATABASE_URL validation — found at src/config.py:18, key is read but missing-value error not implemented per spec

Invisible features (EXTRA — consider documenting):
  1. --verbose flag — found at src/cli.py:67
```

When multiple spec files are present, output one block per file, then an aggregated summary:
```
Spec Gap Analysis: AGGREGATE
Files analyzed: N
Combined score: XX/100

| File | Score | Missing | Partial | Extra |
|------|-------|---------|---------|-------|
| specs/api-spec.md | 72 | 3 | 1 | 0 |
| blueprints/v2-blueprint.md | 88 | 1 | 0 | 2 |
```

## 6. Integration Notes

**As the 8th dimension in `/audit`:**
- Run after `learnability-workflow` (7th dimension)
- Only run if spec documents are detected — skip silently if none found
- Log "No spec documents found — skipping spec-gap-analysis" in the scorecard as N/A
- Score contributes to OVERALL score only if run (not penalized if skipped)

**In `/blueprint-review`:**
- spec-reviewer agent applies this skill as its core methodology
- Operates on a single specified file, not auto-detection
- Writes output incrementally to the designated output file

**Multiple spec files:**
- Analyze each file independently
- Produce per-file tables
- Aggregate into a combined score (average of per-file scores)
- Cross-reference: if claim appears in multiple spec files, count once
