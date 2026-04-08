# Experiment Playbook

> Design patterns for Lean experiments. Each pattern includes a structure, minimum sample, stop rules, and pitfalls. Anti-pattern: running experiments without pre-committed thresholds (p-hacking).

---

## Core Principle: Pre-commit Stop Rules

**Before running any experiment, write down:**
- Kill threshold: "If result X, we kill/pivot"
- Proceed threshold: "If result Y, we advance"
- Sample size and duration

**Never change thresholds after seeing partial results.** This is product p-hacking.

---

## Pattern 1 — Smoke Test (Fake Door)

**Best for:** Validating demand before building.

**Structure:**
1. Create a landing page or button that describes the feature/product
2. Drive traffic (organic, email, or small paid)
3. Measure click-through to a "Join waitlist" or "Get notified" CTA
4. Do not deliver the feature yet — notify users when asked

**Proxy metric:** Click-through rate (CTR) on CTA / waitlist conversion rate

**Minimum sample:** 100–200 unique visitors (or 50 for very niche B2B)

**Stop rules (example):**
- Kill: < 5% waitlist conversion after 200 visitors
- Proceed: ≥ 15% waitlist conversion after 100 visitors

**Pitfalls:**
- Traffic source quality matters (warm email list ≠ cold ad traffic)
- CTR without commitment signal = stated interest only; follow up to confirm intent
- "Join waitlist" is not a commitment — a deposit or API key request is

---

## Pattern 2 — Wizard of Oz

**Best for:** Testing a value proposition that requires back-end work you haven't built.

**Structure:**
1. Present users with the product interface (real or mockup)
2. Manually fulfill requests behind the scenes (human acts as the system)
3. Measure user satisfaction, TTFV, and re-use rate
4. Do not reveal the manual fulfillment until after data is collected

**Proxy metric:** Re-use rate (do users come back?), task completion rate, TTFV

**Minimum sample:** 5–15 users for qualitative signal; 30+ for quantitative

**Stop rules (example):**
- Kill: < 30% of users return after first use
- Proceed: > 60% re-use after first use AND TTFV < 15 min

**Pitfalls:**
- Wizard of Oz introduces bias if fulfillment quality varies per operator
- Results only generalize to users who completed onboarding — selection bias
- Not suitable for measuring activation rate (users are hand-held)

---

## Pattern 3 — Concierge MVP

**Best for:** Testing the full loop with a very small cohort before scaling.

**Structure:**
1. Recruit 5–10 target users manually
2. Deliver the full solution end-to-end (may involve manual steps)
3. Measure the full AARRR funnel: Acquisition → Activation → Retention → Referral → Revenue

**Proxy metric:** Net Promoter Score (NPS) from cohort, retention at 7/14/30 days

**Minimum sample:** 5 users (qualitative) or 15–20 users (semi-quantitative)

**Stop rules (example):**
- Kill: NPS < 0 after 30 days, or retention at day 7 < 40%
- Proceed: NPS > 30 AND retention at day 7 > 60%

**Pitfalls:**
- Concierge results are biased toward enthusiasts — early cohort ≠ general market
- NPS from users you recruited personally is inflated — they want to be polite

---

## Pattern 4 — A/B Test (Feature Variation)

**Best for:** Optimizing an existing activation flow or feature (not for validating a new idea).

**Structure:**
1. Split traffic 50/50 (or using multi-armed bandit)
2. Define one primary metric and one guardrail metric
3. Run until statistical significance OR sample limit reached
4. Do not peek at results before sample limit

**Proxy metric:** Primary: activation rate (or target metric). Guardrail: churn rate.

**Minimum sample:** Use a power calculator. For 5% baseline, 2% lift detection, α=0.05, β=0.20 → ~2,000 per arm.

**Stop rules:**
- Stop early only if guardrail metric is significantly damaged
- Proceed: primary metric lifts with p < 0.05 AND guardrail not damaged
- Kill: no significant lift after pre-defined sample

**Pitfalls:**
- Multiple testing: every additional metric tested inflates false positive rate
- Novelty effect: users try new variant because it's new, not because it's better — measure at 7+ days
- Do not A/B test when sample < 100/arm — use qualitative methods instead

---

## Pattern 5 — Commitment Test (Pre-sales)

**Best for:** Validating commitment-tier intent before building.

**Structure:**
1. Offer the product for pre-sale (even at a discount)
2. Or ask users to schedule a paid onboarding session
3. Or present an LOI / MOU for B2B contexts

**Proxy metric:** Pre-sale conversion rate, deposit acceptance rate

**Minimum sample:** 20–50 outreach targets for B2B; 100+ for consumer

**Stop rules (example):**
- Kill: < 5% deposit/pre-sale conversion after outreach to 30 qualified leads
- Proceed: ≥ 15% conversion, with ≥ 3 deposits received

**Pitfalls:**
- Discounts inflate conversion — test at realistic pricing
- "I'd buy it" ≠ buying it — only count actual deposits or signed documents
- B2B LOI without budget authority is not commitment evidence

---

## Experiment Template (for `EXPERIMENTS/plan-*.md`)

```markdown
### Experiment — [Hypothesis]

**Hypothesis:** If we [action], then [metric] will change by [magnitude] for [user segment].
**Dimension:** wedge | friction | loop | timing | trust
**Pattern:** smoke_test | wizard_of_oz | concierge | ab_test | commitment_test

**Setup:**
- Target segment: [ICP description]
- Instrumentation: [what to track and where]
- Duration: [X days or until N users]
- Sample size: [minimum N per arm]

**Stop Rules (pre-committed):**
- Kill: [specific measurable outcome → what to do next]
- Proceed: [specific measurable outcome → what to do next]
- Iterate: [outcome between kill and proceed → what to adjust]

**Evidence output:**
- File: STATE/<dimension>_<experiment_name>.json
- Items: dimension, claim, method, collected_at, quality_tier
```
