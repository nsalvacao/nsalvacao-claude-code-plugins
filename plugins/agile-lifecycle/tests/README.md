# Integration Testing Suite — agile-lifecycle plugin

## Overview

Static analysis validation suite for the agile-lifecycle plugin. Ensures structural integrity, correct frontmatter/sections, proper formatting, and reference validity.

## Running Tests

From the repository root:

```bash
bash plugins/agile-lifecycle/tests/validate-plugin.sh
```

Exit code: `0` if all checks pass, `1` if any check fails.

## Checks Implemented

### Check 1: SKILL.md Frontmatter Validation
Validates that all SKILL.md files have required frontmatter fields:
- `name:` — skill identifier
- `description:` — skill summary

**Count:** 16 SKILL.md files verified

### Check 2: Agent .md Sections Validation
Validates that all agent .md files have required Markdown sections:
- `## Phase Contract` — contract, entry/exit criteria, assumptions
- `## Templates Available` — list of template files available to the agent
- `## Activities` — detailed activity breakdown

**Count:** 31 agent .md files verified

### Check 3: Line Ending Validation
Ensures all Markdown and template files use LF line endings (Unix), not CRLF (Windows).
This is critical for cross-platform compatibility and CI/CD pipelines.

**Count:** 154 Markdown files verified

### Check 4: Template Reference Validation
Validates that all template references in `docs/` point to existing files.
Pattern: `templates/[a-z0-9/_-]+\.template`

Scans all `.md` files in the docs directory for broken references.

**Count:** 1 unique template reference verified to exist

### Check 5: plugin.json Validation
Validates that `plugins/agile-lifecycle/.claude-plugin/plugin.json` is valid JSON.

### Check 6: marketplace.json Validation
Validates that:
1. `.claude-plugin/marketplace.json` is valid JSON
2. Contains an entry for `agile-lifecycle` plugin

## Test Results

All checks pass (6/6):
- ✓ 16 SKILL.md files with complete frontmatter
- ✓ 31 agent .md files with required sections
- ✓ 154 Markdown files with LF line endings
- ✓ Template references valid
- ✓ plugin.json valid
- ✓ marketplace.json contains agile-lifecycle entry

## Notes

- Tests run with `set -e` safety; uses `var=$((var+1))` pattern instead of `((var++))` for safe counter increments
- Uses relative paths from repository root (scripts called from repo root)
- Color-coded output: green (✓ PASS), red (✗ FAIL)
- Detailed failure reporting per check with specific file paths
