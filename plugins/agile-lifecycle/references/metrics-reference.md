# Metrics Reference

## Overview

This reference defines all metrics used in the agile-lifecycle framework, organized by category. Each metric includes its formula, target threshold, collection method, cadence, and owner. Metrics feed into Sprint Health Records, Phase Reports, and Gate Reviews.

---

## 1. Delivery Metrics

### Velocity

| Field | Value |
|-------|-------|
| **Definition** | Story points completed and accepted in a sprint |
| **Formula** | Sum of story points of items meeting DoD in the sprint |
| **Target** | Stable within ±20% of team baseline velocity |
| **Warning threshold** | >30% drop from 3-sprint rolling average |
| **Collection method** | Sprint review: count accepted items' point values |
| **Cadence** | Per sprint |
| **Owner** | Delivery Lead / Scrum Master |
| **Schema field** | `sprint-health.velocity` |

### Planned Velocity vs Actual Velocity

| Field | Value |
|-------|-------|
| **Definition** | Difference between planned and actual story points |
| **Formula** | `planned_velocity - velocity` (positive = under-delivered) |
| **Target** | Within 10% of planned |
| **Warning threshold** | > 25% under-planned |
| **Collection method** | Sprint planning (planned) vs sprint review (actual) |
| **Cadence** | Per sprint |
| **Owner** | Delivery Lead |

### Commitment Ratio

| Field | Value |
|-------|-------|
| **Definition** | Proportion of committed scope completed by sprint end |
| **Formula** | `velocity_actual / capacity_points` |
| **Target** | ≥ 0.8 (80% of committed scope completed) |
| **Green threshold** | ≥ 0.8 |
| **Amber threshold** | 0.6–0.79 |
| **Red threshold** | < 0.6 |
| **Collection method** | Derived from sprint contract data |
| **Cadence** | Per sprint |
| **Owner** | Scrum Master / PM |
| **Schema field** | `sprint-health.commitment_ratio` |

### Cycle Time

| Field | Value |
|-------|-------|
| **Definition** | Time from when work begins on an item to when it is accepted |
| **Formula** | `acceptance_date - start_date` (calendar days) |
| **Target** | ≤ sprint duration / 3 per story |
| **Warning threshold** | Items older than 2 sprints without acceptance |
| **Collection method** | Tracked per backlog item in tracking tool |
| **Cadence** | Reviewed per sprint in retrospective |
| **Owner** | Delivery Lead |

### Lead Time

| Field | Value |
|-------|-------|
| **Definition** | Time from backlog item creation to delivery acceptance |
| **Formula** | `acceptance_date - creation_date` (calendar days) |
| **Target** | Product-type dependent (set at Phase 2) |
| **Collection method** | Tracking tool |
| **Cadence** | Monthly trend |
| **Owner** | PM |

### Scope Creep Percentage

| Field | Value |
|-------|-------|
| **Definition** | Percentage of sprint scope added after sprint planning |
| **Formula** | `(scope_added_points / capacity_points) * 100` |
| **Target** | ≤ 10% per sprint |
| **Warning threshold** | > 20% per sprint |
| **Collection method** | Track scope changes after sprint start |
| **Cadence** | Per sprint |
| **Owner** | Scrum Master |
| **Schema field** | `sprint-health.scope_creep_pct` |

---

## 2. Quality Metrics

### Defect Density

| Field | Value |
|-------|-------|
| **Definition** | Number of defects per story point or unit of functionality delivered |
| **Formula** | `defect_count / velocity_actual` |
| **Target** | ≤ 0.1 defects per story point |
| **Warning threshold** | > 0.3 defects per story point in any sprint |
| **Collection method** | Bug tracking tool; count defects opened during sprint |
| **Cadence** | Per sprint |
| **Owner** | QA Lead |

### Defect Escape Rate

| Field | Value |
|-------|-------|
| **Definition** | Proportion of defects found in production vs total defects found |
| **Formula** | `production_defects / (pre_release_defects + production_defects)` |
| **Target** | ≤ 5% |
| **Warning threshold** | > 15% |
| **Collection method** | Compare defects found pre-release vs post-release |
| **Cadence** | Per release / monthly in Phase 6 |
| **Owner** | QA Lead |

### Test Coverage

| Field | Value |
|-------|-------|
| **Definition** | Percentage of code or acceptance criteria covered by automated tests |
| **Formula** | Tooling-dependent (e.g. Istanbul for JS, pytest-cov for Python) |
| **Target** | ≥ 80% for critical paths; ≥ 60% overall |
| **Warning threshold** | < 50% overall |
| **Collection method** | CI pipeline test coverage report |
| **Cadence** | Per sprint (CI) |
| **Owner** | Engineering Lead |

### Mean Time to Recovery (MTTR)

