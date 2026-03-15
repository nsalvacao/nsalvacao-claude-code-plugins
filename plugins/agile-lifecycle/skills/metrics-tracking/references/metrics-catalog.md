# Metrics Catalog

## Overview
This catalog defines all metrics tracked in the agile-lifecycle framework. Each entry includes: metric name, category, formula, target threshold, collection cadence, data source, and owner.

---

## Delivery Metrics

### Velocity
- **Formula:** Sum of story points completed in sprint / sprints in period
- **Target:** Stable within ±15% of team's established baseline over 3 sprints
- **Warning:** >20% drop from baseline for 2 consecutive sprints
- **Breach:** >30% drop from baseline
- **Cadence:** Per sprint (collected at sprint review)
- **Source:** Sprint tracking tool (e.g., Jira, Linear)
- **Owner:** Scrum Master / PM
- **Note:** First 2–3 sprints are calibration; do not set baseline before sprint 3.

### Cycle Time
- **Formula:** Average time from ticket "In Progress" to "Done" (in business days)
- **Target:** ≤ team's established baseline (set after sprint 3)
- **Warning:** 20% above baseline
- **Breach:** 50% above baseline
- **Cadence:** Per sprint
- **Source:** Sprint tracking tool
- **Owner:** PM / Scrum Master

### Lead Time
- **Formula:** Average time from ticket creation to "Done" (in business days)
- **Target:** ≤ established baseline; typically ≤ 2× cycle time
- **Warning:** Lead time / cycle time ratio > 3
- **Breach:** Lead time / cycle time ratio > 5
- **Cadence:** Per sprint
- **Source:** Sprint tracking tool
- **Owner:** PM

### Commitment Ratio
- **Formula:** (Story points completed / story points committed at sprint start) × 100%
- **Target:** 85–100%
- **Warning:** 70–84%
- **Breach:** < 70% for 2 consecutive sprints
- **Cadence:** Per sprint
- **Source:** Sprint tracking tool
- **Owner:** Scrum Master / PM

### Predictability
- **Formula:** (Sprints where commitment ratio ≥ 85% / total sprints) × 100%
- **Target:** ≥ 80% of sprints
- **Warning:** 60–79%
- **Breach:** < 60%
- **Cadence:** Monthly / per phase
- **Source:** Derived from commitment ratio data
- **Owner:** PM

---

## Quality Metrics

### Defect Density
- **Formula:** Total defects found / total story points delivered (in period)
- **Target:** ≤ 0.5 defects per story point (calibrate per team)
- **Warning:** 0.5–1.0 defects/SP
- **Breach:** > 1.0 defects/SP
- **Cadence:** Per sprint
- **Source:** Defect tracking tool
- **Owner:** QA Lead

### Defect Escape Rate
- **Formula:** (Defects found in production / total defects found) × 100%
- **Target:** ≤ 10%
- **Warning:** 10–20%
- **Breach:** > 20%
- **Cadence:** Per release cycle
- **Source:** Production incident tracker + QA defect tracker
- **Owner:** QA Lead

### Test Coverage
- **Formula:** (Lines / branches / functions covered by tests / total lines / branches / functions) × 100%
- **Target:** ≥ 80% for new code; ≥ 70% for modified legacy code
- **Warning:** 70–79% for new code
- **Breach:** < 70% for new code
- **Cadence:** Per sprint (automated in CI)
- **Source:** Test coverage tool (e.g., Istanbul, pytest-cov)
- **Owner:** QA Lead / Tech Lead

### MTTR (Mean Time to Recovery)
- **Formula:** Average time from incident detection to service restoration (in minutes or hours)
- **Target:** ≤ defined SLO (e.g., P1 incidents: ≤ 4h; P2: ≤ 24h)
- **Warning:** 1.5× SLO
- **Breach:** > 2× SLO
- **Cadence:** Per incident; aggregated monthly
- **Source:** Incident management tool
- **Owner:** Ops Lead

---

## Product Metrics

### Adoption Rate
- **Formula:** (Active users in period / target user population) × 100%
- **Target:** Defined per product launch plan (e.g., 70% of eligible users within 30 days)
- **Warning:** < 80% of adoption target
- **Breach:** < 60% of adoption target at T+60 days
- **Cadence:** Weekly post-launch (Phase 6)
- **Source:** Product analytics (e.g., Amplitude, Mixpanel, custom)
- **Owner:** Product Owner

