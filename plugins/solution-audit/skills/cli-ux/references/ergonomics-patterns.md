# CLI UX — Ergonomics Patterns

## POSIX/GNU Flag Conventions

### Short Flags (-f)
- Single character, preceded by single dash: `-v`, `-q`, `-n`
- Combinable: `-vq` equivalent to `-v -q` (only valid for boolean flags)
- Reserve single letters for the most-used flags; do not exhaust the alphabet

### Long Flags (--flag)
- Full descriptive name, preceded by double dash: `--verbose`, `--output`, `--dry-run`
- Use hyphens for word separation, never underscores: `--log-level` not `--log_level`
- Every long flag should have a corresponding short form if used frequently

### Value Attachment
Three accepted forms — pick one per flag and document it consistently:
- `--flag=value` (recommended; unambiguous in scripts)
- `--flag value` (common; requires careful parsing when value starts with `-`)
- Positional: only for the primary argument, not for options

Anti-pattern: mixing attachment styles in the same CLI (`--flag value` for some, `--flag=value` for others).

---

## Help Text Quality Rubric

`--help` output must contain all of the following to score "good" or higher:

- [ ] **One-line description** of what the command does (not what it is)
- [ ] **Synopsis / usage line:** `tool [OPTIONS] COMMAND [ARGS]`
- [ ] **All options listed** with their type (string, integer, boolean), default value if any
- [ ] **At least one runnable example** per subcommand or for the main command
- [ ] **Exit codes documented** (at minimum: 0 = success, 1 = error, 2 = misuse)
- [ ] **See also / docs link** for full reference

Rating:

| Rating    | Criteria                                                                 |
|-----------|--------------------------------------------------------------------------|
| Excellent | All 6 items above present; examples are realistic, not toy              |
| Good      | 4-5 items; missing exit codes or docs link                              |
| Acceptable| 3 items; options listed but no examples                                 |
| Poor      | Usage line only, or just "Run tool --help for help" recursively         |

---

## Argument Naming Patterns

### Commands (verbs or verb-noun)
- Prefer imperative verbs: `create`, `delete`, `list`, `update`, `init`, `run`
- Compound commands: verb-noun, `create-key`, `list-users`, not `key-create` or `users-list`
- Avoid abbreviations unless industry-standard (`rm` is acceptable; `dlg` is not)

### Flags (adjective/noun)
- Describe the effect, not the implementation: `--output-format` not `--serializer-type`
- Boolean flags: `--verbose`, `--force`, `--dry-run` (no value required)
- Negation form: `--no-color`, `--no-prompt` (not `--disable-color`)

### Consistent Pluralization
- Collection commands use plural noun: `list users`, `get secrets`
- Single-item commands use singular: `get user`, `delete secret`
- Never mix: if `list users` exists, do not also have `list user` (singular) for something else

---

## Subcommand Depth

### When to Use Subcommands vs Flags
- Use subcommands when the verb changes the fundamental action: `tool create` vs `tool delete`
- Use flags when the verb stays the same but behaviour is modified: `tool list --format=json`
- Anti-pattern: using subcommands for what are really flags (`tool list json` vs `tool list --format=json`)

### Maximum Recommended Depth
- 2 levels maximum for primary paths: `tool resource action`
- 3 levels acceptable only for well-structured platforms: `tool resource subresource action`
- Beyond 3 levels: always a sign of insufficient abstraction; refactor the model

### Alias Conventions
- Common aliases documented in `--help`: `rm` for `remove`, `ls` for `list`, `init` for `initialize`
- Aliases never shadow other commands
- Aliases stable across versions; do not remove aliases without a deprecation cycle

---

## Error Handling Patterns

### Exit Codes
- `0`: success
- `1`: general error (use for recoverable or user-caused errors)
- `2`: misuse (wrong arguments, unknown flag)
- `3-125`: tool-specific codes; document them
- `126`: command cannot execute (permission)
- `127`: command not found
- Never exit `0` when an error occurred — this is a scripting trap

### Output Routing
- Errors and warnings → stderr only
- Normal output → stdout only
- This separation enables: `tool command 2>/dev/null` and `tool command | downstream`
- Anti-pattern: mixing error messages into stdout destroys pipeline composability

### Error Message Quality
- State what failed, not just that it failed
- Include the value that caused the failure (e.g., `unknown flag: --ouput` not `invalid input`)
- Suggest the fix inline when possible (`did you mean --output?`)

---

## Output Formatting

### Human vs Machine Output
- Default: human-readable, may use colour and alignment
- `--json`: machine-readable JSON, no decoration, stable schema
- `--json` output must be valid JSON even when empty (`[]` or `{}`, never ``)

### Verbosity Flags
- `--quiet` / `-q`: suppress all output except errors; exit code still meaningful
- `--verbose` / `-v`: add operational detail (what is happening, why)
- `--debug`: add implementation detail (internal state, timing); acceptable to be noisy

### Colour and Decoration
- `--no-color`: disable all ANSI escape codes; also respect `NO_COLOR` env var (https://no-color.org)
- Never use colour as the only differentiator (accessibility: colourblind users)
- Detect TTY: disable colour automatically when stdout is not a terminal (`isatty()` check)

---

## Scripting Friendliness Checklist

- [ ] **Idempotent where possible:** running the same command twice produces the same result
- [ ] **`--dry-run` for destructive operations:** shows what would change without changing it
- [ ] **Predictable exit codes:** same error always produces the same exit code
- [ ] **No interactive prompts in non-interactive mode:** detect TTY; if not TTY, require explicit flags (`--yes`, `--force`)
- [ ] **`--yes` / `-y` flag:** skip confirmation prompts for automated pipelines
- [ ] **Stable stdout format:** changes to output format are a breaking change; version appropriately
- [ ] **Environment variable support:** every important flag should also be configurable via env var (`TOOL_LOG_LEVEL` for `--log-level`)
- [ ] **Config file support:** long-running use should not require repeating flags on every invocation

---

## Anti-Patterns

- **Order-sensitive flags:** `--flag value command` works but `command --flag value` does not. All flags should be order-independent.
- **Positional args mixed with named args ambiguously:** `tool FILE --output FILE2` where it is unclear which FILE is which.
- **Silent success with no output:** the user has no confirmation the command ran. Always emit at least one line on success (or support `--quiet` explicitly).
- **Errors printed to stdout:** breaks pipelines and scripting; always use stderr for errors.
- **Undocumented environment variables:** env vars that affect behaviour but are not in `--help` or docs.
- **Inconsistent casing in output:** sometimes `Success`, sometimes `success`, sometimes `SUCCESS`.
- **Required flags with no defaults that could be inferred:** if the tool can detect the value, it should (e.g., project name from `package.json`, not required as a flag).
- **Numeric IDs as primary identifiers in UX:** `delete 4821` is worse than `delete my-project-name`; prefer human-readable names.
