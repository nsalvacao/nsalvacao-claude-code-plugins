# Walkthrough — Creating and Managing Artefacts

This walkthrough shows how to find, generate, fill, and submit artefacts as gate evidence.

---

## Step 1: Find the right template

Open `references/artefact-catalog.md`. This catalog lists every artefact in the lifecycle,
the phase it belongs to, the template file, and the gate it is evidence for.

Example entry:
```
| problem-statement | Phase 1 | templates/phase-1/problem-statement.md | Gate A |
```

If unsure which artefact to create, cross-reference with `docs/phase-essentials/phase-N.md`
for the current phase — the **Evidence Required** section lists all mandatory artefacts.

---

## Step 2: Generate the artefact from template

```
/waterfall-artefact-gen problem-statement 1
```

The `artefact-generator` agent:
1. Looks up `problem-statement` in the artefact catalog
2. Copies `templates/phase-1/problem-statement.md` to `lifecycle/phase-1/problem-statement.md`
3. Substitutes project metadata (name, date, owner) from `phase-contract.yaml`
4. Returns the path and opens the file for editing

---

## Step 3: Fill the template using artefact-authoring skill

The `artefact-authoring` skill is invoked by the agent to guide field completion.
It enforces:

- No empty mandatory fields (marked `REQUIRED` in template)
- Consistent terminology with the phase contract
- AI component fields populated where the artefact type requires them

Work through each section. Optional fields marked `OPTIONAL` can be left as `N/A`.

---

## Step 4: Submit as gate evidence

When the artefact is complete, update `phase-contract.yaml`:

```yaml
exit_criteria:
  - criterion: "Problem statement documented and sponsor-reviewed"
    status: met
    evidence: "problem-statement.md"
```

The `/waterfall-gate-review` command validates that the evidence file exists
and is non-empty before accepting the exit criterion as met.

---

## Step 5: Check artefact closure obligation at phase end

Before calling `/waterfall-gate-review`, run `/waterfall-lifecycle-status`.
The status command lists any artefacts in `evidence_required` that are missing or empty.

All required artefacts must exist before the gate review proceeds.
Partial artefacts (files with `REQUIRED` fields still unfilled) will fail the
`phase-contract-enforcement` skill check and block gate closure.

---

## Reference

- Artefact catalog: `references/artefact-catalog.md`
- Artefact-authoring skill: `skills/artefact-authoring/SKILL.md`
- Phase essentials cards: `docs/phase-essentials/`