### Feature Utilization
- **Formula:** (Users who used feature in period / active users) × 100%
- **Target:** Per feature (set in product roadmap)
- **Warning:** < 20% utilization after 30 days for a core feature
- **Breach:** < 10% utilization after 60 days for a core feature
- **Cadence:** Monthly
- **Source:** Product analytics
- **Owner:** Product Owner

### NPS / CSAT
- **NPS Formula:** % Promoters (9–10) − % Detractors (1–6)
- **CSAT Formula:** (Satisfied responses / total responses) × 100%
- **NPS Target:** ≥ 30 for new product; ≥ 50 for established product
- **CSAT Target:** ≥ 75%
- **Warning:** NPS < 20 / CSAT < 65%
- **Breach:** NPS < 0 / CSAT < 50%
- **Cadence:** Quarterly or post-major release
- **Source:** Survey tool (NPS survey, in-app CSAT)
- **Owner:** Product Owner / PM

---

## AI/ML Metrics

### Model Accuracy
- **Formula:** Varies by task type:
  - Classification: (correct predictions / total predictions) × 100%
  - Regression: RMSE or MAE vs baseline
  - Ranking: nDCG or MRR
- **Target:** Defined in model card at Gate D (baseline established from validation set)
- **Warning:** Accuracy drops > 3% from baseline
- **Breach:** Accuracy drops > 10% from baseline
- **Cadence:** Daily automated evaluation; weekly review
- **Source:** Model monitoring pipeline
- **Owner:** AI Lead / AI Ops Lead

### Inference Latency (p99)
- **Formula:** 99th percentile of inference response time (in milliseconds)
- **Target:** ≤ defined SLO (e.g., p99 ≤ 500ms for real-time; p99 ≤ 2000ms for batch)
- **Warning:** 1.5× SLO
- **Breach:** > 2× SLO
- **Cadence:** Real-time monitoring; daily report
- **Source:** APM tool (e.g., Datadog, Grafana)
- **Owner:** AI Ops Lead

### Drift Rate
- **Formula:** Population Stability Index (PSI) or Jensen-Shannon divergence between current input distribution and training distribution
- **Target:** PSI < 0.1 (no significant drift); 0.1–0.2 (moderate drift — investigate); > 0.2 (significant drift — retrain)
- **Warning:** PSI 0.1–0.2
- **Breach:** PSI > 0.2
- **Cadence:** Daily (automated); weekly review
- **Source:** Model monitoring pipeline
- **Owner:** AI Ops Lead

### Experiment Success Rate
- **Formula:** (Experiments achieving stated hypothesis / total experiments run) × 100%
- **Target:** ≥ 30% (higher is better, but low rate indicates learning not failure)
- **Cadence:** Per sprint (Phase 4)
- **Source:** AI Experiment Log
- **Owner:** AI Lead
- **Note:** Low experiment success rate is not a failure metric if learnings are documented.

---

## Governance Metrics

### Gate Pass Rate
- **Formula:** (Gates passed on first attempt / total gate reviews) × 100%
- **Target:** ≥ 80% first-attempt pass rate
- **Warning:** 60–79%
- **Breach:** < 60% (indicates systemic readiness issues)
- **Cadence:** Per gate review; aggregated per phase
- **Source:** Gate review reports
- **Owner:** PM

### Waiver Rate
- **Formula:** (Criteria waived / total criteria reviewed across all gates) × 100%
- **Target:** ≤ 10%
- **Warning:** 10–20%
- **Breach:** > 20% (indicates governance is being bypassed)
- **Cadence:** Per gate review; aggregated across lifecycle
- **Source:** Waiver log
- **Owner:** PM / Gate Reviewer

### Artefact Completion Rate
- **Formula:** (Mandatory artefacts produced / mandatory artefacts required for phase) × 100%
- **Target:** 100% at gate review
- **Warning:** 80–99% (artefacts in progress)
- **Breach:** < 80% at gate review date
- **Cadence:** Weekly (Phase 4+); at each gate
- **Source:** Evidence index / artefact manifest
- **Owner:** PM

### Assumption Resolution Rate
- **Formula:** (Assumptions resolved by review date / total assumptions with passed review date) × 100%
- **Target:** 100%
- **Warning:** < 80%
- **Breach:** < 60% (indicates assumption tracking is not being maintained)
- **Cadence:** Per sprint
- **Source:** Assumption register
- **Owner:** PM
