# Partial Credit Rules

Rules for when to award partial credit vs zero. Apply these after the primary rubric to resolve edge cases.

---

## When to Award 50% Credit

Award half points when:

1. **File exists but is template/placeholder-only** — The file is present but contains unreplaced template variables (e.g., `[Your Name]`, `<!-- Add description here -->`), or is a copy of a template without customization.

2. **Feature present but misconfigured** — A CI workflow exists but has a syntax error preventing it from running; or a test framework is installed but no test files exist.

3. **Present in wrong location** — CONTRIBUTING.md is in root instead of `.github/`; this still demonstrates intent and should receive partial credit.

4. **Partial completeness** — README exists with description and installation but missing usage examples; CHANGELOG exists but has not been updated in >12 months.

---

## When to Award 0% (Zero)

Award zero when:

1. **File completely missing** — The referenced file does not exist anywhere in the repository.

2. **Empty or trivially short** — File exists but has <10 meaningful lines (excluding blank lines, comments, and HTML/markdown headers).

3. **Auto-generated boilerplate, no customization** — File is byte-for-byte identical to a known template (e.g., GitHub's default LICENSE text without YEAR/NAME substituted).

4. **Explicitly disabled** — CI workflow is present but has `if: false` on all jobs, or tests are skipped unconditionally.

---

## Rounding Rules

- Round individual sub-item scores to the nearest integer
- Never subtract points (floor at 0 per sub-item)
- Total category score is also floored at 0
- Overall score is floored at 0 and capped at 100

---

## Edge Cases

### Monorepos

- Score the highest-quality package/module, not the average
- If root README is empty but each package has a full README, award full README points
- CI must cover at least one package to receive CI points

### Forks

- Check for differentiation from the original: custom README, new commits, different CI
- If the fork is identical to upstream with no commits, score as-if a fresh repo (penalize for missing customization)

### Private Repositories

- Skip checks that require public access (badge rendering, external link resolution)
- Score only what can be assessed from file content

### Monolingual vs Multi-language

- Detection patterns: if Python detected, check Python-specific tools (ruff, pytest)
- If no language detected, only score universal items (README, LICENSE, CI presence)
