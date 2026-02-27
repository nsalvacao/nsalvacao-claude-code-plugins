---
name: repo-audit
description: Non-destructive quality check with detailed scoring report
argument-hint: "[--format=json|markdown|terminal] [--categories=all|security|docs|ci|community]"
allowed-tools:
  - Read
  - Bash
  - Grep
  - Glob
  - Skill
---

# Repository Audit Command

Perform comprehensive quality assessment without modifying files.

## Behavior

1. Use `quality-scoring` skill to calculate score
2. Use `compliance-standards` skill to check frameworks
3. Generate report in specified format
4. Save to `.repo-audit-YYYY-MM-DD.md` (if markdown/terminal)

## Usage

```bash
/repo-audit                           # Full audit, terminal + markdown
/repo-audit --format=json             # JSON output only
/repo-audit --categories=security,ci  # Specific categories
```

## Output

**Terminal (colorized):**
```
Quality Score: 82/100 ⚠️ Good

Documentation: 22/25 (88%) ✅
Security: 18/25 (72%) ⚠️
  - Missing: Dependabot (-3 pts)
  - Missing: CodeQL (-3 pts)
CI/CD: 25/25 (100%) ✅
Community: 17/25 (68%) ⚠️
  - Missing: CODE_OF_CONDUCT (-3 pts)

Recommendations:
1. [High] Enable CodeQL scanning (+3 pts)
2. [Medium] Add CODE_OF_CONDUCT (+3 pts)
3. [Low] Configure Dependabot (+3 pts)

Report saved: .repo-audit-2024-02-09.md
```

Execute quality-scoring script and present results clearly.
