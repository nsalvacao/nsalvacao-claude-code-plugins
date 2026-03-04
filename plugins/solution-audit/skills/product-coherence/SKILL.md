---
name: Product Coherence
description: This skill should be used when the user asks to "check if docs match code", "find ghost features", "audit product coherence", "detect naming drift", "find undocumented features", "check README accuracy", or needs to verify alignment between what a product promises and what it actually implements.
version: 0.1.0
---

# Product Coherence Audit

Detect misalignment between what a solution promises (README, docs, marketing, help text) and what actually exists in code. This is the most impactful audit dimension — it catches the gap between intention and reality.

## Core Concept

Product coherence means every documented feature exists, every implemented feature is discoverable, and naming is consistent across all touchpoints. Violations erode user trust and signal uncontrolled development.

## Audit Procedure

### 1. Inventory Documented Claims

Scan all user-facing documentation to build a feature inventory:

- **README.md**: Extract every feature, capability, and example claimed
- **docs/ directory**: Catalog documented APIs, commands, workflows
- **CLI --help output**: List all commands, flags, and described behaviors
- **CHANGELOG.md**: Note features claimed as shipped in each version
- **Package metadata**: Check description, keywords, and homepage claims

For each claim, record: source file, line number, and the specific promise made.

### 2. Cross-Reference Against Implementation

For each documented claim, verify it exists in code:

- **Entry points**: Check that documented commands/functions/endpoints exist
- **Exports**: Verify public API surface matches documentation
- **Behavior**: Confirm documented behavior matches actual implementation
- **Examples**: Test that documented examples produce expected results

Use Grep to search for function names, command handlers, route definitions, and exported symbols mentioned in documentation.

### 3. Detect Ghost Features

Ghost features are documented but not implemented. Common patterns:

- README lists a command that has no handler
- Docs describe an API endpoint with no route
- Help text mentions a flag that is not parsed
- CHANGELOG claims a feature shipped but code shows it was reverted or never merged

Classify each ghost feature:
- **Critical**: Core feature prominently advertised but absent
- **Warning**: Secondary feature mentioned but missing
- **Info**: Minor capability referenced but not yet built

### 4. Detect Invisible Features

Invisible features are implemented but not documented or discoverable:

- Scan all exported functions/commands/endpoints
- Compare against documentation inventory
- Check for useful utilities hidden in source with no docs
- Look for CLI commands registered but absent from --help
- Find configuration options parsed but never documented

### 5. Detect Naming Drift

Naming drift occurs when the same concept uses different names across touchpoints:

- Compare terminology in README vs code identifiers vs CLI output vs error messages
- Check for synonyms used inconsistently (e.g., "project" in docs, "workspace" in code, "repo" in CLI)
- Verify command names match their documentation references
- Check configuration key names match documented settings

Build a terminology map: concept → {docs name, code name, CLI name, UI name}. Flag any concept with more than one name.

### 6. Detect Promise Inflation

Promise inflation is when documentation overstates capabilities:

- README uses superlatives ("comprehensive", "complete", "full") for partial implementations
- Feature lists include planned features without marking them as upcoming
- Badges or status indicators suggest maturity beyond actual state
- Comparison tables claim advantages not supported by code

### 7. Check Version Alignment

Verify documentation references match current state:

- Docs referencing removed or renamed APIs
- Examples using deprecated syntax
- Version numbers in docs not matching package version
- Installation instructions pointing to old package names

## Finding Classification

| Severity | Criteria | Example |
|----------|----------|---------|
| Critical | Core feature gap visible to users | README documents main command that doesn't exist |
| Warning | Secondary feature or naming issue | Config option documented but not implemented |
| Info | Minor inconsistency | Slightly different terminology in one doc section |

## Output Format

For each finding, report:
```
[SEVERITY] Category: Brief description
  Source: file:line — "quoted claim"
  Reality: What actually exists (or doesn't)
  Fix: Specific action to resolve
```

## Scoring

Start at 100, subtract per finding:
- Critical: -15 points
- Warning: -7 points
- Info: -2 points

Score reflects the trust gap between promises and reality.

## Additional Resources

### Reference Files

- **`references/detection-patterns.md`** — Detailed grep/glob patterns for common project types (Node.js, Python, CLI tools, APIs)
