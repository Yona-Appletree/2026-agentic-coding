---
name: yona-handoff
description: Hand this session's unfinished work to another agent — land and push every change, ensure a draft pull request exists, write a dated handoff document in the durable planning directory, list it in the day's handoff roll-up, and hand back its exact path plus a short restart prompt. Invoked manually.
---

# Yona Handoff

This skill is invoked by hand, and only by hand. When it runs, the decision to stop has already been made and the work is going to another agent. Do not weigh whether a handoff is warranted, propose finishing the work first, or ask whether the user really wants to stop. Execute.

Agents are amnesic. The agent picking this up starts from zero and can recover only what is on disk and on the remote. A handoff is the act of moving everything valuable out of the conversation before the conversation disappears.

**The definition of done: every change is pushed, a draft PR marked `[HANDOFF]` points at it, a dated handoff file exists in the durable planning directory, that handoff is listed in the day's roll-up document, and the user has its exact path plus a prompt that restarts the work.**

```text
land the code → draft PR → handoff file → session title → roll-up entry → path + restart prompt
```

Parked work is marked so it is visible at a glance — `[HANDOFF] ` on the PR title, and on the session title where the harness allows it. Every marker this skill applies carries an instruction for removing it, inside the handoff document, so the marks mean "still parked" rather than "was handed off once".

Run all four steps without checking in. There are no gates in this skill; the only legitimate stopping points are in Stop And Ask at the end.

## Relationship To The Other Skills

- `yona-implement` finishing a plan writes `_DONE.md` and archives the plan. That is completion, not handoff.
- `yona-push` takes finished work to a green PR. It assumes local checks passed.
- `yona-handoff` is the unfinished-work counterpart. Broken builds and red CI are expected input, not problems to solve. **Never archive a plan during a handoff** — the plan stays `status: active`.

## 1. Land The Code

Nothing stays local, and nothing stays uncommitted.

Start by seeing the whole picture:

```bash
git status --short
git log --oneline @{u}..HEAD 2>/dev/null || git log --oneline -10
git diff --stat
```

**Small wrap-ups are allowed.** A missing import, a stale comment, a rename you were halfway through, deleting a scratch file — finish those. Timebox it to a few minutes.

**Big things are not.** Do not start new work, do not fix the failing test, do not refactor to make the diff prettier. If it is not a couple of minutes of tidying, it is handoff material. Write it down instead.

Account for every file in `git status`. Each one is either committed or deliberately deleted — say which in the handoff. Do not leave a dirty tree behind, and do not sweep unexplained files into a commit without mentioning them.

### WIP commits

When the tree does not build, tests fail, a migration is half-applied, or the change is otherwise unfinished, **commit it anyway**. Unfinished work on the remote beats finished work on a laptop nobody opens.

Pre-commit hooks and local check gates will reject that commit. Bypassing them is permitted here — and only here — because the alternative is losing the work:

```bash
git commit --no-verify -m "wip: <subject> — UNFINISHED, <what is broken>" \
  -m "<what remains, in a sentence or two>" \
  -m "Handoff: <planning-dir-basename>/<YYYY-MM-DD-hhmm>-handoff.md"
```

Rules for a WIP commit:

- The subject line must be unmistakable on its own. Someone reading `git log` a month from now sees only that line — `wip:` plus an explicit statement of what is broken. Never let unfinished work wear a normal conventional-commit subject.
- It must state what is broken, not just that something is.
- It must land on a **draft** PR (step 2). A bypassed check gate is only acceptable behind a draft.
- Bypass the hooks, never weaken them. Do not delete a test, loosen an assertion, or edit the hook config to get the commit through.

Work that is finished and passing gets a normal conventional commit and normal hooks. Do not use `--no-verify` out of impatience.

### Push

```bash
git push -u origin HEAD
```

Never end a handoff with unpushed commits. Never commit to `main`, `master`, or another protected base — if the work is sitting on one, create a branch from the current state first and say so in the handoff.

If pushing is genuinely blocked (no remote, broken auth, branch policy), that is the single most important fact in the document: put it at the top of the handoff, name the exact commits at risk and where the local branch or worktree lives, and tell the user in your final response.

## 2. Ensure A Draft PR

```bash
gh pr view --json number,url,title,state,isDraft,headRefName,baseRefName
```

If none exists, create one:

```bash
gh pr create --draft --base main --head "$(git branch --show-current)" \
  --title "[HANDOFF] <type>: <title>" --body-file -
```

### The `[HANDOFF]` title marker

**Every PR this skill touches gets a `[HANDOFF] ` prefix on its title**, in front of the conventional-commit type. Scanning a PR list should answer "what is parked waiting for someone to pick it up?" without opening anything.

When the PR already exists, retitle it:

```bash
gh pr edit <n> --title "[HANDOFF] <existing title>"
```

Two rules: never double-prefix a title that already carries the marker, and never let the marker replace the real title — it is a prefix, not a rename.

The marker is a claim that the work is parked, so it has to come off when the work is picked up again. Step 3 puts that instruction in the handoff document itself, where the next agent is guaranteed to read it.

