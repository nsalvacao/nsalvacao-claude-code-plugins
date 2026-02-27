---
name: Quality Scoring
description: This skill should be used when the user asks to "calculate quality score", "audit repository quality", "check repo health", "score documentation", "measure code quality", or needs quantitative assessment of repository quality across documentation, security, CI/CD, and community standards.
version: 0.1.0
---

# Quality Scoring

Quantitative assessment engine for repository quality with weighted scoring across four categories: Documentation, Security, CI/CD, and Community.

## Overview

Provides objective, repeatable quality measurement with:
- **0-100 point scale** across four categories
- **Weighted scoring** (configurable, default 25% each)
- **Historical tracking** for trend analysis
- **Actionable recommendations** with point impact
- **Compliance mapping** to industry standards

## Scoring Categories

### Documentation (25 points default)

**README Completeness (12 pts):**
- Project title and description (2 pts)
- Installation instructions (2 pts)
- Usage examples (3 pts)
- Contributing guidelines link (2 pts)
- License badge/link (1 pt)
- Prerequisites listed (1 pt)
- Contact/support information (1 pt)

**API Documentation (5 pts):**
- Function/method docstrings (2 pts)
- Type annotations (Python, TypeScript) (1 pt)
- Generated API docs (Sphinx, JSDoc, etc.) (2 pts)

**Additional Docs (5 pts):**
- CONTRIBUTING.md exists (2 pts)
- Architecture/design docs (1 pt)
- Changelog (1 pt)
- Examples directory (1 pt)

**Inline Documentation (3 pts):**
- Comment density (>10% of LOC) (1 pt)
- Complex function documentation (1 pt)
- Module-level docstrings (1 pt)

---

### Security (25 points default)

**Security Policy (8 pts):**
- SECURITY.md present (3 pts)
- Vulnerability reporting process (2 pts)
- Supported versions documented (2 pts)
- Security contact provided (1 pt)

**Dependency Management (8 pts):**
- Dependabot/Renovate configured (3 pts)
- Dependency lockfiles present (2 pts)
- Known vulnerabilities = 0 (3 pts)

**Code Scanning (6 pts):**
- CodeQL or equivalent enabled (3 pts)
- SAST tool configured (2 pts)
- Secret scanning enabled (1 pt)

**Best Practices (3 pts):**
- No hardcoded secrets in code (1 pt)
- Input validation present (1 pt)
- Secure defaults (1 pt)

---

### CI/CD (25 points default)

**Automated Testing (10 pts):**
- Test suite exists (3 pts)
- Tests pass on latest commit (3 pts)
- Code coverage >70% (2 pts)
- Coverage >90% (additional 2 pts)

**Continuous Integration (8 pts):**
- CI workflow configured (3 pts)
- Runs on PR (2 pts)
- Multiple OS/versions tested (2 pts)
- Status checks required for merge (1 pt)

**Code Quality (4 pts):**
- Linter configured (2 pts)
- Linter passing (1 pt)
- Formatter configured (1 pt)

**Deployment (3 pts):**
- Automated release workflow (2 pts)
- Package published to registry (1 pt)

---

### Community (25 points default)

**License (6 pts):**
- LICENSE file present (3 pts)
- OSI-approved license (2 pts)
- License in package manifest (1 pt)

**Contribution Process (8 pts):**
- CONTRIBUTING.md present (3 pts)
- Clear contribution workflow (2 pts)
- Issue/PR templates (2 pts)
- Code of Conduct (1 pt)

**Community Health (6 pts):**
- CODE_OF_CONDUCT.md (3 pts)
- Issue response time <7 days (1 pt)
- Active maintenance (commit in last 30 days) (1 pt)
- Multiple contributors (1 pt)

**Documentation Quality (5 pts):**
- README professionally written (2 pts)
- No broken links (2 pts)
- Badges up-to-date (1 pt)

---

## Scoring Script

Main scoring engine: `scripts/calculate-score.py`

**Usage:**
```bash
cd /path/to/project
python3 $CLAUDE_PLUGIN_ROOT/skills/quality-scoring/scripts/calculate-score.py
```

**Output format (JSON):**
```json
{
  "score": 82,
  "max_score": 100,
  "grade": "Excellent",
  "timestamp": "2024-02-09T10:30:00Z",
  "git_commit_sha": "abc123def456",
  "categories": {
    "documentation": {
      "score": 22,
      "max": 25,
      "percentage": 88,
      "breakdown": {
        "readme_completeness": 11,
        "api_documentation": 4,
        "additional_docs": 5,
        "inline_documentation": 2
      },
      "issues": [
        {
          "severity": "warning",
          "message": "Missing architecture documentation",
          "impact": -1,
          "recommendation": "Add docs/architecture.md with system design"
        }
      ]
    },
    "security": {
      "score": 18,
      "max": 25,
      "percentage": 72,
      "breakdown": {
        "security_policy": 8,
        "dependency_management": 5,
        "code_scanning": 3,
        "best_practices": 2
      },
      "issues": [
        {
          "severity": "critical",
          "message": "CodeQL not configured",
          "impact": -3,
          "recommendation": "Add .github/workflows/codeql.yml"
        },
        {
          "severity": "warning",
          "message": "Dependabot not enabled",
          "impact": -3,
          "recommendation": "Add .github/dependabot.yml"
        }
      ]
    },
    "ci_cd": {
      "score": 25,
      "max": 25,
      "percentage": 100,
      "breakdown": {
        "automated_testing": 10,
        "continuous_integration": 8,
        "code_quality": 4,
        "deployment": 3
      },
      "issues": []
    },
    "community": {
      "score": 17,
      "max": 25,
      "percentage": 68,
      "breakdown": {
        "license": 6,
        "contribution_process": 5,
        "community_health": 3,
        "documentation_quality": 3
      },
      "issues": [
        {
          "severity": "warning",
          "message": "CODE_OF_CONDUCT missing",
          "impact": -3,
          "recommendation": "Add CODE_OF_CONDUCT.md using Contributor Covenant 2.1"
        },
        {
          "severity": "info",
          "message": "Issue/PR templates not found",
          "impact": -2,
          "recommendation": "Add .github/ISSUE_TEMPLATE/ and PULL_REQUEST_TEMPLATE.md"
        }
      ]
    }
  },
  "recommendations": [
    {
      "priority": "high",
      "category": "security",
      "action": "Enable CodeQL code scanning",
      "impact": "+3 pts",
      "effort": "low"
    },
    {
      "priority": "medium",
      "category": "community",
      "action": "Add CODE_OF_CONDUCT.md",
      "impact": "+3 pts",
      "effort": "low"
    },
    {
      "priority": "low",
      "category": "security",
      "action": "Configure Dependabot",
      "impact": "+3 pts",
      "effort": "low"
    }
  ]
}
```

