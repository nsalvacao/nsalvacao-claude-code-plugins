---
name: repo-validate
description: Fast validation of repository structure with auto-fix capability
argument-hint: "[--fix] [--strict]"
allowed-tools:
  - Read
  - Bash
  - Grep
  - Glob
  - Write
  - Task
---

# Repository Validate Command

Quick validation of structure completeness and correctness.

## Behavior

Delegate to `structure-validator` agent with appropriate flags.

## Usage

```bash
/repo-validate              # Validate only
/repo-validate --fix        # Validate + auto-fix issues
/repo-validate --strict     # Fail on warnings
```

## Output

```
Validation Report

✅ README.md complete
✅ LICENSE valid (MIT)
⚠️ SECURITY.md missing
❌ Invalid YAML: .github/workflows/test.yml

Issues: 2 critical, 1 warning

[If --fix: "Fixing 1 issue automatically..."]
```

Invoke structure-validator agent and present results.
