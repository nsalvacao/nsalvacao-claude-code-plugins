# Release Checklist

Use this checklist before publishing changes to GitHub or updating plugin distribution.

## 1. Repository Readiness

- [ ] `git status` is clean or intentionally scoped
- [ ] Required governance docs are present
- [ ] `README.md` reflects current plugin catalog
- [ ] `CHANGELOG.md` updated
- [ ] `ROADMAP.md` reviewed (if priorities changed)

## 2. Plugin Readiness

For each changed plugin:

- [ ] `plugins/<name>/.claude-plugin/plugin.json` updated
- [ ] `plugins/<name>/README.md` updated
- [ ] Commands/skills reviewed for clarity and consistency
- [ ] Generated output paths documented (for example, `.ideas/`)

## 3. Marketplace Manifest

- [ ] `.claude-plugin/marketplace.json` updated with plugin metadata
- [ ] Version numbers are consistent between plugin manifest and marketplace entry
- [ ] JSON validated locally (`jq empty <file>`)

## 4. QA and Validation

- [ ] Local structure validated (paths, naming, required files)
- [ ] GitHub workflow checks pass (if remote CI is available)
- [ ] Security-sensitive content check completed (no secrets)

## 5. GitHub Publication

- [ ] `main` branch is up to date
- [ ] Remote configured correctly
- [ ] Tag created for release version (if applicable)
- [ ] Release notes drafted from changelog

## 6. Post-Release

- [ ] Confirm repository renders correctly on GitHub
- [ ] Validate links in root and plugin READMEs
- [ ] Track first feedback/issues and triage quickly
