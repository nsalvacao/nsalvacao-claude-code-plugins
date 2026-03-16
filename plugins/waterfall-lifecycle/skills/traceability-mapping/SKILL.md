---
name: traceability-mapping
description: This skill should be used when creating or maintaining a Requirements Traceability Matrix (RTM), validating traceability coverage, detecting orphaned requirements, and preparing the RTM for Gate B submission.
---

# Traceability Mapping

## Purpose
Requirements traceability is the backbone of waterfall governance — every requirement must be traceable from its origin (business objective) through acceptance criteria to test cases and ultimately to delivered artefacts. This skill governs RTM creation, coverage measurement, gap detection, and baseline maintenance.

## When to Use
- Building the initial RTM from a completed requirements set
- Validating RTM coverage before Gate B submission
- Detecting orphaned requirements (requirement with no acceptance criterion or test ref)
- Detecting orphaned test cases (test with no linked requirement)
- Updating the RTM after a change control decision

## Instructions

### Step 1: Establish the RTM Structure
The RTM table has these mandatory columns:

| REQ-ID | Requirement Title | Category | Priority | AC-ID | Acceptance Criterion | Test Ref | Status | Source Artefact |
|--------|-------------------|----------|----------|-------|----------------------|----------|--------|-----------------|

Column definitions:
- `REQ-ID` — unique requirement identifier (REQ-YYYY-NNN)
- `Requirement Title` — short title from the requirement
- `Category` — functional|ai|nfr|constraint
- `Priority` — must|should|could|wont
- `AC-ID` — unique acceptance criterion ID (AC-YYYY-NNN, linked to REQ-ID)
- `Acceptance Criterion` — the Given/When/Then text
- `Test Ref` — test case ID or TBD if Phase 4 not yet started
- `Status` — draft|reviewed|approved|deferred
- `Source Artefact` — which Phase 2 document defines this requirement

### Step 2: Populate from Requirements Artefacts
Source all REQ-IDs from:
- `business-requirements-set.md` (category: functional, constraint)
- `ai-requirements-specification.md` (category: ai)
- `nfr-specification.md` (category: nfr)

For each requirement: extract all acceptance criteria; assign AC-YYYY-NNN IDs; set Test Ref to TBD.

### Step 3: Compute Coverage Metrics
- **Requirements coverage** = (requirements with ≥1 AC) / total requirements × 100%
- **AC coverage** = (ACs with test ref assigned) / total ACs × 100% (expected TBD in Phase 2)
- **Must coverage** = (must requirements with ≥1 AC) / total must requirements × 100%
- Gate B threshold: requirements coverage = 100%, must coverage = 100%

### Step 4: Detect Orphans
- **Orphaned requirements**: REQ-ID with 0 acceptance criteria → gate blocker
- **Orphaned ACs**: AC-ID not linked to a REQ-ID → data integrity error
- Report all orphans in the RTM coverage report

### Step 5: Validate Against Schema
Review `schemas/requirement.schema.json` for each entry. Confirm all REQ-IDs in the RTM exist in the requirements set (no phantom IDs).

### Step 6: Gate B Submission
Before Gate B, confirm:
- Requirements coverage = 100%
- Must coverage = 100%
- Zero orphaned requirements
- RTM version matches requirements-baseline.md version

## Key Principles
1. **100% must coverage is a gate blocker** — every must requirement without an acceptance criterion blocks Gate B; no exceptions.
2. **RTM is the single source of truth** — when requirements and RTM diverge, the RTM is wrong; update RTM, not requirements.
3. **AC-IDs are permanent** — deferred ACs keep their ID; they are marked deferred in status.
4. **Test Ref = TBD is acceptable at Gate B** — test cases are defined in Phase 4; leave TBD but ensure AC exists.
5. **Change control updates RTM atomically** — when a requirement changes post-baseline, the RTM, acceptance criteria, and version number must all be updated in the same change control record.

## Reference Materials
- `schemas/requirement.schema.json` — requirement entry validation
- `schemas/requirements-baseline.schema.json` — baseline completeness validation
- `references/rtm-patterns.md` — RTM table examples, coverage calculation formulas, AC ID format, Gate B RTM checklist
- `references/gate-criteria-reference.md` — Gate B traceability requirements
- Script: `scripts/check-traceability.sh` — automated RTM coverage validation

## Quality Checks
- Requirements coverage = 100% (every REQ-ID has ≥1 AC)
- Must coverage = 100% (no must requirement without AC)
- Zero orphaned requirements or ACs in the RTM
- All AC-IDs follow format AC-YYYY-NNN
- RTM version number matches requirements-baseline.md version
- Gate B submission RTM is exported/frozen and version-controlled
