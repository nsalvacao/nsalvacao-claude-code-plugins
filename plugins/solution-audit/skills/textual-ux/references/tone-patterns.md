# Textual UX — Tone Patterns

## Tone Taxonomy

| Tone        | Context                                       | Characteristics                                              |
|-------------|-----------------------------------------------|--------------------------------------------------------------|
| Neutral     | Default operational output                    | Factual, no personality markers, no exclamations             |
| Friendly    | Onboarding, first-run, success after setup    | Encouraging, uses "you", avoids jargon, short sentences      |
| Urgent      | Errors, warnings, destructive operations      | Direct, imperative, action-oriented, no softening            |
| Technical   | `--verbose` / `--debug` output                | Precise, includes values, paths, durations, no prose padding |

### When to Switch Tones
- Onboarding screens and `init` wizard: friendly
- Routine operational output: neutral
- `WARNING:` and `ERROR:` messages: urgent — do not soften errors with "Oops!" or "Hmm."
- Debug output: technical — developers reading this want data, not narrative

Anti-pattern: applying friendly tone to error messages ("Uh oh! Something went wrong 😬") — it undermines urgency and wastes the user's time.

---

## Jargon Detection Patterns

Flag any of the following as potential jargon violations:

- **Internal code terms exposed:** function names, class names, module paths in user-facing messages (e.g., `NullPointerException in AuthService.validateToken()`)
- **Unexplained acronyms on first use:** "Configure your IAM role" without explaining IAM for non-AWS-native users
- **Domain-specific language without definition:** "reconcile your workspace" — what does reconcile mean here?
- **Implementation leakage:** error messages that name internal state ("Redis key not found") instead of user-facing concept ("session expired — log in again")
- **Version-specific internal names:** referring to a feature by its code name, not its product name

Audit method: read each message as if you have zero knowledge of the codebase. Circle any term you would have to look up. Each circled term is a jargon violation.

---

## Error Message Anatomy

Every error message must contain all three components:

1. **What happened** — factual, specific, includes the value or file that caused the error
2. **Why it happened** — root cause in user-facing terms, not stack trace
3. **What to do next** — specific, actionable step the user can take immediately

### Examples

**Anti-pattern (missing all three components):**
```
Error: failed
```

**Anti-pattern (has what, missing why and next step):**
```
Error: could not read config.json
```

**Good (all three components):**
```
Error: could not read config.json — file not found.
Create a config file by running: tool init
```

**Excellent (all three + context value):**
```
Error: could not read config at /home/user/.config/tool/config.json — file not found.
Run `tool init` to create a default configuration, or set CONFIG_PATH to an existing file.
```

### Error Message Checklist
- [ ] Names the specific file, flag, or value that caused the problem
- [ ] Explains root cause without mentioning internal code structure
- [ ] Provides a concrete next step (command, URL, or config change)
- [ ] Written in second person ("your config") not passive ("config was not found")
- [ ] Does not end with a question mark
- [ ] Does not use exclamation marks

---

## Verbosity Calibration Matrix

| Level   | Flag        | What Appears                                                              |
|---------|-------------|---------------------------------------------------------------------------|
| Quiet   | `--quiet`   | Nothing on success; errors only on failure                               |
| Normal  | (default)   | Key actions confirmed, counts/summaries, warnings, errors                |
| Verbose | `--verbose` | Each step as it runs, values used, decisions made                        |
| Debug   | `--debug`   | All of verbose + internal state, timing, config resolution, HTTP calls   |

### Rules
- Quiet mode must still exit with correct code (0/non-0); silence does not mean success
- Normal mode should confirm the primary action: "Created 3 files in ./output"
- Verbose should be useful to a power user diagnosing unexpected behaviour, not just more of the same
- Debug is for developers; it may be noisy and unstable across versions

---

## Consistency Requirements

### Terminology
- Identify the core nouns of the product (e.g., "project", "workspace", "environment", "pipeline") and use them consistently throughout all output, docs, and help text
- Never alternate: pick "project" or "workspace", not both for the same concept
- Maintain a term glossary (even internal) and enforce it during review

### Product Name Capitalization
- Product and feature names: always use the official casing (e.g., "GitHub Actions", not "Github actions")
- Flag names in prose: use backtick code formatting: "use `--output` to specify the path"
- Commands in prose: use code formatting and full form: "`tool create-key`", not "the create key command"

### Tense and Voice
- Completed actions: past tense ("Created 3 files")
- In-progress actions: present continuous ("Creating files...")
- Instructions: imperative ("Run `tool init`", not "You should run `tool init`")

---

## Affirmation Patterns

A good success message contains:
1. **Confirms the action taken** — what was done, not just "done"
2. **What changed** — count, name, path, or state that is now different
3. **Next step (if any)** — what the user might logically do next

### Examples

**Anti-pattern:**
```
Done.
```

**Acceptable:**
```
Config file created.
```

**Good:**
```
Config file created at /home/user/.config/tool/config.json
```

**Excellent:**
```
Config file created at /home/user/.config/tool/config.json
Next: run `tool connect` to verify your credentials.
```

---

## Pluralization Rules

- Never: "1 errors found" — singular noun required when count is 1
- Never: "0 errors found" — prefer "No errors found" when count is 0
- Always: "2 errors found", "1 error found", "No errors found"
- Avoid: "1 file(s) changed" — commit to one form based on count

Correct patterns:
```
No files changed.
1 file changed.
3 files changed.
```

Zero-count phrasing guidance:
- "No items found" — neutral, appropriate for search results
- "Nothing to do" — appropriate for idempotent operations
- "0 results" — acceptable only in --json output where parsers expect numbers

---

## Grammar Patterns to Avoid

- **Passive voice in errors:** "File was not found" → "Could not find file at PATH"
- **Double negatives:** "Cannot not be empty" → "Must not be empty" or "Required field"
- **Interrogative errors:** "Could not the file be found?" — never phrase errors as questions
- **Hedge words in warnings:** "This might potentially cause issues" → "This will overwrite FILE"
- **Nominalisation (turning verbs into nouns):** "Perform an installation of" → "Install"
- **Run-on instructions:** split multi-step instructions into numbered lists, not comma-separated prose

---

## Emoji Usage

### Appropriate Uses
- Status indicators in interactive / human-readable output only:
  - `✓` or `✗` for pass/fail in summaries
  - `⚠` for warnings that require attention
  - `→` for indicating "next step" or navigation
- Sparingly in onboarding, first-run messages, and progress summaries

### Never Use Emoji
- In `--json` output or any machine-readable format
- In error messages (urgency conflicts with informal decoration)
- In `--quiet` or piped output
- As the only indicator of status (accessibility: screen readers)
- In log files or `--debug` output

### Density Rule
Maximum 1 emoji per output line. More than 1 per line reads as informal/unprofessional in a tool context.
