# Harness traps

Failure modes that have each cost a director a session or a night. Read
before the first dispatch.

## A completion notification is not a completion signal

The harness notifies whenever a sub-agent stops with no live background
children. That is identical for "finished" and "stalled" — both arrive
labelled completed. **Read the result prose every time.** If it does not
contain the report the brief demanded, the agent stalled mid-task.

Observed rate: in one session, both dispatched agents stalled within twenty
minutes, each having backgrounded a long command and ended its turn believing
a notification was coming.

## No notification is not "still working"

A quiet agent may be idle, dead, or waiting on something that will never
arrive. Check the agent list rather than inferring from silence.

## Prose cannot prevent a belief

Agents do not disobey "never pause on background work" — they background a
command, form a true-sounding belief that a notification is coming, and stop.
Six occurrences across multiple sessions and models, including sessions where
the rule was sent verbatim in bold.

**Forbid the mechanism, not the consequence.** Name `run_in_background`, `&`,
and `Monitor` explicitly and ban them. Ban the tool, not the outcome.

## The worktree sandbox wall

An agent launched with `isolation: worktree` cannot run git in another
worktree's path, even via `git -C`. Briefs must say **"push to branch X"**,
never "work in worktree X".

## The resume trap

Two separate failures, both expensive:

1. A resumed sub-agent runs **only while the parent session is in a turn**. If
   you send a resume and your turn ends, the agent sits idle until the next
   user message — six hours, in one recorded case. Keep the turn alive with a
   cheap bounded wait after any resume.
2. A stopped `isolation: worktree` agent has its worktree **auto-cleaned as
   unchanged**. Resuming it lands the agent in the *parent's* worktree, where
   it will happily start work. Never resume one; re-dispatch from the pushed
   branch.

## Resume with facts, not encouragement

Re-read the true state — PR mergeability, head sha, what landed on the base
branch — and send that. An agent resumed with the state of the world it lacks
converts into progress; one resumed with "please continue" wastes the round.

## Nested helper reports surface to the director

A milestone agent's helpers post their full reports into the *director's*
context as completion notifications. Useful as a peek. **Do not act on them** —
the milestone agent owns that work. Ignore helper notifications by name.

## Permission-sensitive commands run alone

A merge chained behind a semicolon can be blocked by the permission
classifier while the same command alone goes through. Never chain them.

## Watch tools lie about cancelled runs

A cancelled CI run reads as a failure to some tools and as success to others;
editing a PR body restarts CI. Before assigning meaning to a red, confirm the
run is the current one for the current head.

## `ls` before you append

Appending to a guessed filename creates a stray file beside the real brief,
which then goes unread. Milestone files are often named differently from their
titles. Check the path first.

## Disk

Check free space before dispatching anything that builds. When space drops
with no matching growth in the tree, suspect filesystem snapshots before build
caches — a build-cache pruner's dry run is the cheap way to rule the cache
out.

A full disk kills the shell tool in *every* session simultaneously, including
yours, so no agent can self-rescue. This is a resource only the user can
clear; clear it before they leave.

## Warm build caches carry stale state

Reusing a dead agent's worktree for its warm build directory saves hours and
risks artifacts built from source that no longer exists. If the project has
ever produced a non-reproducible build, that trade is the first suspect for
any subsequent unexplained divergence. Take it if the rebuild cost warrants,
and say in the brief that you took it.

## Session-scoped scheduling

Cron jobs created in a session are in-memory: they die with the session and
expire after seven days. Any status cadence built on one must be re-armed
after every handoff.
