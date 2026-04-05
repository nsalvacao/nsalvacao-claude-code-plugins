---
name: Ask Qwen
description: This skill should be used when the user invokes "/qwen-delegate:ask-qwen" to directly delegate a task or prompt to the Qwen CLI (cloud-backed). This is a user-invocable skill — invoked via the skills mechanism (argument-hint frontmatter), not via a commands/ file. Execute the task using the qwen CLI, validate the result, and return it to the user. Accepts an optional task argument; if absent, prompt the user for the task.
argument-hint: "<task or prompt to delegate to Qwen>"
allowed-tools:
  - Bash
version: 0.1.0
---

# Ask Qwen — Direct Delegation

Execute a user-specified task on the local Qwen model (`qwen` CLI) and return the validated result.

## Execution Steps

1. **Get the task** — Use the argument provided by the user. If no argument was given, ask: *"What task would you like to delegate to Qwen?"*

2. **Classify the task** to select the right command pattern:
   - Text/analysis task with no file context → Pattern A
   - Task referencing a file the user mentioned → Pattern B
   - Code generation or refactoring → Pattern C

3. **Execute** the appropriate command (see patterns below).

4. **Validate** Qwen's output before presenting it (see Validation section).

5. **Present** the result with a brief attribution line.

## Command Patterns

### Pattern A — Text task, no files

```bash
qwen "TASK" \
  --output-format text \
  --approval-mode yolo \
  --max-session-turns 1 \
  --exclude-tools run_shell_command,edit,write_file
```

Simple text transformations only. Use `--max-session-turns 2` if the task is moderately complex.

### Pattern B — Task with file context

```bash
cat FILE_PATH | qwen "TASK" \
  --output-format text \
  --approval-mode yolo \
  --max-session-turns 2 \
  --exclude-tools run_shell_command,edit,write_file
```

### Pattern C — Code generation or refactoring

```bash
qwen "TASK" \
  --output-format text \
  --approval-mode yolo \
  --max-session-turns 3 \
  --exclude-tools run_shell_command,edit,write_file
```

Minimum 3 turns for code tasks — Qwen uses thinking turns internally. Using `--max-session-turns 1` on code tasks causes exit code 53.

## Prompt Construction

Construct a self-contained prompt for Qwen — it has no conversation history. Include all context the task requires:

- For code: language, function name, signature, expected behaviour, edge cases.
- For text: desired format, length, tone.
- For transformations: input and target format.

Incorporate the user's argument verbatim as the core of the prompt, expanding only where necessary for clarity.

## Validation (Mandatory)

Before presenting results, verify:

- **Code output**: Correct logic, valid syntax, no obvious security issues, edge cases handled.
- **Text output**: Accurate, complete, matches requested format/tone.
- **Structured output**: Valid schema, required fields present.

Apply corrections directly if needed; do not re-delegate fixes.

## Response Format

Present the result as:

```
[Qwen's validated output here]

---
*Drafted by local Qwen (coder-model), validated by Claude.*
```

For trivial transformations (e.g., reformatting a small JSON), omit the attribution footer.

## Error Handling

If the `qwen` command fails or returns an empty result:

1. Report the error to the user with the raw stderr output.
2. Offer to retry with a refined prompt or handle the task directly with Claude.
