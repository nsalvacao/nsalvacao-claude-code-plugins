---
name: Documentation Quality
description: This skill should be used when the user asks to "audit documentation", "check doc quality", "find broken links", "review README", "check if docs are up to date", "assess documentation structure", or needs to evaluate whether documentation is accurate, useful, and well-organized beyond mere existence.
version: 0.1.0
---

# Documentation Quality Audit

Assess documentation quality beyond existence checks — evaluate whether docs are useful, accurate, structured, and maintained. Bad documentation is worse than no documentation because it creates false confidence.

## Core Concept

Documentation quality measures how well docs serve their purpose: helping users accomplish real tasks. A beautiful README that misleads is worse than a sparse one that is accurate. This audit focuses on utility, accuracy, and structure.

## Audit Procedure

### 1. Classify Documentation Assets

Inventory all documentation and classify by type:

- **Tutorials**: Step-by-step learning experiences (learn by doing)
- **How-to guides**: Problem-oriented recipes (accomplish a specific task)
- **Reference**: Technical descriptions (API docs, CLI reference, config reference)
- **Explanation**: Conceptual understanding (architecture, design decisions, rationale)

Map each doc file to its type. Flag docs that mix types (a common quality issue — a tutorial that becomes a reference mid-way).

### 2. Assess README Utility

The README is the front door. Evaluate:

- **First impression**: Does a reader understand what this is within 10 seconds?
- **Value proposition**: Is the problem being solved clearly stated?
- **Installation**: Are steps complete, copy-pasteable, and correct?
- **Quick example**: Is there a minimal working example that produces visible output?
- **Next steps**: Does it guide to deeper docs after the quick example?

Flag README anti-patterns:
- Marketing fluff without substance ("blazingly fast", "enterprise-grade")
- Badge overload (10+ badges before any content)
- Wall of text without structure
- Missing installation or quick start
- Examples that require unreasonable setup to try

### 3. Verify Doc-to-Code Alignment

Check that documentation matches current code:

- **API references**: Documented functions/methods match actual exports
- **Configuration**: Documented options match parsed config fields
- **CLI commands**: Documented commands match registered handlers
- **Return values**: Documented types match actual types
- **Default values**: Documented defaults match code defaults

Use Grep to cross-reference documented identifiers against source code.

### 4. Check Link Integrity

Verify all links in documentation:

- **Internal links**: Relative paths to other docs resolve correctly
- **Anchor links**: Section references (#section-name) exist in target
- **External links**: URLs to external resources (check existence with Bash curl -sI)
- **Image links**: Referenced images exist at specified paths
- **Code references**: Links to source files point to existing files

### 5. Validate Examples

Check that documented examples work:

- **Code snippets**: Syntax is valid for the target language
- **Command examples**: Commands use current CLI syntax and flags
- **Output examples**: Shown output matches what the code actually produces
- **Import statements**: Referenced modules/packages exist
- **Configuration examples**: Config files use valid keys and values

### 6. Assess Documentation Hierarchy

Evaluate the structural organization:

- **Logical ordering**: Docs progress from simple to complex
- **Navigation**: Easy to find specific information
- **Cross-references**: Related docs link to each other
- **No dead ends**: Every doc leads somewhere useful
- **Index/TOC**: Table of contents exists for doc collections
- **Consistent formatting**: Same style across all docs

### 7. Detect Documentation Debt

Identify maintenance issues:

- **Duplication**: Same information in multiple files (drift risk)
- **Staleness markers**: References to removed features, old versions, or deprecated APIs
- **TODO/FIXME in docs**: Unresolved documentation tasks
- **Placeholder content**: Lorem ipsum, "TBD", empty sections
- **Orphaned docs**: Files not linked from anywhere

### 8. Evaluate Writing Quality

Assess the effectiveness of documentation prose:

- **Clarity**: Sentences are direct and unambiguous
- **Conciseness**: No unnecessary words or repetition
- **Scannability**: Headers, lists, and code blocks break up text
- **Consistency**: Same terminology throughout
- **Actionability**: Reader knows what to do after reading

## Finding Classification

| Severity | Criteria | Example |
|----------|----------|---------|
| Critical | Docs actively mislead or block users | Install instructions that fail, wrong API signatures |
| Warning | Docs are incomplete or stale | Missing sections, outdated examples |
| Info | Minor quality or style issues | Inconsistent formatting, minor typos |

## Output Format

For each finding, report:
```
[SEVERITY] Category: Brief description
  File: path/to/doc.md:line
  Issue: What is wrong
  Impact: How this affects users
  Fix: Specific action to resolve
```

## Scoring

Start at 100, subtract per finding:
- Critical: -15 points
- Warning: -7 points
- Info: -2 points

Score reflects how much users can trust and rely on the documentation.

## Additional Resources

### Reference Files

- **`references/doc-assessment-criteria.md`** — Detailed rubrics for each documentation type
