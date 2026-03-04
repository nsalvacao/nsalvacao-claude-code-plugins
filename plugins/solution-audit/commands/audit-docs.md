---
name: audit-docs
description: Audit documentation quality — accuracy, structure, and usefulness
argument-hint: "[--check-links] [--check-examples]"
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Skill
---

# Documentation Audit

Audit the quality, accuracy, and structure of all project documentation.

## Behavior

1. **Orient**: Inventory all documentation files (README, docs/, CHANGELOG, CONTRIBUTING, etc.)
2. **Load skill**: Apply `documentation-quality` skill
3. **README assessment**: Evaluate utility (useful vs marketing), completeness, and structure
4. **Accuracy check**: Cross-reference documented APIs, commands, and configs against current code
5. **Link checking** (with --check-links): Verify all internal and external links resolve
6. **Example validation** (with --check-examples): Check documented code examples against current API
7. **Structure assessment**: Evaluate documentation hierarchy (tutorial vs reference vs explanation)
8. **Freshness check**: Find stale references, removed features, outdated version numbers
9. **Report**: Present structured findings

## Arguments

- `--check-links`: Verify all documentation links (internal and external)
- `--check-examples`: Test documented code examples against current implementation

## Output Format

```
Documentation Audit — [project-name]

Documentation Quality: XX/100 [Grade]

Files assessed: N
  README.md: [assessment]
  docs/: N files

Findings:
  [Categorized by: accuracy, links, examples, structure, freshness]
  [Each with file:line, issue, and fix suggestion]

Actionable fixes: [prioritized list]
```
