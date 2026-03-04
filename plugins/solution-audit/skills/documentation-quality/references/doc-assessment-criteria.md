# Documentation Assessment Criteria

Detailed rubrics for evaluating documentation quality across different document types.

## README Assessment Rubric

### Structure (0-20 points)

| Criteria | Points | How to check |
|----------|--------|-------------|
| Project title and one-line description | 3 | First H1 + first paragraph |
| Problem statement / value proposition | 3 | Why this exists, what problem it solves |
| Installation instructions | 3 | Complete, copy-pasteable steps |
| Quick start / minimal example | 4 | Working example with visible output |
| Feature overview | 2 | What it does (not how it works) |
| Prerequisites listed | 2 | Runtime, tools, OS requirements |
| License reference | 1 | Badge or text reference |
| Link to deeper docs | 2 | Points to docs/ or wiki for more |

### Quality Indicators

**Good README signals:**
- First example appears within first scroll
- Install steps are 3 or fewer commands
- Examples show real output, not just input
- Links work and point to current versions
- Badges show live status (not decorative)

**Bad README signals:**
- Starts with badges before any text
- "Enterprise-grade", "blazingly fast" without evidence
- Installation requires reading 3 other docs first
- All examples are theoretical (no actual output shown)
- README longer than 500 lines without table of contents

## API Reference Assessment

### Completeness

For each public function/method/endpoint:
- Name and signature documented
- Parameters described with types
- Return value described with type
- At least one usage example
- Error conditions documented

### Accuracy

- Documented signatures match actual code
- Parameter names match between docs and code
- Default values documented match code defaults
- Documented types match actual types

### Checking patterns

```bash
# Find all exported functions (TypeScript)
grep -rn "^export function\|^export const\|^export class" src/ --include="*.ts"

# Cross-reference with docs
# For each exported symbol, search docs for its name
```

## Tutorial Assessment

### Structure criteria

| Criteria | Points | Description |
|----------|--------|-------------|
| Clear learning objective | 3 | What the reader will achieve |
| Prerequisites stated | 2 | What the reader needs to know/have |
| Step-by-step progression | 4 | Each step builds on the previous |
| Working code at each step | 3 | Reader can verify progress |
| Expected output shown | 3 | Reader knows if they got it right |
| Complete by end | 3 | Reader achieves the stated objective |
| No forward references | 2 | No "we'll explain this later" |

## Link Integrity Checking

### Internal links
```bash
# Find all markdown links
grep -rn '\[.*\](.*\.md\|#.*\|\.\./)' docs/ README.md --include="*.md"

# Verify each link target exists
# For relative paths: check file exists
# For anchors: check heading exists in target file
```

### External links
```bash
# Extract URLs
grep -oP 'https?://[^\s\)]+' README.md docs/**/*.md

# Check each URL (head request only)
# curl -sI "$url" | head -1
```

## Documentation Hierarchy Assessment

### Diataxis Framework

Good documentation covers four quadrants:

| Quadrant | Purpose | User need | Quality signal |
|----------|---------|-----------|---------------|
| Tutorials | Learning | "I want to learn" | Step-by-step, success guaranteed |
| How-to | Goals | "I want to do X" | Problem → solution, practical |
| Reference | Information | "I need to look up Y" | Complete, accurate, structured |
| Explanation | Understanding | "I want to understand why" | Context, reasoning, alternatives |

Check that the project has at least tutorials and reference coverage. Flag if all docs are one type.

## Freshness Detection

### Staleness indicators
```bash
# Version references that might be outdated
grep -rn "v[0-9]\+\.[0-9]\+\|version [0-9]" docs/ README.md --include="*.md"

# References to potentially renamed/removed files
# Extract all file references from docs and verify they exist
grep -oP '`[^`]*\.(py|ts|js|go|rs|sh|json|yaml|yml|toml)`' docs/ README.md --include="*.md"

# TODO/FIXME in docs
grep -rn "TODO\|FIXME\|TBD\|PLACEHOLDER\|WIP" docs/ README.md --include="*.md"
```

## Duplication Detection

### Common duplication patterns
- Same install instructions in README and GETTING_STARTED.md
- Same API description in README and API reference
- Same config examples in README and config reference
- Same troubleshooting in README and dedicated troubleshooting doc

Duplication creates drift risk: when one copy is updated, the other becomes stale.
