---
name: ci-audit
description: Audit all GitHub Actions workflows for syntax errors, logic issues, permissions, and known failure patterns
---

# /ci-audit

Audit all `.github/workflows/*.yml` files and report every issue found.

## Usage

```
/ci-audit [--fix-plan]
```

- Default: diagnose-only — lists all issues without changing files
- `--fix-plan`: generate an ordered fix plan after diagnosis

## Protocol

**REQUIRED SKILL:** Load the `ci-diagnostics` skill before starting.

### Step 1: Discover workflows

Read ALL files matching `.github/workflows/*.yml` and `.github/workflows/*.yaml`. Do not skip any.

### Step 2: Apply ci-diagnostics patterns to each file

For each workflow file, check all 10 patterns from the ci-diagnostics skill:

1. bash -e arithmetic trap (`((n++))`)
2. YAML indentation errors
3. Missing or invalid `on:` key
4. Missing permissions (contents/pull-requests/packages)
5. Missing or undocumented secrets/env vars
6. Matrix strategy fail-fast setting
7. Checkout depth for tag/release workflows
8. Cache key missing lockfile hash
9. Markdownlint config format
10. Invalid runner name

### Step 3: Output structured report

For each issue found, report:
```
[SEVERITY] filename.yml:line — Pattern N: <description>
  Found: <exact problematic text>
  Fix: <what to change>
```

Severity levels: BLOCKER | WARNING | INFO

### Step 4: Summary table

```
| File | BLOCKERs | WARNINGs | INFOs |
|------|----------|----------|-------|
| ci.yml | 2 | 1 | 0 |
| release.yml | 0 | 1 | 2 |
```

### Step 5 (with --fix-plan): Generate ordered fix plan

Order: BLOCKERs first, then WARNINGs, then INFOs.
Within each severity, order by dependency (fix syntax before logic).
Output as numbered list: `N. Fix [pattern] in [file]:[line]`

## Important

- Read all workflow files BEFORE reporting any issues
- Do not modify any files unless --fix-plan is combined with /ci-fix
- If no `.github/workflows/` directory exists, report "No workflows found"
