# Rubric — Scoring Anchors per Dimension

> Anchors 0–5 per dimension. Used by `calc_scorecard.py` and dimension agents.
> Scientific frameworks are listed per dimension to anchor the construct.

---

## wedge — Real Pain / Pull

**Frameworks:** JTBD (job, forces), Customer Development (commitment signals), Kano (must-be vs delight)

| Score | Anchor |
|-------|--------|
| 0 | Vague pain, no current alternative identified, no commitment signals |
| 1 | Pain mentioned anecdotally by 1–2 people, no behavioral evidence |
| 2 | Pain confirmed by multiple stated sources, current alternative identified |
| 3 | Pain frequent, current alternative expensive/risky, moderate pull signals |
| 4 | Strong pull signals (waitlist, deposit, install), clear JTBD job-to-be-done |
| 5 | Commitment-tier evidence (paid, referred, gave access), ICP well-defined |

**Key proxy:** WedgeScore = f(severity × frequency × urgency × commitment_signal)

---

## friction — Ease / Time to First Value

**Frameworks:** TAM (perceived usefulness + ease of use), ISO 9241-11 (efficacy/efficiency/satisfaction), Fogg Behavior Model (Ability + Motivation + Prompt)

| Score | Anchor |
|-------|--------|
| 0 | No onboarding defined; TTFV unknown |
| 1 | Setup requires expert knowledge; activation rate < 10% |
| 2 | Steps documented; TTFV > 30 min; drop-offs at key steps |
| 3 | TTFV 10–30 min; activation rate 20–40%; main friction points identified |
| 4 | TTFV < 10 min; activation rate > 40%; main drop-offs addressed |
| 5 | TTFV < 5 min; activation > 60%; task success rate validated with real users |

**Key proxy:** TTFV (median minutes), Activation Rate (% reaching first value)

---

## loop — Distribution / Referral / Network Effects

**Frameworks:** Network Effects (Katz & Shapiro), Bass Diffusion (innovators vs imitators), AARRR (Referral leg)

| Score | Anchor |
|-------|--------|
| 0 | No referral mechanism; growth is purely paid or manual |
| 1 | Sharing possible but not instrumented; K-factor unknown |
| 2 | Share mechanism exists; low share rate (< 5%); K-factor < 0.3 |
| 3 | Share rate 5–15%; observable referral loop; OSS star/fork velocity tracked |
| 4 | K-factor > 0.5; referral converts > 20%; loop cycle time < 30 days |
| 5 | K-factor > 1.0 or dominant OSS signal (star→install ratio > 0.5, fork velocity high) |

**Key proxy:** K-factor = invites_per_user × conversion_rate

---

## timing — Window / Acceleration / Catalysts

**Frameworks:** Rogers Diffusion of Innovations (relative advantage, compatibility, trialability), Bass Diffusion (slope and phase)

| Score | Anchor |
|-------|--------|
| 0 | No timing signal; market trend unknown |
| 1 | Stable market; no identified catalyst; low urgency |
| 2 | Mild upward slope in searches/mentions; weak catalyst |
| 3 | Clear upward trend (WoW/MoM); identifiable catalyst (regulation, platform shift, API change) |
| 4 | Accelerating trend; strong catalyst recently triggered; competitors growing |
| 5 | Window is open now; urgency is high; first-mover advantage visible; strong Bass acceleration |

**Key proxy:** Slope of demand/mentions (WoW or MoM), Catalyst flag (explicit external event)

---

## trust — Risk Acceptance / Security Posture

**Frameworks:** Mayer–Davis–Schoorman (ability/benevolence/integrity), Privacy Calculus (risk vs benefit), NIST CSF (governance/controls for B2B)

| Score | Anchor |
|-------|--------|
| 0 | No trust signals; security posture unknown; no privacy consideration |
| 1 | Trust actions defined but not measured; no security documentation |
| 2 | Some users have taken trust actions; NIST CSF-lite not addressed |
| 3 | Trust action rate > 30%; churn post-trust-action < 20%; basic security docs present |
| 4 | Trust action rate > 50%; NIST CSF-lite checklist complete; low churn post-trust |
| 5 | High trust action rate; strong OSS trust signals (security policy, SBOM, signed releases); audit trail |

**Key proxy:** Trust action rate (% who gave permission/key/data), Time-to-trust

---

## migration — Switching Costs (optional, Infra_Fork_Standard mode)

**Frameworks:** Klemperer Switching Costs (technical, learning, transaction, lock-in), Katz & Shapiro Compatibility

| Score | Anchor |
|-------|--------|
| 0 | Migration path undefined; no rollback plan |
| 1 | Migration documented at high level; rollback untested |
| 2 | Step-by-step migration guide; rollback feasible but untested |
| 3 | Migration guide validated; rollback tested; diff surface < 20% of API |
| 4 | Automated migration tooling; < 1h estimated migration time; rollback < 30 min |
| 5 | Zero-downtime migration validated; full compatibility maintained; switching cost minimal |

**Key proxy:** Estimated migration time, Rollback feasibility, Diff surface (API/config/format changes)
