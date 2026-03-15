# AI/ML Lifecycle Overlay

## Overview
This document defines the AI/ML-specific activities, artefacts, and gate criteria that overlay the standard 7-phase lifecycle for projects containing AI or ML components. It also covers GenAI/LLM-specific requirements.

---

## Phase 1 — Opportunity and Portfolio Framing

### AI-Specific Activities
- **AI justification**: Document why AI is necessary (vs rule-based, heuristic, or manual approaches). Include the fallback scenario if AI fails or is removed.
- **Data feasibility assessment**: Assess whether sufficient data exists (volume, variety, quality, access rights). Produce `ai-data-feasibility-note.md`.
- **AI risk assessment**: Identify initial AI-specific risks: data availability, bias potential, regulatory constraints (GDPR for personal data, HIPAA for medical data), ethical considerations.
- **AI ROI framing**: Estimate the value AI could deliver vs. the cost of data, training, and maintenance.

### Gate A AI Criteria
- AI justification documented in opportunity statement or separate note
- Data feasibility assessed (even if preliminary)
- AI-specific risks noted in initial risk register

---

## Phase 2 — Inception and Product Framing

### AI-Specific Activities
- **AI architecture decision**: Choose model type (classical ML, deep learning, LLM, hybrid). Document rationale in initial ADR. Consider: interpretability requirements, latency constraints, cost of training vs. inference.
- **Data architecture**: Define data sources, ingestion pipeline, storage, versioning, lineage tracking. Assess data governance requirements.
- **Model selection rationale**: If using a foundation model (LLM): which model, which API, what constraints. If training from scratch: which algorithm family, what hardware needed.
- **MLOps tooling decision**: Choose experiment tracking (MLflow, W&B), model registry, serving infrastructure.
- **Privacy impact assessment**: If using personal data — assess GDPR compliance, data minimization, purpose limitation.

### Gate B AI Criteria
- AI architecture decision recorded in ADR
- Data architecture documented
- MLOps tooling selected and justified
- Privacy impact assessment completed (if personal data)

---

## Phase 3 — Discovery and Backlog Readiness

### AI-Specific Activities
- **Training data requirements**: Define minimum dataset size, data quality thresholds, labeling requirements, data collection timeline.
- **Experiment backlog**: Create backlog items for AI experiments: data collection, preprocessing, model training, evaluation. Each experiment must have a hypothesis and success criteria.
- **Data readiness assessment**: Assess current data state against training requirements. Identify gaps and data collection plan.
- **Labeling plan**: If supervised learning with unlabeled data — define labeling process, tooling, quality control.

### Gate C AI Criteria (if AI component)
- Training data requirements documented
- Experiment backlog created with at least first 2 experiments defined
- Data readiness assessment completed

---

## Phase 4 — Iterative Delivery and Continuous Validation

### AI-Specific Activities

#### Experiment Loop
Each experiment cycle follows:
1. **Hypothesis**: "We believe [approach/feature/architecture change] will improve [metric] by [amount] because [rationale]"
2. **Setup**: data version pinned, baseline defined, success criteria specified
3. **Execute**: train model or evaluate approach within timebox
4. **Evaluate**: measure against success criteria and baseline
5. **Decide**: validate (ship), pivot (try different approach), or abandon (accept baseline)
6. **Document**: update AI experiment log with all results, learnings, next steps

#### Model Training
- Version control training data (hash or data version tag)
- Track hyperparameters, training configuration, environment
- Evaluate on held-out validation set, not training set
- Document training time, compute cost, energy consumption

#### Model Evaluation
- Accuracy metrics: appropriate to task (classification: F1, AUC; regression: RMSE, MAE; ranking: nDCG)
- Calibration: predicted probabilities should match observed frequencies
- Fairness: evaluate across demographic segments if applicable
- Robustness: test on edge cases, out-of-distribution inputs

#### Model Card Production (mandatory before Gate D)
Model card must contain:
- Model type, architecture, training framework
- Training dataset: source, size, data period, version, known limitations
- Evaluation results: all metrics on validation and test sets
- Fairness evaluation: performance by segment (if applicable)
- Intended use: specific use cases the model is designed for
- Out-of-scope use: cases where the model should NOT be used
- Known limitations: edge cases, failure modes
- Maintenance: drift threshold, retraining cadence

### Gate D AI Criteria
- AI experiment log complete and up to date
- Model card produced (mandatory if ML model trained)
- Red-team evidence produced (mandatory if LLM used)
- Dataset documentation complete
- Integration test includes AI inference paths

---

## Phase 5 — Release, Rollout and Transition

### AI-Specific Activities

