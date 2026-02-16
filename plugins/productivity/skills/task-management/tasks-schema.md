# TASKS.md Schema Reference

Schema specification for the Productivity Dashboard task board. Any `.md` file following this format is fully parsed by `dashboard.html`.

## File Structure

```markdown
# Tasks

## Section Name

- [ ] **Task title** - optional note or context
  - [ ] Subtask text
  - [x] Completed subtask

## Another Section

- [x] **Completed task** - note (2026-02-14)
```

## Rules

### Sections (columns)

| Element | Format | Required |
|---------|--------|----------|
| File title | `# Title` (H1) | Optional, ignored by parser |
| Section header | `## Section Name` (H2) | At least one required |
| Section ID | Auto-generated: lowercase, non-alphanumeric → `-` | Automatic |

- Each `## Section` becomes a **board column** in the dashboard
- Section names can be anything (status-based, phase-based, category-based)
- `### H3` headers are ignored — tasks under them stay in the parent `##` section
- Non-task lines (plain text, notes, code blocks) are ignored by the parser

### Tasks (cards)

| Element | Format | Example |
|---------|--------|---------|
| Unchecked task | `- [ ] **Title** - note` | `- [ ] **Fix login bug** - reported by user #42` |
| Checked task | `- [x] **Title** - note` | `- [x] **Add auth** - JWT with refresh tokens` |
| No bold title | `- [ ] Plain text` | Works, but entire text becomes the title |
| No note | `- [ ] **Title**` | Valid, note will be empty |

**Bold extraction regex:** `^\*\*(.+?)\*\*(.*)$`
- First `**...**` at the start of text → `title`
- Everything after → `note` (leading ` - ` stripped)
- If no bold found: entire text = `title`, no `note`

### Subtasks

| Element | Format |
|---------|--------|
| Unchecked subtask | `  - [ ] Subtask text` (2-space indent) |
| Checked subtask | `  - [x] Subtask text` |

- Must be indented (2+ spaces before `- [`)
- Belong to the immediately preceding task
- No bold extraction — entire text is the subtask label

## Internal Data Model

```javascript
// Section
{ id: "section-id", name: "Section Name" }

// Task
{
  id: Number,          // auto-generated (Date.now + random)
  title: String,       // bold text or full line
  note: String,        // text after bold, or empty
  checked: Boolean,    // [x] = true, [ ] = false
  subtasks: [          // indented child checkboxes
    { text: String, checked: Boolean }
  ],
  section: String      // parent section ID
}
```

## Serialization (toMarkdown)

When the dashboard saves back to file:

```markdown
# Tasks

## Section Name
- [ ] **Title** - note
  - [ ] Subtask text
  - [x] Completed subtask
```

- Always writes `# Tasks` as the H1
- Bold titles are always wrapped in `**`
- Notes prefixed with ` - `
- Subtasks indented with 2 spaces
- Trailing newline at end of file

## Examples

### Status-based (generic productivity)

```markdown
# Tasks

## Active

- [ ] **Review budget proposal** - for Sarah, due Friday
  - [ ] Check Q2 projections
  - [ ] Validate headcount numbers
- [ ] **Draft Q2 roadmap** - sync with Greg first

## Waiting On

- [ ] **API spec review** - sent to Platform team, since 2026-02-10

## Someday

- [ ] **Automate monthly report** - low priority

## Done

- [x] **Setup CI pipeline** - GitHub Actions (2026-02-12)
```

### Phase-based (engineering project)

```markdown
# Tasks

## Phase 1: Setup

- [x] **T001 Create project directories** - src/crawler, src/generator, src/lib
- [x] **T002 Initialize pyproject.toml** - Python 3.11+, zero deps

## Phase 2: Core Implementation

- [x] **T006 Define schema** - CLIMap, Command, Flag entities
- [ ] **T017 Integration test** - docker CLI end-to-end

## Phase 3: Polish

- [ ] **T030 Add observability** - structured logging, per-stage metrics
- [ ] **T037 Update README** - demo GIF, comparison table
```

### Category-based (mixed workload)

```markdown
# Tasks

## Bugs

- [ ] **Login timeout on mobile** - reproduced on iOS 17, #issue-234
- [x] **CSV export encoding** - was UTF-16, now UTF-8

## Features

- [ ] **Dark mode support** - design tokens ready, needs implementation

## Ops

- [ ] **Upgrade Node to v22** - breaking change in ESM loader
```

## Dashboard Behavior

- **File access**: Uses browser File System Access API (`showOpenFilePicker`)
- **Auto-save**: Changes saved to the original file on edit
- **File watching**: Detects external changes and reloads
- **Drag-and-drop**: Cards can be moved between sections; sections can be reordered
- **Views**: Board (kanban columns) and List (flat checklist)
- **No server**: Runs entirely in-browser, zero backend
