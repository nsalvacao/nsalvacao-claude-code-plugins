# Tailoring Guide

The agile-lifecycle framework adapts to your product type, team size, and regulatory context. Tailoring adjusts the depth, scope, and formality of lifecycle activities — but does not eliminate gates. Every product must pass gate reviews; what changes is the rigor and evidence threshold.

**Quick start:** Use `/agile-tailoring [product-type]` to configure the framework. Or read this guide to understand your tailoring options.

---

## What Gets Tailored?

### Gate Depth
How rigorous a gate review is — which criteria are checked, how much evidence is required.

| Level | Scope | When to use |
|-------|-------|------------|
| **Full** | All criteria verified; critical artefacts require formal approval | Regulated products, high-risk features, enterprise-scale teams |
| **Standard** | All criteria checked; most artefacts can pass at "reviewed" threshold | Internal SaaS, standard products, 5–10 person teams |
| **Lightweight** | Simplified criteria; "exists" threshold acceptable; PM may be both proposer and reviewer | MVP, prototype, internal tooling, small teams |

### Phase Scope
Whether a phase runs in full or streamlined mode.

| Mode | Subfases & artefacts | When to use |
|------|----------------------|------------|
| **Full** | All subfases, all artefacts in the catalog | Regulated products, complex features, operations-critical phases |
| **Standard** | All subfases; optional artefacts are truly optional | Most products in most phases |
| **Lightweight** | Merged or abbreviated subfases; 1–2 core artefacts per phase | MVP, early phases, simple features |

### Artefact Set
Which artefacts are required vs optional for gate criteria.

| Set | Scope |
|-----|-------|
| **Full** | All artefacts in the catalog; no skipping |
| **Reduced** | Core artefacts mandatory; supporting ones optional |
| **Minimal** | 1–2 per phase; only those satisfying gate criteria |

### Sprint Structure
How work is organized and how velocity is tracked.

| Structure | When appropriate |
|-----------|-----------------|
| **Full Scrum** | Phase 4 (development) for all product types; 2-week sprints, all ceremonies, strict DoD |
| **Kanban** | Phase 6 (operations); continuous flow, cycle time as primary metric |
| **Research sprints** | AI/ML-heavy Phase 3 and Phase 4; hypothesis-driven, timeboxed experiments |

### AI Activities
Whether GenAI overlay activities (experiment tracking, model cards, red-teaming) are active.

---

## Product Type Profiles

Choose your profile below, or mix-and-match dimensions for custom tailoring.

### SaaS Product

**Characteristics:** Multi-tenant, external users, SLO-sensitive, continuous delivery, hypercare required.

| Phase | Mode | Key requirements |
|-------|------|-----------------|
| 1 | Standard | Value hypothesis includes MRR/ARR targets |
| 2 | Full | Working Model documents SaaS operating model |
| 3 | Full | External user research; user journey maps required |
| 4 | Full | CI/CD mandatory; canary deployment in plan |
| 5 | Full | SLA-based hypercare; ops team onboarding mandatory |
| 6 | Full | SLO monitoring; NPS tracking quarterly |
| 7 | Standard | User data migration plan mandatory |

**Gates:** All A–F mandatory.
**Artefacts:** Full set.
**Sprint structure:** Full Scrum (Phase 4); Kanban (Phase 6).
**Command:** `/agile-tailoring saas`

---

### Web Application

**Characteristics:** Browser-based, SEO/performance sensitive, accessibility critical, external or internal users.

| Phase | Mode | Key requirements |
|-------|------|-----------------|
| 1 | Standard | Feasibility includes performance and SEO assessment |
| 2 | Standard | Architecture addresses CDN, caching, SSR/CSR |
| 3 | Standard | User journey maps; accessibility requirements documented |
| 4 | Full | WCAG accessibility testing mandatory in DoD |
| 5 | Standard | Blue/green or rolling deployment |
| 6 | Standard | Core Web Vitals tracked as product metrics |
| 7 | Standard | Deprecation plan if applicable |

**Gates:** All mandatory. Gate D includes accessibility audit evidence.
**Artefacts:** Full set (minus AI-specific unless AI features exist).
**Command:** `/agile-tailoring web`

---

### Desktop / CLI Tool

**Characteristics:** Installed software, developer/power-user audience, versioned releases, package distribution.

