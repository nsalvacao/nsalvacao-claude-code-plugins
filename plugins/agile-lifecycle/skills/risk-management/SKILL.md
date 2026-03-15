---
name: risk-management
description: Use when managing risks, assumptions, clarifications, or dependencies. Triggers when adding new risks, updating risk status, identifying assumptions, or tracking open decisions.
---

# Risk Management

## Purpose
Risk management in this framework is a continuous, transversal activity. Risks are tracked in a risk register from Phase 1 onwards. Assumptions are documented and resolved or accepted. Clarifications represent open decisions that must be closed before phase completion. Dependencies on external parties are tracked separately. This skill provides the process for identifying, categorizing, and maintaining all four registers.

## When to Use
- A new risk, assumption, clarification, or dependency needs to be recorded
- Existing risk status needs to be updated (probability changed, mitigation completed)
- Assumptions need to be reviewed at a phase boundary
- Open clarifications need follow-up (past due date, blocking progress)
- A gate review requires a risk summary
- AI/ML-specific risks need assessment (model drift, data quality, bias)

## Instructions

### Step 1: Identify What Needs to Be Tracked
Determine whether the item is:
- **Risk**: something that might go wrong; has probability and impact
- **Assumption**: something believed to be true; needs validation by a certain date
- **Clarification**: an open decision or question that blocks progress until resolved
- **Dependency**: reliance on an external system, team, or deliverable

### Step 2: Create the Register Entry
Use the appropriate template:
- Risk: `templates/transversal/risk-register-entry.md.template`
- Assumption: `templates/transversal/assumption-register-entry.md.template`
- Clarification: `templates/transversal/clarification-entry.md.template`

Fill all mandatory fields. For risks:
- `id`: unique identifier (e.g., `RISK-001`)
- `description`: clear description of the risk event and its cause
- `category`: technical | AI/data | organizational | commercial | compliance
- `probability`: low | medium | high | critical
- `impact`: low | medium | high | critical
- `owner`: named person responsible for managing the risk
- `phase`: current phase (1–7)
- `mitigation`: specific actions to reduce probability or impact
- `contingency`: what to do if the risk materializes
- `status`: open | mitigated | accepted | closed

### Step 3: Score and Prioritize
Calculate the risk score using the probability × impact matrix in `references/risk-patterns.md`. Prioritize:
- **Critical × Critical** = immediate escalation required
- **High × High** = active mitigation plan mandatory
- **Medium × Medium** = monitor with defined review cadence
- **Low × Low** = log and accept; review at phase gate

### Step 4: Define Mitigation Actions
For risks rated Medium or above:
- Document at least one specific mitigation action
- Assign the mitigation action to a named owner
- Set a target completion date
- Define a trigger: the condition that would cause the risk to materialize

### Step 5: Track and Update
At each sprint review and phase gate:
- Review all open risks for status changes
- Close mitigated risks (document what was done)
- Accept risks where mitigation cost exceeds impact (document rationale)
- Flag overdue mitigations as blockers
- Review assumptions past their review date for validation

### Step 6: Manage Assumptions
For each assumption entry:
- `assumption`: the statement believed to be true (e.g., "API latency will remain below 200ms")
- `validation_method`: how the assumption will be confirmed or refuted
- `review_date`: when this assumption must be validated
- `owner`: who is responsible for validating it
- If assumption is invalidated: escalate as a risk or scope change

### Step 7: Track Clarifications
For each clarification entry:
- `question`: the specific open decision or question
- `context`: why this is blocking or critical
- `owner`: who is responsible for resolving it
- `due_date`: when it must be resolved
- `resolution`: fill this when the decision is made
If a clarification is past its due date and unresolved: escalate to PM and flag as blocker.

### Step 8: AI/ML Risk Assessment
For projects with AI/ML components, apply the AI-specific risk patterns from `references/risk-patterns.md`:
- Assess model drift risk (prediction quality degrading over time)
- Assess data quality risk (training/inference data problems)
- Assess bias and fairness risk
- Assess hallucination risk (for LLMs)
- Record each as a separate risk entry with AI-specific mitigation

## Key Principles
1. **Every risk needs an owner** — unowned risks are not managed risks.
2. **Assumptions are risks deferred** — if an assumption is wrong, it becomes a risk; validate early.
3. **Clarifications block progress** — track them with due dates and escalate when overdue.
4. **AI risks are distinct** — model behavior risks require AI-specific mitigations, not generic ones.
5. **Risk registers are living documents** — update at every sprint review; stale risk registers mislead gate reviewers.

## Reference Materials
- `references/risk-patterns.md` — Risk categories, probability × impact matrix, mitigation templates, AI-specific patterns
- Schema: `schemas/risk-register.schema.json`
- Schema: `schemas/assumption-register.schema.json`
- Schema: `schemas/clarification-log.schema.json`

## Quality Checks
- Every open risk has a named owner and status
- All risks rated High or above have at least one mitigation action with owner and due date
- Assumption review dates are current (not past due without resolution)
- Clarifications past due date are flagged and escalated
- AI/ML risks are present in the register for any project with AI components
- Risk register referenced in the evidence index at each gate
