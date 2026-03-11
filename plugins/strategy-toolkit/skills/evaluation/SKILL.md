---
name: Evaluation
description: >
  This skill should be used when the user asks to "evaluate this output", "score this
  document", "assess quality", "rate this against criteria", "give me a structured
  evaluation", "check this before I share it", or when any output needs systematic
  quality assessment before use or publication.
  Provides a structured rubric-based evaluation framework applicable to any output type:
  documents, plans, code outputs, strategic analyses, research summaries, or pitches.
version: 1.0.0
---

# Evaluation Framework

Structured, rubric-based evaluation for any output before it's used, shared, or published.
Produces reproducible quality assessments with specific evidence and actionable improvements.

## When to Use This Skill

Apply evaluation when:
- Any document or output is about to be shared externally
- Comparing two versions or approaches
- Reviewing AI-generated content for quality before use
- Doing a systematic pre-launch check
- Auditing existing documents for gaps

## Core Evaluation Dimensions

### Universal Rubric (applies to any output type)

| Dimension | Weight | Criteria |
|-----------|--------|----------|
| **Accuracy** | 25% | Is the content factually correct? No hallucinations, outdated data, or false claims? |
| **Completeness** | 20% | Does it cover all necessary areas? What's missing? |
| **Usefulness** | 25% | Does it achieve its stated purpose? Better than alternatives? |
| **Clarity** | 15% | Is it readable, well-structured, unambiguous? |
| **Freshness** | 15% | Is the information current? Any stale references or outdated framing? |

### Scoring Scale

| Score | Label | Criteria |
|-------|-------|----------|
| 5 | Exceptional | Exceeds expectations; better than hand-crafted alternatives |
| 4 | Good | Minor gaps; clearly useful and fit-for-purpose |
| 3 | Adequate | Functional but notable room for improvement |
| 2 | Below average | Notable gaps or errors that undermine usefulness |
| 1 | Poor | Significant issues; needs substantial rework |

## Evaluation Process

### Step 1: Understand the Purpose
Before scoring, answer:
- What is this output trying to achieve?
- Who is the audience?
- What's the benchmark for "good"?

### Step 2: Score Each Dimension
For each dimension, provide:
- A score (1-5)
- Specific evidence (quote the exact issue or strength)
- An actionable improvement (if score < 4)

```markdown
#### [Output Name] — Evaluation

| Dimension | Score | Evidence | Improvement |
|-----------|-------|----------|-------------|
| Accuracy | [1-5] | "[exact quote or specific example]" | [what to fix] |
| Completeness | [1-5] | "[what's missing or present]" | [what to add] |
| Usefulness | [1-5] | "[does it achieve its goal?]" | [how to improve] |
| Clarity | [1-5] | "[structural or language issues]" | [how to clarify] |
| Freshness | [1-5] | "[stale elements found]" | [what to update] |
| **Weighted Total** | **[X.X/5]** | | |
```

### Step 3: Calculate Weighted Score

```
Weighted = (Accuracy × 0.25) + (Completeness × 0.20) + (Usefulness × 0.25) + (Clarity × 0.15) + (Freshness × 0.15)
```

### Step 4: Classify and Recommend

| Score | Grade | Recommendation |
|-------|-------|----------------|
| 4.5–5.0 | A | Share/publish as-is |
| 3.5–4.4 | B | Minor polish recommended |
| 2.5–3.4 | C | Notable improvements needed before sharing |
| 1.5–2.4 | D | Significant rework required |
| < 1.5 | F | Start over or fundamentally rethink |

### Step 5: Prioritized Improvement List

Always produce a ranked list of improvements:

```markdown
### Improvements (Priority Order)

**MUST FIX** (blocks sharing):
1. [Specific issue] — [why it matters] — [how to fix]

**SHOULD FIX** (significant quality gain):
2. [Specific issue] — [why it matters] — [how to fix]

**NICE TO HAVE** (minor polish):
3. [Specific issue] — [why it matters] — [how to fix]
```

## Output-Type Specific Extensions

### For Strategic Documents (plans, analyses, reviews)
Add assessment of:
- **Actionability**: Are next steps specific enough to act on?
- **Honesty**: Does it acknowledge risks and failure modes?
- **Evidence**: Are claims supported by data or reasoning?

### For Technical Documentation
Add assessment of:
- **Reproducibility**: Can someone follow this without prior knowledge?
- **Accuracy of commands**: Are code examples tested and correct?
- **Coverage of edge cases**: What happens when things go wrong?

### For Research Summaries
Add assessment of:
- **Source quality**: Are the underlying sources credible?
- **Synthesis quality**: Are patterns and insights genuine vs surface-level?
- **Bias check**: Does the summary fairly represent conflicting evidence?

## Quality Criteria

A good evaluation MUST:
- [ ] Score every dimension (never skip or bundle)
- [ ] Provide specific evidence for each score (no vague "quality is low")
- [ ] Make every improvement actionable (no "make it better")
- [ ] Separate MUST FIX from nice-to-have
- [ ] Calculate the weighted total correctly
- [ ] Be honest even when the score is high (5/5 is almost never correct)

## Anti-Patterns to Avoid

- **Vague scores**: Giving 4/5 without explaining what's good or what's missing
- **Generic improvements**: "Improve clarity" without specifying what's unclear
- **Missing evidence**: Claiming accuracy issues without quoting the specific error
- **Grade inflation**: Scoring 4+ when issues are present to seem positive
- **Omitting dimensions**: Skipping freshness because "it seems recent"
