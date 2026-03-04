---
name: CLI UX
description: This skill should be used when the user asks to "audit CLI UX", "check command ergonomics", "review CLI help output", "evaluate command-line interface", "check flag consistency", "audit CLI discoverability", or needs to assess the usability, ergonomics, and consistency of a command-line interface.
version: 0.1.0
---

# CLI UX Audit

Audit the command-line interface user experience — discoverability, ergonomics, consistency, and overall usability. A CLI is a user interface; it deserves the same design rigor as any GUI.

## Core Concept

CLI UX measures how intuitively users can discover, learn, and use commands without constantly referencing documentation. Good CLI UX means predictable patterns, helpful errors, sensible defaults, and minimal friction.

## Applicability

This audit applies to any project with a CLI component: standalone CLI tools, CLI wrappers around libraries, development tools, or any solution invoked from the terminal. Skip this dimension for pure libraries or APIs with no CLI surface.

## Audit Procedure

### 1. Map the Command Surface

Inventory all available commands and subcommands:

- Run the main entry point with --help or no arguments
- Explore all subcommand groups recursively
- Check for hidden/undocumented commands (grep for command registration)
- Map the command tree: depth, breadth, grouping logic

Flag issues:
- Command tree deeper than 3 levels (hard to remember)
- Inconsistent subcommand patterns (some verbs, some nouns)
- Too many top-level commands without grouping (>10)
- Missing --help at any level

### 2. Evaluate Help Output Quality

For each command's --help output, check:

- **Description**: Clear one-line summary of what the command does
- **Usage pattern**: Shows required and optional arguments clearly
- **Arguments**: Each argument described with type and default value
- **Examples**: At least one real-world usage example
- **Related commands**: Cross-references to related commands
- **Formatting**: Readable, aligned, not a wall of text

Flag help outputs that are:
- Auto-generated without human curation
- Missing examples
- Showing internal/technical details irrelevant to users
- Too long (>50 lines without scrolling consideration)
- Too short (no useful information)

### 3. Assess Argument Ergonomics

Evaluate how arguments and flags are designed:

- **Positional arguments**: Only for the 1-2 most common, required inputs
- **Named flags**: For optional behavior modifications
- **Short aliases**: Common flags have short forms (-v, -o, -f)
- **Boolean flags**: Use --flag/--no-flag pattern, not --flag=true
- **Required vs optional**: Clearly distinguishable
- **Mutual exclusivity**: Conflicting flags handled with clear errors
- **Value types**: Typed values with validation (paths, numbers, enums)

Flag anti-patterns:
- More than 2 positional arguments (order becomes confusing)
- Required flags (should be positional or prompted)
- Inconsistent flag naming across commands
- Missing short forms for frequently used flags

### 4. Check Default Sanity

Evaluate default values and zero-config behavior:

- Running with minimal arguments produces useful output
- Defaults favor safety over speed (non-destructive by default)
- Output goes to stdout by default (pipeability)
- Verbose/debug mode is opt-in, not default
- Color output respects NO_COLOR and terminal detection

### 5. Verify Naming Consistency

Check for naming patterns across all commands:

- **Verb consistency**: Same action uses same verb (create/new/add — pick one)
- **Noun consistency**: Same entity uses same name across commands
- **Flag naming**: Same concept uses same flag name (--output, -o everywhere)
- **Case convention**: Consistent kebab-case, camelCase, or snake_case
- **Abbreviation policy**: Same abbreviations used consistently

### 6. Test Error Handling

Invoke commands with invalid input and evaluate error responses:

- **Missing required arguments**: Error names the missing argument
- **Invalid values**: Error shows what was wrong and valid options
- **File not found**: Error shows the path that was tried
- **Permission denied**: Error suggests resolution (sudo, chmod)
- **Exit codes**: Non-zero for errors, distinct codes for different failures
- **Suggestions**: "Did you mean...?" for similar commands/flags

Flag errors that:
- Show raw stack traces to end users
- Give no actionable guidance
- Use technical jargon
- Exit with code 0 on failure

### 7. Assess Output Quality

Evaluate command output formatting:

- **Human-readable default**: Formatted for terminal reading
- **Machine-parseable option**: --json, --csv, or --format flag
- **Color usage**: Meaningful use of color (not decorative), respects NO_COLOR
- **Progress feedback**: Long operations show progress (spinner, bar, percentage)
- **Quiet mode**: --quiet flag suppresses non-essential output
- **Verbosity levels**: -v, -vv, -vvv or --log-level for debugging

### 8. Check Scripting Friendliness

Evaluate how well the CLI works in scripts and pipelines:

- **Stdin support**: Accept piped input where it makes sense
- **Stdout discipline**: Data to stdout, diagnostics to stderr
- **Exit codes**: Meaningful and documented
- **Non-interactive mode**: Works without a TTY
- **Idempotency**: Safe to re-run commands

## Finding Classification

| Severity | Criteria | Example |
|----------|----------|---------|
| Critical | CLI is broken or severely unusable | --help crashes, common commands fail silently |
| Warning | UX friction or inconsistency | Inconsistent flag names, missing error suggestions |
| Info | Minor ergonomic improvements | Could add short flag aliases, better examples |

## Output Format

For each finding, report:
```
[SEVERITY] Category: Brief description
  Command: which command or global
  Issue: What the UX problem is
  Example: Demonstration of the issue
  Fix: Specific improvement action
```

## Scoring

Start at 100, subtract per finding:
- Critical: -15 points
- Warning: -7 points
- Info: -2 points

Score reflects how productive a user can be with the CLI without external help.
