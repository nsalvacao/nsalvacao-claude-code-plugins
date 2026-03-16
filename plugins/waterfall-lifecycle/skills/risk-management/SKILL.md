---
name: risk-management
description: This skill should be used when identifying, assessing, logging, or reviewing risks in a waterfall lifecycle project. Covers all 5 register types: risk, assumption, clarification, dependency, evidence — with waterfall-specific risk categories and formal escalation paths for gate reviews.
---

# Risk Management

## Purpose
Formal risk management in a waterfall lifecycle requires continuous tracking across all 5 register types — not just the risk register. This skill governs identification, assessment, logging, and escalation of risks, assumptions, clarifications, dependencies, and evidence gaps throughout every phase. It ensures that nothing surfaces unexpectedly at a gate review and that high-severity items receive timely escalation.

## When to Use
- A new risk, assumption, clarification, dependency, or evidence item is identified during any phase
- Preparing for a gate review and need to validate the current risk register state
- A previously logged item changes severity or status
- At phase closure, transferring open items to the next phase register
- An assumption deadline is approaching or has expired without validation
- A CRITICAL clarification is outstanding and phase exit is being considered

## Instructions

### Step 1: Identify Which Register Type
Determine the correct register for the item being logged:
- **Risk**: a possible event that could negatively affect phase outcomes if it occurs
- **Assumption**: a condition believed to be true; requires validation before expiry
- **Clarification**: an open question that must be answered before work proceeds or gate passes
- **Dependency**: an external item, team, or decision that this phase depends on
- **Evidence**: a required artefact that must exist before gate; tracked in the evidence index

### Step 2: Load the Appropriate Schema
Load the schema from the `schemas/` directory corresponding to the register type:
- Risk: `schemas/risk-register.schema.json`
- Assumption: `schemas/assumption-register.schema.json`
- Clarification: `schemas/clarification-log.schema.json`
- Dependency: consult the phase contract dependencies section
- Evidence: consult the evidence index and `schemas/phase-contract.schema.json`

Validate the new entry against the schema before logging.

### Step 3: Assign ID and Score (Risks Only)
For new risk entries:
- Assign a unique ID in the format `R-YYYY-NNN` (e.g., `R-2026-001`)
- Assess **likelihood** on a scale of 1–5 (1 = rare, 5 = almost certain)
- Assess **impact** on a scale of 1–5 (1 = negligible, 5 = critical)
- Compute the risk score: `score = likelihood × impact`
- Assign a severity band:
  - Score 1–4: LOW
  - Score 5–9: MEDIUM
  - Score 10–16: HIGH
  - Score 17–25: CRITICAL

### Step 4: Assign Risk Category
Assign one of the 7 formal risk categories:
- **technical** — architecture, integration, performance, scalability, tech debt
- **business** — scope, stakeholder alignment, budget, timeline, ROI assumptions
- **data** — quality, access, privacy/GDPR, drift, volume
- **ai** — model accuracy, training bias, drift, hallucination, explainability
- **legal** — regulatory compliance, IP ownership, AI liability, export control
- **operational** — team capability, vendor dependency, runbooks, readiness
- **external** — third-party APIs, regulatory change, market shift, dependency team delay

Use the defined taxonomy. Ad-hoc labels are not accepted.

### Step 5: Handle HIGH Risks (score ≥ 12)
- Flag the item immediately in the register (status: `flagged`)
- Add the risk to the phase contract risk summary section
- Include the risk in the gate review risk report
- Define a mitigation action and assign an owner with a deadline
- Track mitigation progress at every sprint review until resolved

### Step 6: Handle CRITICAL Risks (score ≥ 20)
- Escalate immediately to the sign-off authority — do not wait for the next sprint
- Document the escalation: date, channel, response received
- The CRITICAL risk can block gate passage — gate reviewer must explicitly acknowledge it
- Mitigation or acceptance must be documented with the sign-off authority's name

### Step 7: Track Items Across Phases
- All 5 register types must be reviewed at each sprint review for status changes
- Nothing in any register closes without evidence of resolution:
  - Risk: mitigated (with evidence) or accepted (with approver name)
  - Assumption: validated (with source) or invalidated (with impact assessment)
  - Clarification: resolved (with answer and date) or formally deferred
  - Dependency: fulfilled or re-planned with sign-off
  - Evidence: artefact exists and is indexed
- Status "open" at gate time without mitigation progress is treated as a gate risk

### Step 8: Phase Closure — Transfer Open Items
At phase closure:
- Review all 5 registers for open items
- For each open item: add a `transition_note` explaining why it was not resolved in the current phase
- Copy all unresolved items to the next phase's registers, preserving the original ID and history
- Document the transfer in the phase closure report
- The receiving phase PM must acknowledge inherited open items in the next phase contract

## Key Principles
1. **All 5 registers are mandatory** — no register is optional in a formal waterfall lifecycle; omitting any register is a governance gap.
2. **High-impact risks surface at every gate** — a HIGH or CRITICAL risk identified in Phase 1 must appear in every subsequent gate report until resolved.
3. **Assumption deadlines are binding** — an assumption that reaches its validation deadline without being validated is treated as invalidated; its impact must be assessed immediately.
4. **Critical clarifications block exit** — any clarification with severity CRITICAL must be RESOLVED before a gate is approved; deferring it is not acceptable.
5. **Waterfall risk categories are formal** — use the defined 7-category taxonomy; ad-hoc labels obscure pattern recognition and audit traceability.

## Reference Materials
- Risk schema: `schemas/risk-register.schema.json`
- Assumption schema: `schemas/assumption-register.schema.json`
- Clarification schema: `schemas/clarification-log.schema.json`
- `references/risk-patterns.md` — Likelihood-impact matrix, category patterns, mitigation templates
- `references/lifecycle-overview.md` — Phase boundaries and escalation paths
- `references/gate-criteria-reference.md` — How risks feed into gate pass/fail decisions

## Quality Checks
- Every risk entry has a unique `R-YYYY-NNN` ID, a likelihood, an impact, and a computed score
- Every HIGH or CRITICAL risk has a named owner and a mitigation deadline
- No CRITICAL risks are open at gate time without explicit sign-off authority acknowledgement
- Assumption expiry dates are set at creation; expired assumptions are not left in `unvalidated` status
- All CRITICAL clarifications are resolved before gate is requested
- Phase closure includes a full transfer log of all open register items to the next phase
