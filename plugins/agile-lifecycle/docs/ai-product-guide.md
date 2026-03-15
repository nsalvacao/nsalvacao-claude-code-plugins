# AI Product Guide

This guide covers the additional activities and considerations when using agile-lifecycle for AI/ML and GenAI products.

## Quick Setup

Run `/agile-tailoring ai-ml` to activate the full AI/ML overlay.

## AI Activities by Phase

### Phase 1 — Discovery & Framing
- Document AI/ML justification in Opportunity Brief (why AI, not just software?)
- Complete AI Data Feasibility Note (data availability, quality, labeling)
- Assess AI-specific risks: data quality, bias, regulatory compliance
- Use the `ai-lifecycle` skill from the start

### Phase 2 — Architecture & Planning
- AI/ML architecture: model type selection, data pipeline design, infrastructure
- Data architecture: storage, preprocessing, versioning, governance
- Training data requirements documented (volume, quality, labeling)
- Experiment backlog defined alongside product backlog

### Phase 3 — Iteration Design
- Experiment acceptance criteria defined (not just feature acceptance criteria)
- Test data requirements per sprint
- Model evaluation criteria in DoD

### Phase 4 — Build & Integrate
The `ai-implementation` agent (4.3) guides:
- Experiment design and hypothesis documentation
- Training runs with hyperparameter logging
- Evaluation against baseline metrics
- Experiment Log (all runs, results, learnings)
- Model Card (interim, updated at Phase 5)

### Phase 5 — Validate & Gate
The `ai-model-validation` agent (5.2) is mandatory for AI projects:
- Performance evaluation vs. targets
- Bias and fairness assessment
- Safety evaluation
- **Red-team testing (MANDATORY for LLM projects — Gate D/E criterion)**
- Model Card finalization

### Phase 6 — Release
For AI/ML, use phased rollout:
- Shadow mode (compare AI vs. baseline, no user impact)
- Canary (small % traffic)
- Full rollout

Monitor model performance during hypercare alongside system metrics.

### Phase 7 — Operate & Improve
The `ai-ops-analyst` agent (7.2) manages:
- Model drift monitoring (data drift + concept drift)
- Retraining triggers (drift threshold, time-based, performance SLA breach)
- Retraining pipeline coordination
- AI Monitoring Reports (monthly)

## LLM-Specific Considerations

| Topic | What to Do |
|-------|-----------|
| Prompt engineering | Version prompts, evaluate systematically, log in Experiment Log |
| Hallucination | Evaluate in Phase 5 validation; monitor via feedback loops in Phase 7 |
| Red-teaming | Mandatory at Gate E: prompt injection, jailbreaking, harmful content |
| Token cost | Track as a metric; set cost SLO; monitor in Phase 7 |
| RAG pipeline | Document in data architecture; evaluate retrieval quality in Phase 5 |

## Key AI Artefacts

| Artefact | Template | Phase | Gate |
|----------|---------|-------|------|
| AI Data Feasibility Note | `templates/phase-1/feasibility-note.md.template` | 1 | A |
| AI Experiment Log | `templates/phase-4/ai-experiment-log.md.template` | 4 | D |
| Model Card | `templates/phase-4/model-card.md.template` | 4-5 | E |
| Dataset Documentation | `templates/phase-4/dataset-doc.md.template` | 4 | D |
| AI Validation Report | `templates/phase-5/ai-validation-report.md.template` | 5 | E |
| AI Monitoring Report | `templates/phase-7/ai-monitoring-report.md.template` | 7 | — |

## References
- `references/genai-overlay.md` — Complete GenAI/LLM overlay
- `skills/ai-lifecycle/SKILL.md` — AI lifecycle skill
- `skills/ai-lifecycle/references/ai-overlay.md` — AI activities by phase