## Grade Thresholds

| Score | Grade | Emoji | Meaning |
|-------|-------|-------|---------|
| 95-100 | Outstanding | ⭐ | Production-ready, exemplary quality |
| 85-94 | Excellent | ✅ | Minor polish opportunities |
| 70-84 | Good | ⚠️ | Some areas need attention |
| 50-69 | Poor | 🔶 | Significant improvements needed |
| 0-49 | Critical | 🚨 | Immediate action required |

## Weighted Scoring

Customize category weights in config:

```yaml
scoring:
  weights:
    documentation: 20   # Reduced from 25
    security: 35        # Increased from 25 (security-critical project)
    ci_cd: 25           # Default
    community: 20       # Reduced from 25
```

**Validation:** Weights must sum to 100.

## Historical Tracking

Track quality evolution in `.repo-quality-history.json`:

```json
{
  "project": "my-project",
  "history": [
    {
      "timestamp": "2024-02-01T10:00:00Z",
      "score": 45,
      "git_commit_sha": "abc123",
      "triggered_by": "manual-audit",
      "categories": {...}
    },
    {
      "timestamp": "2024-02-09T11:00:00Z",
      "score": 82,
      "git_commit_sha": "def456",
      "triggered_by": "post-setup",
      "improvement": "+37 pts",
      "categories": {...}
    }
  ],
  "trend": {
    "direction": "improving",
    "velocity": "+5.3 pts/week"
  }
}
```

**Analysis:**
- Score trends over time
- Improvement velocity
- Category-specific trends
- Commit correlation

## Partial Credit System

Award partial points for incomplete items:

**Example: README completeness (12 pts total)**
```
Title present:         +2 pts
Description present:   +2 pts
Installation missing:  +0 pts (partial: 50% = +1 pt if incomplete)
Usage present:         +3 pts
Contributing link:     +2 pts
License badge:         +1 pt
Prerequisites:         +1 pt
Contact info missing:  +0 pts
---
Actual score:          11/12 (partial credit: 1 pt from incomplete installation)
```

**Incomplete criteria:**
- Partial implementation (50-70% complete) = 50% credit
- Minimal implementation (<50% complete) = 0% credit

## Validation Scripts

Component validation: `scripts/validate-component.sh`

```bash
# Validate specific components
bash validate-component.sh --check readme
bash validate-component.sh --check license
bash validate-component.sh --check ci

# All validations
bash validate-component.sh --check all
```

## GitHub API Integration

Enhance scoring with GitHub API data:

**Community health score:**
```bash
gh api repos/{owner}/{repo}/community/profile
```

**Returns:**
```json
{
  "health_percentage": 85,
  "files": {
    "readme": {"html_url": "..."},
    "contributing": {"html_url": "..."},
    "license": {"html_url": "..."},
    "code_of_conduct": null
  }
}
```

**Issue response time:**
```bash
gh api repos/{owner}/{repo}/issues --jq '
  [.[] | select(.created_at > (now - 7*86400)) |
   select(.comments > 0)] | length'
```

## Compliance Framework Mapping

Map score to compliance requirements:

**OpenSSF Best Practices:**
- Passing level (50+ pts in security)
- Silver level (70+ pts overall)
- Gold level (90+ pts overall)

**CII Best Practices:**
- Basic badge (60+ pts)
- Silver badge (80+ pts)
- Gold badge (95+ pts)

See: `references/compliance-mapping.md`

## Additional Resources

### Reference Files

- **`references/scoring-rubrics.md`** - Detailed scoring criteria
- **`references/compliance-mapping.md`** - Framework requirement mapping
- **`references/partial-credit-rules.md`** - Partial credit guidelines

### Scripts

- **`scripts/calculate-score.py`** - Main scoring engine
- **`scripts/validate-component.sh`** - Component validation
- **`scripts/analyze-history.py`** - Historical trend analysis

### Examples

- **`examples/score-output.json`** - Sample scoring output
- **`examples/history-analysis.json`** - Trend analysis example

## Integration Points

This skill integrates with:
- **repository-templates** - Validates template completeness
- **compliance-standards** - Maps scores to framework requirements
- **structure-validator** agent - Automated validation after setup

Scoring is used by `structure-architect` agent for gap analysis and improvement prioritization.
