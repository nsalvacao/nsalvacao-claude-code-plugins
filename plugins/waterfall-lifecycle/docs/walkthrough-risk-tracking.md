# Risk Tracking: Managing Risks Across the Waterfall Lifecycle

This walkthrough shows how to identify, score, update, escalate, and hand over risks.

---

## Step 1: Identify initial risks in Phase 1

Use the `risk-compliance-screening` agent in Phase 1 (subfase 1.3).
Identify risks across three categories: technical, business, and operational.

Create the initial risk register:

```
/waterfall-artefact-gen initial-risk-register 1
```

---

## Step 2: Score with the 5×5 matrix

Reference: `skills/risk-management/references/risk-patterns.md`

| Score | Threshold | Action |
|-------|-----------|--------|
| 1–4   | LOW       | Monitor; review at next gate |
| 5–9   | MEDIUM    | Mitigation plan required |
| 10–16 | HIGH      | Immediate mitigation; owner assigned |
| 17–25 | CRITICAL  | Escalate to steering committee |

HIGH risks (score ≥12): add to phase contract risk summary immediately.

---

## Step 3: Update risk register as phase progresses

Update risk status (`open`, `mitigated`, `accepted`, `closed`) and re-score
as new information emerges. Surface all open HIGH+ risks at Gate A review.

---

## Step 4: Phase 1→2 handover: transfer open risks

All open risks are carried into Phase 2 via the handover entry:

```
/waterfall-artefact-gen handover-entry 1
```

The receiving phase lead reviews the handover entry as part of Phase 2 entry criteria.
Risks evolve as requirements become clearer in Phase 2.

---

## Step 5: HIGH risk escalation at gate review

When `/waterfall-gate-review N` runs, the `gate-reviewer` agent:
1. Loads all risks with `status: open` and `score >= 10`
2. Lists them under **Outstanding High Risks** in the gate report
3. Requires sign-off authority acknowledgement before gate passes
4. Blocks gate if any CRITICAL risk (score ≥17) is unacknowledged

---

## Step 6: V&V phase target state

By Phase 5 (V&V), the risk register should show most risks in `mitigated` or `accepted`
state. Any remaining `open` HIGH risks must be explicitly accepted by the sign-off authority
before Gate E can close.

---

## Reference

- Risk patterns and 5×5 matrix: `skills/risk-management/references/risk-patterns.md`
- Initial risk register template: `templates/phase-1/initial-risk-register.md`
- Handover template: `templates/transversal/handover-entry.md`
- Gate criteria (risk section): `references/gate-criteria-reference.md`
