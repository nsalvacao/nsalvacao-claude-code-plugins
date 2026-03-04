---
name: Architecture Coherence
description: This skill should be used when the user asks to "audit architecture", "check architecture drift", "find module coupling", "detect boundary violations", "review code structure", "check dependency direction", or needs to verify that declared architecture matches actual code organization and dependencies.
version: 0.1.0
---

# Architecture Coherence Audit

Detect drift between a solution's declared or intended architecture and its actual code structure. Architecture drift is silent — it accumulates gradually and creates maintenance nightmares.

## Core Concept

Architecture coherence means module boundaries are respected, dependencies flow in the declared direction, responsibilities are correctly distributed, and abstractions serve real needs. Violations indicate structural debt.

## Audit Procedure

### 1. Discover Architecture Intent

Identify the intended architecture from available sources:

- **ARCHITECTURE.md** or design documents
- **ADRs** (Architecture Decision Records) in docs/adr/ or similar
- **Directory structure** — naming implies intended boundaries
- **Package/module organization** — top-level directories define domains
- **README** — architecture overview sections
- **Config files** — workspace/monorepo configuration implies structure

If no explicit architecture docs exist, infer intent from directory naming and package structure. Note this as a finding (missing architecture documentation).

### 2. Map Actual Module Boundaries

Analyze the codebase to understand real module relationships:

- List all top-level source directories and their purposes
- For each module/package, catalog its exports and entry points
- Identify shared utilities, common libraries, and cross-cutting concerns
- Map the directory tree depth — excessive nesting signals structural issues

### 3. Trace Import Graph

Build the actual dependency graph by analyzing imports:

- For each source file, extract import/require/include statements
- Map dependencies between modules (not files within the same module)
- Identify direction of dependencies (who depends on whom)
- Flag circular dependencies between modules

Use Grep with language-appropriate patterns:
- JavaScript/TypeScript: `import .* from`, `require\(`
- Python: `from .* import`, `import .*`
- Go: `import "`, `import \(`
- Rust: `use `, `mod `

### 4. Detect Boundary Violations

Compare actual imports against intended architecture:

- **Cross-boundary imports**: Module A imports internals of Module B (not its public API)
- **Wrong-direction dependencies**: Core/domain importing from UI/infrastructure
- **Layering violations**: Presentation layer directly accessing data layer
- **Shared state**: Modules communicating through global/shared mutable state instead of defined interfaces

### 5. Assess Coupling

Evaluate the degree of coupling between modules:

- **Afferent coupling** (Ca): How many modules depend on this one — high Ca = high responsibility
- **Efferent coupling** (Ce): How many modules this one depends on — high Ce = high fragility
- **Instability** (I = Ce/(Ca+Ce)): Ratio indicating change sensitivity
- **Tight coupling signals**: Modules that always change together, shared internal types, direct field access

Flag modules with unusually high coupling in either direction.

### 6. Check Responsibility Distribution

Verify modules do what their names suggest:

- Read each module's main files and compare against its name/declared purpose
- Flag modules that have grown beyond their original scope
- Identify "god modules" that handle too many concerns
- Find orphaned modules with no clear purpose or consumers
- Detect responsibility duplication (two modules doing similar things)

### 7. Evaluate Abstractions

Assess abstraction quality:

- **Premature abstractions**: Generic interfaces with only one implementation, over-engineered patterns for simple needs
- **Missing abstractions**: Repeated code patterns that should be unified, direct coupling where an interface would help
- **Leaky abstractions**: Implementation details exposed through interfaces, callers needing to know internals
- **Dead abstractions**: Interfaces or base classes no longer serving their purpose

### 8. Detect Structural Debt

Identify accumulated structural issues:

- **Dead code paths**: Modules, files, or functions with no callers
- **Config duplication**: Same configuration in multiple places (drift risk)
- **Orphaned tests**: Tests for removed code
- **Stale dependencies**: Package dependencies no longer used in code
- **Inconsistent patterns**: Similar problems solved differently across modules

## Finding Classification

| Severity | Criteria | Example |
|----------|----------|---------|
| Critical | Core boundary violation or circular dependency | Domain module importing from UI layer |
| Warning | Coupling issue or responsibility drift | Utility module growing into business logic |
| Info | Minor structural inconsistency | Slightly inconsistent naming between modules |

## Output Format

For each finding, report:
```
[SEVERITY] Category: Brief description
  Location: module-a → module-b (or file:line)
  Expected: Declared/intended relationship
  Actual: What the code shows
  Fix: Specific refactoring action
```

## Scoring

Start at 100, subtract per finding:
- Critical: -15 points
- Warning: -7 points
- Info: -2 points

Score reflects structural integrity of the codebase.

## Additional Resources

### Reference Files

- **`references/import-patterns.md`** — Language-specific import/dependency detection patterns
