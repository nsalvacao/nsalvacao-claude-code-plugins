---
name: ai-lifecycle
description: This skill should be used when a project includes AI/ML components and needs guidance on experiment design, model card creation, AI validation, bias and fairness assessment, LLM red-teaming, or drift monitoring configuration. Applies when a user asks to design an AI experiment, plan model validation, set up ML monitoring, or assess AI-specific gate criteria (Gates D and E).
---

# AI Lifecycle

## Purpose
AI/ML projects have lifecycle activities that do not exist in standard software delivery. These include experiment design, training data management, model evaluation, bias/fairness assessment, and ongoing drift monitoring. This skill operationalizes these AI-specific activities at each lifecycle phase and ensures AI governance requirements are met at each gate.

## When to Use
- The project includes any AI/ML component (model, LLM integration, data pipeline)
- AI-specific gate criteria need to be assessed (model card at Gate D, red-team at Gate D for LLMs)
- An experiment needs to be designed, tracked, or evaluated
- Model validation needs to be planned or executed
- AI monitoring needs to be configured for Phase 6
- A GenAI/LLM-specific activity (prompt engineering, red-teaming) needs to be performed

## Instructions

### Step 1: Confirm AI Component Type
Classify the AI component to determine which activities apply:
- **Classical ML model**: supervised/unsupervised learning, trained on structured data
- **Deep learning model**: neural networks, image/audio/NLP tasks
- **LLM integration**: using a foundation model API (GPT, Claude, etc.) with prompts
- **GenAI pipeline**: RAG, agents, tool-calling patterns with LLMs
- **Data pipeline**: data transformation, feature engineering (no model, but data-specific risks)

### Step 2: Apply Phase-Specific AI Activities
Consult `references/ai-overlay.md` for the full phase-by-phase AI activity list. Key activities per phase:
- **Phase 1**: AI justification, data feasibility assessment, initial AI risk note
- **Phase 2**: AI architecture decision, data architecture, model selection rationale
- **Phase 3**: Training data requirements, experiment backlog creation
- **Phase 4**: Experiment loop (hypothesis → train → evaluate → decide), model card creation
- **Phase 5**: AI validation (accuracy, bias, fairness, safety, red-team for LLMs)
- **Phase 6–7**: Drift monitoring, retraining triggers, model performance reporting, version management

### Step 3: Design and Track Experiments
For each AI experiment in Phase 4:
1. **Hypothesis**: "We believe [approach] will achieve [metric] because [rationale]"
2. **Dataset**: define training/validation/test splits and data version
3. **Baseline**: define baseline model or heuristic to compare against
4. **Success criteria**: specific metric threshold (e.g., "accuracy ≥ 0.85 on validation set")
5. **Timebox**: maximum effort before evaluating and deciding
6. **Record in AI experiment log**: `templates/phase-4/experiment-log.md.template`

### Step 4: Produce the Model Card
At Gate D, a model card is mandatory for any trained ML model. The model card must include:
- Model type and architecture summary
- Training dataset description (size, source, version, data period)
- Evaluation metrics (accuracy, precision, recall, F1, RMSE — as applicable)
- Fairness evaluation results (performance across demographic segments if applicable)
- Known limitations and failure modes
- Intended use cases
- Out-of-scope use cases

### Step 5: Execute AI Validation (Phase 5)
Before Gate E, AI validation must cover:
- **Accuracy validation**: confirm model meets accuracy threshold on held-out test set
- **Bias assessment**: evaluate performance across segments; document disparities
- **Fairness check**: confirm acceptable fairness metrics (see model card for thresholds)
- **Safety evaluation**: for LLMs — test for harmful content generation, refusal behaviors
- **Red-team evaluation** (LLMs): adversarial testing for prompt injection, jailbreaks, harmful outputs

### Step 6: Configure AI Monitoring (Phase 6)
After Gate E, AI monitoring must be live before hypercare period begins:
- Input drift monitoring (PSI or JS divergence)
- Prediction distribution monitoring
- Model accuracy estimation (if labels available)
- Latency monitoring (p50, p95, p99)
- Alert thresholds set and tested
- Retraining pipeline defined (trigger conditions, process, approvals)

### Step 7: LLM-Specific Activities
For projects using LLMs:
- **Prompt engineering lifecycle**: version prompts, track changes, evaluate prompt performance
- **Red-teaming at Gate D**: mandatory — document adversarial test scenarios and results
- **Hallucination management**: implement output validation, citation requirements, or RLHF guardrails
- **Prompt injection protection**: implement input sanitization and output filtering

## Key Principles
1. **AI justification before investment** — AI is not always the right solution; document why AI is needed in Phase 1.
2. **Experiments are time-boxed, not open-ended** — an experiment without a timebox and decision point is not an experiment; it is scope creep.
3. **Model cards are not optional** — at Gate D, no model card means gate fails on criterion D6.
4. **Red-teaming is mandatory for LLMs at Gate D** — security and safety testing is not optional for generative models.
5. **Drift is inevitable** — plan for retraining from Day 1 of Phase 6; do not treat it as an edge case.

## Reference Materials
- `references/ai-overlay.md` — Full AI/ML activity overlay per phase with trigger conditions and evidence requirements
- `skills/risk-management/references/risk-patterns.md` — AI-specific risk patterns
- Schema: `schemas/definition-of-done.schema.json` (includes AI/ML DoD additions)

## Quality Checks
- AI justification documented in Phase 1 artefacts
- Experiment log updated after each experiment cycle
- Model card produced before Gate D review
- Red-team evidence present for LLM projects at Gate D
- AI monitoring live with tested alerts before Gate F
- Drift threshold defined and documented in model card
