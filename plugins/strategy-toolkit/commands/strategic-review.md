---
name: strategic-review
description: >
  Pre-launch quality evaluation and improvement recommendations.
  Uses evaluation frameworks to systematically score and improve project outputs
  before public exposure. Saves to .ideas/evaluation-results.md.
---

# Strategic Review (Pre-Launch Evaluation)

Systematic quality evaluation before public exposure. This command should be run
AFTER the project is functionally complete but BEFORE any public launch
(HN, Reddit, blog posts, Product Hunt, etc.).

## Purpose

Prevent embarrassing quality gaps from undermining a strong project. A single
broken demo, unclear README, or poor-quality generated output can kill launch
momentum permanently.

## Phase 1: Load Context

1. **Read `.ideas/brainstorm-expansion.md`** if it exists — understand strategic goals
2. **Read `.ideas/execution-plan.md`** if it exists — understand quality audit findings
3. **Read README.md** — evaluate first-impression quality
4. **Read core outputs** — whatever the project generates, evaluate the output quality
5. **Run tests** if a test suite exists — verify everything passes

## Phase 2: Output Quality Evaluation

Score every generated/public output on these dimensions:

### Evaluation Rubric (apply to each output)

| Dimension | Score (1-5) | Weight | Criteria |
|-----------|-------------|--------|----------|
| **Accuracy** | | 25% | Does the output correctly represent reality? No hallucinations, wrong data, or stale info? |
| **Completeness** | | 20% | Does it cover all cases? What percentage of the domain is captured? |
| **Usefulness** | | 25% | Does it actually help the user accomplish their goal better than alternatives? |
| **Format Quality** | | 15% | Is it well-structured, consistent, readable, properly formatted? |
| **Freshness** | | 15% | Is the data current? Are there stale references or outdated information? |

### Scoring Guide
- **5**: Exceptional — better than hand-crafted alternatives
- **4**: Good — minor gaps, clearly useful
- **3**: Adequate — functional but could be better
- **2**: Below average — notable gaps or issues
- **1**: Poor — needs significant rework

### For each output, document:
```markdown
#### [Output Name]
| Dimension | Score | Evidence |
|-----------|-------|----------|
| Accuracy | [1-5] | [specific examples] |
| Completeness | [1-5] | [what's missing] |
| Usefulness | [1-5] | [compared to what alternative?] |
| Format Quality | [1-5] | [specific issues] |
| Freshness | [1-5] | [stale items found] |
| **Weighted Total** | **[/5]** | |

**Top 3 improvements needed:**
1. [specific, actionable improvement]
2. [specific, actionable improvement]
3. [specific, actionable improvement]
```

## Phase 3: Cross-Output Consistency

If the project generates multiple outputs (e.g., plugins for different CLIs):

1. **Variance analysis**: Score all outputs, identify highest and lowest quality
2. **Systematic bias**: Does the system favor certain input types over others?
3. **Edge cases**: What happens with unusual inputs (very large, very small, empty, exotic)?

### Output Format
```markdown
### Cross-Output Consistency

| Output | Accuracy | Completeness | Usefulness | Format | Freshness | Total |
|--------|----------|-------------|------------|--------|-----------|-------|
| [output 1] | [score] | ... | ... | ... | ... | [weighted] |
| [output 2] | [score] | ... | ... | ... | ... | [weighted] |
| ...

**Best**: [which and why]
**Worst**: [which and why]
**Systematic bias**: [if any detected]
**Edge case gaps**: [if any found]
```

## Phase 4: README Conversion Audit

The README is the #1 conversion surface. Evaluate:

| Element | Present? | Score (1-5) | Notes |
|---------|----------|-------------|-------|
| **Hook/tagline** | Yes/No | | Does it grab attention in 5 seconds? |
| **Problem statement** | Yes/No | | Is the pain point immediately clear? |
| **Solution** | Yes/No | | Is the value prop obvious? |
| **Demo GIF/video** | Yes/No | | Does it show the magic in <30 seconds? |
| **Badges** | Yes/No | | License, CI, version, downloads, language |
| **Quick start** (< 3 commands) | Yes/No | | Can someone try it in 60 seconds? |
| **Comparison with alternatives** | Yes/No | | Why this over existing solutions? |
| **Stats/proof** | Yes/No | | Numbers that prove it works |
| **Installation** | Yes/No | | Clear, copy-pasteable |
| **Examples** | Yes/No | | Real-world use cases |
| **Architecture** | Yes/No | | For those who want to understand internals |
| **Contributing guide** | Yes/No | | Path for community involvement |
| **License** | Yes/No | | Clear and visible |
| **Author/credits** | Yes/No | | Who built this |

### README Score Card
- **Elements present**: [X/14]
- **Average quality**: [X/5]
- **Estimated visitor→star conversion**: [X%] (industry avg: 2-3%)
- **Top 3 improvements for conversion:**
  1. [specific improvement]
  2. [specific improvement]
  3. [specific improvement]

## Phase 5: DX (Developer Experience) Audit

Test the actual user journey. **Actually run commands, don't just describe them.**

