---
name: yona-push
description: Push a finished implementation branch, create or update a GitHub pull request, watch CI until green, diagnose failing checks, make focused fixes, rerun targeted validation, and repeat.
---

# Yona Push

Use this skill after implementation work is locally validated and committed. Assume the full local checks have already run; do not repeat broad validation at the start unless the repo state is suspicious. The job here is final cleanup, PR creation, CI monitoring, and focused repair when CI disagrees.

## Setup

Before pushing:

1. Determine the repo root with `git rev-parse --show-toplevel`.
2. Resolve the current branch, base branch, and GitHub remote. Default the base branch to `main` unless the user or repo config says otherwise.
3. Verify GitHub CLI authentication with `gh auth status`.
4. If there is a related plan or completion log under `docs/plans/` or `docs/archive/plans/`, read it only when it is useful for the PR body.

## Final Cleanup

Inspect, do not churn:

- Run `git status --short` and stop if the branch is dirty with ambiguous or unrelated changes.
- If dirty changes are clearly part of the completed implementation, review them, commit them with the repo's conventional commit style, and continue.
- Confirm the branch is not `main`, `master`, or another protected base branch.
- Run `git fetch origin <base-branch>` and inspect `git log --oneline origin/<base-branch>..HEAD` plus `git diff --stat origin/<base-branch>...HEAD`.
- Scan touched files for accidental conflict markers, debug-only logging, skipped/disabled tests, and TODOs introduced by the implementation.
- Read the implementation `_DONE.md` or plan only when it is easy to identify and useful for the PR body.
- Do not rebase, squash, merge the base branch, or rewrite commits unless the user asked or CI proves it is necessary.

## Push And Create The PR

Push the current branch:

```bash
git push -u origin HEAD
```

If a PR already exists, reuse it:

```bash
gh pr view --json number,url,title,headRefName,baseRefName,state,isDraft
```

Otherwise create a ready PR unless the user asked for a draft or the work is intentionally incomplete:

```bash
gh pr create --base main --head "$(git branch --show-current)" --title "<title>" --body-file -
```

Write a concise PR body with:

- Summary of user-visible or architectural changes.
- Local validation already completed before push.
- Plan, review, or ADR links when available.
- Notes about any intentionally deferred follow-up.

Do not merge the PR unless the user explicitly asks.

## Watch CI

Preferred watcher:

```bash
gh pr checks --watch --interval 20
```

Use `gh pr checks` first because it follows the PR's check rollup and exits successfully only when the PR is green. Use `gh run list`, `gh run watch --compact --exit-status`, and `gh run view --log-failed` only when a check fails, stalls, or needs detailed logs.

A portable helper pattern:

```bash
interval="${YONA_PUSH_CHECK_INTERVAL:-20}"
gh pr checks --watch --interval "$interval"
gh pr checks --json name,workflow,bucket,state,startedAt,completedAt,link,description
```

If no checks appear, inspect changed paths, branch protection, and workflow triggers before treating that as a failure.

While watching, preserve useful links for the final handoff: the PR, failing or pending CI jobs, and the latest relevant GitHub Actions run/job pages. Prefer structured output that includes links and descriptions over scraping terminal output later.

## Fix CI Failures

When a check fails:

1. Collect the failing check names and links with `gh pr checks --json name,workflow,bucket,state,link`.
2. Find the run for the current branch or commit with `gh run list --branch "$(git branch --show-current)" --commit "$(git rev-parse HEAD)" --limit 10`.
3. Read failed logs with `gh run view <run-id> --log-failed`.
4. Fix the smallest real issue that explains the failure.
5. Run the targeted local validation that matches the failure.
6. Commit the fix, push, and watch checks again.

If CI fails after updating the branch from the base branch, fetch the base branch and inspect the conflict locally. Prefer the least surprising branch update that preserves reviewability, and ask before rewriting history.

Stop and ask when:

- The same check fails after two focused repair attempts without a clear new signal.
- The failure depends on secrets, external services, missing permissions, or infrastructure state.
- Fixing the failure would expand scope beyond the implemented plan.
- Visual review, deploy approval, or product judgment needs human approval.

When stopping for a human review or approval step, include direct Markdown links to the pages the human needs, and summarize the exact check descriptions so they know what to look at.

## Completion

Before finishing, run `git status --short` and one final structured check query:

```bash
gh pr view --json number,url,title,headRefName,baseRefName,state,isDraft
gh pr checks --json name,workflow,bucket,state,link,description
```

Finish with direct Markdown links to the PR and important CI results, plus:

- Branch name.
- Current CI state.
- Fixes pushed during CI repair.
- Targeted validation run after those fixes.
- Any remaining human action.
