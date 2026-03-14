---
name: agile-metrics-report
description: Generate a metrics report for the current phase or overall lifecycle — delivery, quality, product, AI, governance metrics.
---

# /agile-metrics-report [scope]

## Overview

Generates a structured metrics report covering delivery, quality, product, AI, and governance dimensions. The report is produced from metrics data collected throughout the lifecycle and compared against baselines and thresholds defined in `references/metrics-reference.md`.

Use this command before gate reviews, at phase transitions, or on demand for stakeholder reporting.

## Usage

```
/agile-metrics-report [scope]
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `scope` | Optional | `phase` (default) for current phase metrics, `lifecycle` for full lifecycle summary, `sprint` for current sprint metrics |

## Metrics Categories

| Category | Examples |
|----------|---------|
| **Delivery** | Velocity, commitment ratio, cycle time, lead time, carry-over rate |
| **Quality** | Defect rate, test coverage, escaped defects, MTTR |
| **Product** | User adoption, feature usage, NPS, goal achievement |
| **AI/ML** | Model accuracy, drift rate, data quality score, retraining frequency, hallucination rate |
| **Governance** | Gate pass rate, waiver count, risk resolution rate, artefact completion rate |

AI/ML metrics are only included if product type is `ai-ml` or `data-product`.

## What It Does

1. Reads metric data from `.agile-lifecycle/metrics/` for the requested scope.
2. Loads thresholds and baselines from `references/metrics-reference.md`.
3. Runs `scripts/generate-metrics-report.sh [scope]` to compile raw data.
4. For each metric:
   - Shows current value vs baseline vs threshold.
   - Flags metrics outside acceptable range with `⚠ warning` or `✗ critical`.
5. Produces a formatted markdown report.
6. Optionally saves the report to `.agile-lifecycle/metrics/report-<date>.md`.
7. Highlights key findings and suggests actions for out-of-range metrics.

## Examples

```
# Report for current phase (default)
/agile-metrics-report

# Full lifecycle summary
/agile-metrics-report lifecycle

# Sprint-level metrics
/agile-metrics-report sprint
```

## Related Commands

- `/agile-gate-review` — uses metrics report as evidence
- `/agile-retrospective` — uses metrics to inform retrospective
- `/agile-status` — includes a metrics snapshot

## Related Agents

- `agents/transversal/metrics-analyst` — compiles, analyses, and interprets metrics data
