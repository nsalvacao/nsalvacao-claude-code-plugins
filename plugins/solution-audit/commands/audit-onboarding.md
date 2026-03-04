---
name: audit-onboarding
description: Audit onboarding experience — setup clarity, prerequisites, time-to-first-success
argument-hint: "[--simulate] [--persona=new-user|developer|contributor]"
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Skill
---

# Onboarding Audit

Audit how easy it is for a new user to go from zero to first meaningful result.

## Behavior

1. **Orient**: Locate the primary onboarding path (README quickstart, GETTING_STARTED.md, etc.)
2. **Load skill**: Apply `onboarding-quality` skill
3. **Prerequisite audit**: Check all stated prerequisites are complete; detect unstated requirements
4. **Step-by-step walkthrough**: Follow each installation/setup step as documented
5. **First-run evaluation**: Assess what happens when the user runs the tool for the first time
6. **Error recovery assessment**: Check what happens when common setup failures occur
7. **Cognitive load evaluation**: Assess how many concepts needed before first productive use
8. **Progressive disclosure check**: Verify complexity is introduced gradually
9. **Report**: Present findings with step-by-step assessment

## Arguments

- `--simulate`: Attempt to follow setup steps and report actual blockers encountered
- `--persona`: Evaluate from the perspective of a specific user type (default: new-user)

## Output Format

```
Onboarding Audit — [project-name]

Onboarding Quality: XX/100 [Grade]

Metrics:
  Steps to first success: N
  Prerequisites documented: X/Y (Y inferred)
  Estimated time-to-first-success: ~N minutes
  Undocumented assumptions: N found

Step-by-step assessment:
  Step 1 — [description]: [pass/issue]
  Step 2 — [description]: [pass/issue]
  ...

Findings:
  [Categorized by: prerequisites, setup, first-run, error recovery, cognitive load]

Actionable fixes: [prioritized list]
```