| Field | Value |
|-------|-------|
| **Definition** | Average time to restore service after an incident |
| **Formula** | `total_incident_duration_hours / incident_count` |
| **Target** | ≤ 4 hours for P1 incidents; ≤ 24 hours for P2 |
| **Collection method** | Incident management tool |
| **Cadence** | Monthly |
| **Owner** | Ops Lead |

### Change Failure Rate

| Field | Value |
|-------|-------|
| **Definition** | Percentage of deployments that result in a production incident or rollback |
| **Formula** | `(failed_deployments / total_deployments) * 100` |
| **Target** | ≤ 5% |
| **Warning threshold** | > 15% |
| **Collection method** | Deployment logs + incident logs |
| **Cadence** | Monthly |
| **Owner** | Engineering Lead + Ops Lead |

---

## 3. Product Metrics

### User Adoption Rate

| Field | Value |
|-------|-------|
| **Definition** | Percentage of target users actively using the product |
| **Formula** | `active_users / target_user_base * 100` |
| **Target** | Product-type dependent (set at Phase 2 in Value Hypothesis) |
| **Warning threshold** | < 50% of target after 90 days in production |
| **Collection method** | Product analytics (DAU/MAU from analytics platform) |
| **Cadence** | Monthly |
| **Owner** | Product Lead |

### Feature Utilization Rate

| Field | Value |
|-------|-------|
| **Definition** | Percentage of delivered features actively used by users |
| **Formula** | `features_with_active_usage / total_features_delivered * 100` |
| **Target** | ≥ 70% of features used by ≥ 10% of active users |
| **Warning threshold** | < 50% feature utilization |
| **Collection method** | Feature flagging + analytics events |
| **Cadence** | Monthly |
| **Owner** | Product Lead |

### Net Promoter Score (NPS) / CSAT

| Field | Value |
|-------|-------|
| **Definition** | NPS: likelihood to recommend (−100 to +100). CSAT: satisfaction score (1–5). |
| **Formula** | NPS = `% promoters − % detractors`. CSAT = `mean(scores)`. |
| **Target** | NPS ≥ 30; CSAT ≥ 4.0 |
| **Warning threshold** | NPS < 0; CSAT < 3.5 |
| **Collection method** | In-product survey or periodic email survey |
| **Cadence** | Quarterly |
| **Owner** | Product Lead |

### Time to Value

| Field | Value |
|-------|-------|
| **Definition** | Time from user onboarding to first meaningful value action |
| **Formula** | `first_value_action_date − onboarding_date` (calendar days) |
| **Target** | Set at Phase 2; typical target ≤ 7 days |
| **Collection method** | Analytics event tracking |
| **Cadence** | Monthly |
| **Owner** | Product Lead |

---

## 4. AI/ML Metrics

### Model Accuracy

| Field | Value |
|-------|-------|
| **Definition** | Proportion of correct predictions on the validation/test dataset |
| **Formula** | `correct_predictions / total_predictions` |
| **Target** | ≥ threshold set in AI Feasibility Note (Phase 1) |
| **Collection method** | Model evaluation pipeline against held-out test set |
| **Cadence** | Per model version; monthly drift check |
| **Owner** | ML Lead |

### Precision and Recall (Classification)

| Field | Value |
|-------|-------|
| **Definition** | Precision: of predicted positives, how many are correct. Recall: of actual positives, how many are found. |
| **Formula** | `Precision = TP / (TP + FP)`. `Recall = TP / (TP + FN)`. |
| **Target** | Set per use case; documented in AI Feasibility Note |
| **Collection method** | Evaluation pipeline |
| **Cadence** | Per model version |
| **Owner** | ML Lead |

### Inference Latency P99

| Field | Value |
|-------|-------|
| **Definition** | 99th percentile inference latency (time for model to produce a response) |
| **Formula** | P99 of inference_duration_ms across sampled requests |
| **Target** | Use-case dependent; typically ≤ 2000ms for interactive features |
| **Warning threshold** | > 5000ms P99 |
| **Collection method** | APM / observability platform |
| **Cadence** | Continuous; reviewed monthly |
| **Owner** | ML Lead + Ops Lead |

### Model Drift Rate

| Field | Value |
|-------|-------|
| **Definition** | Rate of change in model performance metrics over time (data drift or concept drift) |
| **Formula** | `(current_accuracy − baseline_accuracy) / baseline_accuracy * 100` |
| **Target** | < 5% drift from baseline before retraining trigger |
| **Warning threshold** | > 10% drift → mandatory review |
| **Collection method** | Monitoring pipeline comparing production predictions vs ground truth (when available) |
| **Cadence** | Weekly monitoring; monthly review |
| **Owner** | ML Lead |

### AI Experiment Success Rate

