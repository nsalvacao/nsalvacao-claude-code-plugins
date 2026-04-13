# qwen-delegate

Offload high-volume, low-risk text and code transformations to the Qwen CLI behind a deterministic validation pipeline — Claude only intervenes on persistent failures.

**Version:** 0.2.0

## Overview

`qwen-delegate` bridges Claude Code and the `qwen` CLI (Qwen Code), routing delegatable tasks through a deterministic validation layer. Qwen handles the generation; bash validators (linters, parsers, hash checks) gate delivery. Claude reads output only on escalation — not on the happy path.

> **Note:** The `qwen` CLI is cloud-backed (Qwen/Alibaba infrastructure, OAuth — not a local LLM runner). All delegated content is sent to Alibaba cloud.

## Features

- **Deterministic validation pipeline** — linters, parsers, idempotency checks gate every delegation
- **Cognitive delegation skill** — Claude auto-delegates matching tasks
- **Slash command** — `/qwen-delegate:ask-qwen` for direct user delegation
- **Delegation advisor agent** — proactively triages task lists

## Prerequisites

- `qwen` CLI installed and authenticated
- Verify: `qwen --version` (requires 0.14.0+)
- Authenticate: `qwen auth` (OAuth or Alibaba Cloud Coding Plan)
- Python 3 (required for JSON/Python validators and escalation payloads)

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

Auto-activates when Claude recognises a delegatable task. In v0.2.0, the skill routes through validated bash scripts instead of raw `qwen` invocations.

### Command: `ask-qwen`

Direct delegation by the user:

```
/qwen-delegate:ask-qwen Summarise this PR description in 3 bullets
/qwen-delegate:ask-qwen Format this JSON with sorted keys
/qwen-delegate:ask-qwen Write a Python function to validate an email address
```

### Agent: `qwen-advisor`

Proactive triage of task lists:

```
What could I delegate to Qwen from today's tasks?
```

## Delegation Categories

| Category | Delegate | Validator |
|---|---|---|
| Summarisation | ✅ | Word count, sentence structure |
| JSON / YAML formatting | ✅ | Syntax, idempotency, schema |
| Markdown formatting | ✅ | markdownlint |
| Code generation | ✅ | py_compile / mypy / shellcheck / tsc |
| Boilerplate generation | ✅ | Syntax + AST structure |
| Translation | ✅ | langdetect, structure diff |
| Text transformation | ✅ | Bounds, structure |
| Architectural decisions | ❌ | — |
| Security-critical code | ❌ | — |
| Mechanical refactoring | ❌ | Use libcst / jscodeshift / black |

## Validation Pipeline

```
qwen output
    ↓
Deterministic validators (0 Claude tokens)
    ├─ PASS → deliver with attribution
    └─ FAIL → retry Qwen with error feedback (max 2×)
           → persistent fail → escalation payload to Claude
```

Claude reads only the error message on escalation — not the raw Qwen output.

## Security

- Pre-flight rejects sensitive paths: `.env`, `*.pem`, `*.key`, credentials, `.git/`
- File-aware tasks use `--approval-mode auto-edit` + `--checkpointing` (was `yolo`)
- Tool whitelist: `--allowed-tools read_file,glob,grep_search` for read-only patterns
- All Qwen output wrapped in `<qwen_output>` — treated as untrusted data, not instructions

## Known Limitations

- **Cloud dependency:** requires internet access and valid Qwen authentication
- **Session turns:** complex tasks may require `--max-session-turns 3+`; scripts handle this automatically
- **Model fixed:** `coder-model` (Qwen Code default)
- **Validator degradation:** optional yamllint/markdownlint/mypy/tsc validators are skipped with a warning if not installed
- **Stateless invocations:** each delegation call starts fresh (no conversation context)
- **Privacy:** content is sent to Alibaba cloud — do not delegate secrets, credentials, or NDA code
