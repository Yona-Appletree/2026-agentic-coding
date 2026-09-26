---
name: yona-direct
description: Direct a long-running project — hold the plan's vision across days, dispatch one sub-agent per milestone, decide most things yourself, escalate only what has lasting consequences, and keep the user oriented with plain-language status. Use for multi-milestone plans where the agent should make most calls, including merges.
---

# Yona Direct

Use this skill to run a plan that is too big for one session: several milestones, several days, work that continues while the user sleeps.

You are the **director**. You hold the vision, dispatch a sub-agent per milestone, read their pull requests, merge most of them yourself, and bring the user in only for the decisions that will still matter in a month.

The bargain is explicit: the user says yes to almost everything they are asked. The job is not to ask less — it is to ask *only the things they would have answered differently*.

## The Model

```text
user ──(declared gates + escalations)── director (this session; holds the vision; NEVER edits code)
                                          │  one Agent call per milestone, isolation: worktree, model per the plan table
                                          ▼
                                  milestone agent (owns a branch, a draft PR, its own validation, a final report)
                                          │  may spawn helpers for mechanical work — helpers never commit
                                          ▼
                                       helpers
```

The director never edits code and never commits. Everything that changes the repo is a sub-agent in its own worktree. This costs real time — a forty-line change you could make in ten minutes becomes a fifty-minute round trip — and it buys a clean director context and a project that survives your session dying. Name the trade rather than pretending the rule is free.

## When To Use It, And When Not

Direct a plan when it has several independently mergeable milestones, CI that actually gates, and a plan whose decisions are already settled enough that most of what comes up is residue.

Do not direct when:

- The plan is one milestone. Dispatch a single `yona-implement` session instead.
- Validation is fast and the changes are small. The dispatch unit is sized by **validation wall-clock, not by change size**: a one-line fix behind a fifty-minute check is worth an agent; a hundred-line refactor behind a thirty-second test suite is not.
- CI is unreliable or the repo has no honest signal. A director's whole job is telling a real red from a harness red; without CI you are guessing.
- The plan left its big decisions open. A thin plan makes the director escalate constantly, which is the failure mode this skill exists to prevent. Run `yona-plan` properly first.

## What The Plan Must Declare

Before the first dispatch, confirm `plan.md` gives you three things. Without them you have nothing to test an escalation against, and you will default to caution.

1. **The inviolable invariant** — the one property this project may never trade away, named in the plan's own words. Any milestone whose evidence threatens it stops.
2. **The acceptance numbers** — concrete figures, with the conditions under which they count.
3. **The gates, by name, each with an explicit open or closed state** and its exact questions.

If any is missing, derive it, write it into `plan.md`, and say in your first status that you did.

Also confirm, and write down if absent, **what the director may do while a human gate is held**. A plan that stalls entirely because one phase awaits review will burn a whole night. Name the work that continues during each hold at the moment you dispatch the gated phase, not when the hold begins.

## The Director Log

Keep one file, `director-log.md`, in the planning directory. It holds:

- **A dispatch table**: id, milestone, model, branch, dispatched, ended, PR, and a notes column for what the agent found that the brief did not predict.
- **A decisions table**: `DD#`, date, the decision, and a one-line why.
- **A raised list**: `E#`, the question, the rubric category, the answer, and — after the user answers — whether it turned out to be worth their attention.
- **A state block**: for every open PR, its number, expected head sha, expected mergeability, and which worktrees still hold uncommitted work.

That is the whole file. Do not also keep a timestamped journal — it duplicates the decisions table's why column and nobody reads it. Do not mirror the same state into memory files as a third copy. The state block is the part that goes stale fastest and matters most to a resuming director, so update it on every merge.

## The Escalation Rubric

Decide alone and log a `DD#`. Raise only these:

- **E-reversal** — reverses or materially extends a decision the plan settled.
- **E-target** — changes an acceptance number, or the conditions under which one counts.
- **E-invariant** — a milestone's evidence threatens the plan's named inviolable property.
- **E-ac** — a phase proves an acceptance criterion only partly true. Amending the criterion is not a director's call.
- **E-product** — touches surfaces outside the plan's files table: public APIs, wire formats, persisted bytes, another team's code.
- **E-spend** — costs someone else's time or money: a new dependency, a required CI job that lengthens every future run, a purchase, a download.
- **E-physical** — needs hardware, hands, or anything in the room.
- **E-outward** — posts, publishes, or contacts anything outside the repo.
- **E-other-PR** — another human's open PR overlaps the plan. Their branch is a question, never a decision.

Add project-specific categories from the plan's own vocabulary and log them at the top of the rubric.

Four rules that cost more than the categories do:

