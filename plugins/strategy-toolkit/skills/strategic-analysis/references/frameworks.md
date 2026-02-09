# Strategic Frameworks Reference

Complete reference for all frameworks used by the Strategy Toolkit.
These frameworks should be applied adaptively based on the project context.

---

## 1. Asset Identification (Pre-Framework Step)

Before applying any framework, identify the project's **real asset**. This is the critical
foundation — frameworks applied to the wrong asset produce irrelevant output.

### Method

Analyze the project and answer:
1. **What is the code?** — The literal implementation (language, architecture, LOC)
2. **What is the concept?** — The underlying idea the code proves
3. **What is the moat?** — What makes this hard to replicate
4. **What is the schema/format/protocol?** — If the project defines a data format or standard, that IS the asset

### Common Patterns
- Tool projects → the real asset is the **format/schema** they produce, not the tool itself
- Platform projects → the real asset is the **network effect**, not the features
- Library projects → the real asset is the **API surface/developer experience**
- Framework projects → the real asset is the **ecosystem** (plugins, extensions, community)

### Output Format
```markdown
## What Is the REAL Asset?

Not the [code description]. The real asset is threefold:

1. **[Concept proof]** — [what the project demonstrates is possible]
2. **[Schema/format/standard]** — [what data structure or protocol it creates]
3. **[Bridge/connection]** — [what two things it connects that weren't connected before]

**Key insight:** [one sentence about what truly matters for long-term value]
```

---

## 2. SCAMPER Analysis

Creative thinking framework using 7 transformation lenses.
Apply each lens to the project's core components.

### The 7 Lenses

| Lens | Question | Application |
|------|----------|-------------|
| **S**ubstitute | What inputs, outputs, or technologies could be substituted? | Table: Current → Substitute → Opportunity |
| **C**ombine | What could be combined with complementary capabilities? | Table: A + B = C (synergy description) |
| **A**dapt | What adjacent audiences or use cases could benefit? | Bullet list: audience → adapted use case |
| **M**odify / Magnify | What if we 10x the scope, depth, intelligence, or community? | Table: Magnify dimension → From → To |
| **P**ut to other uses | What unexpected applications exist? | Numbered list with 1-2 sentence justification |
| **E**liminate | What constraints, dependencies, or manual steps could be removed? | Table: Eliminate → Result |
| **R**everse / Rearrange | What if the flow, audience, or model were inverted? | Bullet points with reversal description |

### Quality Criteria
- Each lens should produce 3-5 concrete ideas minimum
- Ideas should range from incremental to radical
- Include at least 2 ideas per lens that feel uncomfortable or unrealistic

---

## 3. Divergent Ideation

Generate maximum quantity of ideas without filtering. Target: 20 wild ideas minimum.

### Rules
1. No idea is too crazy — quantity over quality at this stage
2. Build on previous ideas (yes-and thinking)
3. Include at least 5 ideas that feel impossible with current resources
4. Mix timeframes: near-term (weeks), medium (months), long-term (years)
5. Mix scales: feature-level, product-level, platform-level, ecosystem-level

### Prompt Structure
Think about the project from these perspectives:
- **Developer tool perspective**: What tools could be built on this foundation?
- **Platform perspective**: What marketplace or registry could emerge?
- **Standard perspective**: What specification or protocol could be defined?
- **Community perspective**: What would 1000 contributors build?
- **Enterprise perspective**: What would a company pay for?
- **Education perspective**: What learning experiences could be created?
- **Integration perspective**: What if this connected to every tool in the ecosystem?

### Output Format
Numbered list (1-20+) with one-line title and one-sentence description each.

---

## 4. Convergent Analysis (Tier Ranking)

Filter divergent ideas into actionable tiers based on impact and feasibility.

### Tier Definitions

| Tier | Star Potential | Characteristics |
|------|---------------|-----------------|
| **S — Transformative** | 100k+ | Changes the industry. Creates new category. Network effects. |
| **A — High Impact** | 10k-50k | Significant value. Clear audience. Achievable with effort. |
| **B — Strong** | 1k-10k | Solid contribution. Niche but valuable. Lower effort. |

### Evaluation Criteria per Idea
For each Tier S/A idea, document:
- **What**: One-paragraph description
- **Why it's huge**: Market analysis justification
- **Path**: 3-5 step execution sequence
- **Comparable**: Existing successful projects with similar trajectory
- **Revenue potential**: None / Indirect / Direct
- **Risk**: Primary risk and mitigation
- **Effort**: Low / Medium / High

---

## 5. Blue Ocean Strategy

Identify where the project creates uncontested market space.

### Analysis Steps

1. **Map the Red Ocean**: Table of existing solutions with their weaknesses
2. **Identify the Blue Ocean**: What the project uniquely offers that none do
3. **Strategic Canvas**: List 5-7 factors where the project competes differently
4. **Positioning Statement**: One sentence that captures the unique position

### Output Format
```markdown
### Current Market (Red Ocean)
| Existing Solution | Stars/Users | Weakness |
|...table...|

### Blue Ocean Opportunity
**What they all lack:** [gap description]

**Strategic canvas — [project] uniquely offers:**
- [Factor 1] (vs [competitor approach])
- [Factor 2] (vs [competitor approach])
- ...

**Positioning:** "[one-line positioning statement]"
```

