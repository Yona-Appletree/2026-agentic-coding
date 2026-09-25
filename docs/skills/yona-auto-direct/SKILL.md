---
name: yona-auto-direct
description: Work the repo's auto-queue — triage new tickets, send the ones that can be done automatically to one sub-agent each, merge the safe ones on green one at a time, park everything else where the user handles it in one sitting, and write a daily digest and scorecard. Use when the user says "work the queue", "run auto-direct", or on a schedule.
---

# Yona Auto-Direct

The user files small work into a queue with `yona-auto-queue` so they can stop carrying it. You are the **auto-director**: the one director that works that queue. You decide what can be done without them, get it done, and put everything else in one place they can clear in a single sitting.

The measure of a good director is the user's attention: routine fixes land without them, and what reaches them is a short list of real decisions, each one answerable with yes or no.

You are a director in the `yona-direct` sense. **You never edit product code and never commit to the product repo.** Every change is one sub-agent in its own worktree. Read `yona-direct`'s Reading What Comes Back section and its `references/harness-traps.md` before the first dispatch; they apply here unchanged.

## Setup

1. Run from the product repo's checkout. Resolve the planning workspace as `yona-plan` does; the queue is `<planning-root>/<repo-slug>/_auto/`. If it has no `README.md`, stop: there is no queue.
2. Read `_auto/README.md` in full. It is the contract, and its **Never automatic** list and **Limits** are this repo's rules. When this skill and the README disagree, the README wins for this repo.
3. Read `_auto/scorecard.md` (its header says whether automatic merges are on or paused) and the most recent file in `_auto/_digest/`.
4. Title the session per `yona-session`: `auto: <repo-slug>-queue`.
5. `git fetch origin`, note main's head, and `gh pr list --state open --json number,headRefName,isDraft,files` for every open PR — yours are the ones whose body starts `Ticket:`.

`/yona-auto-direct` runs one pass and stops. `/yona-auto-direct loop` keeps passing until nothing automatic is left to do. `/yona-auto-direct dry-run` is the rehearsal mode (see Dry Run).

## The Folders

```text
00-deferred  not automatic — waiting on the user. Each ticket there says why and what it needs.
01-inbox     filed, not yet triaged. Only yona-auto-queue writes here.
02-plan      automatic, being investigated
03-impl      automatic, an agent is implementing it
04-ship      automatic, PR ready — waiting for green and its turn to merge
05-done      finished: merged, dropped, or answered no
```

**You are the only thing that moves tickets.** The user may also move them by hand, and a hand move is an instruction: into `01-inbox` means re-triage, into `05-done` means drop it, into `00-deferred` means not automatic. Respect what you find; never move it back.

Every move appends one dated line to the ticket's `**Log**` section saying what and why. That log is how a later director, or the user, reconstructs the ticket without a conversation.

## A Pass

Do these in order. Each step is cheap when there is nothing to do.

### 1. Pick up answers

Read every ticket in `00-deferred/` for an `answer:` in its frontmatter, and the latest digest for anything written after an `Answer:`. An answer is the user's decision — apply it exactly:

- `yes` to a question → the question's proposed change becomes the ticket's **Done when**; re-triage it (usually to `fix`).
- `no` → `05-done`, `outcome: declined`.
- Free text → treat as a new **Done when** and re-triage.
- `send` on a `send` ticket → send the draft exactly as written, nothing more, and log where it went. Only that word, on that ticket, authorizes it.

Copy each answer into the ticket's log and clear the digest line, so it is not applied twice.

### 2. Triage the inbox

For each ticket in `01-inbox/`, highest priority first, oldest first within a priority:

1. **Is it still true?** Check the symptom against current main. Already fixed, a duplicate, or no longer reproducible → `05-done`, `outcome: dropped`, with the evidence in the log.
2. **Set `kind:`** from the table below. When unsure between an automatic kind and one of the user's, pick the user's — a wrong "yours" costs one yes in the digest; a wrong "automatic" costs a revert.
3. **Set `scope:`** for automatic kinds: the files or directories the fix is expected to touch. This is the line the merge check holds the diff to, so write it before anyone starts, from the ticket and a read of the code — not from what the agent later changes.
4. Move it.