### PR body

The body starts by saying the work is unfinished — first line, not buried — then:

- the plan marker, when a plan exists:

```md
Plan: <repo-slug>/<planning-dir-basename>
Path: <resolvable path to plan.md>
```

- a link or path to the handoff file (write the body now, update it with the final path after step 3)
- what works, what does not, and what the next session should do first

If a PR already exists and is marked ready for review while the work on it is now unfinished, put it back to draft with `gh pr ready --undo` and say so.

**Do not watch CI to green, and do not fix failing checks.** Record the state as it stands and move on:

```bash
gh pr checks --json name,bucket,state,link
```

Red CI is a fact for the handoff, not a task to adopt. If `gh` is unavailable or unauthenticated, record that in one line and continue — a blocked PR is a note, not a stop.

## 3. Write The Handoff File

### Where it goes

Resolve the durable planning workspace exactly as `yona-plan` does:

1. Repo root via `git rev-parse --show-toplevel`.
2. Read `agent-context.toml` at the repo root for `repo_slug`, `planning_root`, `planning_root_env`.
3. Planning root, first match wins: the env var named by `planning_root_env` when set and non-empty, then `planning_root` (expanding `~`), then repo-local `docs/plans/`.
4. Workspace root is `<planning-root>/<repo-slug>/`, or `<repo-root>/docs/plans/` for the repo-local default.

If a config names a planning root that does not resolve, stop and ask. Do not guess a path.

Write the file **inside the planning directory the work belongs to**. When the work spans several plans, or has no plan at all, write it at the workspace root. When there is no plan and the work deserves one, say so in the handoff and let the next session run `yona-plan` — do not write the plan now.

### Filename

```text
<YYYY-MM-DD-hhmm>-handoff.md
```

Local time, 24-hour, captured when you write the file. **Never overwrite an earlier handoff** — the timestamp exists so successive handoffs on the same plan accumulate as a lineage. Older directories contain a plain `handoff.md`; read those without complaint and never rename them.

### Who you are writing for

An agent with an empty context window that has never seen this repo, this plan, or this conversation. Every judgment you made today is gone unless it is in this file.

Two failure modes, equally bad. Restating what `plan.md` and `notes.md` already say wastes the reader's context — link those instead. Leaving out what only existed in the conversation destroys it. The handoff carries what is **not written down anywhere else**.

### Structure

Adapt to the work, but this is the shape that has held up:

```md
# Handoff — <subject> (<where it stands, in a few words>)

Written <YYYY-MM-DD HH:MM> by the session that <did what>. Read this,
then `plan.md`, then <the next file>.

**Planning dir**: <absolute path>
**Repo**: <repo> — branch `<branch>`, PR #<n>, worktree `<path>`

## Clear the handoff markers first

You are picking this up, so it is no longer parked. Before any other work:

1. Strip the prefix from the PR title:
   `gh pr edit <n> --title "<the title without [HANDOFF] >"`
2. Strip the prefix from the session this came from. It is not your own
   session, so you can rename it: list the user's other sessions, match on
   branch `<branch>` or PR #<n>, and set the title without `[HANDOFF] `.
   If nothing matches, say so and move on — do not hunt.
3. Tick this handoff's checkbox in the roll-up:
   `<absolute path to the day's roll-up document>`
   Tick only the section titled `<session title>` — the other sections are
   other people's parked work.

This is not bookkeeping. A marker left in place says "nobody has picked this
up", and once that is wrong the user cannot tell parked work from live work.

## 0. TL;DR and immediate next action
## 1. State of the world          <- a table when there are milestones/phases
## 2. Where the code is           <- branch, PR, HEAD sha, worktree, key commits, dev server
## 3. What is done
## 4. What is NOT done, and what is broken
## 5. Conventions and traps that bit this session
## 6. Decisions made, and why     <- settled; do not relitigate
## 7. Open questions that need the user
## 8. Cross-session coordination  <- when other sessions or PRs touch this work
## 9. Files in this planning directory
```

**Immediate next action** is one concrete action, not a summary of remaining work. "Watch CI on #236, mark ready when green" — something the next session can start on without deciding anything.

### The bar

- **Locations, not descriptions.** Branch names, commit SHAs, PR numbers, absolute or repo-relative paths. Worktrees get pruned and the local branch name may differ from the remote one — record both. Never write "the file we were editing".
- **Separate verified from guessed.** If a number is an approximation, a value came from a photo, or a claim was never run, mark it. A confident wrong fact in a handoff propagates for weeks.
- **Never claim a green check you did not watch.** Paste the command and what it actually printed.
- **Traps as imperative rules.** Every convention that cost you time today becomes a line the next session reads before coding: what to never do, and what breaks when you do it.
- **Expensive discovery is the highest-value content.** Anything that took deep reading, a long subagent run, or hardware to learn goes in, even if it is not needed for the next step. Re-deriving it is the most expensive thing the next session can do.
- **Separate "known gap, recorded, not a bug" from "bug".** Also separate "needs the user" from "needs an agent" — a decision only the user can make should be a numbered question with your lean, not a task.
- **Settled decisions get their reasoning.** Say why, and say plainly that reopening it is not wanted. Without the why, the next session relitigates it.
- **Honest failure.** What is broken, what is unverified, what you ran out of time for, what you got wrong. A handoff that reads like a status report to a manager is worthless.

## 4. Find The Session Title, And Mark The Session

You need this session's title twice: it is the heading of the roll-up entry in step 5, and the thing that gets the `[HANDOFF] ` prefix.

**Reading it.** No tool returns it — session-management tools operate on *other* sessions, and the session list excludes the current one. In Claude Code on macOS the metadata is on disk:

```bash
grep -rl "$(git rev-parse --show-toplevel)" \
  ~/Library/Application\ Support/Claude/claude-code-sessions/ 2>/dev/null
