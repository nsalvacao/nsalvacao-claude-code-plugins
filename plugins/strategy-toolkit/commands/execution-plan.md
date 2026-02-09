---
name: execution-plan
description: >
  Generate a strategic execution plan with second-order thinking, risk register,
  operationalized roadmap, and growth strategy. Saves to .ideas/execution-plan.md.
  Best used after /brainstorm, but works standalone.
---

# Strategic Execution Plan

Generate a comprehensive execution plan for the current project. If a brainstorm
document exists at `.ideas/brainstorm-expansion.md`, read it first and build upon it.
Otherwise, do a quick project analysis before planning.

## Phase 1: Context Gathering (REQUIRED)

1. **Read `.ideas/brainstorm-expansion.md`** if it exists — use its tier ranking
   and strategic insights as input
2. **Read the README** and core source files to understand current state
3. **Check project maturity**: tests, CI, documentation, package publishing, community
4. **Identify gaps**: What's missing for public readiness?

## Phase 2: Second-Order Thinking (Section 1)

For each major initiative identified (from brainstorm or project analysis):

### Method
1. List 3-4 major initiatives (e.g., open standard, registry, GitHub Action, multi-format)
2. For each, trace cascading effects using this table:

| Order | Effect | Implication |
|-------|--------|-------------|

3. End each initiative analysis with: **Key insight:** [the non-obvious conclusion]

### Also analyze:
- **Failure modes by phase**: What could go wrong at each stage? Probability + mitigation.
- **Competitive responses**: If [major players] see this succeed, what do they do? How to stay ahead?
- **Timing risks**: External events that could accelerate or kill momentum.
- **Dependencies & critical path**: ASCII diagram showing what blocks what.

## Phase 3: Polish & Pre-Launch Assessment (Section 2)

Audit the project for public readiness:

### Code Quality Audit
Table with: Area | Status (PASS/PARTIAL/FAIL) | Action Needed | Priority

Check: tests, type hints, error handling, security, documentation, CI/CD,
package publishing, entry points, configuration.

**IMPORTANT: Actually READ source code files, not just list them.** Look for:
- Dead code / no-op functions
- Thread safety issues in concurrent code
- Broken configuration (wrong paths, misplaced TOML sections)
- Error messages or runtime output captured as data
- Hardcoded values that should be configurable
Report specific bugs found with file:line references.

### Documentation Gaps
Table with: Document | Exists (YES/NO) | Action

Check: README, CONTRIBUTING, CHANGELOG, architecture docs, API reference,
JSON schema/spec, guides.

### README Optimization
Evaluate for first-impression impact:
- Demo GIF/video presence
- Badges (CI, version, downloads, license)
- Problem statement clarity
- "Why use this?" comparison with alternatives
- Token cost / performance comparison (if applicable)
- Call-to-action effectiveness

### Pre-Launch Evaluation Checkpoint
**IMPORTANT:** Register that the following evaluation skills should be invoked
before any public exposure:

- **`evaluation` skill**: Score generated outputs on accuracy, completeness,
  usefulness, format quality. Score README on clarity, conversion potential,
  technical accuracy. Score CLI DX on smoothness, error messages, help text.

- **`advanced-evaluation` skill**: Cross-output consistency analysis, bias
  detection, benchmark comparison vs alternatives, edge case analysis.

Document: "Evaluation results should be documented in `.ideas/evaluation-results.md`
before launch."

## Phase 4: Expected Impacts Matrix (Section 3)

For each roadmap item, estimate in a table:

| Item | Reach | Effort (days) | Star Impact | Revenue | Moat Contribution |
|------|-------|---------------|-------------|---------|-------------------|

**Reach**: How many potential users/developers affected
**Effort**: Person-days estimate (be realistic for solo/small team)
**Star Impact**: Low / Medium / High / Critical
**Revenue**: None / Indirect / Direct
**Moat**: How much this makes the project harder to compete with

Group by phase (Phase 1, 2, 3, 4).

## Phase 5: Operationalized Roadmap (Section 4)

Transform the brainstorm roadmap into actionable tracks.

### Structure
- **4 phases** with clear timeframes (weeks/months)
- **Multiple parallel tracks** per phase (labeled A, B, C...)
- **Each track has**:
  - Numbered deliverables with acceptance criteria
  - Effort estimate in days
  - "Quick Win?" flag (Yes/No)
  - Dependencies on other tracks (explicit: "BLOCKS X")

### Phase Template
```markdown
### Phase N: [Name] ([Timeframe])

#### Track X: [Name] ([Weeks]) -- [BLOCKS Y / CAN PARALLEL WITH Z]

| # | Deliverable | Acceptance Criteria | Days | Quick Win? |
|---|-------------|-------------------|------|------------|
| X1 | [specific deliverable] | [measurable criteria] | [days] | Yes/No |

**Exit criteria:** [how to know this track is done]
```

