# Import/Dependency Detection Patterns

Language-specific patterns for tracing import graphs and detecting boundary violations.

## JavaScript / TypeScript

### Import extraction
```bash
# ES modules
grep -rn "^import .* from " src/ --include="*.ts" --include="*.js" --include="*.tsx" --include="*.jsx"

# CommonJS
grep -rn "require(" src/ --include="*.js" --include="*.ts"

# Dynamic imports
grep -rn "import(" src/ --include="*.ts" --include="*.js"
```

### Module boundary detection
```bash
# Cross-module imports (assumes src/<module>/ structure)
# Find imports that reference ../other-module/
grep -rn 'from "\.\./\|from "\.\.\/' src/ --include="*.ts"

# Find imports crossing package boundaries in monorepos
grep -rn 'from "@[^/]*/\|from "packages/' src/ --include="*.ts"
```

### Circular dependency detection
```bash
# Use madge if available
npx madge --circular src/

# Manual: find mutual imports between directories
# If A imports from B and B imports from A = circular
```

## Python

### Import extraction
```bash
# Standard imports
grep -rn "^import \|^from " src/ --include="*.py"

# Relative imports (within package)
grep -rn "^from \." src/ --include="*.py"

# Conditional imports
grep -rn "try:.*import\|if.*import" src/ --include="*.py"
```

### Module boundary detection
```bash
# Cross-package imports (assumes src/<package>/ structure)
# Find imports from sibling packages
grep -rn "^from [a-z_]* import\|^import [a-z_]*" src/ --include="*.py"
```

## Go

### Import extraction
```bash
# Single imports
grep -rn '^import "' . --include="*.go"

# Grouped imports
grep -A 20 '^import (' . --include="*.go" | grep '"'
```

### Module boundary detection
```bash
# Internal package imports
grep -rn '"[^"]*internal/' . --include="*.go"

# Cross-module imports within the project
grep -rn '"github.com/org/project/' . --include="*.go"
```

## Rust

### Import extraction
```bash
# Use statements
grep -rn "^use " src/ --include="*.rs"

# Module declarations
grep -rn "^mod " src/ --include="*.rs"

# External crate usage
grep -rn "^extern crate" src/ --include="*.rs"
```

## Common Analysis Patterns

### Building a dependency matrix

For each source module (top-level directory):
1. List all files in the module
2. Extract all imports from those files
3. Classify each import as: internal (same module), cross-module, external (third-party)
4. Build matrix: rows = source modules, columns = target modules, cells = import count

### Detecting wrong-direction dependencies

Define expected layers (top = can import from bottom):
```
Presentation (CLI, UI, API handlers)
    ↓
Application (use cases, orchestration)
    ↓
Domain (core business logic, entities)
    ↓
Infrastructure (database, HTTP clients, filesystem)
```

Any import going upward (e.g., Domain importing from Presentation) is a boundary violation.

### Dead module detection

A module is potentially dead if:
1. No other module imports from it
2. It has no entry point (not in `main`, not in `bin`, not in a test runner config)
3. It is not referenced in any configuration file