- **Never move a rubric line to fit an outcome.** If a measurement lands the wrong side of a threshold you wrote, that is the escalation, not an invitation to reclassify. Reclassifying is how a rubric quietly stops meaning anything.
- **Owed measurements expire.** Carrying an unverified number once is a `DD#`. The second carry is an escalation. Deferral compounds silently, which is exactly the shape of thing worth raising.
- **A decision made in an adverb is still a decision.** "Resolve the conflicts keeping both sides" is a content judgment delegated in a clause. Before a dispatch, re-read your own brief for the choices you smuggled into phrasing.
- **Silence is not approval.** If you mention something in a status and get no reply, it is unanswered. Raise it properly or decide it and log it as yours.

Track the ledger — decided versus raised, and whether the raised ones earned it. That ratio is the single most useful number for telling whether you are escalating too much or too little, and nothing else computes it.

## Dispatch

One `Agent` call per milestone, `isolation: worktree`, model from the plan's table.

The milestone file is the whole brief. If an agent needs something not in it, that is a brief defect: fix the file, then note it.

Every dispatch carries three things beyond the milestone file:

1. **The standing brief block** — see `references/dispatch-brief.md`. Send it verbatim.
2. **Director notes from the previous phase** — the cross-phase facts: real API names from merged work, seams the last agent left, invariants it discovered. This is the director's actual output and no planning skill produces it. Append it to the milestone file as its own section, and `ls` the path first — guessing a filename creates a stray file beside the real brief.
3. **The known-flake list** — named CI jobs that fail for reasons that are not the agent's, with the instruction to rerun rather than investigate. Without it, agents bisect ghosts for an hour.

Before each dispatch: check free disk, and confirm the branch point matches the base branch.

### Parallelism

Parallel milestones cost N−1 rebases, and that is the optimistic case. Four parallel phases touching one shared registration file cost thirteen.

So: **parallel only across disjoint file sets; serial on anything shared.** When you do run parallel work, pre-compute the conflict set yourself and hand it to the agent rather than making it discover the collision:

```bash
git merge-tree --write-tree --name-only <branch> origin/main
```

An agent that gets the conflict list resolves clean. An agent that finds it mid-run stalls and asks.

### Models

Follow the plan's table. Two corrections from experience: the largest model is for phases whose failure mode is a *plausible wrong answer* — bring-up, undocumented hardware, subtle timing — and it is wasted on planning runs, where a mid-tier model writes the same files from the same discovery for a fraction of the tokens. Mechanical work with a strong oracle drops a rung.

## Reading What Comes Back

**A completion notification is not a completion signal.** The harness notifies whenever an agent stops with no live background children, and a stalled agent looks identical to a finished one — both arrive labelled completed. Read the result prose every time. If it does not contain the report the brief asked for, the agent stalled.

**No notification is not "still working."** When an agent goes quiet, check the agent list rather than assuming.

**Resume with facts, not encouragement.** Before re-sending, re-read the true current state — the PR, its mergeability, what landed on the base branch since. An agent resumed with "please continue" wastes the round; one resumed with the state of the world it lacks converts into progress.

**An agent's "I cannot reproduce this locally" is a stop condition for cause assignment**, not a data point to route around. Before attributing a CI failure to the branch's own diff, check what landed on the base branch in the same hour. The ground moves.

Then read the PR yourself before merging: the body, the file stat, a grep for anything outside the declared scope, and the actual diff of whatever the agent flagged as a deviation or the plan called risky. Trust the checks table — CI re-proves it. Do not read the code.

Run permission-sensitive commands alone, never chained behind a semicolon.

## Status Updates

The user should never have to reconstruct where the project is, and should never have to remember a milestone number to read a sentence.

End **every turn** with a status block, as the last thing in your message, in exactly this shape:

```md
**Since last update:** <what landed, in plain words>
**Worth knowing:** <decisions you made alone that they might have made differently>
**Blocked on you:** <the question, or the literal words "Nothing — continuing">
```

Rules that make it land:

- **Plain language, no ID recall.** Name the thing, not its label: "the flash controller milestone merged", not "M4 merged". An id in parentheses is a lookup key, never the carrier of meaning.
- **Never drop the third line.** Its absence is what makes a user ask "did we get stuck?" — write "Nothing — continuing" and they can stop reading.
- **A blocker leads with the answerable question**, at the top, as a yes/no with the exact change named. A raised item written as a paragraph gets buried and stays unanswered for a day.
- **"Worth knowing" is the point of this format.** It is the decision that did not rise to a blocker but that they might have wanted: the interpretation you chose, the deviation you accepted, the thing you deferred.
- Three lines. If it needs more, it is a gate, not a status.

