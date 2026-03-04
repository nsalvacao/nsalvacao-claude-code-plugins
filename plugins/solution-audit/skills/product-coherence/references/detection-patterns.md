# Detection Patterns by Project Type

Language and framework-specific patterns for detecting product coherence issues.

## Node.js / TypeScript

### Finding exports and entry points
```bash
# Package.json exports
grep -r '"exports"' package.json
grep -r '"main"' package.json
grep -r '"bin"' package.json

# Exported functions/classes
grep -rn "^export " src/ --include="*.ts" --include="*.js"
grep -rn "module.exports" src/ --include="*.js"
```

### Finding CLI command registrations
```bash
# Commander.js
grep -rn "\.command(" src/ --include="*.ts" --include="*.js"
# Yargs
grep -rn "\.command(" src/ --include="*.ts" --include="*.js"
# Oclif
grep -rn "static description" src/commands/ --include="*.ts"
```

### Finding documented features in README
```bash
# Feature lists (typically bulleted)
grep -n "^- \|^* \|^  - \|^  * " README.md
# Code examples
grep -n '```' README.md
# Command examples
grep -n '^\$\|^> ' README.md
```

## Python

### Finding exports and entry points
```bash
# Package entry points (setup.py/pyproject.toml)
grep -rn "entry_points\|console_scripts\|scripts" setup.py pyproject.toml
# __init__.py exports
grep -rn "^from \|^import \|__all__" src/*/__init__.py
# Click/Typer commands
grep -rn "@click.command\|@click.group\|@app.command" src/ --include="*.py"
```

### Finding argparse commands
```bash
grep -rn "add_parser\|add_argument\|add_subparsers" src/ --include="*.py"
```

## Go

### Finding exports and entry points
```bash
# Exported functions (capitalized)
grep -rn "^func [A-Z]" . --include="*.go"
# Cobra commands
grep -rn "cobra.Command{" . --include="*.go"
# Main entry points
grep -rn "func main()" . --include="*.go"
```

## General Patterns

### Cross-referencing README claims with code
1. Extract all feature names/verbs from README headers and bullet points
2. Search codebase for each feature name using multiple variants (singular, plural, kebab, camel, snake)
3. Mark as ghost if no implementing code found after 3+ search variants
4. Mark as invisible if code exists with no README mention

### Naming drift detection
```bash
# Extract terms from README
grep -oP '\b[A-Z][a-z]+(?:[A-Z][a-z]+)*\b' README.md | sort -u > readme-terms.txt

# Extract terms from code
grep -roh '\b[a-z_]+\b' src/ --include="*.py" --include="*.ts" --include="*.js" | sort -u > code-terms.txt

# Compare (manual review needed for semantic matches)
```
