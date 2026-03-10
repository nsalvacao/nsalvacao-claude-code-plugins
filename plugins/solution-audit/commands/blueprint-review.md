---
name: blueprint-review
description: Parallel multi-agent review of a blueprint or spec document — spawns spec-reviewer, coherence-analyzer, and ux-reviewer in parallel with explicit output contracts and rate-limit resilience
argument-hint: "<file-path> | --all [--output-dir=audit-reports/]"
allowed-tools:
  - Read
  - Glob
  - Task
  - Write
  - Bash
---

# Blueprint Review

Run a parallel multi-agent review of a blueprint, spec, or design document. Three specialized agents analyze different risk dimensions simultaneously and their findings are merged into a single consolidated report.

## Arguments

- `<file-path>` — path to a specific blueprint, spec, or design document to review
- `--all` — auto-scan `docs/`, `blueprints/`, `specs/` for spec documents (matches `*-spec.md`, `*-blueprint.md`, `*-requirements.md`, `*-design.md`, `ADR-*.md`)
- `--output-dir=<path>` — directory for output files (default: `audit-reports/`)

When `--all` is used with multiple files found, run a separate `/blueprint-review` pass for each file and produce one consolidated summary.

## Pre-flight (REQUIRED — complete before spawning any agent)

1. **Locate and read the target file(s) completely** — use Read on the specified path. If `--all`, use Glob to find candidates and read each one.
2. **Confirm reviewable content** — verify the file contains spec claims, feature descriptions, or design decisions. If the file is empty or contains only boilerplate, abort with a clear message.
3. **Establish date and output paths** — get current date in YYYY-MM-DD format. Construct output file paths:
   - `[output-dir]/YYYY-MM-DD-spec-gap.md`
   - `[output-dir]/YYYY-MM-DD-feasibility.md`
   - `[output-dir]/YYYY-MM-DD-ux-risks.md`
   - `[output-dir]/YYYY-MM-DD-blueprint-review.md` (merged report)
4. **Create the output directory** — run `mkdir -p [output-dir]` before spawning agents.
5. **Confirm to the user** — print the output paths and state that 3 agents are about to be spawned in parallel.

## Spawning parallel agents

Use the Task tool to spawn all 3 agents simultaneously. Pass each agent its full context — do not assume agents share state.

**Agent 1 — spec-reviewer:**
```
Task: "You are acting as spec-reviewer for /blueprint-review.

Spec file to analyze: [file-path]
Output file: [output-dir]/YYYY-MM-DD-spec-gap.md

Instructions:
1. Write '[IN PROGRESS: YYYY-MM-DD HH:MM]' header to the output file immediately.
2. Read [file-path] completely before any analysis.
3. Extract all claims from the spec (features, APIs, behaviors, integrations, config, constraints).
4. For each claim, search the codebase for implementation evidence (minimum 3 keyword variants per claim).
5. Classify each claim: IMPLEMENTED / PARTIAL / MISSING / EXTRA.
6. Write findings incrementally to the output file after each batch of 10 claims.
7. Generate the full spec-gap-analysis report and score.
8. Update status to '[COMPLETE: YYYY-MM-DD HH:MM]' or '[PARTIAL - interrupted: YYYY-MM-DD HH:MM]' at the end."
```

**Agent 2 — coherence-analyzer:**
```
Task: "You are acting as coherence-analyzer for /blueprint-review.

Blueprint file to analyze: [file-path]
Output file: [output-dir]/YYYY-MM-DD-feasibility.md

Instructions:
1. Write '[IN PROGRESS: YYYY-MM-DD HH:MM]' header to the output file immediately.
2. Read [file-path] completely before any analysis.
3. Assess technical feasibility and architectural coherence of the blueprint:
   - Is the proposed architecture internally consistent?
   - Are there dependency conflicts or circular dependencies in the proposed design?
   - Does the blueprint align with existing codebase patterns and conventions?
   - What are the main technical risks and unknowns?
   - Are there missing integration details or underspecified components?
4. Write findings incrementally to the output file after each section.
5. Produce a structured feasibility assessment with severity-classified findings.
6. Update status to '[COMPLETE: YYYY-MM-DD HH:MM]' or '[PARTIAL - interrupted: YYYY-MM-DD HH:MM]' at the end."
```

