# GenAI / LLM Overlay

## Overview

This overlay defines additional lifecycle activities, gate criteria, and governance controls that apply when a project includes GenAI or LLM components. The overlay is additive — it does not replace standard lifecycle activities but adds LLM-specific requirements at each phase.

**Applicability:** Apply this overlay when the project uses any of the following:
- Large Language Model APIs (OpenAI, Anthropic, Google Gemini, etc.)
- Open-source LLMs deployed locally (LLaMA, Mistral, etc.)
- Embedding models used for semantic search or RAG
- Multi-modal models (vision, audio, text combined)
- Fine-tuned or instruction-tuned model variants

---

## Phase 1 — Opportunity and Portfolio Framing: GenAI Triggers

**Additional activities:**

1. **LLM Justification:** The AI/Data Feasibility Note must include a specific section answering:
   - Why is an LLM necessary rather than a simpler ML or rule-based approach?
   - What is the fallback if the LLM provider is unavailable or too expensive?
   - What data will be passed to the LLM API? Is any of it sensitive or regulated?

2. **Cost Modelling:** Include token cost estimates in the Funding Recommendation:
   - Estimated tokens per user request (input + output)
   - Estimated request volume per month
   - Cost per 1M tokens for chosen model(s)
   - Monthly cost projection at P50 and P95 usage

3. **Data Privacy Pre-Assessment:** If user data or business-sensitive data will be sent to an LLM API:
   - Identify data classification of content to be sent
   - Confirm whether the API provider's data processing agreement covers the data type
   - Flag if GDPR/CCPA/sector regulation applies

**Gate A additional criteria:**
- AI/Data Feasibility Note includes LLM justification section.
- LLM provider identified with cost model in Funding Recommendation.
- Data privacy pre-assessment documented if user data is involved.

---

## Phase 2 — Inception and Product Framing: GenAI Triggers

**Additional activities:**

1. **LLM Architecture Decision Record:** The Initial Architecture Pack must include an ADR covering:
   - LLM API provider selection and rationale
   - Prompt strategy: zero-shot, few-shot, chain-of-thought, or tool-use
   - Context window management strategy (chunking, truncation, summarisation)
   - Cost control mechanisms (caching, rate limiting, model tiering)
   - Fallback strategy if LLM API is unavailable

2. **Prompt Engineering Standards:** Define in the Working Model:
   - How prompts are authored, reviewed, and versioned
   - Who has authority to change prompts in production
   - Prompt versioning strategy (linked to code versioning or separate)

3. **RAG Architecture (if applicable):** If using Retrieval-Augmented Generation:
   - Document index architecture in Initial Architecture Pack
   - Identify document ingestion pipeline owner
   - Define retrieval quality metrics (e.g. recall@k)

**Gate B additional criteria:**
- ADR for LLM API provider and prompt strategy exists.
- Prompt versioning strategy documented.

---

## Phase 3 — Discovery and Backlog Readiness: GenAI Triggers

**Additional activities:**

1. **Prompt Engineering Backlog:** AI Backlog Items must include:
   - Prompt design items for each LLM-powered feature
   - Evaluation items (how will the output quality be measured?)
   - Baseline prompts with expected output examples

2. **Evaluation Framework Design:** Before Phase 4 begins:
   - Define evaluation criteria for LLM outputs (relevance, accuracy, safety, format compliance)
   - Identify evaluation method: human eval, automated eval (LLM-as-judge), reference dataset, or combination
   - Define hallucination detection approach

3. **Data Pipeline Readiness (RAG):** Data Readiness Notes must include:
   - Source documents identified and accessible
   - Chunking strategy defined
   - Embedding model selected
   - Index infrastructure provisioned or planned

**Gate C additional criteria:**
- Evaluation framework for LLM outputs is documented.
- Prompt design backlog items exist for all LLM-powered features.
- RAG data pipeline (if applicable) is confirmed accessible.

---

## Phase 4 — Iterative Delivery and Continuous Validation: GenAI Triggers

**Additional activities:**

1. **Prompt Lifecycle Management:**
   - All prompts are version-controlled (in code repository or dedicated prompt store)
   - Each prompt change is tested against evaluation set before deployment
   - Prompt changes that affect output behavior trigger a regression test run

