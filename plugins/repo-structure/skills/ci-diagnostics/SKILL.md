---
name: CI Diagnostics
description: >
  Pattern library for diagnosing GitHub Actions CI failures.
  Use when reviewing workflow files, debugging CI errors, or auditing automation.
  Activated by: "CI is failing", "workflow error", "GitHub Actions issue", /ci-audit, /ci-fix.
version: 1.0.0
---

# CI Diagnostics Skill

Pattern library for common GitHub Actions failures. Apply these patterns when reading workflow files or CI logs.

## Pattern 1: bash -e Arithmetic Trap

**Symptom:** Step fails with exit code 1 on arithmetic expression.
**Cause:** `((n++))` returns exit code 1 when `n=0` because `((0))` is falsy in bash.
**Fix:** Replace `((n++))` with `n=$((n+1))`. Replace `((n--))` with `n=$((n-1))`.
**Detection:** Grep for `((\w*\+\+))` or `((\w*--))` in scripts run under bash with `set -e` or `shell: bash`.

## Pattern 2: YAML Indentation Errors

**Symptom:** "Invalid workflow file" or "YAML parse error" in Actions tab.
**Cause:** Mixed tabs/spaces, wrong indentation level for `run:` multi-line block.
**Fix:** Use 2-space indent throughout. Multi-line `run:` blocks must use `|` and indent content by 2 more spaces.
**Detection:** Run `yamllint` on all `.github/workflows/*.yml`. Check for tabs with `grep -P "\t" file.yml`.

## Pattern 3: Missing `on:` key

**Symptom:** Workflow never triggers.
**Cause:** Missing or invalid `on:` key, or using `true` as a YAML boolean instead of quoted string.
**Fix:** Every workflow must have an `on:` key. Avoid unquoted `on` at start of line (YAML parses as boolean `true`).
**Detection:** Check `grep -n "^on:" workflow.yml` — must appear exactly once near top.

## Pattern 4: Missing Permissions

**Symptom:** "Resource not accessible by integration" or 403 errors in steps.
**Cause:** Workflow needs `permissions: contents: write` or `pull-requests: write` but does not declare them.
**Fix:** Add `permissions:` block at job or workflow level with minimum required permissions.
**Common cases:**
- Creating releases: `contents: write`
- Commenting on PRs: `pull-requests: write`
- Pushing to branch: `contents: write`
- Reading packages: `packages: read`

## Pattern 5: Missing Secrets/Env Vars

**Symptom:** Step fails with "empty string" or "undefined variable" or authentication error.
**Cause:** Secret not propagated to step via `env:` or `${{ secrets.X }}` not set in repo.
**Fix:** Check `env:` block at step level; verify secret exists in repo/org settings.
**Detection:** Grep for `${{ secrets.` in workflow, verify each is documented.

## Pattern 6: Matrix Strategy and fail-fast

**Symptom:** One matrix job fails and cancels all others, making root cause hard to find.
**Cause:** Default `fail-fast: true` cancels siblings on first failure.
**Fix:** Add `fail-fast: false` to matrix strategy when debugging or when jobs are independent.

## Pattern 7: Checkout Depth for Tags

**Symptom:** `git describe` fails, version detection broken, tag not found.
**Cause:** Default `fetch-depth: 1` shallow clone — no tags or history.
**Fix:** Add `fetch-depth: 0` to `actions/checkout` step when tags or full history needed.

## Pattern 8: Cache Invalidation

**Symptom:** Cached dependencies cause test failures after dep updates.
**Cause:** Cache key not including lockfile hash.
**Fix:** Use `${{ hashFiles('**/package-lock.json') }}` or equivalent in cache key.
**Pattern:**
```yaml
- uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
    restore-keys: ${{ runner.os }}-node-
```

## Pattern 9: Markdownlint Config Format

**Symptom:** markdownlint-cli2 fails with "config file not found" or ignores rules.
**Cause:** Using `.markdownlintrc` (JSON only) instead of `.markdownlint.yml` / `.markdownlint.json`.
**Fix:** Use `.markdownlint.yml` (YAML) or `.markdownlint.json` (JSON) for markdownlint-cli2. Verify config key names match the linter version.

## Pattern 10: Invalid Runner

**Symptom:** "The job was not picked up by any runner" or immediate failure.
**Cause:** Typo in `runs-on` value (e.g., `ubuntu-lastest` instead of `ubuntu-latest`).
**Valid runners:** `ubuntu-latest`, `ubuntu-22.04`, `ubuntu-24.04`, `windows-latest`, `macos-latest`, `macos-14`.
**Detection:** Grep `runs-on:` in all workflows and validate against known values.

## Severity Classification

| Severity | Meaning |
|----------|---------|
| **BLOCKER** | Workflow will never succeed until fixed |
| **WARNING** | May cause intermittent failures or poor DX |
| **INFO** | Improvement opportunity, not currently breaking |

Examples:
- Invalid `runs-on` -> BLOCKER
- Missing `on:` -> BLOCKER
- Missing permissions (403) -> BLOCKER
- `((n++))` with set -e -> BLOCKER (when n=0)
- `fail-fast: true` -> WARNING
- Shallow clone without tags needed -> WARNING (silent failure)
- Cache key without lockfile hash -> WARNING
