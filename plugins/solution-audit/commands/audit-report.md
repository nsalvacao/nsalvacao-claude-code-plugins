---
name: audit-report
description: View, compare, and analyze previous audit reports
argument-hint: "[--latest] [--compare YYYY-MM-DD] [--trend] [--dimension=name]"
allowed-tools:
  - Read
  - Grep
  - Glob
---

# Audit Report

View, compare, and analyze previous solution audit reports.

## Behavior

1. **Discover reports**: Find all `.solution-audit-[0-9]*.json` files in the project root (excludes `.solution-audit-latest.json`)
2. **Display based on arguments**:
   - No args or `--latest`: Show most recent audit report summary
   - `--compare YYYY-MM-DD`: Show diff between two reports (regressions, improvements, new/resolved findings)
   - `--trend`: Show score evolution across all saved reports
   - `--dimension=name`: Filter to a specific dimension
3. **No reports found**: Suggest running `/audit` first

## Arguments

- `--latest`: Display the most recent audit report (default behavior)
- `--compare YYYY-MM-DD`: Compare current with a specific dated report
- `--trend`: Show score trends across all available reports
- `--dimension`: Filter to a specific dimension (product-coherence, architecture-coherence, documentation-quality, onboarding-quality, cli-ux, textual-ux, learnability-workflow, spec-gap-analysis)

## Output Format

### Latest report (default)

```
Latest Audit: [date]
Overall: XX/100 [Grade]

| Dimension              | Score | Grade |
|------------------------|-------|-------|
| [per-dimension rows]   |       |       |

Top unresolved findings:
  1. [CRITICAL] [description]
  2. [WARNING] [description]
  ...

Run /audit to refresh, or /audit-report --trend for history.
```

### Comparison

```
Comparison: [date-A] vs [date-B]

| Dimension              | Before | After | Delta |
|------------------------|--------|-------|-------|
| [per-dimension rows]   |        |       | +/-N  |

Regressions (score decreased):
  [findings that worsened or appeared]

Improvements (score increased):
  [findings resolved or improved]

New findings: N | Resolved findings: N
```

### Trend

```
Score Trend: [N] audits from [first-date] to [last-date]

Columns: Overall, Prod (Product Coherence), Arch (Architecture Coherence), Docs (Documentation Quality),
Onb (Onboarding Quality), CLI (CLI UX), Text (Textual UX), Learn (Learnability & Workflow), Spec (Spec Gap Analysis)

| Date       | Overall | Prod | Arch | Docs | Onb  | CLI  | Text | Learn | Spec |
|------------|---------|------|------|------|------|------|------|-------|------|
| [per-date] |         |      |      |      |      |      |      |       |      |

Trend: [improving/stable/declining] ([velocity: +/-N pts/audit])
Best dimension: [name] ([score])
Needs most work: [name] ([score])
```
