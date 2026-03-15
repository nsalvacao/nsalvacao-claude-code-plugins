# Tailoring Guide

Use `/agile-tailoring [product-type]` to configure the lifecycle for your context.

## Tailoring Dimensions

| Dimension | What Changes |
|-----------|-------------|
| Phase scope | Which phases run in full vs. lightweight mode |
| Gate depth | Which gates are mandatory vs. optional |
| Artefact set | Which artefacts are required vs. optional |
| Sprint structure | Sprint length, ceremonies, DoD |
| AI overlay | Whether GenAI overlay activities are active |

## Product Type Profiles

### SaaS Product (agile-tailoring saas)
All 7 phases, all gates, full artefact set. Emphasis on Phase 7 operations, SLA management, and continuous improvement.

### Web Application (agile-tailoring web)
Phases 1-6 in full, Phase 7 pragmatic. Gates A, B, D, E mandatory; C advisory; F lightweight.

### Desktop / CLI Tool (agile-tailoring desktop)
Phases 1-5 emphasis, Phase 6 simplified (no hypercare), Phase 7 minimal. Gates A and E mandatory.

### AI/ML Product (agile-tailoring ai-ml)
Full lifecycle with complete GenAI overlay. All phases and gates active. AI-specific artefacts mandatory: AI Experiment Log, Model Card, AI Validation Report, red-team (if LLM). Gate D requires red-team evidence for LLM.

### Data Product (agile-tailoring data-product)
Emphasis on Phases 2-4 (data architecture, pipeline, quality). Phase 5 AI validation. Phase 6 data operations.

### Internal Tool (agile-tailoring internal)
Phases 1-4 streamlined. Gates A and D only (mandatory). No Phase 7 formal ops. Lighter artefact set.

### MVP / Prototype (agile-tailoring mvp)
Phases 1-3 only. Gate A mandatory (validate before building). All else optional. Minimal artefact set.

## Decision Tree

```
What is your product?
├─ AI/ML or GenAI → ai-ml profile (full overlay)
├─ SaaS with ops commitment → saas profile
├─ Web app → web profile
├─ Desktop/CLI → desktop profile
├─ Data-centric → data-product profile
├─ Internal only → internal profile
└─ MVP/experiment → mvp profile
```

## Custom Tailoring

If no profile fits, configure dimensions individually:
1. Run `/agile-tailoring` without args to enter guided configuration
2. Specify: which phases full/lightweight, which gates mandatory/optional, AI overlay yes/no
3. The lifecycle-orchestrator saves your tailoring to `lifecycle-state.json`

## Tailoring vs. Waiver

Tailoring is done upfront to configure the framework for your context. Waivers are done at gate time when a specific criterion cannot be met despite the tailoring. Do not use waivers as a substitute for proper tailoring.
