---
name: audit-coherence
description: Audit product-to-implementation and architecture-to-code coherence
argument-hint: "[--focus=product|architecture|both] [--deep]"
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Skill
---

# Coherence Audit

Audit the alignment between what the project promises and what it delivers, and between its declared architecture and actual code structure.

## Behavior

1. **Orient**: Read README.md, architecture docs, and package manifest
2. **Load skills**: Apply `product-coherence` and `architecture-coherence` skills
3. **Product coherence analysis**:
   - Inventory all documented claims (features, commands, APIs)
   - Cross-reference each claim against actual code
   - Detect ghost features (documented but missing)
   - Detect invisible features (implemented but undocumented)
   - Check naming consistency across docs, code, and CLI
4. **Architecture coherence analysis**:
   - Identify declared architecture (docs, ADRs, directory structure)
   - Trace actual import/dependency graph
   - Detect boundary violations and coupling issues
   - Find dead code, orphaned modules, config duplication
5. **Report**: Present findings organized by category with file references
6. **Score**: Calculate scores per dimension

## Arguments

- `--focus`: Limit to product or architecture coherence only. Default: both
- `--deep`: Perform thorough import graph tracing and exhaustive cross-referencing (slower but more complete)

## Output Format

```
Coherence Audit — [project-name]

Product Coherence: XX/100 [Grade]
  Ghost features: N found
  Invisible features: N found
  Naming drift: N instances
  [Detailed findings with file:line references]

Architecture Coherence: XX/100 [Grade]
  Boundary violations: N found
  Coupling issues: N found
  Dead code: N modules
  [Detailed findings with import paths]

Actionable fixes: [prioritized list]
```
