# RTM Patterns Reference

Reference material for the `traceability-mapping` skill. Covers RTM table structure, AC-ID format, coverage formulas, worked examples, Gate B checklist, change control patterns, orphan detection, and status lifecycle.

---

## 1. RTM Table Header

The canonical RTM structure. Every column is mandatory; no columns may be omitted.

| REQ-ID | Requirement Title | Category | Priority | AC-ID | Acceptance Criterion | Test Ref | Status | Source Artefact |
|--------|-------------------|----------|----------|-------|----------------------|----------|--------|-----------------|

### Column Definitions

| Column | Type | Allowed Values | Notes |
|--------|------|----------------|-------|
| `REQ-ID` | String | `REQ-YYYY-NNN` | Foreign key to requirements set |
| `Requirement Title` | String | Free text | Short title (≤ 80 chars) |
| `Category` | Enum | `functional` \| `ai` \| `nfr` \| `constraint` \| `assumption` | Maps to Phase 2 source document |
| `Priority` | Enum | `must` \| `should` \| `could` \| `wont` | MoSCoW |
| `AC-ID` | String | `AC-YYYY-NNN` | Unique per acceptance criterion; not per requirement |
| `Acceptance Criterion` | String | Given/When/Then format | Must be testable |
| `Test Ref` | String | Test case ID or `TBD` | TBD acceptable at Gate B |
| `Status` | Enum | `draft` \| `reviewed` \| `approved` \| `deferred` | Mirrors requirement status |
| `Source Artefact` | String | Phase 2 document name | e.g., `business-requirements-set.md` |

---

## 2. AC-ID Format

Format: `AC-YYYY-NNN`

| Field | Rule | Example |
|-------|------|---------|
| `AC` | Fixed prefix | `AC` |
| `YYYY` | Calendar year of the requirement (inherits from REQ-ID year) | `2026` |
| `NNN` | 3-digit sequential number, zero-padded, independent of REQ sequence | `001`, `015` |

### Linking Rules

- One requirement may have multiple ACs: `REQ-2026-001` can have `AC-2026-001`, `AC-2026-002`, `AC-2026-003`
- AC numbering is sequential across the full requirements set, not per requirement
- AC-IDs are permanent; a deferred AC retains its ID with `status: deferred`
- The year in AC-ID mirrors the year in the source REQ-ID for the same baseline

### Example Mapping

| REQ-ID | AC-IDs |
|--------|--------|
| `REQ-2026-001` | `AC-2026-001`, `AC-2026-002` |
| `REQ-2026-002` | `AC-2026-003` |
| `REQ-2026-003` | `AC-2026-004`, `AC-2026-005`, `AC-2026-006` |

---

## 3. Coverage Calculation Formulas

### Requirements Coverage
```
Requirements Coverage (%) =
  (count of REQ-IDs with at least 1 AC-ID assigned)
  ÷ (total count of REQ-IDs in requirements set)
  × 100
```
Gate B threshold: **100%**

### Must Coverage
```
Must Coverage (%) =
  (count of must-priority REQ-IDs with at least 1 AC-ID assigned)
  ÷ (total count of must-priority REQ-IDs)
  × 100
```
Gate B threshold: **100%** — any must requirement without an AC is a gate blocker.

### AC Coverage (Phase 4+)
```
AC Coverage (%) =
  (count of AC-IDs with a non-TBD Test Ref assigned)
  ÷ (total count of AC-IDs in RTM)
  × 100
```
At Gate B: AC coverage = 0% is expected and acceptable (test refs defined in Phase 4).
At Gate D: AC coverage must reach 100%.

### Orphan Rate
```
Orphan Rate (%) =
  (count of REQ-IDs with 0 AC-IDs)
  ÷ (total count of REQ-IDs)
  × 100
```
Gate B threshold: **0%** — any orphaned requirement blocks gate passage.

---

## 4. Full RTM Example

The following example shows 4 requirements covering functional, AI, and NFR categories with their acceptance criteria.

