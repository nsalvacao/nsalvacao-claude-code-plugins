# Metrics Dictionary

> Formal definitions for all metrics used in `idea-auditor`. Each metric has a name, unit, formula, source, expected range, and pitfalls.

---

## WedgeScore

| Field | Value |
|-------|-------|
| **Unit** | Dimensionless (0–1 normalized) |
| **Formula** | `severity × frequency × urgency × commitment_signal` (each component 0–1) |
| **Source** | JTBD interviews + commitment-tier evidence in STATE/ |
| **Expected range** | 0 (vague pain) → 1 (commitment-tier evidence, frequent, urgent) |
| **Dimension** | wedge |
| **Pitfalls** | Severity and urgency are self-reported — validate with behavioral evidence; stated urgency ≠ actual urgency |

---

## TTFV (Time to First Value)

| Field | Value |
|-------|-------|
| **Unit** | Minutes (median) |
| **Formula** | `median(time_from_install_to_first_value_event)` across sessions |
| **Source** | Session analytics, event tracking (install → first success event) |
| **Expected range** | < 5 min (score 5) → < 10 min (4) → 10–30 min (3) → > 30 min (2) → unknown (0–1) |
| **Dimension** | friction |
| **Pitfalls** | "First value event" must be predefined; account creation is NOT first value; TTFV from power users is biased low |

---

## Activation Rate

| Field | Value |
|-------|-------|
| **Unit** | Percentage (%) |
| **Formula** | `(users_who_reached_first_value_event / total_users_who_started) × 100` |
| **Source** | Product analytics, funnel tracking |
| **Expected range** | > 60% (score 5) → > 40% (4) → 20–40% (3) → < 20% (2) → unknown (0–1) |
| **Dimension** | friction |
| **Pitfalls** | Cohort selection matters — include all who installed, not just those who completed setup; activation event must match TTFV definition |

---

## K-factor

| Field | Value |
|-------|-------|
| **Unit** | Dimensionless (ratio) |
| **Formula** | `invites_sent_per_user × invite_conversion_rate` |
| **Source** | Referral tracking, invite analytics |
| **Expected range** | K > 1.0 (viral) → K 0.5–1.0 (strong assist) → K < 0.3 (slow/no loop) |
| **Dimension** | loop |
| **Pitfalls** | K-factor is a stock metric — does not capture cycle time; K=1.2 with 60-day cycles is much weaker than K=0.8 with 3-day cycles; OSS stars are not invites |

---

## Star→Install Ratio

| Field | Value |
|-------|-------|
| **Unit** | Ratio (0–1+) |
| **Formula** | `install_count / star_count` (for OSS projects) |
| **Source** | GitHub stars + npm/pypi/homebrew download counts |
| **Expected range** | > 0.5 (strong pull-through) → 0.1–0.5 (moderate) → < 0.1 (discovery only) |
| **Dimension** | loop |
| **Pitfalls** | Stars inflate through trending/aggregators; installs may include bots; ratio must be measured over matching time windows |

---

## Demand Slope (WoW/MoM)

| Field | Value |
|-------|-------|
| **Unit** | Percentage change per week or month |
| **Formula** | `(value_current_period - value_prior_period) / value_prior_period × 100` |
| **Source** | Search trend snapshots, GitHub star velocity, forum mentions |
| **Expected range** | > 10% WoW sustained (score 4+) → 2–10% WoW (3) → flat or declining (1–2) → unknown (0) |
| **Dimension** | timing |
| **Pitfalls** | Single-week spikes are not trends; minimum 4 data points to assess slope; seasonal effects must be accounted for |

---

## Trust Action Rate

| Field | Value |
|-------|-------|
| **Unit** | Percentage (%) |
| **Formula** | `(users_who_completed_trust_action / users_who_reached_trust_prompt) × 100` |
| **Source** | Product analytics, onboarding funnel |
| **Expected range** | > 50% (score 4–5) → > 30% (3) → measured but < 30% (2) → unmeasured (0–1) |
| **Dimension** | trust |
| **Pitfalls** | Trust prompt placement matters — a buried prompt has low rate by design; "trust action" must be defined explicitly (e.g. granting API key access, not just accepting TOS) |

---

## Time-to-Trust

| Field | Value |
|-------|-------|
| **Unit** | Days (median) |
| **Formula** | `median(days_from_first_session_to_first_trust_action)` |
| **Source** | Session analytics, trust event tracking |
| **Expected range** | Same session (< 1 day) (high trust) → 2–7 days → > 14 days (low trust signal) |
| **Dimension** | trust |
| **Pitfalls** | Long time-to-trust may indicate learning curve, not distrust — validate with user interviews; cohort contamination if trust prompt changed mid-measurement |

---

## Migration Time

| Field | Value |
|-------|-------|
| **Unit** | Hours (estimated) |
| **Formula** | Estimated total effort to migrate from predecessor to this system (includes setup, data migration, testing, validation) |
| **Source** | Migration guide review, user testing, dry-run measurements |
| **Expected range** | < 1h (score 4+) → 1–8h (3) → 8–40h (2) → > 40h or untested (0–1) |
| **Dimension** | migration |
| **Pitfalls** | Time estimates from documentation authors are optimistic; measure with target users, not internal team; rollback time is a separate but equally important metric |

---

## ConfDim (Confidence per Dimension)

| Field | Value |
|-------|-------|
| **Unit** | Dimensionless (0–1) |
| **Formula** | `clamp(0, 1, 0.2×SourceDiversity + 0.3×Recency + 0.3×Commitment + 0.2×Consistency)` |
| **Source** | Computed by `scripts/grade_evidence.py` |
| **Expected range** | ≥ 0.7 = high confidence → 0.4–0.69 = medium → < 0.4 = low |
| **Dimension** | all |
| **Pitfalls** | High ConfDim with low score_bruto = well-evidenced bad outcome; low ConfDim with high score_bruto = promising but unvalidated — run experiments before proceeding |
