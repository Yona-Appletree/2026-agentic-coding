---
name: yona-push
description: Push an existing implementation branch, create or update its pull request, watch CI until green, diagnose failing checks, make focused fixes, and repeat. Use when a branch already has the work on it.
---

# Yona Push

Use this skill when the work is already implemented on a branch and needs to reach a green pull request.

`yona-implement` opens and drives the PR itself as part of its pipeline; it does not hand off to this skill. Reach for `yona-push` for the standalone case: a branch you already have, work done outside a plan, or a PR that needs picking back up.

Assume full local checks have already run. Do not repeat broad validation at the start unless the repo state is suspicious.

## Setup

1. Determine the repo root with `git rev-parse --show-toplevel`.
2. Resolve the current branch, base branch, and GitHub remote. Default the base branch to `main` unless the user or repo config says otherwise.
3. Verify GitHub CLI authentication with `gh auth status`.
4. If a plan or completion log exists for this branch, read it for the PR title and body. Resolve the planning workspace the way `yona-plan` does: `agent-context.toml` at the repo root for `repo_slug` / `planning_root` / `planning_root_env`, falling back to repo-local `docs/plans/`.

## Final Cleanup

Inspect, do not churn:

- Run `git status --short` and stop if the branch is dirty with ambiguous or unrelated changes.
- If dirty changes are clearly part of the completed implementation, review them, commit them in the repo's conventional commit style, and continue.
- Confirm the branch is not `main`, `master`, or another protected base branch.
- Run `git fetch origin <base-branch>` and inspect `git log --oneline origin/<base>..HEAD` plus `git diff --stat origin/<base>...HEAD`.
- Scan touched files for conflict markers, debug-only logging, skipped or disabled tests, and TODOs introduced by the implementation.
- Do not rebase, squash, merge the base branch, or rewrite commits unless the user asked or CI proves it is necessary.

## Push And Create The PR

```bash
git push -u origin HEAD
```

If a PR already exists, reuse it:

```bash
gh pr view --json number,url,title,headRefName,baseRefName,state,isDraft
```

Otherwise create it:

```bash
gh pr create --draft --base main --head "$(git branch --show-current)" --title "<type>: <title>" --body-file -
```

Title it `<type>: <title>` using the conventional-commit type for the dominant change. When a plan exists, the title is the plan's `# H1` and the body starts with a plan marker on its own line:

```md
Plan: <repo-slug>/<planning-dir-basename>
Path: <resolvable path to plan.md>
```

Then a concise body:

- Summary of user-visible or architectural changes.
- Local validation already completed before push.
- Review or ADR links when available.
- Notes about any intentionally deferred follow-up.

### Draft or ready

Create the PR as a draft. Mark it ready once CI is green, no work remains, and no review gate is pending:

```bash
gh pr ready
```

If a gate is pending, it stays draft and the handoff says so. Never mark a PR ready to satisfy a gate. Do not merge the PR unless the user explicitly asks.

## Watch CI

```bash
gh pr checks --watch --interval 20
```

Use `gh pr checks` first: it follows the PR's check rollup and exits successfully only when the PR is green. Use `gh run list`, `gh run watch --compact --exit-status`, and `gh run view --log-failed` when a check fails, stalls, or needs detailed logs.

If no checks appear, inspect changed paths, branch protection, and workflow triggers before treating that as a failure.

While watching, preserve links for the final handoff: the PR, failing or pending jobs, and the relevant Actions run pages. Prefer structured output with links and descriptions over scraping terminal output later.

## Fix CI Failures

1. Collect failing check names and links: `gh pr checks --json name,workflow,bucket,state,link`.
2. Find the run: `gh run list --branch "$(git branch --show-current)" --commit "$(git rev-parse HEAD)" --limit 10`.
3. Read failed logs: `gh run view <run-id> --log-failed`.
4. Fix the smallest real issue that explains the failure.
5. Run the targeted local validation that matches the failure.
6. Commit the fix, push, and watch checks again.

If CI fails after updating the branch from the base, fetch the base branch and inspect the conflict locally. Prefer the least surprising branch update that preserves reviewability, and ask before rewriting history.

Do not stop between a failure and its fix to ask permission to fix it, and do not stop after pushing a fix to ask whether to keep watching. Stop and ask when:

- The same check fails after two focused repair attempts without a clear new signal.
- The failure depends on secrets, external services, missing permissions, or infrastructure state.
- Fixing the failure would expand scope beyond the implemented work.
- Visual review, deploy approval, or product judgment needs a human.

When stopping for a human, include direct Markdown links to the pages they need and summarize the exact check descriptions so they know what to look at.

## Completion

Before finishing, run `git status --short` and one final structured check query:

```bash
gh pr view --json number,url,title,headRefName,baseRefName,state,isDraft
gh pr checks --json name,workflow,bucket,state,link,description
```

Finish with direct Markdown links to the PR and important CI results, plus:

- Branch name.
- Draft or ready state.
- Current CI state.
- Fixes pushed during CI repair.
- Targeted validation run after those fixes.
- Any remaining human action.