#### AI Validation (pre-Gate E)
- **Accuracy validation**: test against held-out test set; confirm meets model card threshold
- **Bias assessment**: evaluate performance across demographic segments; document disparities
- **Fairness check**: confirm acceptable fairness metrics
- **Safety evaluation** (LLMs): test for harmful content generation, instruction following, refusal behaviors
- **Red-team evaluation** (LLMs):
  - Prompt injection attacks
  - Jailbreak attempts
  - Harmful content generation
  - Data exfiltration attempts
  - Document all scenarios tested and outcomes

#### Deployment Patterns for AI Models
- **Shadow mode**: new model runs in parallel with production model; predictions logged but not served. Used to validate in production traffic without risk.
- **Canary deployment**: new model serves a small percentage (1–5%) of traffic. Monitor for regressions before full rollout.
- **Blue-green deployment**: full switch with instant rollback capability. Used when shadow/canary validation is complete.
- **A/B testing**: serve model to randomly assigned user segments; compare business metrics (not just model metrics).

### Gate E AI Criteria
- AI validation report produced and approved
- Red-team evidence present (if LLM)
- Deployment pattern documented and approved
- AI monitoring plan ready for Phase 6

---

## Phase 6 — Operate, Measure and Improve

### AI-Specific Activities

#### Drift Monitoring
- **Input drift**: monitor distribution of input features vs. training distribution (PSI or JS divergence)
- **Prediction drift**: monitor distribution of model outputs
- **Concept drift**: monitor relationship between inputs and labels (requires ground truth labels)
- Alert thresholds: PSI > 0.1 (warning), PSI > 0.2 (significant drift — investigate/retrain)

#### Retraining Triggers
Define retraining conditions upfront. Triggers may include:
- Drift threshold breached
- Accuracy drops below defined threshold
- Scheduled retraining cadence (e.g., monthly)
- Significant distribution shift in input data (new product category, market event)
- Team judgment after monitoring review

#### Retraining Pipeline
- Automated pipeline for data collection → preprocessing → training → evaluation → promotion
- Human approval gate before promoting new model to production
- Rollback mechanism: previous model must remain deployable for at least 30 days

#### AI Monitoring Report (monthly)
Contents:
- Drift metrics: PSI trend for last 30 days
- Accuracy metrics: estimated accuracy trend (if labels available)
- Latency metrics: p50, p95, p99 trend
- Incidents: AI-related incidents in period
- Retraining status: scheduled, triggered, or none
- Recommendation: continue, monitor closely, or retrain

### Gate F AI Criteria (if AI component)
- AI monitoring live and tested alerts working
- Retraining pipeline documented and tested
- AI monitoring report produced for hypercare period
- Drift thresholds defined and configured

---

## Phase 7 — Retire or Replace

### AI-Specific Activities
- **Model retirement**: remove model from serving; document final model performance metrics
- **Dataset archiving**: archive training datasets per data retention policy
- **Model card archiving**: final model card with full lifecycle history
- **Experiment log archiving**: preserve experiment learnings for future projects
- **Legal/compliance**: confirm data deletion obligations met (if personal data used in training)

---

## LLM-Specific Activities

### Prompt Engineering Lifecycle
1. **Draft**: write initial prompt with role, context, instructions, examples
2. **Evaluate**: test against representative inputs; measure quality metrics (task completion, accuracy, style)
3. **Iterate**: modify prompt based on evaluation; version control all prompt changes
4. **Freeze**: lock production prompt version; changes go through change control
5. **Monitor**: track output quality metrics in production; alert on quality degradation

### Red-Teaming (mandatory at Gate D)
Red-team scope must include:
- Direct prompt injection: "Ignore previous instructions..."
- Indirect prompt injection (via retrieved content in RAG)
- Jailbreak patterns: role-play, hypothetical framing, DAN-style
- Harmful content requests: violence, hate speech, self-harm, CSAM
- Data exfiltration: extracting system prompt, training data, other user data
- Social engineering assistance

Red-team evidence must document:
- Test scenarios used
- Results (pass/fail for each scenario)
- Mitigations implemented for failed scenarios
- Residual risk accepted

### Hallucination Management
- Implement output validation (factual checks where possible)
- Retrieval-augmented generation (RAG) reduces hallucination for knowledge-intensive tasks
- Require citations for factual claims
- Human-in-the-loop for high-stakes decisions
- Monitor hallucination rate in production (human or automated evaluation)

### Prompt Injection Protection
- Input sanitization layer: filter or escape injection patterns
- Output filtering: detect and block harmful or policy-violating outputs
- Privilege separation: system prompt and user input in separate contexts
- Rate limiting and anomaly detection on inputs