| Phase | Mode | Key requirements |
|-------|------|-----------------|
| 1 | Lightweight | AI justification may be N/A |
| 2 | Standard | Architecture includes distribution mechanism (npm, PyPI, Homebrew, etc.) |
| 3 | Lightweight | User research via developer interviews or GitHub issues |
| 4 | Full | Semantic versioning; changelog maintained |
| 5 | Standard | Package distribution documented and tested |
| 6 | Lightweight | GitHub Issues or equivalent as feedback channel |
| 7 | Lightweight | Archive repo; deprecation notice in README |

**Gates:** A–E mandatory; F optional (periodic review if actively maintained).
**Artefacts:** Reduced set (AI artefacts N/A unless tool includes AI features).
**Command:** `/agile-tailoring desktop`

---

### AI/ML Product

**Characteristics:** Model-centric, experiment-driven, data dependency, model monitoring and red-teaming required.

| Phase | Mode | Key requirements |
|-------|------|-----------------|
| 1 | Full | AI/Data Feasibility Note is critical for Gate A |
| 2 | Full | ML architecture decisions documented as ADRs |
| 3 | Full | Data readiness blocks Gate C; experiment backlog required |
| 4 | Full | AI Delivery Loop (4.3) and experiment tracking mandatory |
| 5 | Full | Model Card required before Gate D; red-team evidence required for external exposure |
| 6 | Full | Model drift monitoring; retraining pipeline documented |
| 7 | Full | Model versioning archive; data deletion per governance policy |

**Gates:** All A–F mandatory. Gate D: red-team evidence non-waivable for external exposure.
**Artefacts:** Full set plus AI-specific (Model Card, Experiment Log, Evaluation Results, AI Monitoring Reports).
**Sprint structure:** Research sprints (4.3); standard sprints (4.1, 4.2, 4.4, 4.5).
**Command:** `/agile-tailoring ai-ml`

---

### Data Product

**Characteristics:** Data pipeline, data mart, or data API; consumers are other systems or analysts; data quality and freshness critical.

| Phase | Mode | Key requirements |
|-------|------|-----------------|
| 1 | Standard | Value hypothesis framed around data consumption use cases |
| 2 | Standard | Data architecture and lineage documented |
| 3 | Full | Data contract definition mandatory; SLOs on freshness and quality |
| 4 | Full | Pipeline testing (schema validation, row counts, nullability) in DoD |
| 5 | Standard | Data consumer onboarding documented |
| 6 | Full | Data quality metrics; SLOs on latency and completeness |
| 7 | Standard | Data archival plan; downstream consumers notified |

**Gates:** All mandatory. Gate D includes data quality evidence.
**Artefacts:** Full set (AI artefacts optional unless ML pipeline included).
**Command:** `/agile-tailoring data-product`

---

### Internal Tool

**Characteristics:** Internal users only, lower regulatory risk, faster iteration acceptable, minimal ops overhead.

| Phase | Mode | Key requirements |
|-------|------|-----------------|
| 1 | Lightweight | Sponsor sign-off; simplified Value Hypothesis |
| 2 | Lightweight | Governance model reduced; PM may be PO |
| 3 | Lightweight | Internal user interviews; 1-sprint backlog sufficient |
| 4 | Standard | DoD simplified; security assessment scoped to internal risk |
| 5 | Lightweight | Internal deployment; ops handover to team lead |
| 6 | Lightweight | Usage metrics via access logs or Slack feedback |
| 7 | Lightweight | Archive; notify users |

**Gates:** A, C, D mandatory (simplified form). B, E optional. F: internal review only.
**Artefacts:** Minimal set. Gate criteria reduced.
**Command:** `/agile-tailoring internal`

---

### MVP / Prototype

**Characteristics:** Time-limited validation, disposable or pivotable, rapid learning, external users may test.

| Phase | Mode | Key requirements |
|-------|------|-----------------|
| 1 | Lightweight | 1-page Opportunity Statement + Value Hypothesis combined |
| 2 | Lightweight | Ways of Working: 1 document; Architecture: 1 ADR |
| 3 | Lightweight | 1 user research session minimum; 1-sprint backlog ready |
| 4 | Standard | DoD focused on learning criteria, not production quality |
| 5 | Lightweight | Release to controlled group only; no formal ops handover |
| 6 | N/A | MVP either graduates to full lifecycle or is retired |
| 7 | Lightweight | Archive and lessons-learned document |