| REQ-ID | Requirement Title | Category | Priority | AC-ID | Acceptance Criterion | Test Ref | Status | Source Artefact |
|--------|-------------------|----------|----------|-------|----------------------|----------|--------|-----------------|
| REQ-2026-001 | User CSV Export | functional | must | AC-2026-001 | Given a registered user with an active account, when the user requests a CSV export of transaction history, then the system shall return a valid CSV file within 3 seconds for datasets up to 10,000 rows. | TBD | approved | business-requirements-set.md |
| REQ-2026-001 | User CSV Export | functional | must | AC-2026-002 | Given a registered user, when the export contains more than 10,000 rows, then the system shall return an asynchronous job reference and notify the user by email when the file is ready. | TBD | approved | business-requirements-set.md |
| REQ-2026-002 | Classification Model Accuracy | ai | must | AC-2026-003 | Given the held-out validation set of 5,000 labelled records (ref: REQ-2026-002-testset.csv), when the classification model is evaluated at inference time, then precision shall be ≥ 0.85 and recall shall be ≥ 0.80. | TBD | approved | ai-requirements-specification.md |
| REQ-2026-003 | API Response Time SLA | nfr | must | AC-2026-004 | Given 1000 concurrent users submitting search queries simultaneously, when the search endpoint is called, then p95 response time shall be ≤ 200ms and p99 shall be ≤ 500ms. | TBD | approved | nfr-specification.md |
| REQ-2026-004 | Data Encryption at Rest | nfr | must | AC-2026-005 | Given a compliance audit conducted against ISO 27001 A.8.24, when storage encryption is verified, then all persistent data stores shall use AES-256 encryption with keys managed via the enterprise KMS. | TBD | draft | nfr-specification.md |

### Coverage Metrics for Example

- Total requirements: 4
- Requirements with ≥1 AC: 4
- **Requirements coverage: 100%**
- Must requirements: 4
- Must requirements with ≥1 AC: 4
- **Must coverage: 100%**
- Total ACs: 5
- ACs with non-TBD test ref: 0
- **AC coverage: 0%** (expected at Gate B — Phase 4 not started)

---

## 5. Gate B RTM Checklist

Ordered validation sequence before submitting the RTM for Gate B review.

- [ ] **1. Requirements coverage = 100%** — every REQ-ID in the requirements set has at least one AC-ID in the RTM
- [ ] **2. Must coverage = 100%** — no must-priority requirement has zero acceptance criteria
- [ ] **3. Zero orphaned requirements** — no REQ-ID in the RTM has 0 associated AC-IDs
- [ ] **4. Zero orphaned ACs** — every AC-ID in the RTM is linked to a valid REQ-ID that exists in the requirements set
- [ ] **5. Zero phantom IDs** — all REQ-IDs in the RTM exist in the source requirements set (no RTM rows for requirements that were deleted or never created)
- [ ] **6. AC-ID format validated** — all AC-IDs follow `AC-YYYY-NNN` format with correct zero-padding
- [ ] **7. Acceptance criteria format** — all ACs are in Given/When/Then format with a measurable outcome
- [ ] **8. AI ACs reference test dataset** — every AC for an `ai` category requirement cites a named test dataset
- [ ] **9. RTM version number** — RTM document version matches the version in `requirements-baseline.md`
- [ ] **10. Source artefact populated** — every RTM row references the Phase 2 document where the requirement is defined
- [ ] **11. Status alignment** — RTM status values match the corresponding requirement status in the source document
- [ ] **12. RTM frozen** — Gate B submission RTM is exported as a read-only snapshot and committed to version control

---

## 6. Change Control RTM Update Pattern

When a requirement changes after baseline, the following fields must be updated atomically in the same change control record.

### Fields to Update

| Field | Action |
|-------|--------|
| `Requirement Title` | Update to reflect the revised title |
| `Acceptance Criterion` | Revise or add/remove AC rows as required |
| `Test Ref` | Invalidate linked test refs if criterion changed; set back to TBD |
| `Status` | Reset to `reviewed` until re-approved |
| `Source Artefact` | Update version reference if source document version changed |

### Version Bump Rules

