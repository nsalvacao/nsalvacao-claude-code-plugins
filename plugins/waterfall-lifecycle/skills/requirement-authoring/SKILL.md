---
name: requirement-authoring
description: This skill should be used when authoring, reviewing, or validating requirements in a waterfall lifecycle project — including functional requirements, AI requirements, NFRs, and acceptance criteria. Covers ID assignment, SMART criteria, category assignment, and requirement quality gates.
---

# Requirement Authoring

## Purpose
Formal requirement authoring in a waterfall lifecycle follows a precise structure: unique IDs, SMART acceptance criteria, category tagging, and traceability hooks. This skill governs the full lifecycle of a requirement from elicitation to baseline, ensuring every requirement is unambiguous, testable, and traceable.

## When to Use
- A new business, AI, or NFR requirement is being documented
- Reviewing a requirements set for completeness or testability
- Authoring acceptance criteria for a requirement
- Assigning category and priority to a requirement
- Preparing requirements for baseline freeze

## Instructions

### Step 1: Assign Requirement ID
- Format: `REQ-YYYY-NNN` (e.g., `REQ-2026-001`)
- YYYY = the current year; NNN = 3-digit sequential number padded with zeros
- IDs are permanent and never reused — deferred/rejected requirements retain their ID with status `deferred`

### Step 2: Assign Category
Use one of 5 formal categories:
- **functional** — what the system must do; user-facing behaviour
- **ai** — AI/ML-specific behaviour, model constraints, acceptance thresholds
- **nfr** — non-functional: performance, security, scalability, availability, compliance
- **constraint** — fixed constraints: technology mandates, budget caps, regulatory limits
- **assumption** — conditions believed true; if invalidated, requirement may change

### Step 3: Assign Priority (MoSCoW)
- **must** — mandatory; gate failure if absent
- **should** — important but can be deferred if justified
- **could** — desirable but not critical for gate passage
- **wont** — explicitly out of scope for this baseline (document why)

### Step 4: Write the Requirement Body
Apply SMART criteria:
- **Specific** — unambiguous, no vague language ("the system should be fast" is not specific)
- **Measurable** — includes a numeric target or verifiable condition
- **Achievable** — technically feasible given constraints from Phase 1
- **Relevant** — links to a business objective or Gate A artefact
- **Time-bound** — references a phase, milestone, or delivery date where applicable

For AI requirements, also include:
- Acceptance threshold (e.g., "precision ≥ 0.85 on held-out test set")
- Fallback behaviour if threshold is not met
- Explainability requirement (if applicable)
- Data source and volume assumptions

For NFRs, include:
- Measurable target (e.g., "p95 response time ≤ 200ms under 1000 concurrent users")
- Test approach (load test, penetration test, compliance audit)
- Compliance framework reference (GDPR Article N, ISO 27001 control N)

### Step 5: Write Acceptance Criteria
Each requirement MUST have ≥1 acceptance criterion in this format:
```
Given [precondition], when [action], then [expected outcome with measurable target].
```
For AI requirements, acceptance criteria MUST include the test dataset reference and metric threshold.

### Step 6: Validate Against Schema
Load `schemas/requirement.schema.json` and validate the requirement entry. Required fields: id, title, description, category, priority, acceptance_criteria, status, owner.

### Step 7: Add Traceability Hook
Every requirement must reference:
- The business objective or Gate A artefact it derives from (`traceability_refs.upstream`)
- Leave `test_ref` as TBD until Phase 4 (Build and Test)

## Key Principles
1. **IDs are permanent** — deferred or rejected requirements keep their ID; status changes, ID does not.
2. **No requirement without acceptance criteria** — a requirement that cannot be tested is not a requirement; it is a wish.
3. **AI acceptance criteria must reference test data** — "the model should be accurate" is not a criterion; "precision ≥ 0.85 on REQ-2026-010-testset.csv" is.
4. **NFRs must be measurable** — every NFR must state a numeric target and a test approach; vague NFRs are rejected at gate.
5. **Category drives traceability** — functional → system design; ai → model design; nfr → architecture; constraint → governance; assumption → risk register.

## Reference Materials
- `schemas/requirement.schema.json` — validates requirement entries
- `references/requirement-patterns.md` — ID format, SMART patterns, acceptance criteria templates, AI requirement templates, NFR templates
- `references/artefact-catalog.md` — how requirements link to downstream artefacts
- `references/gate-criteria-reference.md` — Gate B requirements quality criteria

## Quality Checks
- Every requirement has a unique `REQ-YYYY-NNN` ID
- Every requirement has ≥1 acceptance criterion in Given/When/Then format
- AI requirements have measurable thresholds referencing a test dataset
- NFRs have numeric targets and a stated test approach
- No requirement body uses vague language (fast, robust, user-friendly, good)
- All requirements are categorised using the 5-category taxonomy
- All requirements have status (draft|reviewed|approved|deferred)