| Field | Value |
|-------|-------|
| **Definition** | Proportion of AI experiments that met their stated hypothesis |
| **Formula** | `successful_experiments / total_experiments` |
| **Target** | ≥ 0.3 (30% of experiments yield a positive signal — AI experimentation is inherently uncertain) |
| **Warning threshold** | < 0.1 for 3 consecutive sprints (methodology or hypothesis quality concern) |
| **Collection method** | Experiment Log entries |
| **Cadence** | Per sprint; trend monthly |
| **Owner** | ML Lead |
| **Schema field** | `sprint-health.ai_experiment_success_rate` |

### Token Cost per Request (GenAI/LLM)

| Field | Value |
|-------|-------|
| **Definition** | Average LLM API cost per user request or operation |
| **Formula** | `total_token_cost / request_count` |
| **Target** | Set during Phase 2 based on business case |
| **Warning threshold** | > 150% of target cost per request |
| **Collection method** | LLM API billing dashboard + request count |
| **Cadence** | Weekly |
| **Owner** | Engineering Lead + ML Lead |

---

## 5. Governance Metrics

### Gate Pass Rate

| Field | Value |
|-------|-------|
| **Definition** | Proportion of gate reviews that pass on first attempt |
| **Formula** | `gates_passed_first_attempt / total_gate_reviews` |
| **Target** | ≥ 80% across the lifecycle |
| **Warning threshold** | < 60% — indicates systematic quality or readiness issues |
| **Collection method** | Gate Review Records |
| **Cadence** | Per gate; reported at Phase 6 Gate F |
| **Owner** | PM |

### Waiver Rate

| Field | Value |
|-------|-------|
| **Definition** | Proportion of gate criteria waived vs total criteria checked |
| **Formula** | `criteria_waived / total_criteria_checked * 100` |
| **Target** | ≤ 10% of criteria waived per gate |
| **Warning threshold** | > 25% of criteria waived at any single gate |
| **Collection method** | Waiver Log + Gate Review Records |
| **Cadence** | Per gate |
| **Owner** | Gate Reviewer |

### Artefact Completion Rate

| Field | Value |
|-------|-------|
| **Definition** | Proportion of mandatory artefacts completed at the required evidence threshold for each gate |
| **Formula** | `artefacts_at_threshold / mandatory_artefacts_required * 100` |
| **Target** | 100% for mandatory artefacts at each gate |
| **Collection method** | Artefact Manifest + Evidence Index |
| **Cadence** | Pre-gate check |
| **Owner** | PM |

### Phase Duration

| Field | Value |
|-------|-------|
| **Definition** | Calendar days spent in each lifecycle phase |
| **Formula** | `end_date − start_date` (calendar days) |
| **Target** | Set in Initial Roadmap (Phase 2) |
| **Warning threshold** | > 150% of planned phase duration |
| **Collection method** | Lifecycle State dates |
| **Cadence** | Tracked continuously; reported at gate |
| **Owner** | PM |

---

## 6. Operational Governance Metrics

### Service Level Objective (SLO) Compliance

| Field | Value |
|-------|-------|
| **Definition** | Proportion of time the service meets its defined SLO targets |
| **Formula** | `minutes_within_slo / total_minutes * 100` |
| **Typical SLOs** | Availability ≥ 99.5% (internal), ≥ 99.9% (external SaaS); Latency P95 ≤ target |
| **Target** | 100% of SLOs met in reporting period |
| **Warning threshold** | Any SLO breached in reporting period → mandatory review |
| **Collection method** | Observability platform (uptime monitors, latency percentiles) |
| **Cadence** | Continuous monitoring; monthly report; Gate F review |
| **Owner** | Ops Lead |

### Incident Rate by Severity

| Field | Value |
|-------|-------|
| **Definition** | Number of production incidents per severity level per month |
| **Formula** | Count of P1/P2/P3 incidents in period |
| **Target** | 0 P1 incidents per month; ≤ 2 P2 per month |
| **Collection method** | Incident management tool |
| **Cadence** | Monthly |
| **Owner** | Ops Lead |

### Release Quality Indicator

| Field | Value |
|-------|-------|
| **Definition** | Composite indicator: deployments in period, rollback count, P1 incidents post-release, change failure rate |
| **Formula** | RAG status based on: rollbacks ≤ 5%, P1 incidents post-release = 0, change failure rate ≤ 5% |
| **Green** | All three criteria met |
| **Amber** | One criterion breached |
| **Red** | Two or more criteria breached |
| **Collection method** | Deployment logs + incident logs |
| **Cadence** | Per release + monthly |
| **Owner** | Engineering Lead + Ops Lead |

### Mean Time Between Failures (MTBF)

| Field | Value |
|-------|-------|
| **Definition** | Average time between production incidents of a given severity |
| **Formula** | `total_uptime_hours / incident_count` |
| **Target** | Increasing trend (MTBF improving over time indicates stable operations) |
| **Collection method** | Incident management tool |
| **Cadence** | Monthly |
| **Owner** | Ops Lead |
