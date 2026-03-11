---
name: Advanced Evaluation (LLM-as-Judge)
description: >
  This skill should be used when the user asks for "LLM-as-judge evaluation",
  "advanced quality assessment", "multi-dimensional scoring", "pairwise comparison",
  "evaluate with position bias mitigation", "judge this output against criteria",
  or when high-stakes outputs need a rigorous, multi-pass quality assessment.
  Extends the base evaluation skill with pairwise comparison, position bias mitigation,
  self-consistency checks, and calibrated confidence scoring.
version: 1.0.0
---

# Advanced Evaluation (LLM-as-Judge)

High-rigor evaluation framework using LLM-as-judge methodology. Applies systematic
bias mitigation, pairwise comparison, and multi-pass scoring to produce reliable,
calibrated quality assessments for high-stakes outputs.

## When to Use This Skill vs Basic Evaluation

Use **advanced-evaluation** when:
- Comparing two or more competing outputs (A vs B)
- The output will be used in high-stakes contexts (public launch, investor materials, policy)
- You suspect the evaluation might be influenced by order, framing, or recency bias
- You need confidence intervals, not just point scores
- You want to stress-test an output with adversarial probing

Use **evaluation** (base skill) for routine quality checks.

## Core Methodology

### 1. Direct Scoring with Rubrics

Apply the base evaluation rubric from the `evaluation` skill, but with enhanced evidence requirements:

**Evidence Quality Standard:**
- **Level 3 (Required)**: Quote specific text; explain why it's a problem; link to what "good" looks like
- **Level 2 (Acceptable)**: Specific example without full context
- **Level 1 (Insufficient)**: Generic statement ("the writing is unclear") — NEVER use this

### 2. Position Bias Mitigation

When evaluating a single output, run TWO passes:
- **Pass A**: Evaluate normally (top to bottom)
- **Pass B**: Evaluate in reverse order (bottom to top, or reframe the prompt)
- **Reconcile**: If scores differ by >0.5, investigate — bias likely; use the lower score

When comparing two outputs (A vs B):
- Score A first, then B — record scores
- Score B first, then A — record scores
- Final score = average of both orderings
- Flag if position bias > 0.5 delta on any dimension

### 3. Pairwise Comparison Protocol

When comparing N outputs:

```markdown
#### Round-Robin Comparison

| Match | Winner | Margin | Key Differentiator |
|-------|--------|--------|--------------------|
| A vs B | [A/B/tie] | [0-2] | [specific reason] |
| A vs C | [A/C/tie] | [0-2] | [specific reason] |
| B vs C | [B/C/tie] | [0-2] | [specific reason] |

**Ranking**: [1st] > [2nd] > [3rd]
**Consensus**: [High/Medium/Low — based on margin consistency]
```

### 4. Self-Consistency Check

After scoring, ask: "If I saw this output cold without knowing the context, would I give the same scores?"

Run a quick adversarial probe:
- **Steelman the output**: What's the strongest case for a HIGHER score?
- **Devil's advocate**: What's the strongest case for a LOWER score?
- **Adjust if necessary**: If either argument is compelling, revise the score with explanation

### 5. Calibration Reference

Use these anchors to calibrate your scores against known examples:

| Score | Anchor |
|-------|--------|
| 5 | Wikipedia featured article quality; textbook explanation; Paul Graham essay |
| 4 | Good Stack Overflow accepted answer; solid technical blog post |
| 3 | Average README; generic ChatGPT output; first-draft document |
| 2 | Incomplete FAQ; bullet-point notes without synthesis |
| 1 | Wrong, misleading, or incoherent |

## Advanced Scoring Dimensions

In addition to the base dimensions (Accuracy, Completeness, Usefulness, Clarity, Freshness), add:

| Dimension | Weight | Criteria |
|-----------|--------|----------|
| **Coherence** | bonus | Does the output have internal logical consistency? No contradictions? |
| **Originality** | bonus | Does it add genuine insight beyond summarizing? |
| **Calibration** | bonus | Are claims appropriately hedged vs stated with false certainty? |

These are bonus dimensions — include when relevant, skip when not applicable.

## Output Format

```markdown
## Advanced Evaluation Report

**Date**: [today]
**Output evaluated**: [name/description]
**Methodology**: LLM-as-Judge with position bias mitigation
**Passes**: [1 / 2 / N]

---

### Pass 1 Scores (Forward)

| Dimension | Score | Evidence (Level 3) | Improvement |
|-----------|-------|-------------------|-------------|
| Accuracy | [1-5] | "[exact quote]" — [why this is an issue] | [specific fix] |
| Completeness | [1-5] | "[what's missing]" | [what to add] |
| Usefulness | [1-5] | "[does it achieve goal?]" | [how to improve] |
| Clarity | [1-5] | "[structural/language issues]" | [how to clarify] |
| Freshness | [1-5] | "[stale elements]" | [what to update] |
| **Subtotal** | **[X.X/5]** | | |

### Pass 2 Scores (Reverse / Alternative Framing)

[Same table with reverse-order evaluation]

### Position Bias Check

| Dimension | Pass 1 | Pass 2 | Delta | Bias Detected? |
|-----------|--------|--------|-------|----------------|
| Accuracy | | | | Yes/No |
| ... | | | | |
| **Overall bias impact**: [High/Medium/Low/None] |

### Adversarial Probing

**Steelman (case for higher score)**: [strongest argument]
**Devil's advocate (case for lower score)**: [strongest argument]
**Conclusion**: [revised score if warranted, with reasoning]

---

### Final Calibrated Score

| Dimension | Score | Confidence |
|-----------|-------|------------|
| Accuracy | [1-5] | [High/Medium/Low] |
| Completeness | [1-5] | [H/M/L] |
| Usefulness | [1-5] | [H/M/L] |
| Clarity | [1-5] | [H/M/L] |
| Freshness | [1-5] | [H/M/L] |
| **Weighted Total** | **[X.X/5]** | |
| **Grade** | **[A/B/C/D/F]** | |

### Prioritized Improvements

**MUST FIX** (blocks use):
1. [Specific issue with Level 3 evidence] → [exact fix]

**SHOULD FIX** (significant quality gain):
2. [Issue] → [fix]

**NICE TO HAVE**:
3. [Issue] → [fix]

### Recommendation
[Clear, unambiguous recommendation with reasoning]
```

## Quality Criteria

An advanced evaluation MUST:
- [ ] Run at least 2 passes (forward + reverse or alternative framing)
- [ ] Document position bias check with explicit delta
- [ ] Include adversarial probing (steelman + devil's advocate)
- [ ] Provide Level 3 evidence for every score below 4
- [ ] State confidence levels alongside scores
- [ ] Produce a clear, actionable recommendation

## Anti-Patterns

- **Anchoring**: Letting the first impression lock in the final score — mitigated by Pass 2
- **Halo effect**: Letting one strong dimension inflate others — each dimension scored independently
- **Confirmation bias**: Looking for evidence to confirm initial impression — adversarial probing counteracts
- **False precision**: Giving 3.7/5 when evidence supports 3-4 range — use confidence levels instead
