---
name: lifecycle-tailoring
description: This skill should be used when a project needs the lifecycle framework adapted to its specific product type (MVP, startup, data platform, enterprise, or regulated product), team size, or risk profile. Triggers when the user asks "what phases are mandatory for us", "can we skip Gate B", "we're building an MVP — what's the minimum governance", or when Phase 1 is starting and the governance configuration must be decided.
---

# Lifecycle Tailoring

## Purpose
The framework is designed to be adapted, not applied uniformly. A startup validating an MVP needs different governance intensity than an enterprise platform migration. Lifecycle tailoring is a Phase 1–2 decision that determines which phases to compress, which gates are mandatory, which artefacts to simplify, and which quality thresholds to apply. Done correctly, tailoring prevents over-engineering of governance for simple products and under-engineering of controls for complex or regulated ones.

## When to Use
- Phase 1 (Framing) is starting and the team needs to decide governance intensity
- The product type (MVP, data platform, enterprise, regulated) is known and needs to be matched to a tailoring profile
- A gate is being challenged as unnecessary for the product context
- An artefact requirement seems disproportionate to the project scale
- The delivery team is new to the framework and needs a calibrated starting configuration
- Phase 2 (Architecture) is completing and the Phase 3–7 plan needs to be finalised with the tailored approach

## Instructions

### Step 1: Identify the Product Type and Context
Assess the product and delivery context against four primary tailoring dimensions:
- **Product complexity**: simple feature vs. multi-system platform vs. regulated product
- **Team size**: solo/micro (1–3) vs. small (4–10) vs. large (10+)
- **Risk profile**: experimental/exploratory vs. production-grade vs. safety/compliance-critical
- **Delivery speed requirement**: rapid iteration vs. scheduled releases vs. milestone-driven

Load `references/lifecycle-overview.md` for the standard phase map and default gate criteria.

### Step 2: Select a Tailoring Profile
Match the context to one of the standard profiles (or define a hybrid):

- **MVP/Startup profile**: Compress Phases 1–2 into a single framing week. Gate A and B are informal checkpoints. Phase 3 runs in parallel with early Phase 4 sprints. Gate C is a team self-assessment. Mandatory artefacts reduced to: phase contract, risk register, backlog.

- **Data platform profile**: Full Phase 1–2 required. Gate A mandatory (data governance sign-off). Phase 3 must include data model artefacts. Gate C includes data quality and lineage evidence. Phase 5 (Hardening) has extended test windows.

- **Enterprise integration profile**: All phases and gates mandatory. Phase 2 must produce integration architecture. Gate B requires architecture review board sign-off. Phase 4 has a mandatory security sprint. Gate E requires operational readiness review.

- **Regulated product profile**: All phases, all gates, all artefacts mandatory. Additional compliance artefacts required (audit log, traceability matrix, validation protocol). Gate reviews require external or independent reviewer sign-off.

### Step 3: Define Phase Compression and Skip Rules
For the selected profile, document which phases can be compressed or skipped:
- A phase can be compressed if its outputs are produced in the preceding phase
- A phase can be skipped only if all its mandatory outputs are produced elsewhere and documented
- Skipped phases must be recorded as tailoring decisions with rationale
- Document the decision in the Phase 1 phase contract

### Step 4: Identify Mandatory vs. Optional Gates
For each gate (A–F), classify as:
- **Mandatory**: cannot proceed without formal gate decision
- **Conditional**: mandatory if specific conditions are met (e.g., external users, regulated data)
- **Optional**: team self-assessment is sufficient; no external reviewer required

Record gate classification in the lifecycle tailoring decision document. Reference `docs/phase-essentials/` for gate defaults per phase.

### Step 5: Simplify Artefacts for the Profile
For each artefact in `references/artefact-catalog.md`, classify as:
- **Required**: must be produced and validated
- **Simplified**: required, but a lighter version is acceptable (e.g., risk register as a table rather than schema-validated JSON)
- **Optional**: produced if value justifies the effort
- **Deferred**: not required for this phase but may be needed later

Document simplification decisions with rationale.

### Step 6: Record the Tailoring Decision
Create a lifecycle tailoring decision document as a Phase 1 artefact:
- Selected profile name and rationale
- Phase compression and skip decisions
- Gate classification decisions
- Artefact simplification decisions
- Approver (delivery lead or PM)

Add this document to the Phase 1 evidence index. It will be referenced at all subsequent gate reviews as the authority for governance configuration.

### Step 7: Review Tailoring at Phase Gates
At each gate review, validate that the tailoring decisions are still appropriate:
- Has project complexity increased beyond the original profile?
- Have compliance or regulatory requirements changed?
- If the context has materially changed: update the tailoring decision document and communicate to the team

## Key Principles
1. **Tailor down, not out** — simplify governance proportionally; never eliminate accountability for decisions.
2. **Tailoring is a decision, not a drift** — undocumented changes to governance are scope creep, not tailoring.
3. **Profiles are starting points** — always adapt to the specific project; no two products are identical.
4. **Gate bypass requires explicit approval** — skipping a gate cannot be a team-level decision; it requires PM or sponsor approval.
5. **Tailoring decisions age** — review at each gate; a startup that gains enterprise customers may need to upgrade its governance profile.

## Reference Materials
- `references/lifecycle-overview.md` — Standard phase map, default gate criteria, phase dependencies
- `references/artefact-catalog.md` — Full artefact list with phase assignment and mandatory/optional classification
- `docs/phase-essentials/` — Per-phase essentials cards with tailoring guidance

## Quality Checks
- A tailoring decision document exists as a Phase 1 artefact
- Every skipped phase or gate has documented rationale and approver
- Artefact simplifications are recorded with justification
- Tailoring profile is reviewed at each gate review
- Tailoring decisions are visible to gate reviewers in the evidence pack
- No governance element is removed without explicit sign-off
