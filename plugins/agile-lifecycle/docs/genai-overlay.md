# GenAI / LLM Overlay

This guide covers the additional activities and considerations when your agile-lifecycle project includes GenAI or LLM components.

## Quick Setup

Activate the GenAI overlay when your project:
- Uses LLM APIs (OpenAI, Anthropic, Google Gemini, etc.)
- Deploys local LLMs (LLaMA, Mistral, etc.)
- Includes embedding models (semantic search, RAG)
- Uses multi-modal models (vision + text, audio + text)

## When to Use GenAI Decisions

| Phase | Decision Point | Key Activity |
|-------|---|---|
| **Phase 1** | Justify LLM over simpler approaches | Include LLM justification in Opportunity Brief |
| **Phase 1** | Model token costs | Add cost estimates to Funding Recommendation |
| **Phase 1** | Data privacy | Assess data classification and provider agreement fit |
| **Phase 2** | LLM architecture | Document provider, prompt strategy, cost controls in ADR |
| **Phase 2** | Prompt versioning | Define how prompts are authored, reviewed, and deployed |
| **Phase 3** | Evaluation metrics | Design evaluation criteria before building |
| **Phase 3** | RAG pipeline (if used) | Confirm document sources, chunking, embedding model |
| **Phase 4** | Prompt lifecycle | Version-control all prompts; test before deploying |
| **Phase 4** | Risk tracking | Monitor hallucination, prompt injection, data leakage, cost |
| **Phase 5** | Red-teaming | Test for prompt injection, jailbreaking, harmful outputs |
| **Phase 5** | Model Card | Document model, version, intended use, limitations |
| **Phase 6** | Cost monitoring | Track token cost, latency, quality metrics, user feedback |

## Phase-by-Phase Checklist

### Phase 1 — Opportunity & Portfolio Framing

- [ ] **LLM Justification:** Why LLM over rule-based or ML? What's the fallback?
- [ ] **Data Privacy:** What data goes to the LLM? Does provider's data agreement cover it?
- [ ] **Cost Model:** Estimate tokens per request, monthly volume, total monthly cost at P50 and P95
- [ ] **Provider Selected:** Specific provider and model identified

**Gate A:** LLM justification and cost model in Funding Recommendation

### Phase 2 — Inception & Product Framing

- [ ] **LLM Architecture ADR:** Document provider choice, prompt strategy, context window approach, cost controls
- [ ] **Prompt Standards:** Define authorship, review, versioning, who can change prompts in production
- [ ] **RAG Architecture (if applicable):** Index type, document ingestion pipeline, retrieval metrics defined

**Gate B:** ADR for LLM provider and prompt versioning strategy exists

### Phase 3 — Discovery & Backlog Readiness

- [ ] **Prompt Backlog:** Define baseline prompts for each LLM-powered feature with expected examples
- [ ] **Evaluation Framework:** How will you measure output quality? (accuracy, relevance, safety, format compliance)
- [ ] **Hallucination Detection:** How will you detect and handle incorrect outputs?
- [ ] **RAG Data Pipeline (if applicable):** Documents accessible, chunking strategy defined, embedding model selected

**Gate C:** Evaluation framework documented; prompt backlog exists for all LLM features

### Phase 4 — Iterative Delivery & Continuous Validation

- [ ] **Prompt Version Control:** All prompts in code repo or prompt store with change logs
- [ ] **Evaluation in Sprint:** Test prompt changes against evaluation set before deploying
- [ ] **Experiment Log:** Document every test — hypothesis, variables changed, metric, result, decision
- [ ] **Risk Register:** Include hallucination, prompt injection, data leakage, bias, cost, provider outage
- [ ] **Prompt Injection Testing:** Sprint DoD includes testing user-facing LLM features for injection vulnerabilities
- [ ] **Minimum Evaluation:** 20+ evaluation examples per feature before production

**AI Delivery Loop (Sub-phase 4.3):** research → prompt design → evaluate → refine → adopt

### Phase 5 — Validation & Release

- [ ] **Model Card:** Document model used, version, provider, intended use, known limitations, evaluation results
- [ ] **Red-Team Testing (MANDATORY for user-facing LLM):** Test prompt injection, jailbreaking, sensitive data extraction, harmful content
- [ ] **Hallucination Evaluation:** Measure hallucination rate; document acceptable threshold and any mitigations
- [ ] **LLM Monitoring Live:** Token cost dashboard, latency tracking (P50/P95/P99), output sampling, feedback mechanism

**Gate D/E:** Model Card reviewed; red-team evidence reviewed; hallucination evaluation documented

### Phase 6 — Operations & Measurement

- [ ] **Weekly Metrics:** Token cost per request, latency (P95/P99), output quality sampling, user feedback rate
- [ ] **Monthly Drift Check:** Is quality degrading? Trigger prompt review if >10% drop
- [ ] **Cost Anomaly Alerts:** Alert if daily cost exceeds 150% of baseline
- [ ] **Caching Metrics (if applicable):** Monitor cache hit rate; tune caching strategy if <20% hits
- [ ] **Incident Response:** Define LLM-specific runbook (model rollback, feature flag disable, prompt hot-fix)

## Do's and Don'ts

### Do

- ✓ Version-control prompts like code
- ✓ Evaluate before deploying to production
- ✓ Monitor token cost and set budgets
- ✓ Test for prompt injection regularly
- ✓ Document LLM architecture decisions in ADRs
- ✓ Include hallucination evaluation for factual accuracy use cases
- ✓ Use RAG grounding (cite retrieved sources) where accuracy matters
- ✓ Red-team user-facing LLM features before release

### Don't

- ✗ Deploy untested prompts to production
- ✗ Treat prompts as configuration (they are code)
- ✗ Assume LLM output is always correct without validation
- ✗ Skip red-team testing for user-facing LLM features
- ✗ Ignore cost monitoring; token usage can spike unexpectedly
- ✗ Send raw user data or secrets to LLM APIs without filtering
- ✗ Rely on a single LLM provider without documented fallback

## LLM Risk Quick Reference

| Risk | What It Means | Quick Mitigation |
|------|---|---|
| **Hallucination** | Model generates plausible but wrong information | Evaluation framework; RAG grounding; output validation |
| **Prompt Injection** | User input manipulates system prompt or model behavior | Input sanitization; prompt injection testing per sprint |
| **Data Leakage** | User data or system details exposed in LLM response | PII filtering before API call; output scanning |
| **Bias** | Model produces unfair or stereotyped outputs | Red-team testing; evaluate on representative dataset |
| **Cost Overrun** | Token usage exceeds budget | Cost alerts; caching; model tiering; rate limits |
| **Provider Outage** | LLM API unavailable | Documented fallback to degraded mode or alternative provider |

## Key Artefacts

| Artefact | Phase | Gate |
|----------|-------|------|
| LLM Justification (in Opportunity Brief) | 1 | A |
| LLM Architecture ADR (in Initial Architecture Pack) | 2 | B |
| Evaluation Framework (in Backlog) | 3 | C |
| Experiment Log (versioned prompts + test results) | 4 | D |
| Model Card | 4-5 | E |
| Red-Team Evidence | 5 | E |
| Hallucination Evaluation Report | 5 | E |
| AI Monitoring Report (monthly) | 6 | — |

## References

- `references/genai-overlay.md` — Complete GenAI/LLM overlay reference with all activities and criteria
- `docs/ai-product-guide.md` — Full AI/ML product guide
- `skills/ai-lifecycle/SKILL.md` — AI lifecycle skill for extended guidance