### Installation Flow
1. Can a new user install in <60 seconds? **Try it: run pip install or the documented method.**
2. Are there hidden dependencies? **Check pyproject.toml/requirements for completeness.**
3. Do error messages guide toward resolution? **Run with bad input and check stderr.**
4. Does `--help` work and make sense? **Run it.**
5. Does `--version` work? **Run it.**

### First-Use Flow
1. Can a new user get value in <5 minutes?
2. Is there a "hello world" example?
3. Are common mistakes handled gracefully?
4. Is output clear and well-formatted?

### Score
| Dimension | Score (1-5) | Issues Found |
|-----------|-------------|--------------|
| Installation ease | | |
| Time to first value | | |
| Error handling quality | | |
| Help text quality | | |
| Output quality | | |

## Phase 5b: Code Quality Spot-Check

Read 3-5 core source files and look for actual bugs:
- Dead code / no-op functions
- Thread safety issues
- Broken configuration (TOML/JSON/YAML syntax, wrong paths)
- Runtime output captured as data (error messages as descriptions, warnings as content)
- Hardcoded values that should be configurable

Report findings with specific file:line references. This is NOT a full audit — it's a
spot-check to catch the most embarrassing issues before a public audience sees the code.

## Phase 6: Security & Trust Audit

Before public launch, verify:

| Check | Status | Notes |
|-------|--------|-------|
| No hardcoded secrets in repo | PASS/FAIL | |
| Subprocess execution is safe | PASS/FAIL | Check for command injection vectors |
| Dependencies are minimal/audited | PASS/FAIL | |
| License is clear | PASS/FAIL | |
| Author attribution is correct | PASS/FAIL | |
| No accidental PII in outputs | PASS/FAIL | |
| .gitignore covers sensitive files | PASS/FAIL | |

## Phase 7: Competitive Positioning Check

Quick validation that the project's positioning holds up:

1. **Search for competitors**: Search GitHub, Google, and HN for similar projects
   launched in the last 6 months
2. **Feature comparison**: Does the project still have unique advantages?
3. **Messaging check**: Is the positioning still accurate and differentiated?
4. **Timing check**: Is this the right moment to launch? Any upcoming events
   (conferences, product launches) that could amplify or compete?

## Phase 8: Launch Readiness Scorecard

### Final Go/No-Go Assessment

| Category | Score (1-5) | Weight | Weighted |
|----------|-------------|--------|----------|
| Output quality | | 25% | |
| README/docs quality | | 20% | |
| Developer experience | | 20% | |
| Security/trust | | 15% | |
| Competitive positioning | | 10% | |
| Test coverage | | 10% | |
| **TOTAL** | | | **[/5]** |

### Decision Matrix
- **4.0+**: GREEN — Launch confidently
- **3.0-3.9**: YELLOW — Launch with noted improvements planned
- **2.0-2.9**: RED — Fix critical issues before launching
- **<2.0**: STOP — Not ready for public exposure

### Action Items Before Launch
Numbered list of specific, prioritized improvements.
Flag any that are BLOCKERS (must fix) vs NICE-TO-HAVE (fix if time).

## Phase 9: Save Output

1. Save to `.ideas/evaluation-results.md`
2. If overall score is YELLOW or RED, create `.ideas/launch-blockers.md` with
   just the blocking items

## Output Structure

```markdown
# [Project] -- Strategic Review (Pre-Launch Evaluation)

**Date:** [today]
**Overall Score:** [X/5] — [GREEN/YELLOW/RED]
**Recommendation:** [Launch / Fix then launch / Not ready]

---

## 1. Output Quality Evaluation
[per-output scoring tables]

## 2. Cross-Output Consistency
[variance analysis]

## 3. README Conversion Audit
[element checklist + score card]

## 4. Developer Experience Audit
[installation + first-use flow]

## 5. Security & Trust Audit
[checklist]

## 6. Competitive Positioning
[search results + comparison]

## 7. Launch Readiness Scorecard
[go/no-go table + decision]

## 8. Action Items
### Blockers (MUST fix)
[numbered list]

### Improvements (SHOULD fix)
[numbered list]

### Nice-to-Have (CAN fix)
[numbered list]
```

## Quality Criteria

The output document MUST:
- [ ] Score every public output individually (not just overall)
- [ ] Include specific evidence for each score (not just numbers)
- [ ] Provide actionable improvements (not vague "make it better")
- [ ] Include competitive search results (what actually exists today)
- [ ] Have a clear GO/NO-GO recommendation
- [ ] Separate BLOCKER vs NICE-TO-HAVE improvements
- [ ] Be brutally honest — this is a private document

## Important Notes

- This review should find problems. If everything scores 5/5, the review
  wasn't thorough enough. No project is perfect.
- Focus on what a FIRST-TIME VISITOR sees. You already know the project;
  they don't. Evaluate through fresh eyes.
- The goal is not to delay launch indefinitely. It's to fix the 3-5 things
  that would undermine an otherwise strong launch.
- If the project genuinely isn't ready, say so. Better to delay than to
  waste a HN front-page opportunity on a half-baked demo.
