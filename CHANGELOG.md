# Changelog

All notable changes to this repository will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.8.0](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/compare/v1.7.0...v1.8.0) (2026-03-11)


### ✨ Features

* **plugins:** add agents, hooks, and skills to strategy-toolkit, productivity, product-management ([1a65eee](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/1a65eee2ac0b16c974c5e8a81c9b3f3edb810936))
* **repo-structure:** add B1-B4 github/ templates — CONTRIBUTING, SECURITY, CODE_OF_CONDUCT, LICENSE.Apache-2.0 ([6c203a7](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/6c203a75e8a30d8d2be146157d0a7a3994f0081b))
* **repo-structure:** add B5-B9 configs/ and ci/ templates — gitignore, editorconfig, GitHub Actions CI ([8ed6748](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/8ed6748571c452b87b08b0a2bf070979ad849b04))
* **repo-structure:** add G1-G2 missing scripts — install-hooks.sh, check-compliance.sh ([2980413](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/2980413c95948c164f9c1717d6539a494fb4db98))
* **repo-structure:** C1-C3 CI debugging suite — ci-diagnostics skill, /ci-audit, /ci-fix commands ([679522d](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/679522d92a535d119eb214031a9a8063296f6e22))
* **repo-structure:** D1 /pr-respond command — classify-fix-commit flow for PR review comments ([0c3c273](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/0c3c273ee2d380fdd6b1b798a5ec4db013ab4069))
* **repo-structure:** E1-E4 hooks upgrade — shellcheck, yamllint, lf-check, audit-reminder + hooks.json update (2-&gt;5 hooks) ([82e73df](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/82e73df8d0d77ac267fe2b799f7629badc40d6a7))
* **repo-structure:** F1 automation-validator agent — validates workflows, hooks, pre-commit, task runners ([7a9a803](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/7a9a8034e96404884b3f2312ce58664c1134e1a5))
* **repo-structure:** repo-structure plugin v0.2.0 ([7d24054](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/7d2405439e7ad5c96099f7103535dbd2131eeb99)), closes [#45](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/issues/45)


### 🐛 Bug Fixes

* **repo-structure:** address review gaps — validate-structure, template negation, compliance subshell, missing vars, MultiEdit hook ([eb8af9b](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/eb8af9bff6e09cc6055f4abe201f714fa50da1ee))
* **repo-structure:** B1-B4 bug fixes — scoring, link regex, missing detection, jq fallback ([b23396b](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/b23396b46fe03a4d6a0424a5db8198031d265537))
* **repo-structure:** resolve Pyright type errors — scores Dict[str,Any], weights local_weights, subprocess import ([8151dbb](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/8151dbbc321d43f7e21ecabcc5686d522783e44c))
* **solution-audit:** address review gaps — spec-gap-analysis stale tracking, audit-report dimension list, check-examples exit code, check-links user-agent ([c747ce1](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/c747ce159ce7bb8d5766c50d22136534f6e33fb4))


### 📚 Documentation

* add repo-structure v0.2.0 design doc and implementation plan ([dba252e](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/dba252e9f12a45cb9f6a52325b21e20060486733))
* **auto:** sync plugin inventory and README table [skip ci] ([d69475c](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/d69475c3ac006d8515f865408abaa64d4410d5b6))
* **repo-structure:** add H1-H4 reference files — scoring rubrics, partial credit, detection patterns, compliance mapping ([a5f9606](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/a5f96066a022c1b881694de8676dd3ca19d0c342))


### 🔧 Maintenance

* **repo-structure:** bump version 0.1.0-&gt;0.2.0, update README with v0.2.0 components ([5f7c4dd](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/5f7c4ddfe5e178eacb0e0083f512fdd0ebcf0169))

## [1.7.0](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/compare/v1.6.0...v1.7.0) (2026-03-10)


### ✨ Features

* **solution-audit:** elevate to v0.2.0 — scripts, 8th dimension, parallel blueprint review ([#39](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/issues/39)) ([1b40ebe](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/1b40ebec7ab5f9e8e96338a1db5c345eda7f9821))

## [1.6.0](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/compare/v1.5.0...v1.6.0) (2026-03-04)


### ✨ Features

* **solution-audit:** finalize plugin with review fixes and CI improvements ([116e088](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/116e08854bfdad90a1f76dd187ea11de5b3ba94a))


### 📚 Documentation

* regenerate copilot-instructions.md with 11-step discovery workflow v2.0 ([9a2be8a](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/9a2be8a75f246ddcb58a6729c90ee2093eabb6ef))

## [1.5.0](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/compare/v1.4.0...v1.5.0) (2026-03-04)


### ✨ Features

* **solution-audit:** add continuous meta-quality audit plugin ([#35](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/issues/35)) ([8b6b0b9](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/8b6b0b9fa8cc02b87b8f8cf2820a4aa0d3ad4c5b))


### 🔧 Maintenance

* **deps:** bump actions/stale from 9 to 10 ([#34](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/issues/34)) ([b7b3116](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/b7b31165f9208d239454c0bc09c669cc3aa5edac))

## [1.4.0](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/compare/v1.3.0...v1.4.0) (2026-03-01)


### ✨ Features

* **plugin-studio:** filesystem REST API with unit tests ([#3](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/issues/3)) ([#32](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/issues/32)) ([f4d0986](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/f4d09863a6f933d16d275f69e58bdd5e80ee68e1))

## [1.3.0](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/compare/v1.2.0...v1.3.0) (2026-02-28)


### ✨ Features

* **plugin-studio:** Node.js server + Vite/React app scaffold ([#30](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/issues/30)) ([c37d447](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/c37d4471824874794457fb28d3745b46f2f365e9))

## [1.2.0](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/compare/v1.1.0...v1.2.0) (2026-02-28)


### ✨ Features

* **plugin-studio:** add canonical plugin scaffold structure ([#1](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/issues/1)) ([8d8b8f5](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/8d8b8f5f5c3f99e2c75f4443dd03d4e0cfef5b0b))

## [1.1.0](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/compare/v1.0.0...v1.1.0) (2026-02-28)


### ✨ Features

* add 3 cross-project reusable plugins to marketplace ([e44784f](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/e44784f0c19b175a7b6200d5d9457f6e00e57aa1))
* **ci:** add full CI/CD stack with AI-assisted plugin validation ([f1d8ab6](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/f1d8ab677227a2ccf9511d3835f211f19ec4f0c6))


### 🐛 Bug Fixes

* **ci:** exclude CLAUDE.md from command validation; remove empty auto-files ([4ea1fc9](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/4ea1fc9acf129f1740379fa5cb31d210f7fcf39d))
* **ci:** fix bash exit pattern in plugin-validation workflow ([599d079](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/599d079882a60465d8d33b3c887e27a5661e8bb4))
* **ci:** resolve 3 workflow failures ([bf159b8](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/bf159b82fd14443d8d1229d34125554f593f6ab6))
* **ci:** resolve all markdownlint failures ([eb6a572](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/eb6a572e0d7ea7d4cfaa427e7b5c441c4d68f17f))
* **ci:** work around validate-agent.sh bash arithmetic bug ([b84fa89](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/b84fa89912e673b5da16df472d2d2e9568bd0c3a))
* **productivity-cockpit:** internationalize UI strings and remove Python-specific defaults ([c5333b3](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/c5333b34a1efab22104f7b8f7848bd3d3c8d8200))
* **repo-structure:** add &lt;example&gt; to agent description first lines ([89f3d65](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/89f3d65393b333962ca9089e5b28cdba54e8803f))
* **repo-structure:** correct hook timeout values to seconds (not ms) ([4c77080](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/4c77080b1dcd0487f2644b22d2ada38e58ed81e5))
* **repo-structure:** remove unused YELLOW variable (shellcheck SC2034) ([320677e](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/320677e0f609101149a07fffc60a20738def60b6))
* **repo-structure:** use Stop event for prompt hook instead of PostToolUse ([0f5f4ab](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/0f5f4abd4b2bea79561127ab5baf094aa3e3a6d7))


### 📚 Documentation

* add .github/copilot-instructions.md for coding agent onboarding ([#27](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/issues/27)) ([243869d](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/243869d3592ac67d5b94e0408aa2bec727afaf7e))
* **auto:** sync plugin inventory and README table [skip ci] ([b7335af](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/b7335af598bf71a825e28b027e30d00d4b2a985f))
* **readme:** clarify official Claude Code marketplace install flow ([bc40089](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/bc4008972d5dbc1c56a21c8e051d31e0b92eddd7))


### 🔧 Maintenance

* **deps:** bump actions/checkout from 4 to 6 ([#23](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/issues/23)) ([5915fc0](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/5915fc0cc1976552094f1fbc84daf314613d07ba))
* **deps:** bump actions/setup-python from 5 to 6 ([#21](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/issues/21)) ([a7c746a](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/a7c746afb831f90297596eb6fc0c953685c1323d))
* **deps:** bump github/codeql-action from 3 to 4 ([#25](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/issues/25)) ([ec2a9fe](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/ec2a9fe778a5d842d19803218f0ba9421e037a98))
* **deps:** bump ossf/scorecard-action from 2.4.0 to 2.4.3 ([#24](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/issues/24)) ([80ccc66](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/80ccc660cb17bcc261d0eb97513c237501cc8eb9))
* **deps:** bump stefanzweifel/git-auto-commit-action from 5 to 7 ([#22](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/issues/22)) ([617281b](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/617281b1426c18d51020b64c71189fd80501263c))
* **repo:** bootstrap professional repository structure ([5fc88ce](https://github.com/nsalvacao/nsalvacao-claude-code-plugins/commit/5fc88ce52ac411f407dde98e70ad909ff38a7289))

## [Unreleased]

### Added
- Professional repository baseline documentation and governance files
- GitHub issue templates and pull request template
- Release checklist and plugin guidelines
- Plugin README for `strategy-toolkit`

## [0.1.0] - 2026-02-09

### Added
- Initial plugin catalog with `strategy-toolkit`
- Marketplace manifest in `.claude-plugin/marketplace.json`
- `strategy-toolkit` command set:
  - `brainstorm`
  - `execution-plan`
  - `strategic-review`
- `strategic-analysis` skill and framework references
