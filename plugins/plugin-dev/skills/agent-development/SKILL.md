---
name: agent-development
description: Reference guide for Claude Code subagent frontmatter, agent file structure, description/examples, tool and color fields, and plugin compatibility rules. Use this skill when the user wants agent frontmatter reference, agent field reference, agent file format, agent YAML format, how to write an agent description, what fields an agent needs, or help understanding agent structure without creating or benchmarking a new agent.
version: 0.2.0
---

# Agent Development Reference

Use this skill as a reference manual for Claude Code subagent files. It explains the on-disk format, frontmatter fields, description patterns, and validation workflow.

This skill follows the current repository policy and validation workflow for agent files:
- `name`, `description`, `model`, and `color` are required in this repository
- `model` should usually be set to `inherit` unless the agent needs a specific model
- `color` must use a supported value required by the repo validator
- examples use the official comma-separated `tools` format

## Agent File Structure

### Complete Format

```markdown
---
name: code-reviewer
description: >
  Use this agent when the user wants a focused code review, security review,
  or implementation risk analysis for a concrete change. Include both
  positive and near-miss examples.
model: inherit
color: blue
tools: Read, Grep, Glob
memory: false
---

You are a code review specialist.

**Your Core Responsibilities:**
1. Review changed code for correctness, maintainability, and safety.
2. Highlight the highest-severity findings first.
3. Return actionable fixes with file references when possible.

**Review Process:**
1. Read the relevant files and diffs.
2. Identify behavioral regressions, security issues, and missing tests.
3. Prioritize findings by severity.
4. Return a concise review.

**Output Format:**
- Summary
- Findings
- Residual risks

**Edge Cases:**
- If no risky changes are found, say so explicitly.
- If context is missing, state what is missing instead of guessing.
```

### Minimal Valid Agent

```markdown
---
name: simple-agent
description: >
  Use this agent when the user needs the specific workflow described below.
  Examples:

  <example>
  Context: User wants a narrow transformation.
  user: "Please normalize this changelog entry."
  assistant: "I'll use the simple-agent agent to normalize the entry."
  <commentary>
  The request clearly matches the agent's narrow remit.
  </commentary>
  </example>
---

You are a focused transformation agent.

Return the transformed result and a short note about any ambiguity.
```

## Core Frontmatter Fields

### name (required)

Agent identifier used for namespacing and invocation.

- Format: lowercase letters, numbers, hyphens
- Length: 3-50 characters
- Pattern: must start and end with an alphanumeric character

Good examples:
- `code-reviewer`
- `test-generator`
- `api-docs-writer`

Bad examples:
- `my_agent`
- `-reviewer-`
- `Ag`

### description (required)

Defines when Claude should trigger the agent. This is the most important routing field.

Best practice checklist:
- Start with `Use this agent when...`
- Include 2-4 `<example>` blocks
- Cover both should-trigger and should-not-trigger or near-miss scenarios
- Focus on user intent, not implementation trivia
- Make the agent distinct from adjacent agents

Recommended structure:

```text
Use this agent when [clear triggering conditions]. Examples:

<example>
Context: [situation]
user: "[user request]"
assistant: "[what Claude should say before delegation]"
<commentary>
[why this agent should trigger]
</commentary>
</example>
```

### model (required)

Which model the agent should use when it runs.

- Allowed values: `inherit`, `sonnet`, `opus`, `haiku`

Use `inherit` unless the agent genuinely needs a model override.

### color (required)

Visual identifier for the agent in the UI.

- Allowed values: `blue`, `cyan`, `green`, `yellow`, `magenta`, `red`

Practical guidance:
- `blue`, `cyan`: analysis, review, diagnostics
- `green`: generation, docs, happy-path builders
- `yellow`: validation, caution, scoring
- `red`: security, critical controls
- `magenta`: orchestration, transformation, creative workflows

### tools (optional)

Restrict the agent to a smaller tool set.

- Official example format: comma-separated values
- Default when omitted: agent inherits broad tool availability

Examples:

```yaml
tools: Read, Grep, Glob
tools: Read, Write, Grep
```

The JSON-array YAML form works technically, but this skill standardizes on the official comma-separated style for examples and templates.

## Additional Frontmatter Fields

The official Claude Code subagent format supports more than the five commonly used fields above.