2. **Experiment Tracking:** Every LLM experiment must be logged in the Experiment Log with:
   - Hypothesis (what output improvement are we testing?)
   - Variables changed (model, prompt template, temperature, chunk size, etc.)
   - Evaluation method and metric
   - Result and decision (adopt, reject, further explore)

3. **LLM Risk Management:**
   - Risk register must include LLM-specific risk categories: hallucination, prompt injection, data leakage, bias, cost overrun, provider outage
   - Each risk must have a mitigation and contingency entry
   - Prompt injection controls are tested per sprint for user-facing LLM features

4. **Output Quality Validation:**
   - Sprint DoD must include LLM output quality gate (evaluation metrics meet threshold)
   - Automated evaluation runs in CI pipeline (if using reference-based or automated evaluation)

**AI Delivery Loop (Subfase 4.3) — LLM specifics:**
- Sprint rhythm: research → prompt design → evaluation → refine → evaluate → adopt
- Minimum viable evaluation: at least 20 examples per feature before production deployment
- Experiment success definition must be measurable (not subjective)

---

## Phase 5 — Release, Rollout and Transition: GenAI Triggers

**Additional activities:**

1. **Model Card Production:** Before Gate D:
   - Produce a Model Card documenting: model used, version, provider, intended use, out-of-scope uses, known limitations, evaluation results
   - Model Card must be reviewed by Engineering Lead and Product Owner

2. **Red-Team Evidence:** Before Gate D:
   - Conduct adversarial testing of all LLM-powered user-facing features
   - Test categories: prompt injection, jailbreak attempts, sensitive data extraction, harmful content generation, hallucination in critical paths
   - Document red-team scope, methodology, findings, and mitigations
   - Red-team evidence must be at `reviewed` threshold at Gate D

3. **Hallucination Evaluation:** Before Gate D:
   - Produce a hallucination evaluation report for all LLM outputs where factual accuracy matters
   - Define and document the acceptable hallucination rate for the product use case
   - If hallucination rate exceeds threshold, document the risk acceptance or remediation plan

4. **LLM Monitoring Setup:** Before Gate E:
   - LLM output sampling and logging enabled in production
   - Token cost monitoring dashboards operational
   - Latency monitoring (P50, P95, P99) for all LLM API calls
   - Feedback collection mechanism in place (thumbs up/down, explicit rating, or implicit signals)

**Gate D additional criteria (LLM-specific):**
- Model Card exists and is reviewed.
- Red-team evidence exists and is reviewed. **Cannot be waived for externally-facing LLM features.**
- Hallucination evaluation is documented.
- LLM monitoring setup is confirmed operational.

---

## Phase 6 — Operations, Measurement and Improvement: GenAI Triggers

**Additional activities:**

1. **Ongoing Model Monitoring:** AI Monitoring Reports must include:
   - Token cost per request (trend and absolute)
   - Inference latency P95 and P99 (trend)
   - Output quality sampling (random sample of outputs evaluated weekly)
   - User feedback signals (thumbs up/down rate, explicit ratings if collected)
   - Drift indicators (if available via feedback or ground truth comparison)

2. **Retraining / Prompt Refresh Triggers:** Define and monitor:
   - Performance degradation threshold that triggers prompt review (e.g. >10% drop in quality score)
   - Provider model version changes (monitor provider release notes)
   - Significant data distribution shift (if using RAG: document corpus has changed significantly)

3. **Cost Governance:**
   - Monthly token cost vs budget reviewed in Service Reports
   - Cost anomaly alerts configured (e.g. >150% of baseline daily cost → alert)
   - Caching effectiveness monitored (cache hit rate for repeated prompts)

4. **LLM Incident Response:**
   - Incidents involving LLM output harm, data leakage, or cost anomaly are classified as P1 or P2
   - Runbook includes LLM-specific incident response (model rollback, prompt disable, feature flag off)

---

## Prompt Engineering Lifecycle

Prompts are first-class software artifacts. They follow this lifecycle:

