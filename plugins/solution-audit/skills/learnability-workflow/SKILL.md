---
name: Learnability and Workflow
description: This skill should be used when the user asks to "audit learnability", "check workflow friction", "assess learning curve", "review user workflow", "find friction points", "evaluate cognitive load", "check progressive complexity", or needs to evaluate how learnable a solution is and whether its workflow minimizes unnecessary friction.
version: 0.1.0
---

# Learnability & Workflow Audit

Assess how learnable the solution is and whether its primary workflow is free of unnecessary friction. A tool can be powerful but useless if the learning curve is a wall instead of a ramp.

## Core Concept

Learnability measures how quickly a user can form an accurate mental model and start being productive. Workflow quality measures how smoothly the user can accomplish tasks once they understand the tool. Together, they determine whether users adopt or abandon the solution.

## Audit Procedure

### 1. Identify the Mental Model

Determine what mental model the solution requires:

- **What is this?** Can a user understand the tool's purpose in under 30 seconds from the README?
- **Core abstractions**: What are the 2-3 key concepts a user must understand? (e.g., "projects", "pipelines", "stages")
- **Metaphor**: Does the tool use a metaphor? Is it consistent? (e.g., "pipeline" implies sequential flow)
- **Conceptual prerequisites**: What must the user already know? (e.g., Git, Docker, SQL)

Flag issues:
- More than 5 core concepts needed before basic use: Warning
- Metaphor that breaks or misleads: Warning
- Purpose unclear from README first paragraph: Critical

### 2. Map the Primary Workflow

Document the end-to-end workflow for the most common use case:

1. List every step from "I want to do X" to "X is done"
2. Note which steps require documentation reference
3. Note which steps require context switching (leaving terminal, opening browser, editing config)
4. Note decision points where the user must choose between options
5. Measure total step count

Assess the workflow:
- **Linearity**: Is the path mostly linear or does it branch frequently?
- **Step count**: Minimum steps to complete the primary task
- **Automation potential**: Which steps could be automated but aren't?
- **Error recovery**: At each step, what happens if the user makes a mistake?

### 3. Identify Friction Points

For each workflow step, check for friction:

- **Context switches**: User must leave the current tool/terminal
- **Hidden requirements**: Step needs something not mentioned in prior steps
- **Manual repetition**: User must type/do the same thing repeatedly
- **Waiting without feedback**: Operation takes time with no progress indication
- **Unnecessary decisions**: User must choose between options with unclear consequences
- **Memorization burden**: User must remember exact syntax, paths, or values

Classify each friction point:
- Blocks progress entirely: Critical
- Slows down significantly: Warning
- Minor annoyance: Info

### 4. Assess Progressive Complexity

Check that the solution supports both simple and advanced use:

- **Zero-config path**: Does the simplest use case work without any configuration?
- **Gradual opt-in**: Can users add complexity incrementally (config, flags, customization)?
- **Power user shortcuts**: Are there efficiency shortcuts for experienced users?
- **Complexity cliffs**: Are there points where difficulty spikes suddenly?
- **Advanced discoverability**: Can advanced features be found through help/docs without reading source?

Flag patterns:
- No zero-config path for the primary task: Critical
- Complexity cliff between basic and intermediate use: Warning
- Advanced features only discoverable by reading source code: Warning

### 5. Evaluate Documentation Progression

Check that documentation supports the learning journey:

- **README → Getting Started → Tutorial → Reference**: Clear progression path
- **Each level self-contained**: Reader doesn't need to jump back and forth
- **Concepts introduced before use**: No forward references to unexplained concepts
- **Examples at each level**: Working examples that match the reader's current knowledge
- **Skippability**: Advanced users can skip ahead without missing critical info

### 6. Check Feedback Loops

Evaluate whether the user always knows what's happening:

- **State visibility**: Current mode, stage, or context is always clear
- **Action confirmation**: Operations confirm what they did
- **Progress indication**: Long operations show progress
- **Error localization**: Errors point to the specific step that failed
- **Next step guidance**: After each operation, the next action is obvious or suggested

Flag missing feedback:
- No state visibility for multi-step operations: Warning
- No confirmation for important operations: Warning
- Dead-end states with no guidance: Critical

### 7. Assess Recovery and Safety

Evaluate how the solution handles user mistakes:

- **Undo capability**: Can recent actions be reversed?
- **Dry-run mode**: Can operations be previewed before execution?
- **Confirmation prompts**: Destructive actions require explicit confirmation
- **Safe defaults**: Default behavior is non-destructive
- **Partial failure handling**: Clear state after failures (what succeeded, what didn't)
- **Restart capability**: Easy to start over without manual cleanup

### 8. Evaluate Cross-Tool Integration

If the solution works with other tools, check integration quality:

- **Composability**: Works well in pipelines (stdin/stdout, exit codes)
- **Ecosystem fit**: Follows conventions of its ecosystem (npm scripts, make targets, etc.)
- **Configuration alignment**: Config format matches ecosystem norms (YAML, TOML, JSON)
- **Output compatibility**: Output format works with common downstream tools

## Finding Classification

| Severity | Criteria | Example |
|----------|----------|---------|
| Critical | Users cannot form mental model or complete primary task | Purpose unclear, primary workflow blocked by friction |
| Warning | Users face unnecessary friction or confusion | Context switches, missing feedback, complexity cliffs |
| Info | Minor improvements to learning or workflow | Better example placement, optional shortcuts |

## Output Format

For each finding, report:
```
[SEVERITY] Category: Brief description
  Workflow step: Which step or concept (if applicable)
  Issue: What creates friction or confusion
  Impact: How this affects user adoption/productivity
  Fix: Specific action to resolve
```

Include workflow summary:
```
Primary Workflow Steps: N
Context Switches Required: N
Decision Points: N
Estimated Learning Time: ~N minutes (basic) / ~N hours (proficient)
Friction Points: N critical, N warning, N info
```

## Scoring

Start at 100, subtract per finding:
- Critical: -15 points
- Warning: -7 points
- Info: -2 points

Score reflects how quickly a motivated user can become productive.