| Field | Type | Default | Purpose | Plugin Notes |
|---|---|---|---|---|
| `disallowedTools` | string/list | none | Explicit deny-list for tools | Supported |
| `permissionMode` | string | session default | Override approval mode | Plugin agents do not support this |
| `maxTurns` | integer | session default | Limit session turns for the agent | Supported |
| `skills` | string/list | none | Load extra skills for the agent | Supported |
| `mcpServers` | string/list | none | Restrict MCP servers | Plugin agents do not support this |
| `hooks` | object/list | none | Attach hook behavior | Plugin agents do not support this |
| `memory` | boolean/string | session default | Persist or disable memory behavior | Supported |
| `background` | boolean | false | Allow background execution | Supported when the runtime supports it |
| `effort` | string | session default | Override reasoning effort | Supported |
| `isolation` | string | session default | Adjust isolation mode | Supported when available in runtime |
| `initialPrompt` | string | none | Seed additional task-specific instructions | Supported |

For plugin-distributed agents, assume `hooks`, `mcpServers`, and `permissionMode` are unavailable unless the platform explicitly documents support.

## System Prompt Design

The markdown body becomes the agent's system prompt. Write it in second person and keep it specific.

Recommended structure:

```markdown
You are [role] specializing in [domain].

**Your Core Responsibilities:**
1. [primary responsibility]
2. [secondary responsibility]

**Process:**
1. [step one]
2. [step two]

**Output Format:**
- [required section 1]
- [required section 2]

**Edge Cases:**
- [edge case]: [fallback behaviour]
```

Guidance:
- Prefer focused prompts over long generic prompts
- Define output structure explicitly
- Include failure handling or fallback behavior
- Document scope boundaries and what the agent should not do
- Very long prompts above roughly 8,000 tokens may cause registration issues, so prefer concise, high-signal instructions

See `references/system-prompt-design.md` for fuller patterns.

## Testing Agents

### Trigger Testing

Use `scripts/test-agent-trigger.sh` to run empirical trigger checks.

Recommended workflow:
1. Build a phrases file with positive and negative cases
2. Prefix positive cases with `+` and a space, and negative cases with `-` and a space
3. Run `./scripts/test-agent-trigger.sh <path-to-agent.md> phrases.txt`
4. Review pass/fail results and tighten the description when near-miss cases trigger incorrectly

The script prefers native `claude` routing when available. If native routing is unavailable or blocked by rate limits, configure `AGENT_TRIGGER_LLM_COMMAND` or `LLM_RUNNER_COMMAND` for semantic fallback evaluation.

Fallback runs use semantic routing evaluation rather than native Claude delegation, so treat them as resilient approximation rather than perfect equivalence.

### Structural Validation

Validate agent structure before testing routing:

```bash
./scripts/validate-agent.sh <path-to-agent.md>
```

The validator:
- parses multiline YAML descriptions correctly
- treats `model` and `color` as optional
- warns about broad tool access
- flags missing examples, output format, and fallback guidance

## Quick Reference

### Frontmatter Summary

| Field | Required | Default | Example |
|---|---|---|---|
| `name` | Yes | none | `code-reviewer` |
| `description` | Yes | none | `Use this agent when...` |
| `model` | No | `inherit` | `claude-sonnet-4-6` |
| `color` | No | none | `blue` |
| `tools` | No | broad access | `Read, Grep` |

### Practical Do / Don't

Do:
- include multiple concrete examples
- show where the agent should not trigger
- keep tool access narrow
- define output shape explicitly

Don't:
- overlap heavily with action-oriented creation/evaluation skills
- treat `model` or `color` as required
- rely on vague descriptions without examples
- leave fallback behaviour unspecified in the prompt

## Additional Resources

- `references/system-prompt-design.md` - system prompt patterns and prompt-writing guidance
- `references/agent-creation-system-prompt.md` - AI-assisted creation prompt extracted from Claude Code
- `references/agent-reference.md` - consolidated triggering patterns, description examples, full templates, and creation prompt examples
- `scripts/validate-agent.sh` - structural and quality validation
- `scripts/test-agent-trigger.sh` - empirical trigger testing with ordered CLI fallback

## Implementation Workflow

When helping someone author or review an agent:
1. Confirm the agent's remit is distinct from adjacent agents
2. Draft `name` and `description` first
3. Set required `model` and `color`; add optional `tools` when justified
4. Write the system prompt with responsibilities, process, output format, and fallback behavior
5. Validate structure with `scripts/validate-agent.sh`
6. Test positive and negative trigger cases with `scripts/test-agent-trigger.sh`
7. Iterate until routing and output shape are both stable
