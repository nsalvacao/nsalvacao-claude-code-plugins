---
name: Qwen Delegate
description: This skill should be used when Claude is about to perform tasks that can be delegated to the Qwen CLI to save Anthropic PRO tokens. Delegation candidates include "summarise this", "translate this text", "format this content", "generate boilerplate", "create a template", "write this function", "generate this code", "refactor this snippet", "convert this format", "explain this concept", or any text-processing or code-generation task that does not require Claude's reasoning depth. Always apply a validation gate — Claude reviews Qwen output before presenting to the user.
version: 0.1.0
---

# Qwen Delegate

Delegate token-cheap tasks to the `qwen` CLI (Qwen Code, model `coder-model`), preserving Anthropic PRO tokens for tasks that genuinely require Claude's reasoning.

> **Note:** The `qwen` CLI is cloud-backed, not a local LLM runner (it does not use Ollama, LM Studio, or similar). It is an agent CLI that runs against Qwen/Alibaba cloud infrastructure, authenticated via OAuth or Alibaba Cloud Coding Plan. Throughout this skill, references to "Qwen" mean the cloud-backed `qwen` CLI unless explicitly stated otherwise. Delegation avoids Anthropic API calls, not all cloud calls.

## Delegation Criteria

Delegate to Qwen when **all three conditions** are met:

1. **Task type matches** one of the delegatable categories below
2. **No deep reasoning required** — transformation, generation, or summarisation suffices
3. **Output requires Claude validation** — Qwen result is always reviewed before delivery

### Delegatable Task Categories

| Category | Examples |
|----------|----------|
| Summarisation | Summarise a document, meeting notes, PR description |
| Formatting | Convert Markdown→HTML, reformat JSON/YAML, fix indentation |
| Translation | Translate text to another language |
| Boilerplate generation | Scaffold a class, generate CRUD stubs, create a config template |
| Code generation | Write a function from a spec, implement a known algorithm |
| Refactoring | Rename identifiers, extract a method, apply a pattern |
| Text transformation | Convert lists to tables, rewrite in different tone |
| Simple analysis | Count items, extract fields, detect language |

### Do NOT delegate when:

- The task requires architectural decisions or multi-file reasoning
- Security-sensitive code is involved and correctness is critical
- The user explicitly asked for Claude's opinion or judgment
- The task is faster to do directly than to delegate (< 5 lines)

## Command Patterns

### Pattern 1 — Text-only task (no file access)

```bash
qwen "PROMPT" \
  --output-format text \
  --approval-mode yolo \
  --max-session-turns 1 \
  --exclude-tools run_shell_command,edit,write_file
```

Use for: summarisation, translation, formatting, explanation tasks. Use `--max-session-turns 1` only for pure text transformations; Qwen's internal thinking counts as turns — if the task is complex, increase to 2.

### Pattern 2 — File context via stdin

```bash
cat FILE_PATH | qwen "TASK DESCRIPTION" \
  --output-format text \
  --approval-mode yolo \
  --max-session-turns 2 \
  --exclude-tools run_shell_command,edit,write_file
```

Use for: summarising a file, translating a document, reformatting content.

### Pattern 3 — Code generation or refactoring (without file access)

```bash
qwen "TASK DESCRIPTION" \
  --output-format text \
  --approval-mode yolo \
  --max-session-turns 3 \
  --exclude-tools run_shell_command,edit,write_file
```

Use for: generating a function, writing an algorithm, refactoring a snippet. Minimum 3 turns — Qwen uses thinking turns internally; `--max-session-turns 1` causes exit code 53 on code tasks.

### Pattern 4 — Code task with file access (multi-step)

```bash
qwen "TASK DESCRIPTION" \
  --output-format text \
  --approval-mode yolo \
  --max-session-turns 5
```

Use for: scaffolding a module, refactoring across multiple files, tasks that require reading existing code.

> **Why no `--exclude-tools` here:** This pattern intentionally allows Qwen to use `read_file`, `glob`, and `grep_search` to read existing code before generating output. Write/edit/shell tools (`edit`, `write_file`, `run_shell_command`) are still blocked by default in `--approval-mode yolo` without explicit confirmation — Qwen Code will prompt before any write/execute action. Validate all generated code with Claude before applying it to the project.

### Pattern 5 — Custom system prompt for specialised tasks

```bash
qwen "PROMPT" \
  --output-format text \
  --system-prompt "FOCUSED SYSTEM PROMPT" \
  --approval-mode yolo \
  --max-session-turns 2 \
  --exclude-tools run_shell_command,edit,write_file
```

Use for: tasks that benefit from a specific persona or tight output constraints (e.g., "You are a JSON formatter. Return only valid JSON.").

## Execution Workflow

1. **Identify** — Determine if the task matches the delegation criteria above.
2. **Select pattern** — Choose the command pattern that fits (text-only, stdin, code, custom prompt).
3. **Compose prompt** — Write a clear, self-contained prompt for Qwen. Include all necessary context inline or via stdin.
4. **Execute** — Run the `qwen` command via Bash tool.
5. **Validate** — Review Qwen's output critically:
   - Correctness (logic, syntax, facts)
   - Completeness (all requirements addressed)
   - Quality (style, conventions, security)
6. **Fix or augment** — Apply corrections directly; do not re-delegate fixes to Qwen.
7. **Present** — Deliver the validated result to the user. Optionally note: *"Generated by Qwen CLI (coder-model), validated by Claude."*

## Prompt Composition Guidelines

- Be explicit: include all context Qwen needs in the prompt (do not assume it has conversation history).
- For code tasks, specify: language, function signature, expected behaviour, edge cases.
- For text tasks, specify: output format, length constraints, tone.
- Keep prompts focused — one task per delegation call.

### Example: Summarisation

```bash
cat docs/api-reference.md | qwen \
  "Summarise this API reference in 5 bullet points, focusing on authentication and rate limits." \
  --output-format text \
  --approval-mode yolo \
  --max-session-turns 1 \
  --exclude-tools run_shell_command,edit,write_file
```

### Example: Code generation

```bash
qwen "Write a Python function named 'parse_iso_date' that accepts a string and returns a datetime object. Handle invalid input by raising ValueError with a descriptive message. Include type hints." \
  --output-format text \
  --approval-mode yolo \
  --max-session-turns 2 \
  --exclude-tools run_shell_command,edit,write_file
```

### Example: JSON formatting

```bash
echo '{"name":"test","version":"1","deps":["a","b"]}' | qwen \
  "Format this JSON with 2-space indentation and sort keys alphabetically." \
  --output-format text \
  --approval-mode yolo \
  --max-session-turns 1 \
  --exclude-tools run_shell_command,edit,write_file
```

## Validation Gate (Mandatory)

Every delegation result must pass Claude's review before being used or shown to the user:

- **Code**: Check logic, syntax, edge cases, security implications.
- **Text**: Check accuracy, completeness, tone, formatting.
- **Structured output**: Validate schema, field types, required fields.

If Qwen's output is incorrect or incomplete, correct it directly — never present unvalidated Qwen output.

## Attribution

When presenting delegated results, optionally include a one-line note:

> *Drafted by Qwen CLI (coder-model), reviewed and validated by Claude.*

This maintains transparency without being verbose. Omit attribution for minor transformations (formatting, renaming) where it adds no value.