**Gates:** A and D mandatory. All others: lightweight review (not formal gate).
**Artefacts:** Minimal set. No AI artefacts unless core to MVP hypothesis.
**Command:** `/agile-tailoring mvp`

---

## Choosing Your Profile

### Decision Tree

```
Is the product externally-facing (users outside the org)?
├── Yes
│   ├── Does it include AI/ML as a core feature?
│   │   ├── Yes → AI/ML Product profile
│   │   └── No → Continue below
│   ├── Is it primarily a data pipeline or API?
│   │   ├── Yes → Data Product profile
│   │   └── No → Is it a browser app?
│   │       ├── Yes → Web Application profile
│   │       └── No → Is it installed software?
│   │           ├── Yes → Desktop/CLI profile
│   │           └── No → SaaS profile
│   │
└── No (internal only)
    ├── Is it a time-limited validation?
    │   ├── Yes → MVP/Prototype profile
    │   └── No → Is it a distributed dev tool?
    │       ├── Yes → Desktop/CLI profile
    │       └── No → Internal Tool profile
```

### Team Size Modifier

| Team size | Gate depth | Notes |
|-----------|-----------|-------|
| **> 10** | Full | Maintain full rigor regardless of profile |
| **5–10** | Standard | Balanced rigor; most profiles fit here |
| **< 5** | Lightweight | PM and gate reviewer may be same person (except Gate D) |

### Regulatory Context Modifier

| Context | Override | Notes |
|---------|----------|-------|
| **Regulated industry** (finance, healthcare, pharma) | Upgrade to Full | All gates A–F; raised waiver thresholds; named executive sign-off required |
| **GDPR-sensitive data** | Gate D addition | Data Protection Impact Assessment (DPIA) evidence required |
| **EU AI Act applicable** | Gate D + F additions | Gate D adds AI system card; Gate F adds conformance review |

---

## Custom Tailoring

If no predefined profile fits your context, configure dimensions individually:

1. **Run the guided setup:**
   ```
   /agile-tailoring
   ```
   You'll be prompted for:
   - Which phases run in full vs. lightweight mode?
   - Which gates are mandatory vs. optional?
   - Is AI overlay active?
   - Sprint structure (Scrum, Kanban, Research)?

2. **The lifecycle-orchestrator saves your tailoring** to `lifecycle-state.json`.

3. **Document your reasoning** in the tailoring overrides field (see "Override Rules" below).

---

## Override Rules

When to deviate from your chosen profile:

| Situation | Action | Document |
|-----------|--------|----------|
| **Regulatory mandate** | Add the mandatory artefact and gate criterion; document regulatory basis | `tailoring.overrides` in lifecycle-state.json |
| **Risk threshold breached** | ≥2 high-probability/high-impact risks → upgrade gate depth by one level | Risk register + override record |
| **Team capability gap** | No experience with mandatory activity → add learning sprint; do not skip | Capability plan + override record |
| **Time pressure** | Business demands faster delivery → reduce tailoring by one level with **sponsor sign-off and risk acceptance** | Override record (gates cannot be eliminated) |

**Important:** All overrides must be recorded with reason and approver in `tailoring.overrides`.

---

## Tailoring vs. Waiver

**Tailoring** is done upfront to configure the framework for your context. It sets expectations and criteria for gate reviews.

**Waiver** is done at gate time when a specific criterion cannot be met despite proper tailoring. Waivers require gate reviewer approval and risk acceptance.

Do not use waivers as a substitute for proper tailoring. If you find yourself requesting waivers frequently, revisit your tailoring profile.

---

## Related Concepts

- **Lifecycle State:** Your tailoring configuration is stored in `lifecycle-state.json`. Commit this to your repo so all team members work from the same tailoring.
- **Gate Criteria:** Each gate has a standard set of criteria; tailoring affects which criteria apply and how rigorously they are verified.
- **Artefact Catalog:** All artefacts are defined in the reference architecture. Tailoring determines which are mandatory vs. optional for your gates.
- **Ways of Working:** Documented in Phase 2, informed by your tailoring (e.g., Scrum ceremonies for Phase 4, Kanban for Phase 6).
