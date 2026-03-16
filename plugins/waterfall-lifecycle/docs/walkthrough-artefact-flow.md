# Artefact Flow: Creating, Reviewing, and Closing Artefacts

This walkthrough shows how to find, generate, fill, and submit artefacts as gate evidence.

---

## Step 1: Find the right template

Check `references/artefact-catalog.md` for the artefact `artefact_id`.
The catalog lists every artefact, its phase, template file, and gate it evidences.

Example entry:
```
| problem-statement | Phase 1 | templates/phase-1/problem-statement.md | Gate A |
```

If unsure which artefact to create, cross-reference `docs/phase-essentials/phase-N.md`
for the current phase — the **Evidence Required** section lists all mandatory artefacts.

---

## Step 2: Generate from template

```
/waterfall-artefact-gen problem-statement 1
```

The `artefact-generator` agent:
1. Looks up `problem-statement` in the artefact catalog
2. Copies the template to `.waterfall-lifecycle/artefacts/phase-1/problem-statement.md`
3. Substitutes project metadata from the phase contract
4. Returns the path and opens the file for editing

---

## Step 3: Fill using artefact-authoring skill

The `artefact-authoring` skill is invoked by the agent to guide field completion.
No mandatory field (`REQUIRED`) may be left empty. Optional fields can be `N/A`.

---

## Step 4: Self-review with completeness checklist

Each template has a completeness checklist at the bottom. Work through it before
marking the artefact as done.

---

## Step 5: Add to evidence index

Update the phase contract `exit_criteria` entry:

```yaml
- criterion: "Problem statement reviewed and approved by sponsor"
  status: met
  evidence: "problem-statement.md"
```

---

## Step 6: Verify evidence threshold at gate

At gate review, `/waterfall-gate-review A` checks that all `evidence_required` files exist
and are non-empty. The `phase-contract-enforcement` skill will fail on missing or
incomplete artefacts.

---

## Step 7: Fulfil closure obligation at phase end

Before gate review, run `/waterfall-lifecycle-status` to confirm no artefacts are
missing. At phase closure, the closure obligation (archive, baseline, or hand_over)
is recorded in the gate review report.

---

## Reference

- Artefact catalog: `references/artefact-catalog.md`
- Artefact-authoring skill: `skills/artefact-authoring/SKILL.md`
- Phase essentials cards: `docs/phase-essentials/`
