---
name: pr-respond
description: Respond to all unresolved PR review comments — apply code fixes, prepare text responses, commit and summarize
---

# /pr-respond

Respond to all unresolved review comments on a pull request.

## Usage

```
/pr-respond [PR-number | --current] [--repo=owner/repo] [--comment]
```

- `PR-number`: explicit PR number
- `--current`: detect from current branch (`gh pr view --json number`)
- `--repo=owner/repo`: override repository (default: current repo)
- `--comment`: post summary as a PR comment after fixing

## Protocol

### Step 1: Load all unresolved comments

```bash
gh pr view <PR-number> --json reviewThreads --jq '.reviewThreads[] | select(.isResolved == false)'
```

Read the full output. Never proceed without reading all comments first.

### Step 2: Group by type

Classify each comment as:
- **BLOCKER** — reviewer explicitly blocks merge: "must fix", "needs to change", "blocking"
- **QUESTION** — reviewer asks for clarification: "why", "what does", "can you explain"
- **NITPICK** — style/preference: "nit:", "minor:", optional suggestion
- **CODE_CHANGE** — explicit change request without blocking language

Group by file for efficient editing.

### Step 3: Resolve each comment

**BLOCKERs:** Read the referenced file, apply the fix, validate the change is correct.

**QUESTIONS:** Prepare a text response explaining the reasoning. Do not change code unless the question reveals a bug.

**NITPICKS:** Apply if trivial (rename, whitespace, obvious improvement). Defer if opinion-based.

**CODE_CHANGE:** Apply the suggested change. If the change conflicts with other code, note the conflict.

### Step 4: Commit fixes

For each file with applied fixes:
```bash
git add <file>
git commit -m "fix: address PR review comments in <file>

Resolves comments from: <reviewer> re: <brief description>"
```

### Step 5: Post summary comment (with --comment flag)

```bash
gh pr review <PR-number> --comment --body "<summary>"
```

Summary format:
```
## PR Review Response

**Resolved (N):**
- `file.py:45` -- Fixed null check (BLOCKER from @reviewer)
- `README.md:12` -- Clarified installation step (NITPICK)

**Deferred (N):**
- `api.py:89` -- Style preference, keeping original approach (NITPICK from @reviewer)

**Responses to questions:**
- `config.py:34` -- The timeout is set to 30s to match upstream API limits
```

### Step 6: Output summary to terminal

Always print the full summary regardless of --comment flag.

## Important

- Read ALL comments before making ANY changes
- Never push to remote (user will review and push)
- If a fix would break other functionality, note it in the deferred section
- Deferred items always include a reason
