# Testing Guide - Repo-Structure Plugin

Guide for testing the repo-structure plugin in Claude Code.

## Installation for Testing

### Option 1: Local Plugin Directory

```bash
cd /path/to/test-project
cc --plugin-dir /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure
```

### Option 2: Marketplace Installation (after publishing)

```bash
cc plugin install repo-structure
```

## Test Scenarios

### Scenario 1: New Repository Setup

**Objective:** Verify complete structure creation for greenfield project

**Setup:**
```bash
mkdir test-new-repo
cd test-new-repo
git init
```

**Test:**
```
User: "/repo-setup --mode=new"
```

**Expected Behavior:**
1. Structure-architect agent triggers
2. Detects empty repository
3. Prompts for: project name, description, license type
4. Proposes comprehensive structure plan
5. Requests approval by category
6. Creates files in new branch
7. Validates structure
8. Reports quality score (target: 95-100 for new repos)

**Verify:**
- [ ] README.md created with appropriate content
- [ ] LICENSE file present (user's choice)
- [ ] CONTRIBUTING.md present
- [ ] CODE_OF_CONDUCT.md present
- [ ] SECURITY.md present
- [ ] .github/workflows/ directory with CI files
- [ ] .gitignore appropriate for detected stack
- [ ] Git branch created (feat/repo-structure-setup)
- [ ] All files have valid syntax

---

### Scenario 2: Existing Repository Audit

**Objective:** Verify gap analysis and quality scoring

**Setup:**
```bash
# Use repo-structure plugin itself as test subject
cd /mnt/d/GitHub/nsalvacao-claude-code-plugins/plugins/repo-structure
```

**Test:**
```
User: "/repo-audit"
```

**Expected Behavior:**
1. Analyzes existing files
2. Calculates quality score (0-100)
3. Breaks down by category (Documentation, Security, CI/CD, Community)
4. Lists specific issues with point impact
5. Provides recommendations
6. Saves report to `.repo-audit-YYYY-MM-DD.md`

**Verify:**
- [ ] Score calculated and displayed
- [ ] Each category scored separately
- [ ] Issues listed with severity
- [ ] Recommendations actionable
- [ ] Report file created

---

### Scenario 3: Tech Stack Detection

**Objective:** Verify intelligent stack detection

**Test Cases:**

#### Python Project
```bash
mkdir test-python
cd test-python
echo "fastapi==0.104.0" > requirements.txt
echo "pytest" >> requirements.txt
```

**Test:**
```
User: "/repo-setup"
```

**Expected:**
- Detects Python as primary language
- Identifies FastAPI framework
- Identifies pytest for testing
- Creates Python-appropriate configs (.flake8, pyproject.toml)
- Creates pytest-based CI workflow

#### JavaScript Project
```bash
mkdir test-nodejs
cd test-nodejs
npm init -y
npm install express react
```

**Expected:**
- Detects JavaScript/Node.js
- Identifies Express (backend) and React (frontend)
- Creates appropriate .eslintrc, .prettierrc
- Creates npm-based CI workflow

---

### Scenario 4: Targeted Improvements

**Objective:** Verify category-specific improvements

**Setup:**
```bash
# Repository with minimal structure
mkdir test-incomplete
cd test-incomplete
git init
echo "# Test Project" > README.md
```

**Test:**
```
User: "/repo-improve --category=security"
```

**Expected Behavior:**
1. Analyzes security category gaps
2. Proposes: SECURITY.md, Dependabot, CodeQL
3. Requests approval
4. Creates only security-related files
5. Reports security score improvement

**Verify:**
- [ ] Only security files created
- [ ] No unnecessary files created
- [ ] Security score improves
- [ ] Other categories unchanged

---

### Scenario 5: Validation Workflow

**Objective:** Verify structure validation

**Test:**
```
User: "/repo-validate"
```

**Expected Behavior:**
1. Structure-validator agent triggers
2. Checks file completeness
3. Validates YAML/JSON syntax
4. Checks markdown links
5. Reports pass/fail with issues

**With `--fix` flag:**
```
User: "/repo-validate --fix"
```

**Expected:**
- Automatically fixes fixable issues
- Reports what was fixed

---

### Scenario 6: Template Customization

**Objective:** Verify intelligent template adaptation

**Setup:**
```bash
# Create simple Python project
mkdir test-customize
cd test-customize
git init
echo "def hello(): return 'Hello, World!'" > main.py
```

**Test:**
```
User: "Improve my README with actual usage examples from my code"
```

**Expected Behavior:**
1. Template-customizer agent triggers
2. Reads main.py to understand code
3. Generates usage examples from actual functions
4. Enhances README with project-specific content

**Verify:**
- [ ] README includes actual code examples
- [ ] Examples reference real functions/classes
- [ ] Content is context-aware

---

### Scenario 7: Hook Triggering

**Objective:** Verify hooks execute automatically

**Setup:**
```bash
cd test-project
# Plugin already loaded
```

**Test:**
Create invalid YAML file:
```yaml
# Invalid YAML
broken: [unclosed
```

```bash
git add broken.yaml
git commit -m "Test"
```

**Expected Behavior:**
- PreToolUse hook triggers
- Validation script runs
- Detects invalid YAML
- Blocks commit (if strictness configured)

**Verify:**
- [ ] Validation script executed
- [ ] Invalid YAML detected
- [ ] Clear error message shown
- [ ] Commit blocked (or warning shown)

---

### Scenario 8: Configuration Override

**Objective:** Verify config file respects user preferences

**Setup:**
```bash
mkdir .claude
cat > .claude/repo-structure.config.yaml <<EOF
author:
  name: "Test User"
  email: "test@example.com"
defaults:
  license: "Apache-2.0"
  ci_provider: "gitlab-ci"
scoring:
  weights:
    security: 40
    documentation: 20
    ci_cd: 20
    community: 20
EOF
```

**Test:**
```
User: "/repo-setup"
```

**Expected:**
- Uses "Test User" as author (not git config)
- Creates Apache-2.0 LICENSE (not MIT default)
- Creates .gitlab-ci.yml (not GitHub Actions)
- Security category worth 40 points in scoring

---

## Agent Triggering Tests

### Structure-Architect Triggering

**Test phrases that should trigger:**
- "Setup repository structure"
- "Create professional repo"
- "Make this repository enterprise-grade"
- "Add documentation and CI/CD"
- "Initialize repo with best practices"

**Test:**
```
User: "<one of above phrases>"
```

**Verify:** Structure-architect agent loads

---

### Structure-Validator Triggering

**Automatic (Proactive):**
After structure-architect creates files, validator should trigger automatically.

**Manual (Reactive):**
```
User: "Validate my repository structure"
User: "Check if my repo files are correct"
```

**Verify:** Structure-validator agent loads

---

### Template-Customizer Triggering

**Test phrases:**
- "Improve my README"
- "Customize the documentation"
- "Add examples to README"
- "Make the contributing guide more specific"

**Verify:** Template-customizer agent loads

---

## Performance Tests

### Speed Benchmarks

**Small repo (<10 files):**
- Detection: <2 seconds
- Audit: <5 seconds
- Setup: <30 seconds

**Medium repo (10-50 files):**
- Detection: <5 seconds
- Audit: <10 seconds
- Setup: <60 seconds

**Large repo (50+ files):**
- Detection: <10 seconds
- Audit: <30 seconds
- Setup: <120 seconds

---

## Error Handling Tests

### No Git Repository

**Test:**
```bash
mkdir no-git
cd no-git
```

```
User: "/repo-setup"
```

**Expected:**
- Detects no git repository
- Offers to initialize: "Initialize git repo now?"
- If yes: runs `git init` and proceeds
- If no: warns and exits gracefully

---

### Invalid Config File

**Test:**
```yaml
# Invalid config
broken yaml: [unclosed
```

```
User: "/repo-setup"
```

**Expected:**
- Detects invalid YAML
- Shows warning with line number
- Falls back to defaults
- Proceeds with setup

---

### Missing Dependencies

**Test:**
```bash
# Simulate missing jq
alias jq="echo 'jq not found' >&2; exit 1"
```

```
User: "/repo-audit"
```

**Expected:**
- Detects missing tool
- Falls back to Python alternative
- Or warns user gracefully
- Continues with available tools

---

## Integration Tests

### Full Workflow (End-to-End)

**Scenario:** Complete repository transformation

1. Start with bare repo
2. Run `/repo-setup`
3. Approve all categories
4. Run `/repo-validate`
5. Run `/repo-audit`
6. Verify final score 85+

**Success Criteria:**
- All files created
- All validation passes
- Quality score 85-100
- No broken links
- CI workflows valid
- License OSI-approved

---

## Manual Verification Checklist

After running setup, manually verify:

- [ ] README is professional and complete
- [ ] LICENSE matches user choice
- [ ] CONTRIBUTING has clear workflow
- [ ] CODE_OF_CONDUCT is Contributor Covenant 2.1
- [ ] SECURITY has vulnerability reporting process
- [ ] .github/workflows/ files are syntactically valid
- [ ] .gitignore appropriate for detected stack
- [ ] Pre-commit config matches detected stack
- [ ] All badges in README are valid URLs
- [ ] No broken links in any markdown file
- [ ] Git branch created (not committed to main)
- [ ] No placeholder text ({{VAR}}) left unresolved

---

## Troubleshooting Common Issues

### "Agent not triggering"

**Check:**
1. Plugin loaded correctly: `cc --plugin-dir .../repo-structure`
2. Trigger phrase matches examples in agent description
3. Claude model supports agent invocation (Sonnet/Opus recommended)

**Fix:**
- Use explicit `/repo-setup` command instead of natural language
- Check plugin installation with `cc plugin list`

---

### "Template variables not resolved"

**Check:**
1. Git config has user.name and user.email
2. Config file present at `.claude/repo-structure.config.yaml`
3. Git remote configured (for project name extraction)

**Fix:**
```bash
git config user.name "Your Name"
git config user.email "your@email.com"
```

Or create config file with author information.

---

### "Scripts not executing"

**Check:**
1. Scripts are executable: `ls -la scripts/*.sh`
2. Bash available: `which bash`
3. Dependencies installed: `which jq yq python3`

**Fix:**
```bash
chmod +x scripts/*.sh hooks/scripts/*.sh
```

---

## Reporting Issues

If you encounter issues during testing:

1. **Collect information:**
   - Plugin version: `cat .claude-plugin/plugin.json | jq .version`
   - Claude Code version: `cc --version`
   - OS: `uname -a`
   - Error messages (full output)

2. **Create minimal reproduction:**
   - Simplest project that reproduces issue
   - Exact commands used
   - Expected vs actual behavior

3. **Report issue:**
   - GitHub Issues: https://github.com/nsalvacao/nsalvacao-claude-code-plugins/issues
   - Include all collected information
   - Tag with `plugin:repo-structure`

---

## Success Metrics

Plugin is working correctly if:

- ✅ 90%+ of test scenarios pass
- ✅ Agents trigger on appropriate phrases
- ✅ Quality scores are accurate (±5 points)
- ✅ Generated files are valid and complete
- ✅ No security issues (credentials, unsafe commands)
- ✅ Performance within benchmarks
- ✅ Error handling is graceful
- ✅ Documentation matches behavior

---

**Testing completed successfully when all scenarios pass and success metrics are met.**
