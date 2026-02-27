---
name: Compliance Standards
description: This skill should be used when the user asks to "check compliance", "validate against OpenSSF", "CII badge requirements", "OWASP standards", "SOC2 compliance", or needs validation against industry security and quality frameworks.
version: 0.1.0
---

# Compliance Standards

Industry standards validation for OpenSSF Scorecard, CII Best Practices, OWASP Top 10, and SOC2 compliance.

## Supported Frameworks

### OpenSSF Scorecard
Security best practices for open-source projects.

**Checks (16 total):**
- Branch Protection
- CI Tests
- Code Review
- Dangerous Workflow
- Dependency Update Tool
- License
- Maintained
- Pinned Dependencies
- SAST
- Security Policy
- Signed Releases
- Token Permissions
- Vulnerabilities

**Scoring:** 0-10 per check, aggregate 0-10 overall

**Threshold mapping:**
```
8.0+ → Passing
6.0-7.9 → Needs improvement
<6.0 → Failing
```

### CII Best Practices Badge
Core Infrastructure Initiative badge criteria.

**Levels:**
- **Basic** (60 criteria) - Essential practices
- **Silver** (Additional 28 criteria) - Intermediate
- **Gold** (Additional 18 criteria) - Advanced

**Key criteria:**
- Public version control
- Issue tracker
- Build/test instructions
- Security vulnerability reporting
- Automated testing
- HTTPS website

**Assessment:** `scripts/check-cii-compliance.sh`

### OWASP Top 10
Web application security standards (2021).

**Top 10 vulnerabilities:**
1. Broken Access Control
2. Cryptographic Failures
3. Injection
4. Insecure Design
5. Security Misconfiguration
6. Vulnerable Components
7. Auth Failures
8. Software/Data Integrity Failures
9. Security Logging Failures
10. SSRF

**Validation:** Check security practices, dependency scanning, input validation

### SOC2
Enterprise security and availability (Type I/II).

**Trust Service Criteria:**
- Security
- Availability
- Processing Integrity
- Confidentiality
- Privacy

**Repository aspects:**
- Access controls
- Change management
- Security policies
- Audit logging

## Usage

**Check compliance:**
```bash
bash scripts/check-compliance.sh --framework=openssf
bash scripts/check-compliance.sh --framework=cii --level=silver
bash scripts/check-compliance.sh --all
```

**Output:**
```json
{
  "framework": "openssf-scorecard",
  "score": 7.8,
  "grade": "Needs Improvement",
  "checks": {
    "Branch-Protection": 8,
    "CI-Tests": 10,
    "Code-Review": 6,
    "Security-Policy": 10,
    "Vulnerabilities": 10
  },
  "recommendations": [...]
}
```

## Auto-Detection

Determine relevant frameworks:

```yaml
compliance:
  auto_detect_type: true
```

**Logic:**
- Public repo → OpenSSF, CII
- Private repo → SOC2, ISO27001
- Web app → OWASP
- Config override: `enabled_frameworks`

## Integration

Maps to quality-scoring categories:
- Security category → OpenSSF checks
- Community category → CII criteria
- Overall score → Compliance grade

See: `references/` for detailed requirements.
