# Risk Patterns

## Overview
This document provides risk categorization, probability/impact scoring, mitigation pattern templates, and AI-specific risk patterns for the agile-lifecycle framework.

## Risk Categories

| Category | Description | Examples |
|----------|-------------|---------|
| `technical` | Technology choices, architecture, implementation quality | Third-party API instability, tech debt accumulation, integration complexity |
| `AI/data` | Model behavior, data quality, AI-specific failure modes | Model drift, data bias, training data shortage, hallucination |
| `organizational` | Team, process, stakeholder alignment | Key person dependency, team churn, sponsor disengagement |
| `commercial` | Budget, timeline, vendor, market | Budget cuts, vendor lock-in, competitor product launch |
| `compliance` | Regulatory, legal, privacy, security | GDPR non-compliance, security vulnerabilities, audit findings |

## Probability × Impact Matrix

|  | **Low Impact** | **Medium Impact** | **High Impact** | **Critical Impact** |
|--|----------------|-------------------|-----------------|---------------------|
| **Low Probability** | Log & Accept | Monitor | Active monitor | Mitigation plan |
| **Medium Probability** | Monitor | Mitigation plan | Mitigation plan | Escalate |
| **High Probability** | Mitigation plan | Mitigation plan | Escalate | Immediate action |
| **Critical Probability** | Escalate | Escalate | Immediate action | Immediate action + PM escalation |

**Scoring guidance:**
- Low: 25% or less likely / minor impact on schedule, cost, or quality
- Medium: 25–50% likely / moderate impact, recoverable
- High: 50–75% likely / significant impact requiring replanning
- Critical: 75%+ likely / severe impact; threatens project delivery

## Mitigation Pattern Templates

### Pattern: Third-Party Dependency Risk
**Risk type:** Technical / Commercial
**Description:** Reliance on a third-party API, library, or vendor that may become unavailable, change its interface, or degrade in quality.
**Mitigation actions:**
1. Identify and document the dependency with version pinning
2. Assess vendor stability (SLA, track record, alternatives)
3. Design abstraction layer to isolate the dependency
4. Define a fallback (alternative vendor, in-house implementation)
5. Monitor vendor changelog and deprecation notices

### Pattern: Key Person Dependency
**Risk type:** Organizational
**Description:** Critical knowledge or decision-making authority held by one person; if they leave, project velocity drops significantly.
**Mitigation actions:**
1. Document knowledge in shared spaces (wikis, runbooks, ADRs)
2. Pair programming or knowledge transfer sessions
3. Define backup escalation paths
4. Include knowledge transfer in DoD for each sprint

### Pattern: Scope Creep
**Risk type:** Organizational / Commercial
**Description:** Gradual addition of requirements beyond the agreed scope, consuming capacity without formal approval.
**Mitigation actions:**
1. Enforce change control for all scope additions
2. Backlog grooming with explicit "in scope / out of scope" labeling
3. Track scope against baseline at each sprint review
4. Escalate to product owner and PM if scope change > 10% without approval

### Pattern: Integration Complexity
**Risk type:** Technical
**Description:** Multiple systems must integrate; integration points are more complex than anticipated.
**Mitigation actions:**
1. Integration test plan created in Phase 3
2. Integration test environment available from Sprint 1
3. Contract testing (consumer-driven) for critical APIs
4. Integration risks tracked separately in risk register

### Pattern: Data Quality
**Risk type:** AI/data
**Description:** Training or operational data contains errors, gaps, bias, or inconsistencies that degrade model quality.
**Mitigation actions:**
1. Data profiling conducted before training begins
2. Data quality metrics defined and tracked (completeness, accuracy, freshness)
3. Data quality dashboard set up in Phase 4
4. Threshold: if data quality score drops below [X]%, halt training until resolved

### Pattern: Regulatory Change
**Risk type:** Compliance
**Description:** New regulations or updated guidance require product changes after build has started.
**Mitigation actions:**
1. Monitor regulatory horizon (legal/compliance team input in Phase 1–2)
2. Modular architecture to isolate compliance-affected components
3. Budget reserve for compliance rework
4. Legal review scheduled at Gate B and Gate E

## Assumption Tracking Best Practices

1. **State assumptions as falsifiable statements** — "The average transaction volume is below 10,000/day" is better than "traffic will be manageable."
2. **Every assumption needs a review date** — set it to before the next gate where the assumption would materialize.
3. **Assign assumption ownership** — the owner validates the assumption by the review date.
4. **Document the validation method** — how will we know if the assumption is true or false?
5. **Invalidated assumptions become risks or scope changes** — do not silently accept failed assumptions.

## Escalation Thresholds

| Condition | Action |
|-----------|--------|
| Risk rated Critical × Critical | Escalate to sponsor and PM immediately; daily standup until resolved |
| 3+ risks rated High or above in one phase | Risk review meeting with PM and tech lead |
| Assumption past review date and unvalidated | Flag as blocker; PM to follow up within 48h |
| Clarification past due date | PM escalates to decision authority within 1 sprint |
| Risk register not updated in 2+ sprints | Flag in retrospective; assign update task |

## AI-Specific Risk Patterns

### Model Drift
**Description:** Model predictions degrade over time as real-world data distribution shifts from training data.
**Probability trigger:** Models deployed 3+ months with no retraining evaluation.
**Mitigation:** Set up drift monitoring from Day 1 of Phase 6. Define drift threshold (e.g., prediction distribution shift > 5%). Automate retraining pipeline trigger when threshold breached.

### Training Data Shortage
**Description:** Insufficient labeled data to train a model to acceptable accuracy.
**Mitigation:** Data requirements defined in Phase 1 AI feasibility note. Minimum dataset size estimated before committing to AI approach. Data augmentation or transfer learning evaluated.

### Bias and Fairness
**Description:** Model performs unequally across demographic groups or protected characteristics.
**Mitigation:** Fairness metrics defined before training (e.g., equalized odds, demographic parity). Bias audit conducted as part of Phase 5 AI validation. Red-team evaluation for LLMs.

### Hallucination (LLM-specific)
**Description:** LLM generates plausible but factually incorrect or fabricated content.
**Mitigation:** Red-team evaluation mandatory at Gate D for LLM-based features. Guardrails implemented (output validation, retrieval-augmented generation). Human-in-the-loop for high-stakes outputs.

### Prompt Injection (LLM-specific)
**Description:** Malicious input manipulates LLM behavior, bypassing intended constraints.
**Mitigation:** Input sanitization layer. Prompt injection testing in security review. Output filtering for sensitive content categories.

### Data Privacy Leakage
**Description:** Training data or model outputs expose personal or confidential information.
**Mitigation:** Data anonymization/pseudonymization before training. Differential privacy evaluation for sensitive datasets. Privacy impact assessment in Phase 2.