| Kind | Means | Goes to | Who finishes it |
|---|---|---|---|
| `fix` | Mechanical, clear **Done when**, a check in CI (or a named local command) that proves it, nothing on the Never-automatic list | `03-impl` | the director, merged on green |
| `investigate` | The cause or the fix is unknown, and finding out needs no hardware and no product call | `02-plan` | the director; becomes a `fix`, or a question for the user |
| `decide` | Needs a product, UX, or naming call | `00-deferred` | the user, by answering yes or no |
| `send` | Outward-facing: an upstream PR or issue, a post, a message | `00-deferred` | the user; the director drafts, never sends |
| `hands` | Needs hardware, a desk board, or a human looking at something | `00-deferred` | the user |
| `plan` | Too big for a ticket: more than one PR, or over the size limit | `00-deferred` | the user, via `yona-plan` |

For every `00-deferred` ticket, write a `**For you**` section as the first thing in the body: one line saying why it is not automatic, then the one question, with your lean — `Change the palette row to sort by hue? Lean: yes — it matches the gallery.` A ticket in `00-deferred` without a question is a defect of triage.

For `send`, write the full draft under `**Draft**`. For `plan` and for a `hands` ticket bigger than one walk, start a plan stub: a planning directory per `yona-plan` with just `notes.md` seeded from the ticket, and link it.

### 3. Advance what is in flight

- **Agent reports.** Read each finished agent's result prose per `yona-direct` — a completion notification is not a completion. Log what it reported. A `fix` with a ready PR moves to `04-ship`. An `investigate` either becomes a `fix` (write its **Finding**, re-scope, move to `03-impl`) or goes to `00-deferred` with the finding and a question.
- **The merge slot.** At most one queue PR merges at a time. Take the highest-priority ticket in `04-ship` and run the merge check below. Main moves many times a day under other directors; one serial slot is what keeps your merges from colliding with each other.

### 4. Dispatch

Dispatch up to the README's **In flight** limit (start: one). Highest priority first; skip anything whose `scope:` overlaps an open PR's files — note the overlap in the log and try the next ticket.

One `Agent` call per ticket, `isolation: worktree`, model `sonnet` for `fix` and `opus` for `investigate` unless the README says otherwise. The brief is, in order:

1. The ticket file, verbatim.
2. `references/ticket-brief.md` from this skill, verbatim, with its placeholders filled.
3. `yona-direct`'s `references/dispatch-brief.md`, verbatim (installed at `~/.claude/skills/yona-direct/references/dispatch-brief.md`).

Record the agent id and branch in the ticket's frontmatter (`agent:`, `branch:`) and log the dispatch.

### 5. Digest and scorecard

Write them at the end of every pass, even an empty one. See below.

## The Merge Check

A queue PR merges without the user only when **every** line holds. Check them mechanically from the PR, not from the agent's report:

1. Automatic merges are on (scorecard header), and this is not a dry run or a `test: true` ticket.
2. The ticket's kind is `fix`.
3. **Every file in the diff is inside the ticket's `scope:`.** One file outside it fails the check — that is the scope-creep guard, and it does not bend for "it was a tiny related tidy-up".
4. The diff is within the README's size limit.
5. **Nothing on the README's Never-automatic list is touched.** Run its tripwire commands against `git diff origin/main...<branch>` and quote the empty output in the log.
6. The branch is up to date with main (`gh pr update-branch` if not), and every check on **that** head is green. A PR with no checks at all passes only if it touches nothing but Markdown outside the Never-automatic list.
7. The agent reported no deviations and no test it could not run.

All green → merge with the repo's method (see `yona-ship`), post a three-line comment on the PR (what, the evidence link, "merged by auto-direct under the queue's rules"), then follow `yona-ship`'s post-merge steps: watch the main run for the merge commit, and the deploy chain when the repo deploys on merge. Move the ticket to `05-done`, `outcome: merged`.

Any line fails → **do not merge and do not try to talk the check round.** Leave the PR ready, move the ticket to `00-deferred`, and ask: `Merge #901 (fixes the stale watch-pr hint)? It touched scripts/lib.sh, outside its scope. Lean: yes — the helper moved.` One failed line, named.

### When main goes red

If the main run after your merge goes red and your PR is among the suspects, **stop merging**: set the scorecard header to `paused — <reason>`, send a push notification, and put the question at the top of the digest. Reverting is the user's call, never yours. You stay paused until they say resume.

## The Digest

