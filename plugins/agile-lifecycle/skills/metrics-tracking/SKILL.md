---
name: metrics-tracking
description: This skill should be used when sprint metrics, quality metrics, AI/ML model metrics, or governance metrics need to be collected, calculated against thresholds, or reported. Triggers when a user asks for a sprint metrics report, wants to check if velocity is healthy, needs an AI monitoring report, or detects a threshold breach that requires escalation. Also applies when baselining metrics at the start of Phase 4.
---

# Metrics Tracking

## Purpose
Metrics provide objective evidence of delivery health, product quality, and AI/ML system performance. This skill defines which metrics to collect, how to calculate them, when to collect them, and how to report them for gate reviews and stakeholder reporting. Metrics without targets are observations; metrics with targets and thresholds are governance tools.

## When to Use
- Sprint metrics need to be recorded after sprint completion
- A metrics report is requested for stakeholder review or gate package
- A threshold breach is detected and escalation is needed
- AI/ML model metrics need to be captured post-deployment
- Governance metrics (gate pass rate, artefact completion) need reporting
- Baseline metrics need to be established at the start of Phase 4

## Instructions

### Step 1: Identify the Metrics Category
Determine which categories apply to the current context:
- **Delivery metrics**: velocity, cycle time, lead time (Phase 4+)
- **Quality metrics**: defect density, test coverage, MTTR (Phase 4+)
- **Product metrics**: adoption, feature utilization, NPS (Phase 6+)
- **AI/ML metrics**: model accuracy, latency, drift rate (Phase 4+ for AI projects)
- **Governance metrics**: gate pass rate, waiver rate, artefact completion (all phases)

### Step 2: Collect the Raw Data
For each metric, identify the data source:
- Sprint tracking tool (velocity, commitment)
- Test management tool (coverage, defect counts)
- Monitoring dashboard (latency, error rates, drift)
- User analytics (adoption, feature utilization)
- Lifecycle artefacts (artefact completion, gate outcomes)

Collect data at the defined cadence (see metrics catalog for each metric's collection cadence).

### Step 3: Calculate the Metric
Use the formula from `references/metrics-catalog.md`. Do not estimate or approximate — use actual measurements. If data is unavailable, document the data gap as a risk and note the metric as "not available — data gap."

### Step 4: Compare Against Thresholds
For each metric:
- Compare the calculated value against the defined target threshold
- Classify as: **On Target** / **Warning** (within 10% of threshold) / **Breached** (below threshold)
- Any breached metric triggers an action: investigate root cause, define corrective action, assign owner and due date

### Step 5: Produce the Metrics Report
Generate the metrics report using the appropriate template:
- Sprint metrics: include in sprint review record
- Phase metrics: include in gate pack
- Operations metrics: use `templates/phase-6/service-report.md.template`
- AI metrics: use `templates/phase-6/ai-monitoring-report.md.template`

The report must include: metric name, value, target, status (On Target/Warning/Breached), trend (improving/stable/degrading), and action (if any).

### Step 6: Escalate Breached Metrics
If any metric is Breached:
- Create or update the relevant risk register entry
- Notify the metric owner
- Define a corrective action with timeline
- Track corrective action in the improvement backlog
- At next sprint review, re-evaluate the metric

### Step 7: Record in Evidence Index
After producing the metrics report:
- Register it in the evidence index with the gate it satisfies
- Note which metrics were not available and why

## Key Principles
1. **Metrics without targets are vanity** — always define target thresholds before collecting.
2. **Trends matter more than snapshots** — a metric at 80% of target but improving is better than one at 95% and degrading.
3. **AI metrics require baselines** — establish model accuracy and latency baselines at Phase 4 Gate D; deviations in Phase 6 are measured against these baselines.
4. **Governance metrics catch process failures** — a high waiver rate signals the team is under-investing in readiness.
5. **Do not interpolate missing data** — a data gap is a risk to be documented, not a number to be guessed.

## Reference Materials
- `references/metrics-catalog.md` — Complete catalog with formulas, targets, collection methods, and owners
- `templates/phase-6/service-report.md.template` — Operational metrics report template
- `templates/phase-6/ai-monitoring-report.md.template` — AI monitoring report template

## Quality Checks
- All reported metrics include formula, actual value, target, and status
- Breached metrics have an assigned corrective action and owner
- AI metrics include baselines established at Gate D
- Metrics report is registered in the evidence index
- Collection cadence is being met (no gaps of more than 2 sprints for delivery metrics)
