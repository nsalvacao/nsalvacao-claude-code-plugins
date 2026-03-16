# Walkthrough — Tracking Risks Across Phases

This walkthrough shows how to identify, score, update, escalate, and hand over risks.

---

## Step 1: Initial risk identification in Phase 1

Use the `risk-management` skill during Phase 1 (subfase 1.3 — Risk Screening).
The `risk-assumption-tracker` agent prompts you to identify risks across three categories:

- **Technical risks** — AI model accuracy, integration complexity, data quality
- **Business risks** — budget, stakeholder alignment, regulatory compliance
- **Operational risks** — deployment, support capacity, vendor dependency

For each risk, create a `risk-register-entry.md` artefact:

```
/waterfall-artefact-gen risk-register-entry 1
```

---

## Step 2: Score with the 5×5 matrix

The `risk-management` skill applies the 5×5 likelihood × impact matrix.
Reference: `skills/risk-management/references/risk-patterns.md`

| Score | Threshold | Action |
|-------|-----------|--------|
| 1–4   | LOW       | Monitor; review at next gate |
| 5–9   | MEDIUM    | Mitigation plan required |
| 10–16 | HIGH      | Immediate mitigation; owner assigned |
| 17–25 | CRITICAL  | Escalate to steering committee |

Each risk entry captures: `id`, `description`, `likelihood (1-5)`, `impact (1-5)`,
`score`, `threshold`, `mitigation`, `owner`, `status`.

---

## Step 3: Update the risk register across phases

At the start of each phase, run `/waterfall-phase-start N`. The `lifecycle-orchestrator`
agent loads the current risk register and prompts review of open risks.

For each open risk:
- Re-score if conditions have changed
- Update `status` to `open`, `mitigated`, `accepted`, or `closed`
- Add a `review_note` with the date and reviewer

The risk register lives at `lifecycle/risk-register.md` and is cumulative across all phases.

---

## Step 4: High-risk escalation at gate review

When `/waterfall-gate-review N` is called, the `gate-reviewer` agent automatically:
1. Loads all risks with `status: open` and `score ≥ 10`
2. Lists them in the gate report under **Outstanding High Risks**
3. Requires the sign-off authority to acknowledge each one before gate passes

A gate cannot close with an unacknowledged CRITICAL risk (score ≥ 17).

---

## Step 5: Transfer open risks at phase handover

At phase close, the `lifecycle-orchestrator` creates a handover entry:

```
/waterfall-artefact-gen handover-entry N
```

The handover entry includes a snapshot of all open risks being carried into the next phase,
with their current scores, owners, and mitigation status.

The receiving phase lead reviews the handover entry as part of their phase entry criteria.

---

## Reference

- Risk patterns and 5×5 matrix: `skills/risk-management/references/risk-patterns.md`
- Risk register template: `templates/transversal/risk-register-entry.md`
- Handover template: `templates/transversal/handover-entry.md`
- Gate criteria (risk section): `references/gate-criteria-reference.md`
