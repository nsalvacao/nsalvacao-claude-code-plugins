---
name: brainstorm
description: >
  Run structured strategic brainstorm on the current project using 8 frameworks.
  Produces a comprehensive expansion/ideation document saved to .ideas/brainstorm-expansion.md.
  Adaptively analyzes the project before applying frameworks.
---

# Strategic Brainstorm

Run a comprehensive strategic brainstorm for the current project. This command
produces a document with 8 frameworks applied adaptively to the project's context.

## Phase 1: Project Discovery (REQUIRED — do this first)

Before applying any framework, deeply understand the project:

1. **Read the README** (or main documentation) to understand what the project does
2. **Read core source files** — identify the main modules, data structures, schemas
3. **Check project maturity** — tests, CI, users, stars, version, age
4. **Identify the domain** — developer tool, platform, library, SaaS, standard, etc.

## Phase 2: Asset Identification

Based on what was read, answer these three questions:

1. **What is the code?** — The literal implementation
2. **What is the concept?** — The underlying idea the code proves
3. **What is the real moat?** — What makes this hard to replicate

Write these as the opening section: "What Is the REAL Asset?"

Common pattern: The real asset is NOT the code. It's the schema, the format, the
network effect, the community, or the proof that something is possible.

## Phase 3: Apply Frameworks (All 8, in order)

Apply each framework from `references/frameworks.md`. For each:

### 3.1 — SCAMPER Analysis
Apply all 7 lenses (Substitute, Combine, Adapt, Modify/Magnify, Put to other uses,
Eliminate, Reverse) with tables. Minimum 3-5 ideas per lens.

### 3.2 — Divergent Ideation
Generate 20+ wild ideas. Mix timeframes (weeks to years) and scales (feature to
ecosystem). Include at least 5 that feel impossible today.

### 3.3 — Convergent Tier Ranking
Filter divergent ideas into Tier S (transformative), A (high impact), B (strong).
For each S/A idea: What, Why huge, Path, Comparable, Risk, Effort.

### 3.4 — Blue Ocean Strategy
Map the Red Ocean (existing solutions table), identify the Blue Ocean (unique value),
create strategic canvas, write positioning statement.

### 3.5 — TAM/SAM/SOM Market Sizing
Estimate addressable market by user segment. Use public data where possible.
Include realistic 18-month obtainable market.

### 3.6 — Jobs-to-be-Done
For 3-4 user personas: functional, emotional, and social jobs.
Format: "When I am [context], I want to [action] so I can [outcome]."

### 3.7 — Flywheel Mapping
Identify the core virtuous cycle. Draw it as ASCII art.
Find the push point and the friction points.

### 3.8 — One-Line Pitches
Write 4-5 pitches for different audiences:
- For developers, For enterprises, For AI companies, For investors, For CLI/tool authors

## Phase 4: Save Output

1. Create `.ideas/` directory in the project root if it doesn't exist
2. Check if `.ideas/` is in `.gitignore` — add it if not
3. Save the complete document to `.ideas/brainstorm-expansion.md`

## Output Structure (follow this exactly)

```markdown
# [Project Name] — Strategic Brainstorm

**Date:** [today]
**Objective:** [one line about the strategic goal]

---

## 1. What Is the REAL Asset?
[Asset identification — 3 points + key insight]

## 2. SCAMPER Analysis
### S — Substitute
[table]
### C — Combine
[table]
### A — Adapt
[bullets]
### M — Modify / Magnify
[table]
### P — Put to Other Uses
[numbered list]
### E — Eliminate
[table]
### R — Reverse / Rearrange
[bullets]

## 3. Divergent Ideation — 20 Wild Ideas
[numbered list 1-20+]

## 4. Convergent Analysis — Tier Ranking
### Tier S — Transformative (100k+ potential)
#### S1: [idea name]
[detailed analysis]
### Tier A — High Impact (10k-50k potential)
#### A1: [idea name]
[detailed analysis]
### Tier B — Strong (1k-10k potential)
[brief bullets]

## 5. Blue Ocean Strategy
### Current Market (Red Ocean)
[table of competitors]
### Blue Ocean Opportunity
[unique value + strategic canvas + positioning]

## 6. TAM/SAM/SOM
[market sizing table + key insight]

## 7. Jobs-to-be-Done
[persona tables]

## 8. Flywheel
[ASCII diagram + push point + friction]

## 9. One-Line Pitches
[5 pitches for different audiences]

## 10. Honest Weaknesses & Risks
[table: weakness, severity, probability — minimum 5 items]

## 11. Monday Morning Actions
[5 highest-leverage actions to take this week, ordered by impact]
```

## Quality Criteria

The output document MUST have:
- [ ] 350+ lines minimum
- [ ] 20+ divergent ideas
- [ ] 3+ Tier S/A ideas with detailed analysis (What, Why, Path, Comparable, Risk)
- [ ] Honest competitive analysis — no cheerleading, include real weaknesses
- [ ] At least 2 contrarian observations embedded throughout
- [ ] TAM/SAM/SOM with specific numbers (estimates are fine, but be specific)
- [ ] Flywheel with ASCII diagram
- [ ] Pitches that are genuinely different per audience (not just rephrased)
- [ ] Honest weaknesses section with 5+ risks (severity + probability)
- [ ] Monday morning actions — 5 highest-leverage next steps

## Important Notes

- Be HONEST. Include uncomfortable truths about the project's limitations.
- Think like someone who would FORK this project and make it 10x bigger.
- The best ideas often feel wrong or too ambitious at first. Include them.
- This is a private document (.ideas/ is gitignored). Be candid.
