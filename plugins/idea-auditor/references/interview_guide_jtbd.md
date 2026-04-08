# JTBD Interview Guide

> Neutral interviewer guide for Jobs-to-be-Done (JTBD) interviews. Captures severity, frequency, urgency, and commitment signals for the wedge dimension. Anti-pattern: leading questions that confirm the interviewer's hypothesis.

---

## Purpose

Validate whether the pain is real, how often it occurs, and whether users have taken action to solve it. The output feeds `STATE/wedge_interviews.json` items.

---

## Interview Structure

**Duration:** 30–45 minutes  
**Recording:** with consent  
**Interviewer mindset:** curious detective, not salesperson

### Opening (5 min)

Do not mention your product. Set context:

> "Thank you for joining. I'm researching how [role/domain] professionals handle [broad problem area]. I'll ask you about your experience — there are no right or wrong answers, and I'm not pitching anything."

### Part 1 — Situation and Context (10 min)

Understand when and how the problem arises:

1. "Walk me through the last time you had to [do the job]. What triggered it?"
2. "Who else was involved? What tools or processes did you use?"
3. "How often does this situation come up for you?"
4. "How does this compare to [related job or role]?"

**Coding:** Record situation, trigger, frequency.

### Part 2 — Problem Depth (10 min)

Understand severity and the cost of the current alternative:

5. "What's most frustrating about how you handle this today?"
6. "Can you estimate how much time you spend on this per [week/month]?"
7. "Have you ever lost something important (time, money, trust) because of this problem?"
8. "If you could wave a magic wand and fix one thing, what would it be?"

**Coding:** Record severity (pain intensity, cost of current alternative), estimated time lost.

### Part 3 — Commitment Signals (10 min)

Look for behavioral and commitment-tier evidence:

9. "Have you tried to solve this in the past? What did you try?"
10. "Did you pay for any solution — even a partial one?"
11. "Have you built workarounds? What are they?"
12. "If a tool existed that solved this perfectly, what would you need to see before you'd trust it with your [data/workflow/team]?"

**Coding:** Record quality tier (commitment / behavioral / stated / proxy / assumption).

### Part 4 — Pull and Urgency (5 min)

Assess urgency and pull:

13. "Is this something you need to solve in the next 30 days, or is it more of a chronic issue you've learned to live with?"
14. "What would make you drop everything to fix this today?"
15. "Have you recommended anyone else look into this problem?"

**Coding:** Record urgency flag, referral signal.

### Closing (2 min)

> "Thank you. Is there anything I haven't asked that you think is important? Would you be open to a follow-up in a few weeks?"

---

## Evidence Coding

After each interview, code these fields for each item in `STATE/wedge_interviews.json`:

```json
{
  "dimension": "wedge",
  "claim": "Spends 3h/week manually reconciling pricing data across spreadsheets",
  "source": "Interview: [anonymized ID]",
  "method": "user_interview",
  "collected_at": "YYYY-MM-DD",
  "quality_tier": "stated",
  "confidence_components": {
    "source_diversity": 0.5,
    "consistency": 0.8
  },
  "raw": "They mentioned spending about 3 hours every Friday reconciling the export from system A with system B...",
  "severity": 4,
  "frequency": "weekly",
  "urgency": "chronic",
  "commitment_signal": "built a personal Python script to semi-automate it"
}
```

**quality_tier mapping:**
- `commitment` — paid, gave access, referred others unprompted
- `behavioral` — built workaround, uses substitute regularly
- `stated` — said they have the problem explicitly
- `proxy` — mentioned related tools, searched for alternatives
- `assumption` — interviewer inferred from context

---

## Severity / Frequency / Urgency Scales

| Dimension | 1 | 2 | 3 | 4 | 5 |
|-----------|---|---|---|---|---|
| Severity | Mild inconvenience | Noticeable friction | Costly in time/money | Significant risk/loss | Business-critical / blocking |
| Frequency | Rarely (< monthly) | Monthly | Weekly | Multiple times/week | Daily |
| Urgency | No urgency, "someday" | Low ("would be nice") | Moderate ("soon") | High ("need this month") | Immediate ("blocking me now") |

---

## Anti-patterns

- **Leading questions**: "Don't you think X is a problem?" → instead: "Tell me about X."
- **Solution fishing**: "Would you use a tool that did Y?" → instead: validate the problem before the solution.
- **Confirmation bias**: Discarding negative evidence because "they don't get it" — all feedback is signal.
- **Averaging across very different ICPs**: A small business owner and an enterprise VP may have the same stated pain but completely different severity and urgency.

---

## Stop Rule for Interview Series

Run a minimum of 5 interviews. Stop if:
- 4+ out of 5 express the same high-severity, high-frequency pain → sufficient for stated evidence tier
- 2+ out of 5 show commitment-tier signals → strong wedge, advance to commitment test experiment
- 0 out of 5 show any urgency → re-examine ICP or problem framing before continuing
