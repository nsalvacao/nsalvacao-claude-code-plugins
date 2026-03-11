# Compliance Standards Mapping

Maps OpenSSF, CII Best Practices, and OWASP requirements to the repo-structure quality score categories.

---

## OpenSSF Best Practices -> Score Categories

| OpenSSF Requirement | Score Category | Sub-item | Points |
|---------------------|----------------|----------|--------|
| FLOSS license | Community | LICENSE | 6 |
| Website / README | Documentation | README Completeness | 12 |
| Description in README | Documentation | README Completeness | (included above) |
| How to contribute (CONTRIBUTING) | Community | Contribution process | 3 |
| Bug reporting (issue tracker) | Community | Issue templates | 4 |
| Vulnerability reporting (SECURITY.md) | Community | Security Policy | 4 |
| Automated tests | Testing | Test Presence | 10 |
| CI configured for tests | CI/CD | Continuous Integration | 8 |
| HTTPS / badges | Documentation | Badges | 2 |
| Code of Conduct | Community | Code of Conduct | 3 |

**Estimated coverage:** A score >= 75 typically satisfies OpenSSF Passing badge prerequisites for documentation/community requirements.

---

## CII Best Practices -> Score Categories

| CII Requirement | Score Category | Sub-item | Points |
|-----------------|----------------|----------|--------|
| README present | Documentation | README Completeness | 12 |
| OSI-approved LICENSE | Community | License | 6 |
| CONTRIBUTING.md | Community | Contribution process | 3 |
| CI configured | CI/CD | Continuous Integration | 8 |
| Tests exist | Testing | Test Presence | 10 |
| Coverage >80% | Testing | Coverage Quality | 4 |
| SECURITY.md | Community | Security Policy | 4 |

**Estimated coverage:** CII Passing badge requires ~13 criteria; a score >= 70 covers ~85% of them.

---

## OWASP SAMM -> Score Categories

| OWASP SAMM Practice | Score Category | Notes |
|---------------------|----------------|-------|
| Security Requirements | Community | SECURITY.md documents accepted/rejected security behaviors |
| Secure Build | CI/CD | Dependency scanning in CI pipeline |
| Secure Deployment | CI/CD | Deployment pipeline with checks |
| Vulnerability Management | Community | SECURITY.md + issue tracker |
| Environment Hardening | CI/CD | Branch protection, required reviews |

---

## Score Thresholds by Compliance Target

| Score Range | Compliance Interpretation |
|-------------|--------------------------|
| 0-39 | Does not meet basic CII requirements |
| 40-59 | Meets some CII Passing criteria; not OpenSSF Passing |
| 60-74 | Likely meets CII Passing; approaching OpenSSF Passing |
| 75-84 | Meets OpenSSF Passing for most criteria |
| 85-94 | Meets OpenSSF Silver level prerequisites |
| 95-100 | Strong OpenSSF Gold candidate |

---

## Quick Fix Priority by Compliance Impact

If improving compliance score, prioritize in order:

1. Add LICENSE file (+6 pts Community)
2. Add SECURITY.md (+4 pts Community)
3. Add CI workflow (+8 pts CI/CD)
4. Add tests (+10 pts Testing)
5. Add issue templates (+4 pts Community)
6. Complete README (+up to 12 pts Documentation)
