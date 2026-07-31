---
name: yona-implement
description: Execute an existing planning artifact end to end — implement, validate, open and maintain a pull request, watch CI, create ADRs when warranted, and archive the completed plan.
---

# Yona Implement

Use this skill to execute an existing `plan.md` with disciplined validation.

## The Pipeline

**The definition of done is a pushed pull request with CI watched — not a clean worktree, not a green local test run, not a commit.**

```text
no gates:    plan → implement → validate → PR → CI green
with gates:  plan → implement → gate → implement → validate → PR (draft) → CI green → gate
```

Run from the start of the plan to the first declared gate. After a gate is answered, run from there to the next gate, or to the pull request. Do not check in at points that are not gates.

A **gate** is a stopping point the plan declared: a `Review gate:` value other than `none` on a phase, or an entry in the plan's `Gates` section. Nothing else in this document creates a gate except the Stop And Ask list below.

## Plan Location

If the user provides an explicit plan path, use it. Otherwise resolve the planning workspace the same way `yona-plan` does:

1. Determine the repo root with `git rev-parse --show-toplevel`. If the project is not a git repo, use the current working directory.
2. Read `agent-context.toml` at the repo root when present, for `repo_slug`, `planning_root`, and `planning_root_env`.
3. Resolve the planning root, first match wins: the environment variable named by `planning_root_env` when set and non-empty, then `planning_root` from the config (expanding `~`), then repo-local `docs/plans/`.
4. Workspace root is `<planning-root>/<repo-slug>/` for an external root, or `<repo-root>/docs/plans/` for the repo-local default.
5. If several active plans match, ask the user which one to execute.

If a config names a planning root that does not resolve, stop and ask. Do not guess a path.

Completed plans are archived to `<workspace-root>/_archive/<same-basename>/` for an external root, or `<repo-root>/docs/archive/plans/<same-basename>/` for the repo-local default.

## Setup

Read `plan.md` first. Inspect:

- `size` and `depth`
- the plan title (the `# H1` under the frontmatter) — this becomes the PR title
- the `Gates` section — this is the list of legitimate stopping points
- phase/work-item files: `p1-*.md`, `p09-*.md`, `m1-*.md`, `m09-*.md`, and legacy `01-*.md`
- phase directories with their own `plan.md`
- ADR expectations/candidates
- documentation expectations, affected docs, or missing docs called out by the plan
- validation commands
- existing `_DONE.md`, if present

Then read the repo's agent guides — `AGENTS.md`, `CLAUDE.md`, `.cursorrules`, or nearby docs. Implementation must preserve repo-specific constraints and validation rules.

If the plan is missing phase files but marks a work item as `sub-phases required`, write those sub-phase files before implementation.

If `_DONE.md` already exists for the requested plan, inspect it and the current plan status before continuing. Ask before re-running completed work unless the user explicitly requested a follow-up or repair.

If `plan.md` has no `Gates` section — an older plan, or one written by hand — derive the gate list from the phase files' `Review gate:` values and say in your first response what you concluded. Absence of the section is not a reason to stop after every phase.

## Open The Pull Request Early

Open the PR as soon as there is a first commit, before the work is finished and before validation passes. The point is to get CI running against real code while there is still time to react to it, and to give the user and other agents a durable place to see the work.

1. Confirm or create the feature branch. Never implement on `main`, `master`, or another protected base branch. When you create the branch yourself, name it from the plan slug; when the harness already created one, leave it alone.
2. Make the first scoped commit, push with `git push -u origin HEAD`, and open a **draft** PR immediately.
3. Title the PR `<type>: <plan title>`, where the type is the conventional-commit type for the dominant change (`feat`, `fix`, `refactor`, `docs`, `ci`, `chore`) and the title is the plan's `# H1`. This is what makes a PR list readable against a planning workspace.
4. Start the body with a plan marker on its own line so PRs can be searched by plan:

```md
Plan: <repo-slug>/<planning-dir-basename>
Path: <resolvable path to plan.md>
```

   Follow it with current scope from the plan, and resume notes: what another agent should read first, usually `plan.md`, the phase files, and `_DONE.md` if it exists.
5. Keep the body current as commits land — completed phases, validation status, deviations, and next work. Push each implementation commit promptly.
6. Record the PR URL in `plan.md` frontmatter as `pr: <url>`, and later in `_DONE.md` and the final response.

```bash
gh pr create --draft --base main --head "$(git branch --show-current)" --title "<type>: <plan title>" --body-file -
```

