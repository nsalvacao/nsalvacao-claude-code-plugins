# Learnability & Workflow — Friction Patterns

## Friction Taxonomy

| Type          | Definition                                                     | Example                                                                 |
|---------------|----------------------------------------------------------------|-------------------------------------------------------------------------|
| Cognitive     | Too many decisions or concepts required simultaneously         | 12 configuration options with no defaults, all required before first run|
| Mechanical    | Too many physical steps (keystrokes, copy-pastes, file edits) | Manually editing 3 JSON files to add one integration                   |
| Informational | Unclear what to do next after completing a step               | "Installation complete." with no next step                             |
| Emotional     | Tone or output that causes anxiety, confusion, or distrust    | Stack traces as first output, wall of red text for minor warnings       |

### Detection Method
Walk through the primary use case as a new user. At each step, identify:
- How many decisions does the user have to make? (cognitive)
- How many physical actions are required? (mechanical)
- Is the next step clear from the current output? (informational)
- Does the output feel appropriate to the severity of what happened? (emotional)

---

## Progressive Disclosure Checklist

The primary task must be completable without reading advanced documentation.

- [ ] A new user can accomplish the main use case with only the README Quick Start section
- [ ] Default configuration values work for the most common scenario without editing
- [ ] Advanced features are listed in `--help` but not required to complete the primary task
- [ ] The docs have a clear separation: "Getting Started" (required) vs "Configuration Reference" (optional)
- [ ] Error messages do not require reading source code to understand
- [ ] Each level of documentation ends with a pointer to the next level ("For advanced usage, see X")
- [ ] Complexity is introduced one concept at a time, in the order the user will encounter it

Red flags:
- The README leads with architecture diagrams before showing a single command
- "Configuration" is the first section, before "Usage"
- Required flags have no defaults and no `init` to generate them
- Examples jump from "hello world" to a complex production setup with no intermediate steps

---

## Mental Model Alignment Test

The tool should speak the language of the user's domain, not the implementation's domain.

### Vocabulary Alignment
Ask: Does this command name match the verb the user would use to describe this action?

| User would say              | Tool should say    | Bad example        |
|-----------------------------|--------------------|--------------------|
| "create a project"          | `create`           | `initialize-graph` |
| "list my connections"       | `list`             | `enumerate-nodes`  |
| "delete this environment"   | `delete` / `remove`| `deprovision`      |
| "check the status"          | `status`           | `inspect-state`    |

### Behaviour Alignment
Does the command do what its name implies, with no side effects?
- `list` should never modify state
- `create` should never delete anything (including "replacing" existing resources silently)
- `update` should fail clearly when the target does not exist (not silently create)
- `dry-run` should never write to disk or make network calls that mutate state

### Abstraction Level
The user's mental model operates at the product level, not the infrastructure level.
- Wrong: "Wrote to DynamoDB table us-east-1.prod-config-v2"
- Right: "Saved configuration to production environment"

---

## Escape Hatch Inventory

Every well-designed tool provides recovery paths. Audit for the presence of these:

| Escape Hatch            | Description                                                         | Priority |
|-------------------------|---------------------------------------------------------------------|----------|
| `--dry-run`             | Shows what would happen without doing it                           | Critical for destructive ops |
| `--undo` / rollback     | Reverses the last operation (or explains how to manually reverse)  | Important for data-changing ops |
| `--help` at every level | Every subcommand supports `subcommand --help`                      | Required |
| Ctrl+C graceful handling| Interrupted operations clean up temp files; state is consistent    | Required |
| Confirmation prompts    | Destructive operations (delete, overwrite, reset) require `--yes` or interactive confirm |
| Backup before mutate    | Tools that modify config/data should backup first or state clearly they do not |
| `--force`               | Overrides safety guards when the user explicitly accepts the risk   | Documented with what risks are bypassed |

