---
name: repo-improve
description: Targeted improvements for specific quality categories
argument-hint: "[--category=security|docs|ci|community] [--aggressive]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Task
  - Skill
  - AskUserQuestion
---

# Repository Improve Command

Apply targeted improvements to specific quality categories.

## Behavior

1. If `--category` specified → improve that category
2. If no category → show interactive menu with recommendations
3. Use appropriate skills (repository-templates, automation-strategies)
4. Report score improvement

## Usage

```bash
/repo-improve --category=security    # Security improvements only
/repo-improve --aggressive           # Apply without prompts
/repo-improve                        # Interactive menu
```

## Workflow

**Interactive mode (no --category):**
1. Calculate current score
2. Present menu:
   ```
   Select categories to improve:
   [ ] Documentation (+5 pts potential)
   [ ] Security (+10 pts potential)
   [ ] CI/CD (+8 pts potential)
   [ ] Community (+6 pts potential)
   ```
3. Apply selected improvements

**Direct mode (with --category):**
1. Analyze category gaps
2. Propose specific improvements
3. Apply after approval (skip if --aggressive)

Report before/after scores.
