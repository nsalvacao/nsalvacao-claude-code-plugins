---
name: Onboarding Quality
description: This skill should be used when the user asks to "audit onboarding", "check setup experience", "test quickstart", "evaluate time-to-first-success", "review installation steps", "assess new user experience", or needs to evaluate how easy it is for a new user to go from zero to first meaningful result.
version: 0.1.0
---

# Onboarding Quality Audit

Assess how easy it is for a new user to achieve their first meaningful success with the solution. Onboarding is the most critical user experience moment — if it fails, nothing else matters.

## Core Concept

Onboarding quality measures the friction between "I found this project" and "I got my first useful result." Every unnecessary step, unclear instruction, or silent failure is a potential abandonment point. The goal is minimum viable path to value.

## Audit Procedure

### 1. Identify the Onboarding Path

Locate the documented entry point for new users:

- **README quickstart/getting started section**
- **Dedicated GETTING_STARTED.md or docs/quickstart.md**
- **Installation section** in README
- **First linked tutorial** from README

If multiple paths exist, audit the most prominent one (typically README). Flag if the primary onboarding path is unclear or hard to find.

### 2. Audit Prerequisites

Check that all requirements are explicitly stated:

- **Runtime dependencies**: Language version, runtime (Node.js, Python, etc.)
- **System tools**: Required CLI tools (git, docker, make, etc.)
- **OS compatibility**: Which operating systems are supported
- **Accounts/credentials**: Any external accounts or API keys needed
- **Disk/memory**: Any significant resource requirements
- **Network**: Offline capability or required connectivity

Flag missing prerequisites that a new user would discover only by hitting an error. Check if version constraints are specific enough (e.g., "Node.js 18+" vs just "Node.js").

### 3. Walk Through Installation Steps

Follow each installation step as documented and evaluate:

- **Completeness**: Every step is documented (no assumed knowledge)
- **Copy-pasteability**: Commands can be copied and run directly
- **Correctness**: Steps produce the described results
- **Order**: Steps are in the right sequence
- **Platform coverage**: Steps work on documented platforms
- **Error anticipation**: Common failure points are addressed

Count the total number of steps from "clone/install" to "first run." Flag if it exceeds 5 steps for a simple tool or 10 for a complex system.

### 4. Evaluate First-Run Experience

Assess what happens when the user runs the solution for the first time:

- **Immediate value**: Does the first run produce something useful?
- **Clear output**: Is the output understandable without prior knowledge?
- **Success signal**: Is it obvious that it worked?
- **Failure signal**: If it fails, is the error message helpful?
- **Next step**: After first success, is the next action obvious?

Flag first-run experiences that:
- Produce no output or cryptic output
- Require configuration before any functionality works
- Show a help screen instead of doing something useful
- Error without actionable guidance

### 5. Assess Error Recovery

Evaluate what happens when onboarding goes wrong:

- **Missing dependency**: Clear message about what is missing and how to install
- **Wrong version**: Specific version mismatch information
- **Permission errors**: Guidance on required permissions
- **Network failures**: Offline behavior or retry guidance
- **Partial installation**: Clean state after failed install (no broken artifacts)

Check for common onboarding failure scenarios and whether the solution handles them gracefully.

### 6. Evaluate Cognitive Load

Assess how much a new user needs to understand before being productive:

- **Concepts required**: How many new concepts before first use?
- **Configuration complexity**: How much config before first run?
- **Terminology**: Are terms self-explanatory or require learning?
- **Decision points**: How many choices must the user make during setup?
- **Information overload**: Is the user presented with too much at once?

Flag onboarding that requires understanding internal architecture, complex configuration, or multiple new concepts before the user can do anything useful.

### 7. Check Progressive Disclosure

Verify that complexity is introduced gradually:

- **Layer 1**: Install and basic use (should be in README)
- **Layer 2**: Configuration and customization (separate docs)
- **Layer 3**: Advanced features and extension (deep docs)
- **Layer 4**: Contributing and internals (CONTRIBUTING.md)

Flag when advanced concepts are introduced too early in the onboarding path.

### 8. Assess Multi-Persona Onboarding

Check if onboarding addresses different user types:

- **End user**: Wants to use the tool as-is
- **Developer**: Wants to integrate or extend
- **Contributor**: Wants to contribute code

At minimum, the end-user path must be clear. Flag if the primary onboarding assumes developer knowledge when the tool targets non-developers.

## Finding Classification

| Severity | Criteria | Example |
|----------|----------|---------|
| Critical | Onboarding is broken or blocks new users | Install steps fail, missing critical prerequisite |
| Warning | Onboarding has friction or gaps | Unclear steps, missing platform coverage |
| Info | Minor onboarding improvements possible | Could add a quickstart example, minor wording |

## Output Format

For each finding, report:
```
[SEVERITY] Category: Brief description
  Step: Which onboarding step (or "Prerequisites", "First Run", etc.)
  Issue: What the problem is
  Impact: How this affects new users
  Fix: Specific action to resolve
```

Include a summary metric:
```
Onboarding Steps: N (from clone to first success)
Prerequisites Documented: X/Y (Y inferred from actual requirements)
Estimated Time-to-First-Success: ~N minutes
Blockers Found: N critical, N warning
```

## Scoring

Start at 100, subtract per finding:
- Critical: -15 points
- Warning: -7 points
- Info: -2 points

Score reflects the probability that a new user succeeds on their first attempt.