Audit: for each destructive operation in the tool, verify that at least `--dry-run` and a confirmation prompt are present, or that the operation is trivially reversible.

---

## Feedback Loop Quality Rubric

Users need to know: is something happening? did it work? what changed?

### During Long Operations
- Operations > 2 seconds: show a progress indicator (spinner, progress bar, or periodic status line)
- Operations > 10 seconds: show elapsed time or estimated time remaining
- Operations > 1 minute: show steps completed and steps remaining ("Step 2/5: Building...")
- Operations that can fail silently: emit periodic confirmation that work is in progress

| Rating    | Feedback During Long Ops                                              |
|-----------|-----------------------------------------------------------------------|
| Excellent | Progress bar with %, elapsed time, ETA, current step description     |
| Good      | Spinner + current step description                                    |
| Acceptable| Periodic dots or "still working..." every 5s                         |
| Poor      | Silent for the entire duration (user cannot distinguish hung vs running) |

### After Completion
- Always confirm the action completed: "Deployed 3 services in 12s"
- State what changed: counts, names, paths
- If nothing changed (idempotent run): say so explicitly: "Nothing to update — all resources up to date"
- Provide the next logical step when applicable

### On Failure
- Fail fast: do not run 10 steps before surfacing an error detectable at step 1
- On partial failure: clearly state what succeeded and what failed; do not conflate
- Provide recovery command inline when possible

---

## Workflow Step Analysis Template

Use this template to audit a specific workflow or user journey:

| Step | User Intent                     | Tool Action                          | Friction Type  | Severity       |
|------|---------------------------------|--------------------------------------|----------------|----------------|
| 1    | Install the tool                | `npm install -g tool`                | None           | —              |
| 2    | Configure credentials           | Manually edit ~/.tool/config.json    | Mechanical     | Medium         |
| 3    | Verify setup                    | `tool status` (no output on success) | Informational  | High           |
| 4    | Run primary command             | `tool run --env prod`                | None           | —              |
| 5    | Recover from error              | Stack trace, no guidance             | Emotional      | Critical       |

Severity definitions:
- **Critical:** blocks the user; they cannot proceed without help
- **High:** causes significant confusion or wasted time; many users will abandon
- **Medium:** annoying but manageable; experienced users work around it
- **Low:** minor roughness; does not affect completion rate

---

## Common Friction Anti-Patterns

- **Required global config before first use:** the tool refuses to run at all without editing a config file. Fix: provide defaults or an `init` command that generates a working config.

- **Magic invocation order:** commands must be run in a specific sequence that is not documented or enforced. Fix: document the order; better yet, enforce it with checks that emit clear guidance.

- **Undocumented required env vars:** the tool silently reads `TOOL_SECRET_KEY` but never mentions it in `--help` or the README. Fix: document all env vars; emit a clear error if a required one is missing.

- **Silent failures:** the command exits `0` but nothing was done. Fix: always emit confirmation of what was done; exit non-zero when the primary task was not completed.

- **Non-deterministic output:** running the same command twice produces different output for reasons outside the user's control. Fix: make output deterministic; if external state varies, say so explicitly.

- **Version-locked examples:** the README shows commands or APIs from an old version that no longer work. Fix: version-tag examples; automate testing of README examples in CI.

- **Asymmetric commands:** there is a `create` but no `delete`, an `add` but no `remove`. Fix: complete the CRUD surface for all resources the tool manages.

- **Config that requires knowing internals:** config keys are named after implementation details (`redis_connection_pool_max_idle_time_ms`). Fix: name config by user intent (`session_cache_timeout_seconds`).

- **Destructive defaults:** the default behaviour of a command deletes or overwrites. Fix: default to safe/read-only; require explicit opt-in for destructive actions.

- **Intimidating first-run output:** the first thing a new user sees is a wall of warnings, deprecation notices, or telemetry opt-in prompts. Fix: suppress non-critical noise on first run; show one clear "ready to use" message.
