---
description: Initialize the productivity system and open the dashboard
---

# Start Command

> For optional MCP integrations (project trackers, chat, email), see [MCP-SETUP.md](../MCP-SETUP.md).

Initialize the task and memory systems, then open the unified dashboard.

## Instructions

### 1. Check What Exists

Check the working directory for:
- `TASKS.md` — task list
- `CLAUDE.md` — working memory
- `memory/` — deep memory directory
- `.cockpit.json` — cockpit configuration

### 2. Create What's Missing (Check First)

Before creating anything, check if files already exist. Only create what's actually missing — the user may already have these from a previous session or another plugin.

**If `TASKS.md` doesn't exist:** Ask the user before creating. Then use the standard template (see task-management skill). Place it in the current working directory.

**If `CLAUDE.md` and `memory/` don't exist:** This is a fresh setup — after launching the cockpit, begin the memory bootstrap workflow (see below). Place these in the current working directory.

**If `.cockpit.json` doesn't exist:** Copy the default config from `${CLAUDE_PLUGIN_ROOT}/skills/cockpit/.cockpit.json` to the project root. The user can customise paths and AI settings later.

### 3. Open the Dashboard

Launch the cockpit bridge server and open the dashboard:

1. Start the bridge: `python3 ${CLAUDE_PLUGIN_ROOT}/skills/cockpit/bridge.py &`
2. Open the dashboard in the browser:
   - **macOS:** `open http://localhost:8001`
   - **Linux:** `xdg-open http://localhost:8001`
   - **Windows/WSL:** `powershell.exe -c "start http://localhost:8001"` or `wslview http://localhost:8001`

If the bridge is already running or the open command fails, tell the user: "Cockpit is ready at http://localhost:8001. Open it in your browser."

### 4. Orient the User

If everything was already initialized:
```
Dashboard open. Your tasks and memory are both loaded.
- /productivity:update to sync tasks and check memory
- /productivity:update --comprehensive for a deep scan of all activity
```

If memory hasn't been bootstrapped yet, continue to step 5.

### 5. Bootstrap Memory (First Run Only)

Only do this if `CLAUDE.md` and `memory/` don't exist yet.

The best source of workplace language is the user's actual task list. Real tasks = real shorthand.

**Ask the user:**
```
Where do you keep your todos or task list? This could be:
- A local file (e.g., TASKS.md, todo.txt)
- An app (e.g. Asana, Linear, Jira, Notion, Todoist)
- A notes file

I'll use your tasks to learn your workplace shorthand.
```

**Once you have access to the task list:**

For each task item, analyze it for potential shorthand:
- Names that might be nicknames
- Acronyms or abbreviations
- Project references or codenames
- Internal terms or jargon

**For each item, decode it interactively:**

```
Task: "Send PSR to Todd re: Phoenix blockers"

I see some terms I want to make sure I understand:

1. **PSR** - What does this stand for?
2. **Todd** - Who is Todd? (full name, role)
3. **Phoenix** - Is this a project codename? What's it about?
```

Continue through each task, asking only about terms you haven't already decoded.

### 6. Optional Comprehensive Scan

After task list decoding, offer:
```
Do you want me to do a comprehensive scan of your messages, emails, and documents?
This takes longer but builds much richer context about the people, projects, and terms in your work.

Or we can stick with what we have and add context later.
```

**If they choose comprehensive scan:**

Gather data from available MCP sources:
- **Chat:** Recent messages, channels, DMs
- **Email:** Sent messages, recipients
- **Documents:** Recent docs, collaborators
- **Calendar:** Meetings, attendees

Build a braindump of people, projects, and terms found. Present findings grouped by confidence:
- **Ready to add** (high confidence) — offer to add directly
- **Needs clarification** — ask the user
- **Low frequency / unclear** — note for later

### 7. Write Memory Files

From everything gathered, create:

**CLAUDE.md** (working memory, ~50-80 lines):
```markdown
# Memory

## Me
[Name], [Role] on [Team].

## People
| Who | Role |
|-----|------|
| **[Nickname]** | [Full Name], [role] |

## Terms
| Term | Meaning |
|------|---------|
| [acronym] | [expansion] |

## Projects
| Name | What |
|------|------|
| **[Codename]** | [description] |

## Preferences
- [preferences discovered]
```

**memory/** directory:
- `memory/glossary.md` — full decoder ring (acronyms, terms, nicknames, codenames)
- `memory/people/{name}.md` — individual profiles
- `memory/projects/{name}.md` — project details
- `memory/context/company.md` — teams, tools, processes

### 8. Report Results

```
Productivity system ready:
- Tasks: TASKS.md (X items)
- Memory: X people, X terms, X projects
- Dashboard: open in browser

Use /productivity:update to keep things current (add --comprehensive for a deep scan).
```

## Notes

- If memory is already initialized, this just opens the dashboard
- Nicknames are critical — always capture how people are actually referred to
- If a source isn't available, skip it and note the gap
- Memory grows organically through natural conversation after bootstrap