| Stage | Activity | Evidence |
|-------|----------|----------|
| **Design** | Write prompt with clear role, context, instruction, and output format | Prompt template in repository |
| **Evaluate** | Run prompt against evaluation set; measure against defined metrics | Evaluation results document |
| **Refine** | Iterate on prompt based on evaluation failures | Updated prompt + re-evaluation |
| **Version** | Commit prompt version to version control with changelog note | Git commit or prompt store version |
| **Deploy** | Deploy prompt via standard CI/CD pipeline | Deployment record |
| **Monitor** | Monitor production outputs for quality and cost | AI Monitoring Report |
| **Retire** | Replace with improved version; archive old version | Changelog entry |

---

## LLM Risk Categories

| Category | Description | Primary Mitigation |
|----------|-------------|-------------------|
| **Hallucination** | Model generates plausible but incorrect or fabricated information | Evaluation framework; grounding via RAG; output validation |
| **Bias** | Model produces outputs that unfairly discriminate or reinforce stereotypes | Red-team testing; bias evaluation on representative dataset |
| **Data Leakage** | User data or system prompts exposed via model responses or context window | Strict prompt design; PII filtering; output scanning |
| **Prompt Injection** | Malicious user input manipulates system prompt or hijacks model behavior | Prompt injection testing; input sanitization; sandboxing |
| **Cost Overrun** | Token usage exceeds budget due to verbose prompts or high volume | Token monitoring; cost alerts; caching; model tiering |
| **Provider Outage** | LLM API unavailable | Fallback to degraded mode; multi-provider routing |
| **Model Deprecation** | Provider deprecates the model version in use | Model version monitoring; migration plan per model version |
| **Content Safety** | Model generates harmful, offensive, or inappropriate content | Content safety filters (provider-side or custom); red-team testing |

---

## RAG-Specific Considerations

### Data Pipeline Governance

| Consideration | Requirement |
|---------------|------------|
| Source documents | Catalogued with data classification and owner |
| Ingestion frequency | Defined (real-time, daily, weekly) based on data freshness requirements |
| Chunking strategy | Documented and version-controlled |
| Embedding model | Pinned to specific version; change triggers re-indexing and re-evaluation |

### Retrieval Quality Metrics

| Metric | Definition | Target |
|--------|------------|--------|
| Recall@k | Proportion of relevant documents in top-k retrieved results | ≥ 0.8 for k=5 |
| Precision@k | Proportion of top-k results that are relevant | ≥ 0.6 for k=5 |
| Mean Reciprocal Rank (MRR) | Average position of first relevant result | ≥ 0.7 |
| Faithfulness | LLM output is grounded in retrieved documents | ≥ 0.85 (automated eval) |

### Grounding Controls

- LLM must cite or reference retrieved documents in structured outputs where factual accuracy matters.
- Evaluate grounding (faithfulness) as part of the evaluation framework.
- If retrieved context is insufficient, model should state uncertainty rather than hallucinate.

---

## Fine-Tuning Considerations

If the project involves fine-tuning a base model:

### Dataset Governance

- Training dataset must be catalogued with data provenance, classification, and consent basis.
- Dataset version-controlled and reproducible.
- GDPR/privacy review mandatory if training data includes user data.

### Evaluation

- Fine-tuned model must be evaluated against the base model on the target task.
- Regression evaluation: fine-tuning must not degrade performance on adjacent tasks.
- Catastrophic forgetting check: does the fine-tuned model retain general capability?

### Version Control

- Each fine-tuned model version tracked in Artefact Manifest.
- Model provenance documented: base model + dataset version + training config.
- Rollback plan: previous model version available and deployable within defined time.

---

## AI Monitoring for GenAI (Phase 6 Details)

| Metric | Formula | Cadence | Threshold |
|--------|---------|---------|-----------|
| Token cost per request | `total_tokens_billed / request_count` | Weekly | > 150% target → alert |
| Latency P99 | P99 of inference_ms | Continuous | > 5000ms → alert |
| Quality score (sampled) | Automated eval score on random 5% of outputs | Weekly | < 0.7 → review |
| Feedback positive rate | `positive_feedback / total_feedback` | Weekly | < 0.6 → review |
| Drift indicator | Deviation from baseline quality score | Monthly | > 10% → prompt review |
| Cache hit rate (if caching) | `cache_hits / total_requests` | Weekly | < 20% → caching config review |
| Content safety violation rate | `flagged_outputs / total_outputs` | Daily | > 0 → immediate review |
