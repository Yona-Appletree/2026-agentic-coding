---
name: yona-ship
description: Take an implemented branch the rest of the way — get the pull request green, assemble an evidence-first ship report, hold the ship gate when one is warranted, then merge, deploy when configured, watch post-merge CI, and clean up the planning artifacts. Use when implementation is done, or for any branch that needs to reach a merged PR.
---

# Yona Ship

Use this skill when the work is implemented and needs to reach the base branch — and production, when the repo deploys.

`yona-implement` ends at a ready PR with CI watched. This skill owns everything after: the ship report, the ship gate, the merge, the deploy, post-merge CI, and cleanup. It also absorbs the standalone push case — a branch that has the work but no PR yet starts at Get The PR Green below.

**Invoking this skill is the authorization to merge.** Work with no ship gate merges and deploys without checking in. Work with a gate stops exactly once — at the ship report — and a single `go` from the user carries it through merge, deploy, and cleanup.

The user reviews evidence, not diffs. The center of this skill is the ship report: an argument, with links, that the work is safe to merge. Everything before it feeds it; everything after it executes what it promised.

## Setup

1. Determine the repo root with `git rev-parse --show-toplevel`; resolve the current branch, base branch, and GitHub remote. Verify `gh auth status`.
2. Resolve the planning workspace the way `yona-plan` does: `agent-context.toml` at the repo root for `repo_slug` / `planning_root` / `planning_root_env`, falling back to repo-local `docs/plans/`.
3. Find the planning artifacts for this branch: the `Plan:` marker in the PR body, a `pr:` URL in a plan's frontmatter, or the plan the user named. Read `plan.md` (gates, ship gate, ADR expectations), `_DONE.md`, and the phase files' Implementation Result sections — these are the raw material of the ship report. Work without a plan is fine; the report is built from the diff and the PR instead.
4. Read the `[ship]` section of `agent-context.toml` for deploy configuration (see Deploy).

## Get The PR Green

Skip whatever is already true.

- If the branch has no PR: inspect before pushing — `git status --short` (stop on ambiguous dirty state), confirm the branch is not a protected base branch, scan the diff against the base for conflict markers, debug logging, disabled tests, and stray TODOs. Then `git push -u origin HEAD` and create the PR with the same title, plan-marker body, and draft conventions `yona-implement` uses.
- If the PR is draft and the work is feature-complete with no implementation gate pending, mark it ready with `gh pr ready`.
- Watch CI with `gh pr checks --watch --interval 20`. On failure: collect the failing checks (`gh pr checks --json name,workflow,bucket,state,link`), read the logs (`gh run view <run-id> --log-failed`), fix the smallest real issue, run the matching local validation, commit, push, watch again. Two failures of the same check with no new signal is a Stop And Ask.

Do not rebase, squash, or rewrite history unless the user asked or CI proves it necessary. **Do not merge red.** The merge happens only after the check rollup is green.

## The Ship Report

The ship report is not a phase log — `_DONE.md` already records what happened. The report argues that merging is safe, in the user's terms, with every claim linked to evidence.

Sections, in order:

- **What ships** — one paragraph of user-visible or architectural change. Not a phase list.
- **Evidence** — direct links: the CI run for the head commit, changed visual baselines (story/snapshot images) with before/after when they changed, screenshots for anything visual, validation output for anything the user asked to be sure of. Post images inline in the conversation as well as linking them, so the gate can be answered from a phone.
- **ADRs** — created this branch, with paths, or `none`.
- **Deviations and defects** — deviations from the plan, defects filed during implementation against the repo's register, or `none`.
- **Follow-ups** — suggested next work, each one line and actionable, or `none`.
- **Deploy plan** — what happens after merge (post-merge CI, deploy command, nothing), what healthy looks like, and how it would be rolled back. `not configured` is a valid answer; say it.

Post the report as a PR comment so it is durable next to the merge, and in the conversation with images inline. Keep it honest: a weak spot named in the report is cheaper than one discovered after deploy.

## The Ship Gate

Whether to stop at the report is decided in two layers:

1. **The plan declares it.** `yona-plan` records `ship_gate: required | none` in `plan.md` frontmatter. Honor it.
2. **Escalation overrides `none`.** Gate anyway when the work created an ADR, touched a migration/data format/schema, recorded deviations from the plan, filed defects, performs a first-of-its-kind deploy, or does anything irreversible beyond the merge itself.

With no plan at all: gate unless the change is genuinely small — a bug fix, a copy or UI tweak, a doc change — where the two-layer test would obviously say `none`.

At the gate: post the report, state the question in one line so `go` is a sufficient reply — usually `Merge and deploy? Evidence above.` — and stop. Never merge to satisfy a gate; never soften the report to avoid one.

With no gate: emit the report anyway (it can be compact — a few lines plus links), then continue through merge and deploy without stopping. The report is not optional; only the stop is.

## Merge

- Confirm the check rollup is green and the PR is ready, then merge with the repo's dominant method — check recent history (`git log --oneline --merges`) and allowed methods (`gh repo view --json squashMergeAllowed,mergeCommitAllowed,rebaseMergeAllowed`). When unclear: squash a single-purpose branch if allowed, otherwise a merge commit.

```bash
gh pr merge --squash --delete-branch
```

- Never bypass branch protection (`--admin`), required reviews, or required checks. A merge blocked by protection that needs a human approval is a Stop And Ask, with the link.

## Deploy

Deploy is per-repo configuration, declared in `agent-context.toml`:

```toml
[ship]
# Command run after merge, from the base branch. Omit when CI deploys on merge.
deploy = "just studio-web-deploy"
# Whether merging to the base branch triggers deploy via CI.
deploy_via_ci = true
# How to confirm the deploy landed: a command that exits non-zero on failure.
verify = "curl -sfo /dev/null https://example.com/healthz"
```

After the merge, always:

1. **Watch post-merge CI on the base branch** — the run triggered by the merge commit (`gh run list --branch <base> --commit <merge-sha>`, then `gh run watch --compact --exit-status`). A red base branch is this skill's problem: diagnose it; a small clear fix-forward is in scope; a revert is a Stop And Ask.
2. **Run the deploy command** when `[ship]` declares one, from an up-to-date base branch checkout.
3. **Run `verify`** when declared, and include the result and any user-facing URL in the completion report.

When there is no `[ship]` section and no post-merge workflow runs, say deploy is not configured for this repo and move on. Do not invent a deploy procedure.

## Cleanup

- The remote branch is deleted by the merge; delete the local branch too when it is fully merged and not checked out in a live worktree.
- Update `plan.md` frontmatter with `merged: YYYY-MM-DD` and the merge SHA, plus `deployed: YYYY-MM-DD` when a deploy ran.
- Archive the planning directory to the location `yona-plan` defines — this is ship's job, not implement's, because a plan is finished when the work lands, not when the PR opens. Preserve the basename; suffix `-v2` rather than overwrite.
- File the report's follow-ups somewhere durable per the repo's conventions: the defect/debt register, new plan stubs, or the planning workspace's notes. Follow-ups that live only in the conversation do not exist.

## Stop And Ask

Pause and hand back when:

- The ship gate holds (declared, or escalated).
- The same CI check fails after two focused repair attempts without a new signal.
- The merge is blocked by branch protection that needs a human.
- Post-merge CI on the base branch is red with no small clear fix-forward — reverts are the user's call.
- The deploy command or `verify` fails.
- The failure depends on secrets, external services, missing permissions, or infrastructure state.
- The planning root or plan cannot be resolved when the user pointed at one.

**This list is closed. If the reason you are about to stop is not on it, keep going.**

In particular, do not stop to:

- ask whether to merge when no gate holds — invoking the skill answered that
- ask whether to deploy when `[ship]` declares it
- announce the report and wait when no gate holds
- ask whether to keep watching CI, before or after the merge
- ask whether to archive the plan or file the follow-ups

When you do stop, state the single next action in one line, so that `go` is a sufficient reply.

## Completion

Finish with:

- Merged or not, with the merge SHA and PR link.
- Deploy status: command run and verify result with user-facing URL, `via CI` with the run link, or `not configured`.
- Post-merge CI state on the base branch, with links.
- Where the ship report lives (PR comment link).
- Follow-ups filed and where.
- Archive path of the planning directory, if archived.
- Any remaining human action.
