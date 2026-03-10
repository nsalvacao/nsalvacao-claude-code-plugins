# Onboarding Quality — Assessment Criteria

## Steps-to-First-Success Metric

Count discrete user actions required before the tool produces useful output on a fresh machine.
One step = one command, one file edit, one browser action, one account creation.

| Rating     | Step Count | Example                                          |
|------------|------------|--------------------------------------------------|
| Excellent  | ≤ 3        | install → configure → run (or even install → run)|
| Good       | ≤ 6        | install + 1-2 config steps + run                |
| Acceptable | ≤ 10       | typical multi-dependency CLI with env setup      |
| Poor       | > 10       | requires multiple accounts, keys, manual JSON    |

Scoring guidance: count only steps not common knowledge (e.g., `git clone` counts, `cd` does not).
Shell copy-paste blocks count as 1 step each regardless of line count.

---

## Cognitive Load Taxonomy

Measure how many new concepts a user must internalize before their first productive use.

| Rating    | New Concepts Required | Examples of what qualifies as "a concept"                  |
|-----------|-----------------------|------------------------------------------------------------|
| Excellent | ≤ 2                  | "project" + "run" — matches the user's existing vocabulary |
| Good      | ≤ 3                  | adds one domain-specific concept that is well-explained    |
| Acceptable| ≤ 5                  | several tool-specific terms, at least defined on first use |
| Poor      | > 5                  | unexplained jargon, internal naming, leaky abstractions    |

Detection patterns for excessive cognitive load:
- Glossary longer than 5 terms in the README
- Terms used before they are defined
- Concepts that reference implementation details instead of user-facing behaviour
- Configuration keys whose effect is not described in human language

---

## Prerequisite Clarity

### Stated Prerequisites
A good onboarding document lists all prerequisites explicitly before installation steps:
- Runtime version (e.g., Node ≥ 18, Python ≥ 3.11)
- OS constraints (e.g., Linux/macOS only, Windows requires WSL)
- Global tools (e.g., Docker, git ≥ 2.30, make)
- Required accounts (e.g., GitHub account, API key from service X)
- Permissions (e.g., sudo access, write to /usr/local/bin)

### Unstated Prerequisite Detection Patterns
Flag any of the following as an implicit prerequisite gap:
- Environment variables referenced in commands but not listed in prerequisites (e.g., `$GITHUB_TOKEN`)
- Commands that silently fail on unsupported OS versions
- Global tools invoked by scripts without version check or install guidance
- Accounts or API keys only discovered after a runtime error
- Network access requirements (proxies, firewall rules) not mentioned
- File system layout assumptions (e.g., relative paths that only work from a specific directory)

Audit method: run a fresh-machine simulation — trace every command and note each external dependency encountered.

---

## First-Run Experience

What should happen on the very first invocation with no prior configuration:

**Excellent:** Produces useful output or a guided setup prompt. Shows what the tool does.
**Good:** Clear error with actionable next step ("Run `tool init` to configure").
**Acceptable:** Fails with a specific error that is Googleable or points to docs.
**Poor:** Silently exits with code 0, cryptic error, or stack trace as first output.

Checklist for first-run quality:
- [ ] Does `tool --help` work before any config exists?
- [ ] Does `tool` (no args) show help or a default action, not an error?
- [ ] If config is missing, does the error name the missing config and where to create it?
- [ ] Is there a `tool init` or equivalent that sets up the minimum config interactively?
- [ ] Does the first meaningful command confirm what it did (success feedback)?

---

## Error Recovery

Document whether the top 5 most common setup failures have recovery paths in the docs.

| Failure Scenario                        | Expected: Documented Recovery Path                          |
|-----------------------------------------|-------------------------------------------------------------|
| Missing dependency (e.g., Node not found)| Install link + version requirement                         |
| Invalid or missing config file          | Example config + required fields listed                     |
| Auth failure (wrong API key, no token)  | Where to get the key + how to set it                        |
| Permission error                        | Exact command to fix (e.g., `chmod`, `sudo`, group add)     |
| Version mismatch                        | How to upgrade / manage multiple versions (nvm, pyenv, etc.)|

Audit: search the docs for each failure string. If no result, mark as undocumented.

---

## Progressive Disclosure

Principle: basics must be usable without reading advanced documentation.

Rubric:
- **Level 1 (Must work out of the box):** Install + one command = primary use case covered.
- **Level 2 (Discoverable):** Advanced flags and config appear in `--help` and a "Configuration" section, but are not required for Level 1.
- **Level 3 (Reference only):** Edge cases, integrations, internals — live in separate docs pages.

Red flags:
- The README reads as a feature list before explaining the primary use case
- Advanced configuration is required before any feature works
- Examples use advanced flags without showing the simpler form first
- No "Quick Start" or "Getting Started" section separated from full reference

---

## Time-to-First-Success Estimation

Formula: `T = (steps × avg_step_time) + (concepts × learning_time_per_concept) + (errors × avg_recovery_time)`

Baseline assumptions: avg step = 1 min, concept = 3 min, error recovery = 5 min.

Benchmarks by tool type:

| Tool Type       | Excellent | Good    | Acceptable | Poor     |
|-----------------|-----------|---------|------------|----------|
| CLI utility     | < 5 min   | < 10 min| < 20 min   | ≥ 20 min |
| Library/SDK     | < 15 min  | < 30 min| < 60 min   | ≥ 60 min |
| Service/SaaS    | < 30 min  | < 60 min| < 2 hours  | ≥ 2 hours|
| Platform/infra  | < 1 hour  | < 3 hours| < 1 day   | ≥ 1 day  |

Measurement method: time a junior developer (domain-knowledgeable but new to the tool) from cloning the repo to completing the primary use case described in the README.

---

## Common Onboarding Anti-Patterns

- **Wall of prerequisites:** Lists 10+ requirements before the first usable command. Fix: move to a dedicated "Prerequisites" section and provide a check script.
- **Multiple package managers:** Docs show npm, yarn, and pnpm interchangeably without guidance on which to use. Fix: commit to one; note alternatives in a collapsible section.
- **Manual JSON editing:** Onboarding requires editing config JSON by hand with no schema, no defaults, no validation. Fix: provide `init` command or a commented example file.
- **"See source for examples":** No runnable examples in the docs. Fix: every feature needs at least one copy-pasteable example.
- **Version drift:** Examples use API that no longer exists in the current version. Fix: pin examples to version + CI test against latest.
- **Assumed context:** Docs written for contributors, not new users — assume familiarity with the codebase. Fix: separate user docs from contributor docs.
- **Install-then-disappear:** README ends after installation with no "next step" or "basic usage" section.
- **Copy-paste traps:** Commands in docs that reference `<your-value>` placeholders with no explanation of what the value should be or where to find it.