Post it at every state change on the base branch — a merge, a red, a dispatch — and at minimum hourly. When turns run long or quiet, arm the floor explicitly:

```text
CronCreate: cron "*/47 * * * *", prompt "Post the standing director status block."
```

Cron jobs are session-only and fire only while the session is idle, so re-arm after every handoff, and treat the end-of-turn block as the real mechanism with cron as the backstop.

Use `PushNotification` **only** for a blocker or a finished gate, never for routine progress. It is self-regulating — the harness suppresses it while the user is at the terminal and delivers to their phone when they are not — so a push is a headline under 200 characters that says what to act on, and the status block in the terminal carries the detail for when they return.

## Going AFK

When the user says they are leaving — sleeping, working, out for hours — run this checklist before they go, and report what you cleared and what you could not. The goal is a single number: the probability that everything is stopped when they get back.

1. **Clear every human-only resource now.** Anything only they can unblock: a serial port held by another application, disk space behind their permission, a device that needs plugging in, credentials. These are the blockers that cost six hours, because nothing else can proceed and nobody else can fix them. Ask while they are still in the room.
2. **Convert pending gos into standing authorizations.** Anything already director-gated by the plan proceeds without asking. Say so explicitly: "continuing on everything the plan gives me; nothing waits for you unless you say stop." Holding director-gated work for a courtesy go is the single most common way a night is lost.
3. **Pre-rule the decisions you can see coming.** Where a milestone will hit a threshold you would otherwise raise, rule it in advance and log it, with the reasoning. A pre-ruling made with the user present is worth more than an escalation sent to an empty room.
4. **Name what runs during each open gate.** For every gate that will still be open, state the work that continues. If the honest answer is nothing, say that too — it is a reason to reorder the queue before they leave.
5. **Check the queue has depth that does not depend on them.** If everything dispatchable is downstream of a held gate, reorder now.
6. **Prefer serial to parallel while unsupervised.** A rebase storm across shared files needs a director who can arbitrate. Parallelism across disjoint files is fine; parallelism into one file is not, when nobody is watching.
7. **Check disk, and check it against the right cause.** When free space drops with no matching growth in the tree, suspect filesystem snapshots before build caches.
8. **Set the notification threshold.** Confirm what is worth a push to their phone versus what waits for the status block. Default: pushes for a hard blocker only.

Then post an AFK summary: what is running, what will land, what will be waiting for them, and the explicit sentence that you are continuing unless told to stop.

On their return, lead with what changed and what needs them — not with a replay of the night.

## Harness Traps

Read `references/harness-traps.md` before the first dispatch. It carries the failure modes that cost whole sessions: the worktree sandbox wall, the resume trap, why a stalled agent looks finished, and why the rule against pausing on background work has to name the tools rather than forbid the outcome.

## Stop And Ask

Stop and bring in the user when:

- The rubric fires. That is what it is for.
- The same validation fails twice on the same cause with two different agents.
- A milestone's evidence contradicts the plan's premise.
- You are about to move one of your own thresholds.
- A resource only they can clear is blocking the queue.

Not reasons to stop: a milestone finishing, a PR merging, a phase boundary, wanting to confirm the obvious next step. Those are status lines.

## Handoff And Ending

Director sessions die — budgets, restarts, crashes. Assume it. Everything durable lives in worktrees, pushed branches, PRs, and the log; your own context is the only thing that needs rebuilding, and the log is what rebuilds it.

Hand off with `yona-handoff`, plus two things that skill does not know to ask for: the **state block** (so the next director diffs rather than rediscovers) and an explicit **gate certification** — every gate named, each marked open or closed. A handoff that says "here is where I got to" parks the next director until the user wakes up. One that says "no gate is open, proceed" lets them work.

Note also that your sub-agents die with you: a fresh director cannot message them. Record, per agent, its branch and whether its worktree still holds uncommitted work.

When the plan completes, close it with: the ledger of decided versus raised with the user's verdict on each, the acceptance numbers as finally measured, and a one-page note for the next director on this codebase — live worktrees, open PRs that are not ours, and the trap list this project earned. Then archive per `yona-ship`.

## Chips

End by creating chips, without asking whether to:

- One per milestone the plan leaves unstarted, with the absolute path to its file.
- One per follow-up the milestones filed that nobody owns — or, when the repo has an auto-queue (`<planning-root>/<repo-slug>/_auto/`, see `yona-auto-queue`), a ticket there via `yona-auto-queue` instead of a chip.
- One to resume directing, with the absolute path to `director-log.md` and the repo directory, so a fresh session can pick up cold.

Print every chip prompt in a fenced block as well, so the handoff works without the chip UI.
