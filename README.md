# Nuno Salvacao - Claude Code Plugins

[![Plugin Validation](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/actions/workflows/plugin-validation.yml/badge.svg)](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/actions/workflows/plugin-validation.yml)
[![Release](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/actions/workflows/release.yml/badge.svg)](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/actions/workflows/release.yml)
[![Plugins](https://img.shields.io/badge/plugins-5-blue)](#plugin-catalog)
[![License](https://img.shields.io/badge/license-MIT-black)](LICENSE)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/nsalvacao/nsalvacao-claude-code-plugins/badge)](https://scorecard.dev/viewer/?uri=github.com/nsalvacao/nsalvacao-claude-code-plugins)

Production-focused home for reusable **Claude Code plugins**.  
This repository is structured as a long-term plugin portfolio.  
`strategy-toolkit` is the first complete plugin and sets the baseline quality standard.

## Problem

Claude Code users often build useful commands, skills, and workflows in isolated projects.  
Without a shared repository structure, it is hard to:

- Keep plugin quality and documentation consistent
- Reuse patterns across multiple plugins
- Publish and maintain plugins with clear governance
- Scale from one plugin to a maintainable plugin ecosystem

## What This Repository Solves

This repository provides a single, organized source of truth for plugin development and publishing:

- A structured plugin catalog under `plugins/`
- A root marketplace manifest in `.claude-plugin/marketplace.json`
- Consistent contribution and quality standards
- Professional project governance for public collaboration

## Opportunity

By treating plugins as products (not one-off prompt files), this repository can evolve into:

- A trusted plugin collection for Claude Code users
- A repeatable development workflow for future plugins
- A public showcase of high-quality, strategic AI tooling

## Current Status

- First plugin completed: **`strategy-toolkit`**
- Repository prepared for GitHub publication and continuous growth
- Governance and contribution documentation in place

## Plugin Catalog

<!-- PLUGINS-TABLE-START -->
| Plugin | Version | Description | Category | Components |
|--------|---------|-------------|----------|------------|
| `strategy-toolkit` | 0.1.0 | Strategic ideation and execution planning toolkit with reproducible frameworks | productivity | 3 cmd, 1 skill |
| `repo-structure` | 0.1.0 | Enterprise-grade repository structure analyzer, validator, and scaffolder wit... | development | 4 cmd, 5 skill, 3 agent, hooks |
| `product-management` | 1.0.0 | Write feature specs, plan roadmaps, synthesise user research, and analyse com... | productivity | 6 cmd, 6 skill |
| `productivity` | 1.0.0 | Task management, workplace memory, and a visual dashboard. Claude learns your... | productivity | 2 cmd, 2 skill |
| `productivity-cockpit` | 1.0.0 | Task management, workplace memory, and an interactive cockpit dashboard with ... | productivity | 2 cmd, 3 skill |
<!-- PLUGINS-TABLE-END -->

## Repository Structure

```text
.
|- .claude-plugin/
|  |- marketplace.json
|- .github/
|  |- ISSUE_TEMPLATE/
|  |- workflows/
|  |- PULL_REQUEST_TEMPLATE.md
|- docs/
|  |- PLUGIN_GUIDELINES.md
|  |- RELEASE_CHECKLIST.md
|- plugins/
|  |- strategy-toolkit/
|     |- .claude-plugin/plugin.json
|     |- README.md
|     |- commands/
|     |- skills/
|- CHANGELOG.md
|- CODE_OF_CONDUCT.md
|- CONTRIBUTING.md
|- LICENSE
|- ROADMAP.md
|- SECURITY.md
|- SUPPORT.md
```

## Quick Start

### Prerequisites

- Claude Code CLI installed and configured
- Git installed

### Clone

```bash
git clone <your-github-repo-url>
cd nsalvacao-claude-code-plugins
```

### Install from Marketplace (Recommended)

Run these commands inside a Claude Code session:

```text
/plugin marketplace add nsalvacao/nsalvacao-claude-code-plugins
/plugin install strategy-toolkit@nsalvacao-claude-code-plugins
```

This follows the official plugin flow: add marketplace first, then install plugin.

### Local Development Mode (Alternative)

For local development/testing from this repository:

```bash
claude --plugin-dir "$(pwd)/plugins/strategy-toolkit"
```

If you use a local `cc` alias, the same `--plugin-dir` approach applies.

## Publishing Flow

Use `docs/RELEASE_CHECKLIST.md` before each public release.

For this repository bootstrap:

1. Create the remote repository on GitHub
2. Add remote locally: `git remote add origin <url>`
3. Push: `git push -u origin main`

## Quality and Governance

This repository follows professional open-source standards:

- Contribution process: `CONTRIBUTING.md`
- Security process: `SECURITY.md`
- Community behavior: `CODE_OF_CONDUCT.md`
- Version history: `CHANGELOG.md`
- Mid-term priorities: `ROADMAP.md`
- Plugin quality contract: `docs/PLUGIN_GUIDELINES.md`

## Contributing

Contributions are welcome for:

- New plugins
- Improvements to existing plugins
- Documentation and developer experience improvements

Please read `CONTRIBUTING.md` before opening a pull request.

## Security

To report vulnerabilities, follow `SECURITY.md`.

## License

This repository is licensed under the MIT License. See `LICENSE`.
