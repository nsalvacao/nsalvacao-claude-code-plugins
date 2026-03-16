# Walkthrough — Initialising the Framework and Completing Phase 1

This walkthrough shows the full sequence from a blank project to a Gate A-ready Phase 1.

---

## Step 1: Initialise the lifecycle

```
/waterfall-lifecycle-init
```

The `lifecycle-orchestrator` agent runs and creates the directory structure under `lifecycle/`:

```
lifecycle/
  phase-contract.yaml          # populated with Phase 1 defaults
  risk-register.md             # empty register
  assumption-register.md       # empty register
  phase-1/                     # Phase 1 working directory
  references/                  # symlinked to plugin references
```

You are prompted to confirm the project name and product type.

---

## Step 2: Check initial status

```
/waterfall-lifecycle-status
```

Output shows Phase 1 as `in_progress`, all other phases as `not_started`.
Gate A status: `open` (no exit criteria met yet).

---

## Step 3: Start Phase 1

```
/waterfall-phase-start 1
```

Invokes the `problem-value-context` agent (subfase 1.1). The agent guides you through:

- Defining the problem statement
- Articulating the value proposition
- Identifying key stakeholders
- Scoping the AI component and justification

Output: `lifecycle/phase-1/problem-statement.md` is created.

---

## Step 4: Work through subfases 1.2–1.4

**Subfase 1.2 — Feasibility:**
The `feasibility-analyst` agent runs automatically after 1.1.
Creates `lifecycle/phase-1/feasibility-assessment.md` and
`lifecycle/phase-1/ai-component-justification.md`.

**Subfase 1.3 — Risk Screening:**
The `risk-assumption-tracker` agent (transversal) is invoked.
Populates `lifecycle/risk-register.md` with initial entries.
Use the `risk-management` skill to score each risk using the 5×5 matrix.

**Subfase 1.4 — Delivery Framing:**
The `delivery-framing` agent runs.
Creates `lifecycle/phase-1/delivery-framing.md` with timeline, budget, and governance.
Updates `phase-contract.yaml` with `status: ready_for_gate`.

---

## Step 5: Run Gate A review

```
/waterfall-gate-review A
```

Invokes the `gate-reviewer` agent. It:

1. Loads `phase-contract.yaml` and verifies all exit criteria are `met`
2. Checks all `evidence_required` files exist
3. Runs `phase-contract-enforcement` skill
4. Produces `lifecycle/gate-reviews/gate-a-report.md`

If any criterion is not met, the agent lists the gaps and blocks gate closure.

---

## Step 6: Gate passed — Phase 1 complete

When all criteria pass, `gate-a-report.md` is generated with status `PASSED`.
`phase-contract.yaml` is updated to `status: closed`.
`/waterfall-lifecycle-status` now shows Phase 1 `complete`, Phase 2 `ready_to_start`.

Next: `/waterfall-phase-start 2` to begin Requirements and Baseline.

---

## Reference

- Phase 1 details: `docs/phase-essentials/phase-1.md`
- Worked example: `docs/worked-example-phase1-1.md`
- Gate A criteria: `references/gate-criteria-reference.md`