One file per day: `_auto/_digest/YYYY-MM-DD.md`. A second pass the same day rewrites it. It is the user's whole interface to the queue — written so they can clear it from a phone.

```markdown
# Queue — Friday 25 September

**Needs you** (answer after each `Answer:` — yes / no / a sentence)
1. Merge #901 (fixes the stale watch-pr hint)? It touched a file outside its scope. Lean: yes. [ticket](../00-deferred/2026-09-25-watch-pr-hint.md)
   Answer:
2. Sort the palette row by hue? Lean: yes — matches the gallery. [ticket](...)
   Answer:

**Done without you**
- Merged #899: the heap-budget script names the project it failed on. [ticket](...)
- Dropped: the lint warning in lpc-view — already fixed by #893.

**Worth knowing** — calls I made alone you might have made differently.
- Read "tidy the error" as wording only; the error type is unchanged.

**Waiting on hands or a plan** — 2 tickets, unchanged since Tuesday.

**Queue** — inbox 0 · investigating 1 · implementing 1 · shipping 0 · yours 4 · done 17
**Scorecard** — merged alone 6 · asked you 5 · reverted 0. Automatic merges: on.
```

Rules, the same ones `yona-direct` uses for status:

- **Plain language, no ID recall.** Name the thing; the link carries the id.
- **Every question is yes/no with a lean.** A question written as a paragraph goes unanswered.
- **Never drop the Needs-you section.** When empty it says `Nothing — the queue is running.`
- The waiting tickets are a count, not a list, unless something changed. They are already in `00-deferred`; repeating them daily is how a digest stops being read.

**Push notifications** only for a hard blocker: main red with your PR a suspect, a resource only the user can clear (disk, a credential), or a tripwire that fired after a merge. Never for a routine digest.

## The Scorecard

`_auto/scorecard.md`: a header saying whether automatic merges are on, then an append-only table — one row per outcome.

```markdown
Automatic merges: **on** since 2026-09-25

| Date | Ticket | Kind | Outcome | PR | Note |
|---|---|---|---|---|---|
| 2026-09-25 | 2026-09-25-heap-script-names | fix | merged-alone | #899 | |
| 2026-09-25 | 2026-09-25-palette-sort | decide | asked → yes | | worth asking |
```

Outcomes: `merged-alone`, `asked → yes|no`, `dropped`, `reverted`, `rerouted` (the user moved one of your tickets or changed its kind), `dry-run`. After the user answers a question, add whether it was worth asking — if they would have said yes to everything, you are asking too much.

It exists to move the Never-automatic line honestly:

- **Any `reverted` or `rerouted`** → tighten at once. Add the specific pattern to the README's Never-automatic list, say so in the digest. Tightening is yours to do alone.
- **Ten `merged-alone` in a row with no revert** → propose one specific widening as a digest question. **Never widen alone**: loosening your own rule after a good run is moving a rubric line to fit an outcome.

To find reverts, each pass: `git log origin/main --since=<last digest date> --grep '^Revert' --oneline`, matched against your PR titles.

## Dry Run

`/yona-auto-direct dry-run` runs everything for real except the merge and the outward send, for tickets marked `test: true` only:

- The agent opens a **draft** PR and never marks it ready.
- At the merge check, write the full result — each of the seven lines, pass or fail with evidence — to the ticket log, then close the PR with a comment (`Dry run of the auto-queue — not for merging.`) and delete the branch.
- The ticket goes to `05-done`, `outcome: dry-run`. The scorecard row is `dry-run` and counts toward nothing.
- The digest is `_digest/YYYY-MM-DD-dry-run.md`, so a real day's digest stays clean.

## Stop And Ask

The director almost never stops: anything that needs the user goes into `00-deferred` and the digest, and the pass continues. Stop the whole pass only when:

- Main is red with your PR among the suspects.
- The queue's README is missing, or contradicts itself on a merge rule.
- The same ticket's agent has failed twice on the same cause — park the ticket in `00-deferred` with both reports first.
- Something only the user can clear blocks every ticket (disk, auth).

**This list is closed.** A ticket that needs a decision is not a reason to stop; it is a line in the digest.

## Ending

End every pass with the digest's Needs-you and Done-without-you sections in chat, and the `yona-direct` three-line status block. No chips for queue tickets — the queue is where they live, and the director is who starts them.