---

## 6. TAM/SAM/SOM Market Sizing

Estimate the addressable market to prioritize efforts.

### Definitions
- **TAM** (Total Addressable Market): Everyone who could theoretically use this
- **SAM** (Serviceable Addressable Market): Those reachable with current format/technology
- **SOM** (Serviceable Obtainable Market): Realistic capture in 12-18 months

### Method
1. Identify the user segments (developers, CLI authors, enterprises, etc.)
2. Estimate segment sizes using public data (GitHub stats, survey data, npm downloads)
3. Apply realistic penetration rates (0.1-1% for TAM→SOM)

### Output Format
```markdown
### Market Sizing

| Segment | TAM | SAM | SOM (18 months) |
|---------|-----|-----|-----------------|
| [Segment 1] | [estimate] | [subset] | [realistic] |
| ...
| **Total** | **[total]** | **[total]** | **[total]** |

**Key insight:** [which segment to prioritize and why]
```

---

## 7. Jobs-to-be-Done (JTBD)

Understand what "job" users hire the project to do.

### Framework
For each user persona, define:
1. **When I am** [situation/context]
2. **I want to** [motivation/desired outcome]
3. **So I can** [expected result/benefit]

### Categories
- **Functional jobs**: What task does it accomplish?
- **Emotional jobs**: How does it make the user feel?
- **Social jobs**: How does it affect the user's perception by others?

### Output Format
```markdown
### Jobs-to-be-Done Analysis

#### [Persona 1: e.g., "AI Tool Developer"]
| Job Type | Job Statement |
|----------|---------------|
| Functional | When I am [context], I want to [action] so I can [outcome] |
| Emotional | When I am [context], I want to feel [emotion] so I can [outcome] |
| Social | When I am [context], I want others to see me as [perception] |

#### [Persona 2]
...
```

---

## 8. Moat Analysis (Buffett Framework)

Evaluate and strengthen competitive advantages using Warren Buffett's 4 moat types.

### The 4 Moats

| Moat Type | Description | How to Build |
|-----------|-------------|--------------|
| **Network Effects** | Product gets more valuable as more people use it | Registry, community, ecosystem |
| **Switching Costs** | Pain of moving to a competitor | Integration depth, data lock-in, workflow dependency |
| **Brand / Trust** | Recognized as the default/standard | Thought leadership, governance, "the" X for Y |
| **Cost Advantage** | Can deliver at lower cost than competitors | Open source, automation, zero-dependency |

### Assessment
For each moat type, rate:
- **Current strength**: None / Weak / Medium / Strong
- **Buildable?**: Yes/No and how
- **Timeline**: How long to establish
- **Vulnerability**: What could erode it

---

## 9. Flywheel Mapping

Identify virtuous cycles that create compounding growth.

### Method
1. Identify the core value loop (more X → more Y → more X)
2. Map reinforcing loops (what accelerates the flywheel)
3. Identify friction points (what slows it down)
4. Find the "push point" (where minimal effort creates maximum momentum)

### Output Format
```
       ┌──────────┐
       │  More     │
       │  Users    │
       └────┬─────┘
            │
            ▼
   ┌────────────────┐
   │  More Community │
   │  Contributions  │
   └────────┬───────┘
            │
            ▼
     ┌──────────────┐
     │  Better       │
     │  Content      │
     └──────┬───────┘
            │
            ▼
       ┌──────────┐
       │  More     │
       │  Users    │ ← (cycle repeats)
       └──────────┘

Push point: [where to apply effort]
Friction: [what to remove]
```

---

## 10. Pre-Mortem Analysis

Imagine the project has FAILED in 2 years. Work backwards to identify why.

### Method
1. Set the scene: "It's [date + 2 years]. The project has been abandoned. Why?"
2. Each team member (or thinking angle) proposes a cause of death
3. Group causes into categories
4. For each, assess probability and create preventive action

### Failure Categories
- **Technical**: Architecture didn't scale, dependencies broke, security incident
- **Market**: Timing wrong, competitor won, need disappeared
- **Execution**: Burnout, scope creep, wrong priorities, no community
- **External**: Platform changes, regulation, economic downturn

### Output Format
```markdown
### Pre-Mortem: Why Did [Project] Fail?

| # | Cause of Death | Category | Probability | Prevention |
|---|----------------|----------|-------------|------------|
| 1 | [specific failure] | [category] | [%] | [preventive action] |
| ...
```

---

## 11. Contrarian Thinking

Challenge every assumption. Ask "what if the opposite is true?"

### Method
For each core assumption, ask:
1. **What if this is wrong?** — Explore the inverse
2. **What if it's right but irrelevant?** — Even if true, does it matter?
3. **What if the timing is wrong?** — Right idea, wrong decade?
4. **Who disagrees and why are they smart?** — Steelman the opposition