If PR creation or pushing is blocked — missing `gh` auth, no remote, branch policy, network failure — record the blocker in one line, continue local implementation, and report it at the end. A blocked PR is a note, not a stop.

## Draft Or Ready

The PR stays **draft** while any of these is true:

- phases remain
- a gate is pending
- CI is not green

Mark it **ready for review** when all three clear: every phase is done, CI is green, and no gate is pending.

If the plan's last act is a gate, the PR stays draft and the handoff says so — the user marks it ready, or tells you to. Never mark a PR ready to satisfy a gate.

```bash
gh pr ready
```

## Execution

For each work item:

1. Execute directly or delegate to another agent when appropriate and available.
2. Keep the work inside the stated scope.
3. Review every delegated result before moving on.
4. Re-run the work-item validation commands.
5. Record phase-level implementation results when phase files exist.
6. Update relevant documentation when the change alters public behavior, workflows, architecture, commands, package/module purpose, configuration, operations, or planning/process conventions.
7. Check for shortcuts: TODOs, stubbed logic, suppressed warnings, disabled tests, scope creep, stale docs, or unrelated refactors.

If a phase says `sub-phases recommended`, decide whether to split before execution. If it says `sub-phases required`, split before execution.

Delegated agents do not commit.

When recording phase-level implementation results, append a short section to the phase file instead of renaming it:

```md
## Implementation Result

Status: done
Completed: YYYY-MM-DD
Commit: pending

- Changed: ...
- Validated: ...
- Deviations: none
```

After the final commit exists, update `Commit: pending` entries with the commit SHA when practical.

## Model Selection

Delegation must not default to the most capable model:

- When delegating a work item to another agent, pass the phase's `Model:` suggestion via the agent `model` parameter. If the plan predates model suggestions, choose per the ladder `haiku -> sonnet -> opus -> fable`, defaulting to `opus` or the session model, whichever is smaller.
- Never delegate to a model larger than the current session model without asking the user first.
- Read-only discovery/search delegations (locate files, summarize code) default to a small model regardless of the phase model.
- Escalate one tier when a work item stalls: validation fails twice with the same error class or an unchanged hypothesis, or the delegated agent reports being blocked. Report each escalation and what triggered it.
- De-escalate freely for mechanical follow-ups discovered mid-phase.
- When reviewing a smaller model's result, look for the shortcut signature: loosened tolerances, weakened or deleted assertions, disabled tests, quietly narrowed scope. Any delegated diff that touches validation code gets extra scrutiny.

## Stop And Ask

Pause and hand back when:

- You reach a declared gate.
- The plan is ambiguous or contradictory on something you must decide now.
- Validation fails twice for the same work item with no new signal.
- Fixing an issue would expand scope or change public APIs beyond the plan.
- A hard bug appears that needs real debugging and a decision about how far to chase it.
- The planning root or requested plan path cannot be resolved.
- An action needs human authority: a destructive operation, a merge, a release, anything outside the repo.

**This list is closed. If the reason you are about to stop is not on it, keep going.**

In particular, do not stop to:

- report progress at a phase boundary whose `Review gate:` is `none`
- ask permission to continue to the next phase
- ask whether to commit, push, or open the PR — the pipeline already answers all three
- announce that implementation is done and ask whether to push
- ask whether to mark the PR ready — the Draft Or Ready rule already answers it
- wait out a CI run you could be watching

When you do stop, state the single next action in one line, so that `go` is a sufficient reply.

## Gates

At a declared gate, hand off properly. If the repo documents its own procedure — for example `docs/process/review-gates.md` — follow it. Otherwise:

- State the exact gate questions and what "pass" looks like. A gate without questions is a status update.
- For anything the reviewer must look at or operate, start the server or produce the artifact yourself and hand over a working link. Never hand back "run it yourself to see".
- Post screenshots or artifacts into the conversation as well as linking them, so the gate can be answered asynchronously. Label the options and state your lean.
- Say where the work stands: PR URL, draft status, phases complete, phases remaining.

After the gate is answered, resume without re-planning and run to the next gate or to the PR.

## Validate

Run the plan's validation commands, plus whatever the repo documents as its pre-push gate. Prefer the repo's own aggregate command over a hand-assembled subset — matching CI locally is the point.

If validation fails, fix the smallest real issue that explains the failure and re-run. Two failures on the same work item with no new signal is a Stop And Ask.

## Commit

Create conventional commits at sensible checkpoints. For a small plan this is usually one or two commits; for phased work, commit at completed phase boundaries or other useful handoff points. Prefer small commits that tell a story over one large commit at the end.

