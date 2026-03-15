# Tailoring Guide

## Overview

The agile-lifecycle framework is designed to be tailored to different product types, team sizes, and regulatory contexts. Tailoring does not mean skipping governance — it means adjusting the depth, scope, and formality of lifecycle activities to match the risk profile and complexity of the product.

**Non-negotiable:** Gate reviews cannot be eliminated by tailoring. They can be made lighter (fewer criteria, lower evidence thresholds) but the gate event must occur.

---

## Tailoring Dimensions

### 1. Gate Depth

How rigorous the gate review is — number of criteria checked, evidence thresholds required.

| Depth | Description | When appropriate |
|-------|-------------|-----------------|
| Full | All criteria checked; approved threshold for critical artefacts | Regulated, high-risk, or enterprise-scale products |
| Standard | All criteria checked; reviewed threshold acceptable for most artefacts | Internal SaaS, team-scale products |
| Lightweight | Simplified criteria; exists threshold for most; reviewer is same as PM | MVP, prototype, internal tooling |

### 2. Phase Scope

Whether a phase runs in full or lightweight mode.

| Mode | Description | Typical phases |
|------|-------------|----------------|
| Full | All subfases, all artefacts | All phases for regulated products |
| Standard | All subfases, reduced artefact set | Most phases for standard products |
| Lightweight | Subfases merged or abbreviated; 1-2 artefacts per phase | Phase 1, 2 for MVP; Phase 7 for simple decommissioning |

### 3. Artefact Set

Which artefacts are mandatory vs optional.

| Level | Description |
|-------|-------------|
| Full set | All artefacts in the catalog; no skipping |
| Reduced set | Core artefacts mandatory; supporting artefacts optional |
| Minimal set | 1-2 per phase; only those satisfying gate criteria |

### 4. Sprint Structure

Whether sprints are used and how.

| Structure | Description | When appropriate |
|-----------|-------------|-----------------|
| Full Scrum | 2-week sprints, all ceremonies, full DoD | Phase 4 for all product types |
| Kanban-style | Continuous flow, cycle time as primary metric | Phase 6 (operations and improvement) |
| Research sprints | Timeboxed experiments, hypothesis-driven | AI/ML-heavy Phase 3 and 4 |

---

## Product Type Profiles

### SaaS — Standard

**Characteristics:** Multi-tenant, external users, SLO-sensitive, continuous delivery.

| Phase | Mode | Notes |
|-------|------|-------|
| 1 | Standard | Value hypothesis must include MRR/ARR targets |
| 2 | Full | Working Model must include SaaS operating model |
| 3 | Full | User research mandatory; external user journey maps required |
| 4 | Full | CI/CD mandatory; canary deployment in rollout plan |
| 5 | Full | SLA-based hypercare; ops team onboarding mandatory |
| 6 | Full | SLO monitoring; NPS quarterly |
| 7 | Standard | Migration plan mandatory for user data |

**Gates:** All mandatory (A–F). Gate E has extended hypercare criteria.
**Artefacts:** Full set.
**Sprint structure:** Full Scrum (Phase 4); Kanban (Phase 6).

---

### Web Application — Standard

**Characteristics:** Browser-based, internal or external users, SEO/performance sensitive.

| Phase | Mode | Notes |
|-------|------|-------|
| 1 | Standard | Feasibility must include performance and SEO assessment |
| 2 | Standard | Architecture must address CDN, caching, SSR/CSR decision |
| 3 | Standard | User journey maps required; accessibility requirements documented |
| 4 | Full | Accessibility testing (WCAG) mandatory in DoD |
| 5 | Standard | Deployment: blue/green or rolling |
| 6 | Standard | Core Web Vitals tracked as product metrics |
| 7 | Standard | — |

**Gates:** All mandatory. Gate D includes accessibility audit evidence.
**Artefacts:** Full set minus AI-specific artefacts if no AI features.

---

### Desktop / CLI Tool

**Characteristics:** Installed software, developer or power user audience, versioned releases.

| Phase | Mode | Notes |
|-------|------|-------|
| 1 | Lightweight | AI justification may be N/A |
| 2 | Standard | Architecture pack must include distribution mechanism |
| 3 | Lightweight | User research may be internal developer interviews |
| 4 | Full | Release versioning (semver) mandatory; changelog maintained |
| 5 | Standard | Package distribution (npm, PyPI, Homebrew etc.) documented |
| 6 | Lightweight | GitHub Issues or equivalent as feedback channel |
| 7 | Lightweight | Archive repo; deprecation notice in README |

**Gates:** A–E mandatory; F optional (periodic review only if product is actively maintained).
**Artefacts:** Reduced set. AI artefacts N/A unless the tool includes AI features.

---

### AI/ML Product

**Characteristics:** Model-centric, experiment-driven, data dependency, model monitoring required.

| Phase | Mode | Notes |
|-------|------|-------|
| 1 | Full | AI/Data Feasibility Note is critical gate A artefact |
| 2 | Full | ML architecture decisions must be documented as ADRs |
| 3 | Full | Data readiness is a gate C blocker; experiment backlog required |
| 4 | Full | AI Delivery Loop (4.3) and experiment tracking mandatory |
| 5 | Full | Model card required before Gate D; red-team evidence required |
| 6 | Full | Model drift monitoring; retraining pipeline documented |
| 7 | Full | Model versioning archive; data deletion per governance policy |

