# The standing dispatch brief

Send this block verbatim with every milestone dispatch, after the milestone
file and the Director notes. Each line is a failure some director paid for
once.

Where a line names a tool or a command, keep the name. Every line here that
was written as a principle got ignored; the versions that name the mechanism
are the ones agents obey.

---

## Branch and push

- Push to branch `<name>`. Do **not** work in, or refer to, another worktree's
  path — a worktree-isolated agent cannot reach one, even with `git -C`.
- Open a **draft PR the moment the branch has its first commit**, before the
  work is done, so CI gives signal early.
- **Commit at every green checkpoint and push after every commit.** An
  unpushed worktree is one crash from gone. This rule is why three host
  crashes cost one commit between them.
- Never `git stash`. The stash stack is shared across worktrees and other
  sessions pop it.
- Rebase onto the base branch at your next commit boundary whenever you are
  told it moved.
- Prefix scratch files with your branch name. Shared scratch directories mean
  another agent's file lands on your PR.

## Validation

- Run every long command in the **FOREGROUND** under an explicit `timeout`.
  You may not use `run_in_background`, `&`, or the `Monitor` tool for any
  reason. If a command exceeds its timeout, split it into pieces and run the
  pieces — do not background it and stop.
- Do **not** watch CI. Push, mark the PR ready, and report. The director
  watches CI.
- **Do not stop before your final report.** A notification is not a stopping
  point.
- The full check is the **LAST** command before your final push, after your
  final commit. A check that ran before your last two commits has not checked
  them.
- A test you could not run locally has **NEVER RUN**. Say so in your checks
  table, in those words.
- A local green is only evidence if the run actually built what it claims;
  quote the line that proves it rather than the exit code.
- Known flakes: `<named jobs>`. Rerun them; do not investigate them.

## Helpers

- Helpers run with `run_in_background: false`. A parent that stops while
  background helpers run never resumes, and their reports surface to the
  director instead of to you.
- Helpers never commit.

## Honesty

- Report deviations **as deviations**, with the evidence that drove each one.
  A deviation with a stated reason and a test is welcome; a silent one is a
  defect.
- Never tune a number toward an expected value. If a measurement disagrees
  with the brief, report the disagreement.
- If you cannot reproduce a failure locally, **stop and say so** rather than
  assigning it a cause.
- If the brief contradicts itself or the code, implement what you can and
  leave the contradiction as an explicit ruling for the director. Do not
  guess.
- Do not expand scope. Do not suppress warnings or disable tests to get green.

## Your final report must contain

- The PR URL and its state.
- A checks table: every validation command, its result, and any you could not
  run.
- The gate evidence the milestone file asked for, quoted rather than
  summarised.
- Every deviation, with its reason.
- Anything you found that the brief did not predict.