### Core Assumptions to Challenge
- "This problem needs solving" → What if users have already adapted?
- "Open source is the right model" → What if proprietary captures more value?
- "Community will form" → What if it stays a solo project forever?
- "The technology won't be obsoleted" → What makes this future-proof?
- "More features = more value" → What if simplicity is the moat?

### Output Format
```markdown
### Contrarian Challenges

| Assumption | Contrarian View | Probability of Being Wrong | Hedge |
|------------|----------------|---------------------------|-------|
| [assumption] | [what if opposite] | [%] | [how to protect against] |
```

---

## 12. Second-Order Effects Analysis

For every major initiative, trace cascading consequences.

### Method
For each initiative:
1. **1st order**: What directly happens when it succeeds?
2. **2nd order**: What happens because of the 1st-order effect?
3. **3rd order**: What happens because of the 2nd-order effect?

### Key Question at Each Level
- "And then what happens?"
- "Who else is affected?"
- "What changes in the incentive structure?"
- "What new problems does this create?"

### Output Format
Table with Order | Effect | Implication columns.
End with: **Key insight:** [the non-obvious conclusion]

---

## 13. Growth & Visibility Framework

Structured approach to going from 0 to critical mass.

### Launch Channels (Ranked by Dev Project Impact)
1. Hacker News ("Show HN") — 500K+ dev readers, highest conversion
2. Reddit (r/programming, r/[language], r/[domain]) — Large, segmented audiences
3. Dev.to / Hashnode — Tutorial-friendly, SEO value
4. Twitter/X — Real-time, influencer amplification
5. LinkedIn — Professional angle, enterprise reach
6. Product Hunt — Broader tech audience
7. Awesome lists — Passive long-term discovery

### HN Title Patterns That Work
1. **Technical**: "Show HN: I [impressive technical feat] to build [useful thing]"
2. **Problem-focused**: "Show HN: Stop [frustrating problem everyone has]"
3. **Analogy**: "Show HN: [Known Standard] for [new domain] -- [value prop]"

### Content Calendar Template
| Week | Content | Channel | Purpose |
|------|---------|---------|---------|
| Launch | Show HN post | HN | Initial burst |
| +1 week | Tutorial article | Dev.to | Depth + SEO |
| +3 weeks | Technical deep-dive | Blog/HN | Credibility |
| +5 weeks | Engagement post (rankings/scores/comparisons) | HN + Blog | Virality |
| +8 weeks | Feature launch post | Dev.to | Sustained growth |
| Monthly | "State of [Project]" | Blog | Community retention |

### Star Growth Model
| Milestone | Typical Timeline | Strategy |
|-----------|-----------------|----------|
| 100 | Launch week | HN + Reddit burst |
| 500 | Month 1-2 | Tutorial content + awesome lists |
| 1,000 | Month 2-3 | Feature launch + GitHub Action/integration |
| 5,000 | Month 6-9 | Multi-platform support + registry |
| 10,000 | Month 12-18 | Industry standard + conference talks |

---

## 14. Risk Register Framework

Systematic risk identification and mitigation.

### Risk Categories
- **Technical**: Code quality, scalability, dependencies, security
- **Market**: Competition, timing, demand, pricing
- **Execution**: Resources, burnout, scope, priorities
- **External**: Platform changes, regulation, economy
- **Community**: Adoption, contributions, governance, toxicity

### Risk Assessment Matrix

| Probability ↓ / Impact → | Low | Medium | High | Critical |
|--------------------------|-----|--------|------|----------|
| **High (>50%)** | Monitor | Mitigate | Mitigate urgently | Block & fix |
| **Medium (20-50%)** | Accept | Monitor | Mitigate | Mitigate urgently |
| **Low (<20%)** | Accept | Accept | Monitor | Mitigate |

### Output Format
| # | Risk | Prob. | Impact | Mitigation |
|---|------|-------|--------|------------|
| R1 | [specific risk] | [%] | [Low/Med/High/Critical] | [concrete action] |

---

## Application Guidelines

### Framework Selection by Project Type

| Project Type | Priority Frameworks | Secondary |
|-------------|-------------------|-----------|
| **Developer tool** | Asset ID, SCAMPER, Blue Ocean, Moat, Growth | TAM, JTBD, Flywheel |
| **Platform/Marketplace** | Flywheel, Network Effects, TAM, JTBD | SCAMPER, Pre-Mortem |
| **Open source library** | JTBD, Moat, Contrarian, Growth | Blue Ocean, SCAMPER |
| **SaaS product** | TAM, JTBD, Flywheel, Moat, Pre-Mortem | SCAMPER, Growth |
| **Standard/Protocol** | Asset ID, Moat, 2nd Order, Contrarian | TAM, Growth |

### Quality Benchmarks

A good brainstorm document should have:
- 350+ lines
- 20+ divergent ideas
- 3+ Tier S/A ideas with detailed analysis
- Honest competitive analysis (no cheerleading)
- At least 3 uncomfortable contrarian challenges

A good execution plan should have:
- 500+ lines
- Second-order effects for every major initiative
- 10+ identified risks with mitigations
- Operationalized roadmap with acceptance criteria per deliverable
- Growth strategy with specific channels, timing, and expected outcomes
- Pre-mortem with at least 8 failure scenarios