**Agent 3 — ux-reviewer:**
```
Task: "You are acting as ux-reviewer for /blueprint-review.

Blueprint file to analyze: [file-path]
Output file: [output-dir]/YYYY-MM-DD-ux-risks.md

Instructions:
1. Write '[IN PROGRESS: YYYY-MM-DD HH:MM]' header to the output file immediately.
2. Read [file-path] completely before any analysis.
3. Assess UX risks in the blueprint:
   - Does the proposed UX align with existing interaction patterns in the codebase?
   - Are there learnability risks — new concepts that break the existing mental model?
   - Are there workflow friction risks — steps that are unnecessarily complex or multi-stage?
   - Are error cases and edge cases considered in the design?
   - What is the onboarding impact of the new features on existing users?
   - Are there naming or terminology inconsistencies with the existing product?
4. Write findings incrementally to the output file after each section.
5. Produce a structured UX risk assessment with severity-classified findings.
6. Update status to '[COMPLETE: YYYY-MM-DD HH:MM]' or '[PARTIAL - interrupted: YYYY-MM-DD HH:MM]' at the end."
```

## Waiting and merging

After all 3 agents complete (or are interrupted by a timeout or rate limit):

1. **Read all 3 output files** — use Read on each path
2. **Check status of each:**
   - `[COMPLETE]` — full results available (mark ✓)
   - `[PARTIAL - interrupted]` — partial results available (mark ⚠)
   - File missing or empty — agent did not run (mark ✗)
3. **Create the merged report** — use the Write tool to create `[output-dir]/YYYY-MM-DD-blueprint-review.md` with the full merged content

## Merged report format

```markdown
# Blueprint Review: [filename]

Date: YYYY-MM-DD
File: [file-path]
Agents: spec-reviewer [✓/⚠/✗], coherence-analyzer [✓/⚠/✗], ux-reviewer [✓/⚠/✗]
(✓ = complete, ⚠ = partial, ✗ = not run)

## Executive Summary

[2-3 paragraphs synthesizing the most important findings across all agents.
Lead with the overall risk level. Highlight the top 2-3 issues that need
attention before this blueprint is ready to implement.]

## Priority Issues

| Priority | Issue | Dimension | Severity | Agent |
|----------|-------|-----------|----------|-------|
| 1 | [issue description] | Spec Gap | CRITICAL | spec-reviewer |
| 2 | [issue description] | Feasibility | HIGH | coherence-analyzer |
| 3 | [issue description] | UX Risk | MEDIUM | ux-reviewer |

## Spec Gap Analysis

[Full content from YYYY-MM-DD-spec-gap.md]

## Technical Feasibility

[Full content from YYYY-MM-DD-feasibility.md]

## UX Risk Assessment

[Full content from YYYY-MM-DD-ux-risks.md]

---

*Generated by /blueprint-review*
*Individual agent outputs: [output-dir]/YYYY-MM-DD-spec-gap.md, [output-dir]/YYYY-MM-DD-feasibility.md, [output-dir]/YYYY-MM-DD-ux-risks.md*
```

When assembling Priority Issues, draw from all three agents and rank by severity. Use judgment to de-duplicate issues raised by multiple agents — list once with a note if multiple agents flagged it.

## Rate-limit resilience

If this session hits a rate limit during agent execution:
- Partial results are preserved in the individual output files in `[output-dir]/`
- The merged report may be incomplete or absent
- To resume: re-run `/blueprint-review [file-path] --output-dir=[output-dir]`
- To read partial results directly: `Read [output-dir]/YYYY-MM-DD-spec-gap.md` etc.

Individual output files are the source of truth — the merged report is derived from them. If the merged report is missing but individual files exist, the work is not lost.

## Tips

- Use `--output-dir=` to keep blueprint reviews organized alongside the project (e.g., `--output-dir=docs/reviews/`)
- If only one dimension is needed, invoke the individual agent directly instead: use spec-reviewer for spec-only analysis, coherence-analyzer for architecture review
- For iterative blueprint development, re-run after each major revision to track improvement
- Add `audit-reports/` (or your chosen output dir) to `.gitignore` if you do not want to commit review artifacts
