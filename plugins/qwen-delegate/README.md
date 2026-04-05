# qwen-delegate

Delegate tasks to the Qwen CLI to preserve Anthropic PRO tokens for work that genuinely needs Claude.

## Overview

`qwen-delegate` bridges Claude Code and the `qwen` CLI (Qwen Code), enabling token-efficient workflows where Qwen handles generative and transformative tasks and Claude focuses on reasoning, architecture, and validation.

## Features

- **Cognitive delegation skill** — Claude learns autonomously when and how to delegate to Qwen
- **Direct delegation command** — `/qwen-delegate:ask-qwen` for user-initiated delegation
- **Delegation advisor agent** — Proactively triages task lists to identify Qwen candidates

## Prerequisites

- `qwen` CLI installed and authenticated in the current WSL environment
- Verify with: `qwen --version`

## Components

### Skill: `qwen-delegate` (cognitive)

Auto-activates when Claude is about to perform delegatable tasks. Teaches Claude:

- When to delegate (summarisation, formatting, translation, boilerplate, code generation)
- How to call the `qwen` CLI with the correct flags
- How to pass file context via stdin
- The mandatory validation gate before presenting results

### Skill: `ask-qwen` (user-invoked)

Direct delegation by the user:

```
/qwen-delegate:ask-qwen Write a Python function to validate an email address
```

### Agent: `qwen-advisor`

Proactive triage of task lists and workflows. Invoke when you want to optimise token usage across multiple tasks:

```
What could I delegate to Qwen from today's task list?
```

## Delegation Categories

| Category | Delegate | Keep with Claude |
|----------|----------|-----------------|
| Summarisation | ✅ | — |
| Formatting / conversion | ✅ | — |
| Translation | ✅ | — |
| Boilerplate generation | ✅ | — |
| Code generation (well-specified) | ✅ | — |
| Refactoring (mechanical) | ✅ | — |
| Architecture decisions | — | ✅ |
| Security-critical code | — | ✅ |
| Multi-file reasoning | — | ✅ |
| Deep debugging | — | ✅ |

## Validation Gate

All Qwen output is reviewed by Claude before delivery. This is non-negotiable and enforced by the skill's workflow.

## Token Economy

The `qwen` CLI uses its own backend (Qwen/Alibaba cloud, authenticated via OAuth or Alibaba Cloud Coding Plan) — no Anthropic API calls are made during delegation. This is not a local LLM runner like Ollama or LM Studio; it is a separate cloud agent CLI that runs against Qwen's own infrastructure. Token savings relative to Anthropic PRO are highest for large text transformations and boilerplate-heavy code generation tasks.
