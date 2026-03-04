---
name: audit-ux
description: Comprehensive UX audit — CLI ergonomics, textual quality, learnability, and workflow friction
argument-hint: "[--focus=cli|text|learnability-workflow|all] [--deep]"
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Skill
---

# UX Audit

Comprehensive user experience audit covering CLI ergonomics, textual communication quality, and learnability/workflow design.

## Behavior

1. **Orient**: Read README.md and identify project type (CLI tool, library, API, web app)
2. **Load skills**: Apply `cli-ux`, `textual-ux`, and `learnability-workflow` skills
3. **CLI UX analysis** (skip if no CLI component):
   - Map all commands, subcommands, and flags
   - Evaluate --help quality, argument ergonomics, naming consistency
   - Test error handling with invalid input
   - Assess output formatting and scripting friendliness
4. **Textual UX analysis**:
   - Inventory all user-facing strings (errors, help, prompts, logs)
   - Assess tone consistency and terminology
   - Check for jargon leakage, verbosity calibration, pluralization
   - Evaluate error message quality (context, actionability, tone)
5. **Learnability & Workflow analysis**:
   - Map primary user workflow end-to-end
   - Identify friction points and context switches
   - Assess cognitive load and progressive complexity
   - Check feedback loops and escape hatches
6. **Quick wins**: Highlight easy fixes with high UX impact
7. **Report**: Present unified UX report

## Arguments

- `--focus`: Limit to specific UX dimension (`cli`, `text`, `learnability-workflow`). Default: all
- `--deep`: Perform exhaustive analysis including edge cases and all error paths

## Output Format

```
UX Audit — [project-name]

Scorecard:
| Dimension           | Score | Grade | Findings |
|---------------------|-------|-------|----------|
| CLI UX              | XX    | [G]   | N        |
| Textual UX          | XX    | [G]   | N        |
| Learnability & Workflow | XX | [G]   | N        |
| UX OVERALL          | XX    | [G]   | N        |

Quick Wins (high impact, low effort):
  1. [fix description]
  2. [fix description]

Detailed Findings:
  [Organized by dimension, each with evidence and fix suggestion]

Friction Map (if learnability assessed):
  | Step | Description | Friction | Severity |
  [Primary workflow steps with friction indicators]
```
