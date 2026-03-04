# Plugins Directory

This directory contains all Claude Code plugins maintained in this repository.

## Current Plugins

- `plugin-studio` - Visual dashboard for creating and managing Claude Code plugins
- `product-management` - Full PM workflow: specs, roadmaps, user research, competitive analysis
- `productivity` - Task management, workplace memory, and visual dashboard
- `productivity-cockpit` - Task management, memory, and interactive cockpit dashboard with AI chatbot
- `repo-structure` - Enterprise-grade repository structure analyzer, validator, and scaffolder
- `solution-audit` - Continuous meta-quality audit across 7 development dimensions
- `strategy-toolkit` - Strategic ideation and execution planning toolkit

## Add a New Plugin

1. Create `plugins/<plugin-name>/`
2. Add required manifest at `plugins/<plugin-name>/.claude-plugin/plugin.json`
3. Add `plugins/<plugin-name>/README.md`
4. Register the plugin in `.claude-plugin/marketplace.json`

See `docs/PLUGIN_GUIDELINES.md` for full requirements.