Commit code and ADRs together. Include ADR paths in the commit body when ADRs were created. Include a `Plan:` line pointing to the planning directory basename so commit history and the PR both link back to the planning artifact.

Push each commit after it is created. A commit is not a checkpoint to stop at — commit, push, keep going.

## Push And Watch CI

After the final commit for the current stretch of work, push and watch CI to green.

```bash
gh pr checks --watch --interval 20
```

Use `gh pr checks` first: it follows the PR's check rollup and exits successfully only when the PR is green. Use `gh run list`, `gh run watch --compact --exit-status`, and `gh run view --log-failed` when a check fails, stalls, or needs detailed logs.

If no checks appear, inspect changed paths, branch protection, and workflow triggers before treating that as a failure.

When a check fails:

1. Collect failing check names and links: `gh pr checks --json name,workflow,bucket,state,link`.
2. Find the run: `gh run list --branch "$(git branch --show-current)" --commit "$(git rev-parse HEAD)" --limit 10`.
3. Read failed logs: `gh run view <run-id> --log-failed`.
4. Fix the smallest real issue that explains the failure.
5. Run the targeted local validation that matches the failure.
6. Commit, push, and watch again.

Stop and ask when the same check fails after two focused repair attempts without a new signal, when the failure depends on secrets, external services, permissions, or infrastructure state, or when fixing it would expand scope beyond the plan.

Do not rebase, squash, merge the base branch, or rewrite commits unless the user asked or CI proves it is necessary. Do not merge the PR unless the user explicitly asks.

## ADRs

Do not write `summary.md`.

After implementation and validation, evaluate ADR candidates against the completed diff.

Create accepted ADR files in the repo when a decision meets this criterion:

> The change chooses a direction among plausible alternatives and that choice has lasting architectural, operational, security, data-model, API, workflow, product, embedded, or cross-repo/process consequences.

Use:

```text
docs/adr/YYYY-MM-DD-short-title.md
```

If no ADR is warranted, state that in the final response.

Historical ADR backfill is different: produce an ADR candidate list for human review before creating historical ADR files unless the user explicitly approved the candidates.

## Documentation

Before final validation, review the completed diff for documentation impact.

Update docs when the implementation changes:

- public commands, setup, deployment, validation, or troubleshooting steps
- package/module purpose, especially `README.md` files next to changed packages
- architecture, runtime boundaries, module ownership, data models, APIs, or workflows
- user-visible behavior, UI flows, permissions, operational runbooks, or process conventions
- ADR-worthy decisions that should be durable in `docs/adr/`

Prefer existing repo docs near the changed code before adding new docs. If no docs need changes, record why in the implementation log or final response. If docs are intentionally deferred, record the follow-up explicitly.

If the repo keeps a defect or debt register, follow its conventions: close the entry for a defect this work fixes, and append to the incident log of a standing burden this work hit.

## Implementation Log

After implementation, validation, ADR handling, and the final commit, write `_DONE.md` in the planning directory. This is the completion log for what actually happened, separate from ADRs and separate from `notes.md`.

Use frontmatter:

```md
---
kind: implementation-log
status: done
repo: <repo-slug>
plan: plan.md
completed: YYYY-MM-DD
commit: <sha>
pr: <url>
adrs:
  - docs/adr/...
---
```

Then include:

- Outcome.
- Completed work.
- PR URL, draft/ready state, and final CI state.
- Validation commands and results.
- Deviations from the plan, or `None`.
- Documentation updated, or why no docs were needed.
- ADRs created, or why no ADR was warranted.
- Follow-up work that remains outside the completed scope.

Update `plan.md` frontmatter to `status: done` and add `completed: YYYY-MM-DD`, `commit: <sha>`, and `pr: <url>`.

Do not rename `plan.md` or phase files after completion.

## Archive

After `_DONE.md` is written, move the completed planning directory to the archive location resolved in Plan Location, preserving the basename. If a destination already exists, add a short suffix such as `-v2` rather than overwriting it.

For repo-local planning, include the archive move in the implementation commit when possible. For an external planning workspace, the move is not part of the repo diff — just report it.

Archive only when the plan is actually finished. A plan that stopped at a gate stays active.

## Completion

Finish with:

- Outcome.
- PR link and whether it is draft or ready.
- Current CI state, and any fixes pushed during CI repair.
- Files changed.
- Validation commands and results.
- Documentation updated, or why no docs were needed.
- ADRs created, or why none were warranted.
- Archive path, if archived.
- Any remaining follow-up work, or the gate questions if you stopped at a gate.
