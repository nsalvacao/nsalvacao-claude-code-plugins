# qwen-delegate

Delegate tasks to the Qwen CLI to preserve Anthropic PRO tokens for work that genuinely needs Claude.

**Version:** 0.1.0

## Overview

`qwen-delegate` bridges Claude Code and the `qwen` CLI (Qwen Code), enabling token-efficient workflows where Qwen handles generative and transformative tasks and Claude focuses on reasoning, architecture, and validation.

> **Note:** The `qwen` CLI is **not** a local LLM runner (Ollama, LM Studio, or similar). It is a cloud-backed agent CLI that runs against Qwen/Alibaba infrastructure, authenticated via OAuth or Alibaba Cloud Coding Plan.

## Features

- **Cognitive delegation skill** — Claude learns autonomously when and how to delegate to Qwen
- **User-invoked skill** — `/qwen-delegate:ask-qwen` for direct delegation (invoked via the skills mechanism, not a `commands/` file)
- **Delegation advisor agent** — Proactively triages task lists to identify Qwen candidates

## Prerequisites

- `qwen` CLI installed and authenticated in the current shell environment
- Verify with: `qwen --version`
- Authentication: `qwen auth` (OAuth or Alibaba Cloud Coding Plan)

## Installation

### Via marketplace (recommended)

```
/plugin marketplace add nsalvacao/nsalvacao-claude-code-plugins
/plugin install qwen-delegate@nsalvacao-claude-code-plugins
```

### Local development

```bash
claude --plugin-dir /path/to/nsalvacao-claude-code-plugins/plugins/qwen-delegate
```

## Components

### Skill: `qwen-delegate` (cognitive)

Auto-activates when Claude is about to perform delegatable tasks. Teaches Claude:

- When to delegate (summarisation, formatting, translation, boilerplate, code generation)
- How to call the `qwen` CLI with the correct flags
- How to pass file context via stdin
- The mandatory validation gate before presenting results

### Skill: `ask-qwen` (user-invoked)

Direct delegation by the user. Invoked as a skill via Claude Code's skill mechanism:

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

The `qwen` CLI uses its own backend (Qwen/Alibaba cloud, authenticated via OAuth or Alibaba Cloud Coding Plan) — no Anthropic API calls are made during delegation. Token savings relative to Anthropic PRO are highest for large text transformations and boilerplate-heavy code generation tasks.

## Known Limitations

- **Cloud dependency:** The `qwen` CLI requires internet access and valid Qwen authentication. It is not an offline/local runner.
- **Session turns:** Qwen uses internal thinking turns — tasks that fail with `--max-session-turns 1` (exit code 53) should be retried with 2–3 turns minimum.
- **Model fixed:** The available model is `coder-model` (Qwen Code default). Model selection may be limited depending on the authentication plan.
- **Write safety in Pattern 4:** When allowing file access (`--approval-mode yolo` without `--exclude-tools`), Qwen may attempt to write files. Always validate and apply generated code manually via Claude.
- **No conversation context:** Qwen invocations are stateless — each delegation call starts fresh with no knowledge of the Claude conversation history.