**Gates:** All mandatory (A–F). Gate D: red-team evidence non-waivable for external exposure.
**Artefacts:** Full set plus AI-specific (Model Card, Experiment Log, Evaluation Results, AI Monitoring Reports).
**Sprint structure:** Research sprints (4.3); standard sprints (4.1, 4.2, 4.4, 4.5).

---

### Data Product

**Characteristics:** Data pipeline, data mart, or data API; consumers are other systems or analysts.

| Phase | Mode | Notes |
|-------|------|-------|
| 1 | Standard | Value hypothesis framed around data consumption use cases |
| 2 | Standard | Data architecture and lineage documented in Architecture Pack |
| 3 | Full | Data contract definition mandatory; SLOs on data freshness and quality |
| 4 | Full | Data pipeline testing (schema validation, row counts, nullability) in DoD |
| 5 | Standard | Data consumer onboarding documented |
| 6 | Full | Data quality metrics; SLOs on pipeline latency and completeness |
| 7 | Standard | Data archival plan mandatory; downstream consumers notified |

**Gates:** All mandatory. Gate D includes data quality evidence.
**Artefacts:** Full set; AI artefacts optional unless ML pipeline included.

---

### Internal Tool

**Characteristics:** Internal users only, lower regulatory risk, faster iteration acceptable.

| Phase | Mode | Notes |
|-------|------|-------|
| 1 | Lightweight | Sponsor sign-off; simplified Value Hypothesis |
| 2 | Lightweight | Governance model reduced; PM may be PO |
| 3 | Lightweight | Internal user interviews; 1-sprint backlog sufficient for Gate C |
| 4 | Standard | DoD simplified; security assessment scoped to internal risk |
| 5 | Lightweight | Internal deployment; ops handover to team lead |
| 6 | Lightweight | Usage metrics via access logs or Slack feedback |
| 7 | Lightweight | Archive; notify users |

**Gates:** A, C, D mandatory (in simplified form). B, E optional. F: internal review only.
**Artefacts:** Minimal set. Gate criteria reduced.

---

### MVP / Prototype

**Characteristics:** Validation experiment, time-boxed, disposable or pivotable.

| Phase | Mode | Notes |
|-------|------|-------|
| 1 | Lightweight | 1-page Opportunity Statement and Value Hypothesis combined |
| 2 | Lightweight | Ways of Working: 1 document; Architecture: verbal + 1 ADR |
| 3 | Lightweight | 1 user research session minimum; backlog: 1 sprint ready |
| 4 | Standard | MVP DoD focused on learning criteria, not production quality |
| 5 | Lightweight | Release to controlled group only; no formal ops handover |
| 6 | N/A | MVP either graduated (full lifecycle) or retired |
| 7 | Lightweight | Archive and lessons-learned document |

**Gates:** A and D only (mandatory). All others lightweight review, not formal gate.
**Artefacts:** Minimal set. No AI artefacts unless core to MVP hypothesis.

---

## Tailoring Decision Tree

```
Is the product externally-facing (users outside the org)?
├── Yes → SaaS, Web, AI/ML, or Data Product profile
│   ├── Does it include AI/ML as a core feature?
│   │   ├── Yes → AI/ML Product profile (full gates, red-team mandatory)
│   │   └── No → SaaS or Web profile (standard gates)
│   └── Is it primarily a data pipeline or API?
│       ├── Yes → Data Product profile
│       └── No → SaaS or Web profile
└── No (internal only)
    ├── Is it a time-limited validation?
    │   ├── Yes → MVP/Prototype profile (gates A, D only)
    │   └── No → Internal Tool profile (gates A, C, D)
    └── Is it a developer tool distributed externally?
        ├── Yes → Desktop/CLI profile
        └── No → Internal Tool profile
```

**Team size modifier:**
- > 10 people: full gate depth regardless of profile
- 5–10 people: standard gate depth
- < 5 people: lightweight gate depth; PM and gate reviewer may be same person (except Gate D)

**Regulatory context modifier:**
- Regulated industry (finance, healthcare, pharma): full gates A–F; waiver thresholds raised; sign-off authority must be named executive role
- GDPR-sensitive data: Gate D must include data protection impact assessment (DPIA) evidence
- AI Act (EU) applicable: Gate D adds AI system card; Gate F adds conformance review

---

## Override Rules

When to deviate from the profile recommendation:

1. **Regulatory requirement:** A regulation mandates a specific gate or artefact. Override: add the mandatory artefact and gate criterion; document the regulatory basis.
2. **Risk threshold breached:** Risk register has ≥ 2 high-probability/high-impact risks. Override: upgrade gate depth by one level.
3. **Team capability gap:** Team has no experience with a mandatory activity. Override: add learning sprint; do not skip the activity.
4. **Time pressure:** Business demands faster delivery. Override: tailoring profile may be reduced by one level with explicit sponsor sign-off and risk acceptance documented. Gates cannot be eliminated.

All overrides must be recorded in the Lifecycle State `tailoring.overrides` field with reason and approver.