```

Each match is a JSON file with `sessionId`, `title`, `cwd`, `branch`, and `lastActivityAt`. Match on `cwd` and `branch`; when several sessions share a worktree, the current one is the most recent `lastActivityAt`. This is an internal path, not a supported API — if it is missing or the shape has changed, fall back to the branch name as the heading and say in your report that the title could not be read. Do not go hunting.

**Setting it.** You cannot. The harness refuses a self-rename outright — *"Refusing to rename the current session from within itself"* — even given the correct session id. Do not spend attempts on it. Instead put one copy-ready line at the end of your report:

```text
Rename this session to: [HANDOFF] <current title>
```

Removing the marker later is not the user's job; the picking-up agent does it, per the instructions at the top of the handoff document.

## 5. Append To The Day's Handoff Roll-Up

One document per day collects every handoff, so parked work can be found without remembering which plan it belonged to.

```text
<workspace-root>/_handoff/<YYYY-MM-DD> - Handoffs.md
```

`<workspace-root>` is the one resolved in step 3 — `<planning-root>/<repo-slug>/` for an external planning root, or `<repo-root>/docs/handoffs/` for the repo-local default. Local date. Create the directory and the file when they do not exist.

**Append a section at the end. Never rewrite, reorder, or re-tick existing sections** — earlier entries belong to other sessions and may already be ticked.

~~~md
## <session title, from step 4>

Created at <YYYY-MM-DD> @ <HHMM>

- [ ] Tick here when handed off to new agent

`<absolute path to the handoff file>`

**Branch / PR:** `<branch>`, <push and tree state>, HEAD `<sha>`. Draft [PR #<n>](<full github url>) — <one clause on the PR's state>.

**Restart prompt:**
```
<the same restart prompt you give in step 6>
```
~~~

Details that matter:

- **PR links are real Markdown links** to the full URL, not bare `#123`. Take the URL from `gh pr view --json url,number` rather than assembling it by hand.
- **Keep the checkbox line verbatim.** It is the user's tracking mechanism, and the picking-up agent ticks it (see below).
- **Write the restart prompt as flowing sentences separated by spaces**, not hard-wrapped lines. Copying out of a rendered Markdown block can drop newlines and glue words together — a prompt that survives that is worth more than one that looks tidy in the file.
- If a section for this same session already exists in today's file — a second handoff on one day — append a new one rather than editing the old. Two entries is accurate history; one edited entry is not.

Record the roll-up path in the handoff document's marker-clearing section, and add ticking the checkbox as the third thing the picking-up agent does.

## 6. Report Back

Finish with, in the chat:

1. **The exact path to the handoff file.** Absolute, on its own line, so it can be clicked or copied without reconstruction.
2. **The path to the roll-up document**, and confirmation that the section was appended.
3. Branch, PR link with its `[HANDOFF] ` title, and draft state.
4. What was committed — including anything committed as WIP with checks bypassed, called out explicitly.
5. CI state as last observed, or that it was not checked.
6. The session rename line from step 4, and anything else waiting on the user.
7. **The restart prompt**, in a fenced block so it can be copied straight into a new session.

The restart prompt is short — two to four sentences. It does not reconstruct state; the handoff file does that. It names the file by absolute path, states the single next action, and mentions any decision the user still owes.

```text
Continue the <subject> work. Read
/abs/path/to/<YYYY-MM-DD-hhmm>-handoff.md first — it has the full state.
Immediate next action: <the one thing>.
<Any pending user decision, one clause.>
```

## Stop And Ask

Stop and hand back to the user when:

- Pushing is blocked and one attempt to fix it did not work.
- Committing would include secrets, credentials, or data that should not reach the remote.
- Landing the work requires a destructive action: force-push, history rewrite, discarding someone's changes, or committing directly to a protected branch.
- The planning root is configured but does not resolve.

**This list is closed. If the reason you are about to stop is not on it, keep going.**

In particular, do not stop because:

- the build is broken or tests fail — that is the expected input to this skill
- CI is red
- the work feels too unfinished or too small to be worth a handoff
- a PR already exists
- you are unsure which planning directory it belongs to — pick the closest, say why, and note the alternative in the file
