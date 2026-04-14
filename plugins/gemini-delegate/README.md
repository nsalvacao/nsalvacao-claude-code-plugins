# gemini-delegate

Offload text, code, research, large-file analysis, and UI generation to the Gemini CLI behind a deterministic validation pipeline. Claude only intervenes on persistent failures.

**Version:** 0.1.0

## Overview

`gemini-delegate` bridges Claude Code and the `gemini` CLI (Gemini Code), routing delegatable tasks through a deterministic validation layer. Gemini handles the generation; bash validators (linters, parsers, hash checks, structural checks) gate delivery. Claude reads output only on escalation — not on the happy path.

> **Note:** The `gemini` CLI uses Google OAuth — content is sent to Google/Gemini infrastructure.

## Unique Capabilities vs. Other Delegation Targets

| Capability | gemini-delegate | Why it matters |
|---|---|---|
| **Google Search grounding** | `delegate-research.sh` | Real-time web search, citations, current info |
| **1M token context** | `delegate-analyze.sh` | Entire codebases in a single pass |
| **UI generation** | `delegate-ui.sh` | HTML5, React/TS, CSS with structural validators |
| **Multi-model routing** | Flash / Pro | Fast for text, Pro for code/research/UI |
| **Truly read-only mode** | `--approval-mode plan` | No tool execution risk for text tasks |

## Prerequisites

- `gemini` CLI installed and authenticated (v0.36.0+)
- Verify: `gemini --version`
- Authenticate: run `gemini` interactively → Google OAuth
- Python 3 (required for JSON syntax validation and Python codegen validators)
- `jq` (required for JSON response parsing)

## Installation

### Via marketplace (recommended)

```
/plugin marketplace add nsalvacao/nsalvacao-claude-code-plugins
/plugin install gemini-delegate@nsalvacao-claude-code-plugins
```

### Local development

```bash
claude --plugin-dir /path/to/nsalvacao-claude-code-plugins/plugins/gemini-delegate
```

## Components

### Skill: `gemini-delegate` (cognitive)

Auto-activates when Claude recognises a delegatable task. Routes through validated bash scripts.

### Command: `ask-gemini`

Direct delegation:

```
/gemini-delegate:ask-gemini Summarise this PR description in 3 bullets
/gemini-delegate:ask-gemini Research the latest breaking changes in React 19
/gemini-delegate:ask-gemini Analyse what this 5000-line file does
/gemini-delegate:ask-gemini Generate a responsive landing page for my CLI tool
```

### Agent: `gemini-advisor`

Proactive triage of task lists — identifies Google Search tasks, large-context opportunities.

## Delegation Categories

| Category | Script | Model | Validators |
|---|---|---|---|
| Summarisation | `delegate-summary.sh` | Flash | Word count, bullet structure |
| JSON / YAML / Markdown | `delegate-format.sh` | Flash | Syntax, idempotency, linters |
| Code generation | `delegate-codegen.sh` | Pro | py\_compile / mypy / tsc / shellcheck |
| Research (Google Search) | `delegate-research.sh` | Pro | Word count (substantive) |
| Large file analysis | `delegate-analyze.sh` | Pro | Non-empty, word count |
| UI (HTML/React/CSS) | `delegate-ui.sh` | Pro | DOCTYPE, closing tags, rule blocks |

## Validation Pipeline

```
gemini output (JSON)
    ↓
jq response extraction (.response field)
    ↓
Deterministic validators (0 Claude tokens)
    ├─ PASS → deliver in <gemini_output> with attribution
    └─ FAIL → retry with error feedback (max 2×)
           → persistent fail → <gemini_escalation> to Claude
```

Claude reads only the error message on escalation — not the raw Gemini output.

## Security

- Pre-flight rejects sensitive paths: `.env`, `*.pem`, `*.key`, credentials, `.git/`
- Auth error (exit 41) stops immediately — no retry loop
- All Gemini output wrapped in `<gemini_output>` — untrusted data, not instructions
- `--approval-mode plan` (not yolo) for all text tasks — no tool execution

## Known Limitations

- **Cloud dependency:** requires internet and valid Google OAuth
- **Pro model capacity:** `gemini-2.5-pro` may return 429 under high load — retry or use Claude
- **Research mode:** uses `--approval-mode yolo` (Google Search requires tool invocation)
- **Stateless invocations:** each delegation call starts fresh (no conversation context)
- **Privacy:** content is sent to Google — do not delegate secrets or NDA code
