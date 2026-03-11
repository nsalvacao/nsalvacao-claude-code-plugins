---
name: ci-fix
description: Fix all GitHub Actions workflow issues — runs ci-audit internally then applies fixes in order
---

# /ci-fix

Fix all identified issues in `.github/workflows/*.yml` files.

## Usage

```
/ci-fix [--dry-run]
```

- Default: applies all fixes, validates each file, commits one per workflow file
- `--dry-run`: shows what would be done without modifying files

## Protocol

**REQUIRED SKILL:** Load the `ci-diagnostics` skill before starting.

### Step 1: Internal audit

Run the full /ci-audit protocol internally. Build complete issue list across all workflow files. Do not output the audit report yet (it will be included in the final summary).

### Step 2: Apply fixes in dependency order

Order: BLOCKERs first, then WARNINGs.
Within each file, fix from top to bottom (line order).

For each fix:
1. Read the current file content
2. Apply the specific fix (targeted Edit, not full rewrite)
3. Validate with yamllint (or python3 yaml fallback) immediately after
4. If validation fails: revert the edit and mark as "FAILED — manual review needed"
5. Continue to next fix

### Step 3: Commit (one commit per workflow file)

For each modified workflow file:
```bash
git add .github/workflows/<filename>.yml
git commit -m "fix(ci): <summary of fixes> in <filename>.yml"
```

### Step 4: Final summary

```
CI Fix Summary
==============
Files modified: N
Fixes applied: N
Fixes skipped (manual): N

Fixed:
  ci.yml -- [BLOCKER] bash arithmetic trap (line 45)
  ci.yml -- [WARNING] fail-fast not disabled (line 12)

Skipped (manual review needed):
  release.yml -- [BLOCKER] complex permissions issue
```

### Dry-run output format

```
[DRY RUN] Would fix in ci.yml:
  Line 45: ((errors++)) -> errors=$((errors+1))
  Line 12: add fail-fast: false to matrix strategy
```

## Important

- Always run internal /ci-audit first — never fix without full diagnosis
- Never use --no-verify on git commits
- If yamllint validation fails after a fix, revert and mark for manual review
- Do not fix INFO-level items by default (too opinionated)
