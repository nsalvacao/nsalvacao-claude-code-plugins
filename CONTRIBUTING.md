# Contributing Guide

Thank you for your interest in contributing to this repository.

This project hosts a growing collection of production-grade Claude Code plugins.  
Please follow the standards below to keep quality high and maintenance predictable.

## Ways to Contribute

- Add a new plugin under `plugins/<plugin-name>/`
- Improve an existing plugin
- Improve repository documentation and templates
- Report bugs or suggest features

## Before You Start

1. Check existing issues and pull requests to avoid duplicate work.
2. Open an issue (or discussion) for non-trivial changes before implementation.
3. Keep pull requests focused on a single logical change.

## Development Principles

- Keep plugins self-contained and clearly documented.
- Prefer explicit, reproducible instructions.
- Keep command and skill descriptions actionable.
- Avoid hidden assumptions in prompts and workflows.
- Maintain backwards compatibility when possible.

## Branch and Commit Conventions

- Branch naming:
  - `feat/<short-topic>`
  - `fix/<short-topic>`
  - `docs/<short-topic>`
  - `chore/<short-topic>`
- Commit format (Conventional Commits):
  - `feat(scope): add plugin onboarding command`
  - `fix(strategy-toolkit): improve risk register guidance`
  - `docs(repo): update release checklist`

## Plugin Contribution Checklist

For each new plugin:

1. Create `plugins/<plugin-name>/`
2. Add plugin manifest: `plugins/<plugin-name>/.claude-plugin/plugin.json`
3. Add plugin README: `plugins/<plugin-name>/README.md`
4. Add at least one functional component (`commands/`, `skills/`, `agents/`, hooks, or MCP integration)
5. Update root marketplace manifest: `.claude-plugin/marketplace.json`
6. Validate JSON files (`jq` or equivalent)
7. Ensure docs are clear and in English

## Pull Request Requirements

Every pull request should include:

- Purpose and scope summary
- Linked issue (if applicable)
- Files changed and why
- Backward compatibility notes
- Test/validation notes (what was checked)

## Review Expectations

Reviews prioritize:

- Correctness and clarity
- Security and safety
- Documentation quality
- Long-term maintainability

## Code of Conduct

By participating in this project, you agree to follow `CODE_OF_CONDUCT.md`.
