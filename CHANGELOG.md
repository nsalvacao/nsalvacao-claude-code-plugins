# Changelog

All notable changes to this repository will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
