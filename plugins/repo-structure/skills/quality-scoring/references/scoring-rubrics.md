# Quality Scoring Rubrics

Detailed rubrics for each sub-item in the 4 scoring categories. Each rubric defines 0%, 50%, and 100% criteria.

---

## Documentation (30 pts total)

### README Completeness (12 pts)

| Score | Criteria |
|-------|----------|
| 0% | README missing, or contains only placeholder text (e.g. "# Project Name") |
| 50% | README present with basic description but missing quickstart, installation, or usage examples |
| 100% | README has title, description, badges, installation instructions, usage examples, and at least one code snippet |

### API Documentation (5 pts)

| Score | Criteria |
|-------|----------|
| 0% | No API docs, no docstrings, no generated docs |
| 50% | Some docstrings or partial API reference; no hosted/generated HTML |
| 100% | Complete API reference (docstrings + generated HTML, or dedicated docs site) |

### Additional Docs (8 pts)

| Score | Criteria |
|-------|----------|
| 0% | No CONTRIBUTING, CHANGELOG, architecture docs, or examples |
| 50% | 1-2 of: CONTRIBUTING.md, CHANGELOG.md, examples directory |
| 100% | All of: CONTRIBUTING.md, CHANGELOG.md, examples, and at least one architecture/design doc |

### Inline Documentation (3 pts)

| Score | Criteria |
|-------|----------|
| 0% | <5% comment density, no function-level docstrings |
| 50% | 5-10% comment density, or only top-level docstrings |
| 100% | >10% comment density with function-level docstrings on public API |

### Badges (2 pts)

| Score | Criteria |
|-------|----------|
| 0% | No badges in README |
| 50% | Decorative badges only (language, license) but no CI status badge |
| 100% | CI status badge + at least one quality badge (coverage, license, version) |

---

## CI/CD (25 pts total)

### Automated Testing (8 pts)

| Score | Criteria |
|-------|----------|
| 0% | No test runner configured, no .github/workflows running tests |
| 50% | Tests exist and run locally, but no CI automation OR CI exists but does not run tests |
| 100% | CI workflow runs tests on every push/PR, tests actually pass |

### Continuous Integration (8 pts)

| Score | Criteria |
|-------|----------|
| 0% | No CI configuration (.github/workflows/ empty or absent) |
| 50% | CI workflow exists but only runs on main; no PR checks |
| 100% | CI runs on push and pull_request, checks multiple branches |

### Code Quality Gates (5 pts)

| Score | Criteria |
|-------|----------|
| 0% | No linting or formatting checks in CI |
| 50% | Linting configured but not in CI, or in CI but not blocking |
| 100% | Linting and/or formatting check runs in CI and blocks merge on failure |

### Deployment Pipeline (4 pts)

| Score | Criteria |
|-------|----------|
| 0% | No deployment automation |
| 50% | Manual deployment steps documented, or partial automation (build only) |
| 100% | Automated deployment triggered by release/tag; includes rollback documentation |

---

## Testing (25 pts total)

### Test Presence (10 pts)

| Score | Criteria |
|-------|----------|
| 0% | No test files found (no tests/, test/, spec/ directory; no test_*.py files) |
| 50% | Test files exist but <20% of modules have corresponding tests |
| 100% | Test directory present with comprehensive coverage of core modules |

### Coverage Configuration (8 pts)

| Score | Criteria |
|-------|----------|
| 0% | No coverage tooling (.coveragerc, coverage.xml, nyc, c8) |
| 50% | Coverage tool configured but threshold not enforced |
| 100% | Coverage configured with enforced minimum threshold (>60%) |

### Coverage Quality (4 pts, heuristic)

| Score | Criteria |
|-------|----------|
| 0% | Coverage file not present or coverage.xml shows <50% |
| 50% | Coverage between 50-80% |
| 100% | Coverage >80% (heuristic, inferred from coverage config) |

### Multi-Environment Testing (3 pts)

| Score | Criteria |
|-------|----------|
| 0% | Single OS, single runtime version in CI |
| 50% | Matrix with 2 versions but single OS, or 2 OS but single version |
| 100% | Matrix testing across multiple OS and/or multiple runtime versions |

---

## Community (20 pts total)

### License (6 pts)

| Score | Criteria |
|-------|----------|
| 0% | No LICENSE file |
| 50% | LICENSE file exists but is non-standard or non-OSI-approved |
| 100% | Standard OSI-approved license (MIT, Apache-2.0, GPL-3.0, etc.) |

### Code of Conduct (3 pts)

| Score | Criteria |
|-------|----------|
| 0% | No CODE_OF_CONDUCT.md |
| 50% | File exists but is custom/incomplete |
| 100% | Standard CoC (Contributor Covenant 2.x or similar) with enforcement contact |

### Security Policy (4 pts)

| Score | Criteria |
|-------|----------|
| 0% | No SECURITY.md |
| 50% | SECURITY.md exists but lacks reporting instructions or supported versions |
| 100% | SECURITY.md with reporting email/mechanism, supported versions, response SLA |

### Issue Templates (4 pts)

| Score | Criteria |
|-------|----------|
| 0% | No issue templates (.github/ISSUE_TEMPLATE/ missing) |
| 50% | Issue templates directory exists with 1 template |
| 100% | Bug report and feature request templates both present |

### CODEOWNERS (3 pts)

| Score | Criteria |
|-------|----------|
| 0% | No CODEOWNERS file |
| 50% | CODEOWNERS exists but assigns all files to one owner |
| 100% | CODEOWNERS with per-directory or per-file ownership assignments |