### Phase Exit Metrics
Each phase must have measurable success metrics:
- Stars count
- Download/install count
- Community metrics (PRs, issues, contributors)
- Product metrics (plugins count, formats supported, etc.)

## Phase 6: Pre-Mortem Analysis (Section 4b — NEW)

Imagine the project has FAILED in 2 years. Apply the pre-mortem framework:

| # | Cause of Death | Category | Probability | Prevention |
|---|----------------|----------|-------------|------------|

Categories: Technical, Market, Execution, External, Community.
Minimum 8 failure scenarios. Be brutal and honest.

## Phase 7: Moat Assessment (Section 4c — NEW)

Evaluate current and buildable moats using Buffett framework:

| Moat Type | Current | Buildable? | How | Timeline |
|-----------|---------|-----------|-----|----------|
| Network Effects | [None/Weak/Medium/Strong] | [Yes/No] | [method] | [time] |
| Switching Costs | ... | ... | ... | ... |
| Brand / Trust | ... | ... | ... | ... |
| Cost Advantage | ... | ... | ... | ... |

## Phase 8: Risk Register (Section 5)

Systematic risk identification:

| # | Risk | Prob. | Impact | Mitigation |
|---|------|-------|--------|------------|

Minimum 10 risks across categories: Technical, Market, Execution, External, Community.
Include probability percentage and concrete mitigation action.

## Phase 9: Growth & Visibility Strategy (Section 6)

### Launch Channels
Table: Channel | Audience size | Timing | Expected impact | Content type

### Content Calendar
Table: Week | Content piece | Channel | Purpose
Plan first 24 weeks with specific content titles.

### Community Building
Table: Mechanism | When | Why
Progressive: Discussions → Good first issues → Contribution guide → Monthly updates → Discord (only if warranted)

### Partnership Opportunities
Table: Partner type | Targets | Pitch (one line) | Timing

### HN Title A/B Options
3 variants: Technical, Problem-focused, Analogy-based.
Identify which is likely strongest and why.

### Star Growth Model
Table: Milestone | Target date | Strategy to reach it

## Phase 10: Contrarian Challenges (Section 7 — NEW)

Challenge the plan's own assumptions:

| Assumption | Contrarian View | Prob. Wrong | Hedge |
|------------|----------------|-------------|-------|

Minimum 5 challenges. Include at least one that questions the entire premise.

## Phase 11: Save Output

1. Create `.ideas/` directory if it doesn't exist
2. Ensure `.ideas/` is in `.gitignore`
3. Save to `.ideas/execution-plan.md`

## Output Structure

```markdown
# [Project] -- Strategic Execution Plan

**Date:** [today]
**Author:** [from git config or project metadata]
**Status:** Draft v1.0

---

## Table of Contents
[numbered sections]

## 1. Second-Order Thinking & Anticipation Layer
### 1.1 Second-Order Effects by Initiative
### 1.2 Failure Modes by Phase
### 1.3 Competitive Responses
### 1.4 Timing Risks
### 1.5 Dependencies & Critical Path

## 2. Polish & Improvements Before Public Exposure
### 2.1 Code Quality Audit Checklist
### 2.2 Documentation Gaps
### 2.3 README Optimization
### 2.4 Demo/GIF/Video Needs
### 2.5 Pre-Launch Evaluation with Skills

## 3. Expected Impacts Matrix
### Phase 1-4 tables

## 4. Operationalized Roadmap
### Phase 1: Foundation
### Phase 2: Expand
### Phase 3: Platform
### Phase 4: Ecosystem

## 4b. Pre-Mortem Analysis

## 4c. Moat Assessment

## 5. Risk Register

## 6. Growth & Visibility Strategy
### 6.1 Launch Channels
### 6.2 Content Strategy
### 6.3 Community Building
### 6.4 Partnership Opportunities
### 6.5 HN Title A/B Testing
### 6.6 Star Growth Model

## 7. Contrarian Challenges

## Appendices
### A: Immediate Action Items (This Week)
### B: Key Files Reference
### C: Quantitative Analysis (token costs, performance, etc.)
```

## Quality Criteria

The output document MUST have:
- [ ] 500+ lines minimum
- [ ] Second-order effects for every major initiative
- [ ] 10+ identified risks with concrete mitigations
- [ ] 8+ pre-mortem failure scenarios
- [ ] 5+ contrarian challenges including one that questions the premise
- [ ] Moat assessment with all 4 Buffett moat types
- [ ] Operationalized roadmap with numbered deliverables and acceptance criteria
- [ ] Growth strategy with specific channels, timing, and expected outcomes
- [ ] Phase exit metrics that are measurable
- [ ] Honest assessment — flag weaknesses, don't hide them

## Important Notes

- This is a PRIVATE document. Be completely candid about weaknesses and risks.
- Effort estimates should assume solo developer (adjust if team is known).
- "Quick Win" items should genuinely be completable in <1 day.
- If no brainstorm exists, suggest running `/brainstorm` first but still produce the plan.
