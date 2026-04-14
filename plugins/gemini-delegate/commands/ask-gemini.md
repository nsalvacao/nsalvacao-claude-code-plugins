---
name: ask-gemini
description: Delegate a task directly to the Gemini CLI (Google OAuth, cloud-backed). Selects the appropriate delegate script, runs deterministic validators, and returns the validated result.
argument-hint: "<task or prompt to delegate to Gemini>"
allowed-tools:
  - Bash
---

# Ask Gemini — Direct Delegation

Execute a user-specified task via the `gemini` CLI (Gemini Code, Google OAuth). No Anthropic API calls during delegation.

> **Privacy:** Gemini CLI sends content to Google/Gemini infrastructure. Do not delegate secrets, credentials, private keys, personal data, or NDA-protected code.

## Execution Steps

1. **Get the task** — Use the argument provided. If none: ask *"What task would you like to delegate to Gemini?"*

2. **Pre-flight check:**

```bash
ls ~/.gemini/settings.json
```

If absent, stop and tell user to run `gemini` interactively (Google OAuth).

3. **Classify the task:**

   - Summarisation → `delegate-summary.sh`
   - JSON / YAML / Markdown formatting → `delegate-format.sh <type>`
   - Code generation or boilerplate → `delegate-codegen.sh <lang> "<spec>"`
   - Research / web search → `delegate-research.sh "<question>"`
   - Large file analysis → `delegate-analyze.sh "<question>" <files...>`
   - UI / HTML / CSS / React → `delegate-ui.sh <type> "<spec>"`

4. **Execute** the appropriate command.

5. **Handle output** — see "Output handling" section.

## Commands

### Summarisation

```bash
echo "CONTENT" | bash plugins/gemini-delegate/scripts/delegate-summary.sh
bash plugins/gemini-delegate/scripts/delegate-summary.sh path/to/file.md
```

### JSON formatting

```bash
echo 'RAW_JSON' | bash plugins/gemini-delegate/scripts/delegate-format.sh json
```

### YAML formatting

```bash
bash plugins/gemini-delegate/scripts/delegate-format.sh yaml path/to/file.yaml
```

### Markdown formatting

```bash
bash plugins/gemini-delegate/scripts/delegate-format.sh markdown path/to/file.md
```

### Code generation

```bash
bash plugins/gemini-delegate/scripts/delegate-codegen.sh python "SPEC"
bash plugins/gemini-delegate/scripts/delegate-codegen.sh typescript "SPEC"
bash plugins/gemini-delegate/scripts/delegate-codegen.sh bash "SPEC"
```

### Research (Google Search grounded)

```bash
bash plugins/gemini-delegate/scripts/delegate-research.sh "RESEARCH QUESTION"
```

### Large file / codebase analysis

```bash
bash plugins/gemini-delegate/scripts/delegate-analyze.sh "QUESTION" path/to/file
bash plugins/gemini-delegate/scripts/delegate-analyze.sh "QUESTION" path/to/directory/
```

### UI / HTML / CSS / React generation

```bash
bash plugins/gemini-delegate/scripts/delegate-ui.sh html "SPEC"
bash plugins/gemini-delegate/scripts/delegate-ui.sh react "SPEC"
bash plugins/gemini-delegate/scripts/delegate-ui.sh css "SPEC"
```

## Output handling

**Success (`<gemini_output>`, exit 0):** Present content to user with:

```
[content from <gemini_output> block]

---
*Drafted by Gemini CLI (Google OAuth), validated by deterministic pipeline.*
```

**Escalation (`<gemini_escalation>`, exit 70):** Read only `error` and `validators` from the JSON — do NOT re-read raw Gemini output. Decide: fix directly, or tell user: *"Gemini output failed validation ([error]). Handle with Claude directly — shall I?"*

**Auth failure (exit 41 or exit 80):** Tell user: *"Gemini not authenticated. Run `gemini` interactively to complete Google OAuth login."*

**Pro model at capacity (exit 1, 429):** Tell user: *"gemini-2.5-pro is temporarily at capacity. Retry in a few minutes, or use Claude directly."*

## Error troubleshooting

| Error | Cause | Fix |
|---|---|---|
| `gemini: command not found` | CLI not installed | Install Gemini CLI; verify with `gemini --version` |
| Exit 80 or 41 — not authenticated | OAuth never run / token expired | Run `gemini` interactively (Google OAuth) |
| Exit 70 — escalation after retry | Gemini persistently invalid output | Handle with Claude directly |
| Empty response | Model returned blank | Script retries automatically; escalates on failure |
| 429 / capacity exhausted | Pro model overloaded | Retry in a few minutes |
| Network error | No internet | Gemini CLI requires cloud access |
