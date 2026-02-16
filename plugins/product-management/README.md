# Product Management Plugin

A Claude Code plugin for the full PM workflow: writing feature specs, managing roadmaps, communicating with stakeholders, synthesising user research, analysing competitors, and tracking product metrics. Works in any project type.

## Installation

```
claude plugins add nsalvacao/product-management
```

## What It Does

An AI-powered product management partner that helps with:

- **Feature Specs & PRDs** — Generate structured product requirements documents from a problem statement or feature idea. Includes user stories, requirements prioritisation, success metrics, and scope management.
- **Roadmap Planning** — Create, update, and reprioritise your product roadmap. Supports Now/Next/Later, quarterly themes, and OKR-aligned formats with dependency mapping.
- **Stakeholder Updates** — Generate status updates tailored to your audience (executives, engineering, customers). Pulls context from connected tools to save you the weekly update grind.
- **User Research Synthesis** — Turn interview notes, survey data, and support tickets into structured insights. Identifies themes, builds personas, and surfaces opportunity areas with supporting evidence.
- **Competitive Analysis** — Research competitors and generate briefs with feature comparisons, positioning analysis, and strategic implications.
- **Metrics Review** — Analyse product metrics, identify trends, compare against targets, and surface actionable insights.

## Commands

| Command | What It Does |
|---|---|
| `/write-spec` | Write a feature spec or PRD from a problem statement |
| `/roadmap-update` | Update, create, or reprioritise your roadmap |
| `/stakeholder-update` | Generate a stakeholder update (weekly, monthly, launch) |
| `/synthesize-research` | Synthesise user research from interviews, surveys, and tickets |
| `/competitive-brief` | Create a competitive analysis brief |
| `/metrics-review` | Review and analyse product metrics |

## Skills

| Skill | What It Covers |
|---|---|
| `feature-spec` | PRD structure, user stories, requirements categorisation, acceptance criteria |
| `roadmap-management` | Prioritisation frameworks (RICE, MoSCoW), roadmap formats, dependency mapping |
| `stakeholder-comms` | Update templates by audience, risk communication, decision documentation |
| `user-research-synthesis` | Thematic analysis, affinity mapping, persona development, opportunity sizing |
| `competitive-analysis` | Feature comparison matrices, positioning analysis, win/loss analysis |
| `metrics-tracking` | Product metrics hierarchy, goal setting (OKRs), dashboard design, review cadences |

## Example Workflows

### Writing a PRD

```
You: /write-spec
Claude: What feature or problem are you speccing out?
You: We need to add SSO support for enterprise customers
Claude: [Asks about target users, constraints, success metrics]
Claude: [Generates full PRD with problem statement, user stories, requirements, success metrics, open questions]
```

### Preparing a Stakeholder Update

```
You: /stakeholder-update
Claude: What type of update? (weekly, monthly, launch, ad-hoc)
You: Weekly update for the exec team
Claude: [Pulls context from connected MCP tools]
Claude: [Generates executive summary with progress, decisions, risks, and next milestones]
```

## MCP Integration

Connect your tools for the best experience. Without them, provide context manually — all commands work either way.

See [MCP-SETUP.md](MCP-SETUP.md) for setup instructions.

| Category | Examples | What it enables |
|----------|----------|----------------|
| Project tracker | Linear, Asana, Jira, ClickUp, monday.com | Roadmap sync, ticket context |
| Knowledge base | Notion, Confluence | Specs, research, meeting notes |
| Chat | Slack, Teams | Team context, message scanning |
| Design | Figma | Mockups, design context |
| Analytics | Amplitude, Pendo | Product metrics and usage data |
| User feedback | Intercom | Support tickets, feature requests |
| Meeting notes | Fireflies, Gong | Transcripts, action items |

## Configuration

Create `.claude/product-management.local.md` in your project root to set your connected tools:

```markdown
---
enabled: true
project_tracker: linear        # linear | jira | asana | clickup | monday | none
knowledge_base: notion         # notion | confluence | none
chat: slack                    # slack | teams | none
design: figma                  # figma | none
analytics: amplitude           # amplitude | pendo | none
feedback: none                 # intercom | canny | none
meeting_notes: none            # fireflies | gong | none
---

# Product Management Plugin — Project Settings

Connected tools for this project. Run `/mcp` in Claude Code to verify connections.
```

## Privacy Note

Add to your project's `.gitignore` to keep local settings private:

```gitignore
.claude/*.local.md
.claude/*.local.json
```
