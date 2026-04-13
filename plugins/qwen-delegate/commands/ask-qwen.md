---
name: ask-qwen
description: Delegate a task directly to the Qwen CLI (cloud-backed, OAuth-authenticated). Selects the appropriate delegate script, runs deterministic validators, and returns the validated result.
argument-hint: "<task or prompt to delegate to Qwen>"
allowed-tools:
  - Bash
---

# Ask Qwen — Direct Delegation

Execute a user-specified task via the `qwen` CLI (Qwen Code, cloud-backed Qwen/Alibaba). No Anthropic API calls are made during delegation.

> **Privacy:** Qwen CLI sends all content to Alibaba cloud infrastructure. Do not delegate secrets, credentials, private keys, personal data, or NDA-protected code.

## Execution Steps

1. **Get the task** — Use the argument provided. If none: ask *"What task would you like to delegate to Qwen?"*

2. **Pre-flight check:**

```bash
qwen auth status
```

If not authenticated, stop and tell the user to run `qwen auth`.

3. **Classify the task:**

   - Summarisation → `delegate-summary.sh`
   - JSON / YAML / Markdown formatting → `delegate-format.sh <type>`
   - Code generation or boilerplate → `delegate-codegen.sh <lang> "<spec>"`
   - Translation / text transformation → Pattern T (direct qwen invocation)

4. **Execute** the appropriate command (see below).

5. **Handle output** — see "Output handling" section.

## Commands

### Summarisation

```bash
echo "CONTENT" | bash plugins/qwen-delegate/scripts/delegate-summary.sh
# or
bash plugins/qwen-delegate/scripts/delegate-summary.sh path/to/file.md
```

### JSON formatting

```bash
echo 'RAW_JSON' | bash plugins/qwen-delegate/scripts/delegate-format.sh json
```

### YAML formatting

```bash
bash plugins/qwen-delegate/scripts/delegate-format.sh yaml path/to/file.yaml
```

### Markdown formatting

```bash
bash plugins/qwen-delegate/scripts/delegate-format.sh markdown path/to/file.md
```

### Code generation

```bash
bash plugins/qwen-delegate/scripts/delegate-codegen.sh python "SPEC"
bash plugins/qwen-delegate/scripts/delegate-codegen.sh typescript "SPEC"
bash plugins/qwen-delegate/scripts/delegate-codegen.sh bash "SPEC"
```

### Translation (Pattern T)

```bash
cat FILE_PATH | qwen \
  "Translate to TARGET_LANGUAGE. Preserve markdown and code blocks. Output ONLY the translation." \
  --output-format text \
  --approval-mode yolo \
  --max-session-turns 2 \
  --exclude-tools run_shell_command,edit,write_file
```

## Output handling

**Success (`<qwen_output>`, exit 0):** Present the content to the user with:

```
[content from <qwen_output> block]

---
*Drafted by Qwen CLI (coder-model), validated by deterministic pipeline.*
```

**Escalation (`<qwen_escalation>`, exit 70):** Read only `error` and `validators` from the JSON payload — do NOT re-read the raw Qwen output. Decide: fix directly, or tell the user: *"Qwen output failed validation ([error]). I can handle this with Claude directly — shall I?"*

**Pre-flight failure (exit 80):** Tell the user: *"Delegation blocked: [reason from stderr]. Qwen CLI may not be authenticated. Run `qwen auth` to log in."*

## Error troubleshooting

| Error | Cause | Fix |
|---|---|---|
| `qwen: command not found` | CLI not installed | Install Qwen Code CLI; verify with `qwen --version` |
| Exit 80 — not authenticated | OAuth expired / never run | Run `qwen auth` |
| Exit 53 — turns exhausted | Task too complex for turn limit | Increase `--max-session-turns`; script retries automatically |
| Network error | No internet | Check connectivity; Qwen CLI requires cloud access |
| Exit 70 — escalation after retry | Qwen persistently producing invalid output | Handle with Claude directly |