- Minor text correction (no AC impact): increment patch version (e.g., 1.0.0 → 1.0.1)
- AC revised or added: increment minor version (e.g., 1.0.1 → 1.1.0)
- Requirement added or removed: increment minor version
- Baseline re-approved after changes: lock minor version and update approval date

### Change Control Record Template

```
Change Ref:       CCR-YYYY-NNN
Date:             [YYYY-MM-DD]
Requested by:     [name / role]
Approved by:      [sign-off authority name]
Requirements affected:
  - REQ-2026-NNN: [brief description of change]
ACs affected:
  - AC-2026-NNN: [revised | added | deferred]
  - AC-2026-NNN: [revised | added | deferred]
Test refs invalidated:
  - [test case IDs or "none"]
RTM version:      [before] → [after]
Baseline version: [before] → [after]
Rationale:        [why the change is necessary]
Impact:           [scope, effort, timeline impact]
```

---

## 7. Orphan Detection Patterns

| Orphan Type | Description | Detection Method | Resolution |
|-------------|-------------|------------------|------------|
| **Orphaned requirement** | REQ-ID exists in requirements set but has 0 AC-IDs in RTM | Query RTM for REQ-IDs with no matching AC rows; cross-reference requirements set | Author acceptance criteria using the `requirement-authoring` skill; add to RTM |
| **Orphaned AC** | AC-ID exists in RTM but its REQ-ID does not exist in requirements set | Query RTM for AC-IDs whose REQ-ID column value is missing or invalid | Determine if requirement was deleted (update AC to deferred) or if REQ-ID is a typo (correct it) |
| **Phantom REQ-ID** | REQ-ID in RTM was deleted or never created in requirements set | Diff RTM REQ-ID list against requirements set REQ-ID list | Remove row from RTM if requirement was intentionally deleted; create requirement if row was added prematurely |
| **Duplicate AC-ID** | Same AC-ID appears on multiple RTM rows | Check for duplicate values in AC-ID column | Assign new unique AC-IDs; update linked test refs |
| **Orphaned test ref** | Test case ID in Test Ref column has no corresponding test case in test management system | Cross-reference Test Ref values against test management tool | Correct test case ID or set back to TBD if test was deleted |

### Automated Detection via Script

The `scripts/check-traceability.sh` script detects the first four orphan types automatically. Run before Gate B submission:

```bash
bash scripts/check-traceability.sh plugins/waterfall-lifecycle/artefacts/rtm.md --strict
```

Expected output on a clean RTM:
```
Requirements coverage: 100%
Must coverage: 100%
Orphaned requirements: 0
Orphaned ACs: 0
Phantom REQ-IDs: 0
Gate B: PASS
```

---

## 8. RTM Status Lifecycle

### Pre-Baseline Lifecycle

```
draft → reviewed → approved
```

| Status | Meaning | Who Sets It |
|--------|---------|-------------|
| `draft` | Requirement and AC authored; not yet peer-reviewed | Requirement author |
| `reviewed` | Peer-reviewed; ready for sign-off | Reviewer |
| `approved` | Signed off by PM or sign-off authority; eligible for baseline | Sign-off authority |

### Baseline

At baseline freeze, all approved requirements are locked. The RTM version number is incremented to match the baseline version. Status `approved` becomes the stable state.

### Post-Baseline (Change Control)

```
approved → reviewed → approved  (after change control)
approved → deferred              (if requirement is deferred out of scope)
```

| Status | Meaning | Who Sets It |
|--------|---------|-------------|
| `reviewed` | Requirement re-opened by change control; pending re-approval | Change control process |
| `approved` | Re-approved after change control review | Sign-off authority |
| `deferred` | Moved out of scope; AC-ID retained with deferred status | PM with sign-off authority approval |

### Post-Baseline: RTM Locked State

The Gate B submission RTM snapshot is version-controlled and treated as immutable for audit purposes. Any change after Gate B requires a change control record (CCR) before the working RTM is updated.

```
Gate B snapshot (locked, version-controlled)
        ↓ CCR required for any modification
Working RTM (updated per change control)
```
