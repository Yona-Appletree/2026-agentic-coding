# The ticket brief

Send this block with every ticket dispatch, after the ticket file and before
`yona-direct`'s standing dispatch brief. Fill the `<placeholders>`; keep
everything else verbatim. It adds what a queue ticket needs that a milestone
does not: a hard scope line, and permission to stop small.

---

## This is a queue ticket, not a project

- Repo: `<absolute path to the product repo>`. Base branch: `<main>`.
- Push to branch `<claude/auto-<ticket-id>>`.
- PR title: `<type>: <ticket title>`. **The PR body's first line is
  `Ticket: <repo-slug>/_auto/<ticket-id>`**, then what changed and a checks
  table. That line is how the director finds its PRs; do not reword it.
- Mode: `<normal | dry-run>`. In dry-run, keep the PR a **draft** and never
  mark it ready.

## Scope — the line the merge check holds you to

Declared scope: `<files and directories from the ticket's scope:>`

- Touch nothing outside it. The director checks every file in your diff
  against this list and **will not merge** a PR with one file outside it,
  however small or related the change.
- If the fix genuinely needs a file outside scope, make the change, and say
  so as the first line of your report: `OUT OF SCOPE: <file> — <why>`. The
  director asks the user; that is fine and expected. A silent out-of-scope
  change is a defect.
- Do not tidy what you pass. A nearby problem goes in your report under
  "Found", one line each, and the director queues it as its own ticket.

## Never, in this repo

`<the Never-automatic list from _auto/README.md, pasted verbatim>`

If the fix needs any of these, stop, do not push the change, and report
why. That ticket is the user's, not yours.

## Proof

- The ticket's **Done when** is the target. Name the command or CI check that
  proves it and quote its passing line.
- Prefer a test that fails before your change and passes after. If one is
  not possible, say why in one line.
- Size: keep the diff under `<size limit>` changed lines. Over it, stop and
  report; the ticket is too big for the queue.

## Investigations

When the ticket's kind is `investigate`, **do not change product code and do
not open a PR** unless the ticket says to. Your report is a **Finding**:
the cause, the evidence, the smallest fix you would make with the files it
would touch, and whether that fix needs anything on the Never list or a
product call. The director decides what happens next.

## Do not touch the queue

The queue folder is the director's. Never read-modify-write a ticket file;
everything the director needs goes in your final report.
