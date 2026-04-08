# Framework Map — Dimension → Framework → Construct → Proxy → Formula → Limitations

> This table binds each scoring dimension to its scientific anchor.
> `calc_scorecard.py` uses this as the conceptual foundation for weights and formulas.

| Dimension | Framework | Construct | Proxy Metric | Formula / Measurement | Limitations |
|-----------|-----------|-----------|-------------|----------------------|------------|
| **wedge** | JTBD (Christensen) | Job-to-be-done, forces of progress | WedgeScore | severity × frequency × urgency × commitment_signal (0–100) | Subjective severity; interviewer bias |
| **wedge** | Customer Development (Blank) | Commitment signal vs opinion | Conversion to real action | % who paid deposit, gave key, booked call | Small samples early; survivor bias |
| **wedge** | Kano | Must-be vs performance vs delight | Feature category | Interview classification | Classification requires training |
| **friction** | TAM (Davis 1989) | Perceived usefulness + ease of use | Activation rate | % users reaching first value event | Activation definition varies by product |
| **friction** | ISO 9241-11 | Efficacy, efficiency, satisfaction | TTFV + task success rate | Median time to first value (minutes) | Lab vs production context gap |
| **friction** | Fogg Behavior Model | Ability (low friction) | Drop-off rate per step | % drop per funnel step | Requires instrumented funnel |
| **loop** | Network Effects (Katz & Shapiro) | Value grows with network | K-factor | invites_per_user × conversion_rate | Cold-start problem; K-factor < 1 is not viral |
| **loop** | Bass Diffusion (1969) | Innovator vs imitator adoption | Star/install velocity | WoW% growth of installs or stars | Stars ≠ installs; vanity risk |
| **loop** | AARRR (McClure) | Referral leg | Share rate, referral conversion | % who share × % who convert | Referral ≠ viral if conversion is low |
| **timing** | Rogers Diffusion of Innovations | Relative advantage, trialability | Slope of demand | WoW or MoM% change in search volume/mentions | Google Trends noise; lags in data |
| **timing** | Bass Diffusion | Acceleration phase | Bass acceleration | d²Adoption/dt² — is the curve convex? | Requires historical data to fit |
| **trust** | Mayer–Davis–Schoorman (1995) | Ability + Benevolence + Integrity | Trust action rate | % who gave permission/key/data | Self-selection; users who don't trust don't show up |
| **trust** | Privacy Calculus | Risk–benefit trade-off | Churn post-trust action | % who left after providing sensitive info | Requires tracking trust event + retention |
| **trust** | NIST CSF | Governance and controls | Security posture checklist | Binary checklist score (items complete / total) | Checklist ≠ actual security |
| **migration** | Klemperer Switching Costs | Technical + learning + transaction + lock-in | Migration time estimate | Hours from start to equivalent functionality | Estimates often underestimate real effort |
| **migration** | Katz & Shapiro Compatibility | Standard compatibility | Diff surface | % of API/config/format that changed | Hard to measure before implementation |
