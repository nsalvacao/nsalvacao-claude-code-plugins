# Getting Started: Init and Phase 1 Walkthrough

This walkthrough shows the full sequence from a blank project to a Gate A-ready Phase 1.

---

## Step 1: Initialise the lifecycle

```
/waterfall-lifecycle-init my-ai-project
```

The `lifecycle-orchestrator` agent runs and creates the directory structure under `.waterfall-lifecycle/`:

```
.waterfall-lifecycle/
  lifecycle-state.json         # Phase 1 active, gates A-H pending
  artefacts/phase-1/           # Phase 1 working directory
  gate-reports/                # Gate review reports
```

You are prompted to confirm the project name and product type.

---

## Step 2: Check initial status

```
/waterfall-lifecycle-status
```

Output shows Phase 1 as `in_progress`, all other phases as `not_started`.
Gates A–H status: `pending`.

---

## Step 3: Start Phase 1

```
/waterfall-phase-start 1
```

Loads `docs/phase-essentials/phase-1.md` and routes to the `problem-value-context` agent (subfase 1.1).

---

## Step 4: Work through subfases 1.1–1.4

**Subfase 1.1 — Problem and Value Context:**
Work with the `problem-value-context` agent to create `problem-statement`, `vision-statement`, `stakeholder-map`.

**Subfase 1.2 — Feasibility Assessment:**
Invoke the `feasibility-assessment` agent → create `feasibility-assessment`, `data-feasibility-note`, `ai-feasibility-note`.

**Subfase 1.3 — Risk and Compliance Screening:**
Invoke the `risk-compliance-screening` agent → create `initial-risk-register`, `assumption-register`, `clarification-log`.

**Subfase 1.4 — Delivery Framing:**
Invoke the `delivery-framing` agent → create `project-charter`, `initiation-gate-pack`.

---

## Step 5: Confirm Gate A readiness

```
/waterfall-lifecycle-status
```

Confirms all Gate A artefacts present; phase contract shows `status: ready_for_gate`.

---

## Step 6: Run Gate A review

```
/waterfall-gate-review A
```

The `gate-reviewer` agent checks all Gate A criteria. On pass: Gate A status → `passed`, Phase 1 → `approved`. Run `/waterfall-phase-start 2` to move Phase 2 to `in_progress`.

Next: `/waterfall-phase-start 2` to begin Requirements and Baseline.

---

## Reference

- Phase 1 details: `docs/phase-essentials/phase-1.md`
- Worked example: `docs/worked-example-phase1-1.md`
- Gate A criteria: `references/gate-criteria-reference.md`
