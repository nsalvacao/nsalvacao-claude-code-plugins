---
name: repo-setup
description: Main orchestration command for comprehensive repository structure setup and improvement
argument-hint: "[--mode=new|existing|audit] [--dry-run] [--auto-approve]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - AskUserQuestion
  - Task
  - Skill
---

# Repository Setup Command

Orchestrate complete repository structure analysis, planning, and implementation through the structure-architect agent.

## Purpose

This command is the main entry point for users to:
1. Setup new repositories with professional structure
2. Audit and improve existing repositories
3. Transform repos to enterprise-grade standards

## Behavior

**Always delegate to structure-architect agent** - this command's job is to invoke the agent with appropriate context.

## Workflow

### 1. Parse Arguments

**`--mode=<mode>`:**
- `new`: Bootstrap new repository from scratch
- `existing`: Audit and improve existing repository
- `audit`: Non-destructive quality check only
- Auto-detect if omitted (empty repo → new, has files → existing)

**`--dry-run`:**
- Preview changes without applying
- Show what would be created/modified
- Display projected quality score improvement

**`--auto-approve`:**
- Skip approval prompts (use config defaults)
- **Warning**: Only use if confident in config settings
- Useful for CI/CD automation

### 2. Invoke structure-architect Agent

```
Use the structure-architect agent to {mode} this repository.

{If --dry-run: "Preview changes only, do not modify files"}
{If --auto-approve: "Use config defaults, skip approval prompts"}
```

### 3. Monitor Progress

The structure-architect agent will:
- Detect tech stack
- Analyze current structure
- Calculate quality score
- Propose improvements by category
- Request approval (unless --auto-approve)
- Execute approved improvements
- Validate results
- Generate report

### 4. Present Results

After agent completes, summarize:
```markdown
✅ Repository setup complete

**Quality Score:** 45/100 → 87/100 (+42 pts)

**Created:** 12 files across 4 categories
- Documentation: README.md, CONTRIBUTING.md, docs/
- Security: SECURITY.md, dependabot.yml, CodeQL workflow
- CI/CD: test.yml, lint.yml, pre-commit hooks
- Community: LICENSE (MIT), CODE_OF_CONDUCT, templates

**Branch:** feat/repo-structure-setup
**Next steps:** Review changes and merge when ready
```

## Usage Examples

**New repository:**
```
/repo-setup --mode=new
```

**Existing repository (auto-detect):**
```
/repo-setup
```

**Audit only (no modifications):**
```
/repo-setup --mode=audit
```

**Preview changes:**
```
/repo-setup --dry-run
```

**Automated setup (CI/CD):**
```
/repo-setup --auto-approve
```

## Configuration

Command respects `.claude/repo-structure.config.yaml`:
- Author information
- Default license
- CI provider preference
- Category weights
- Automation preferences

## Error Handling

**Not a git repository:**
```
❌ Error: Not a git repository

Hint: Initialize with `git init` or specify directory.
```

**No write permissions:**
```
❌ Error: Cannot write to repository

Check file permissions and try again.
```

**Config invalid:**
```
⚠️ Warning: Config file has errors, using defaults

Details: Invalid YAML syntax in .claude/repo-structure.config.yaml line 15
```

## Tips

- Run `/repo-audit` first to see current state
- Use `--dry-run` to preview before applying
- Review generated branch before merging
- Config file makes setup faster (fewer prompts)

---

**Implementation Note:** This command is a thin wrapper that delegates all work to the structure-architect agent. Keep command logic minimal - complexity belongs in the agent.
