---
name: yona-auto-queue
description: Put a small piece of work — a bug, a tidy-up, a follow-up, a nagging little thing — into the repo's auto-queue as one ticket file, so `yona-auto-direct` works it without the user tracking it. Use when the user says "queue this", "auto-queue it", "put it in the queue", or when another yona skill has a follow-up and the repo has a queue.
---

# Yona Auto-Queue

The user is drowning in small things: a flaky test noticed in passing, a stale doc, a follow-up a ship report named, a bug found mid-walk. Each one used to become a chip or a mental note. This skill turns one into a ticket file in a queue that `yona-auto-direct` works on its own, so the user can say "queue it" and stop thinking about it.

**Bugs, debt, and tidy-ups only.** A defect, a flaky test, a stale doc, dead code, a missing test, a workaround that should be removed. Feature-level work — new behaviour, a new surface, anything a plan would describe as a feature — is not queue work; it stays a chip or a `yona-plan`. When in doubt, it is a feature.

Filing is cheap and fast. It does **not** decide whether the work is automatic — the director (`yona-auto-direct`) does that at triage. Your job is to write a ticket another agent can act on cold.

## Where The Queue Lives

Resolve the planning workspace exactly as `yona-plan` does (`agent-context.toml` → `planning_root_env` / `planning_root` / `repo_slug`). The queue is:

```text
<planning-root>/<repo-slug>/_auto/
```

It exists only if that directory exists and has a `README.md`. **No queue, no ticket**: if it is missing, say so in one line and fall back to what the calling skill would otherwise do (a chip). Never create the queue yourself.

Read `_auto/README.md` before filing the first ticket in a session. It is the queue's contract and may carry repo rules this file does not.

## The Ticket

One Markdown file per ticket, written into `01-inbox/`. Nothing else ever writes to `01-inbox/`, and filers never touch the other folders — only the director moves tickets.

**Name:** `<YYYY-MM-DD>-<slug>.md`. The stem is the ticket's id and never changes, even when the file moves between folders. The slug names the thing, not the action, two to five words: `2026-09-25-watch-pr-silent-on-stacked`, not `2026-09-25-fix-bug`. If the name is taken, add `-2`.

```markdown
---
id: 2026-09-25-watch-pr-silent-on-stacked
title: watch-pr reports "no checks" for stacked PRs without saying why
priority: normal          # high | normal | low
filed: 2026-09-25
source: yona-ship, PR #812 ship report        # who filed it and from where
register: docs/debt/two-green-prs-can-red-main.md   # or none
links: []                 # PRs, plan dirs, defect entries, sessions
# --- the director owns everything below; filers leave it out ---
kind:                     # set at triage — see _auto/README.md
pr:
---
# watch-pr reports "no checks" for stacked PRs without saying why

**What** — the problem in one to three sentences, with the exact error or
symptom when there is one.

**Done when** — what observably changes. One or two lines. If you cannot
say, write "unclear — needs investigation" and the director will treat it
that way.

**Where** — files, commands, or the page where it shows up. Absolute paths
for anything outside the repo.

**Found** — how it came up, in one line, so the director can judge whether it
still holds.
```

Priority, in plain terms:

- `high` — it is hurting now: blocks other work, bites every session, or is user-visible.
- `normal` — the default. Worth doing, not urgent.
- `low` — whenever the queue is otherwise empty.

When the user does not say, pick `normal`. Do not inflate: a queue where everything is high has no priority.

## Rules

- **One thing per ticket.** Two problems found together are two tickets. The director's scope check is per ticket, and a ticket with two halves gets bounced as too big.
- **Point at the register; do not copy it.** If the repo has `docs/debt/` or `docs/defects/` and the problem is an entry there, set `register:` to its path and keep the body to what this ticket should do about it. The register entry stays the durable record. If the problem meets the repo's filing bar and has no entry yet, filing the entry is still the calling skill's job, in the repo, per the repo's rules — the ticket is the unit of work, not the record.
- **Check for a duplicate first.** `grep -ril <two distinctive words> <queue>/` across every folder. If a ticket already covers it, append one dated line to that ticket's body under a `**Seen again**` heading instead of filing a second one.
- **Mark tests.** A ticket filed only to exercise the queue carries `test: true` in its frontmatter and `[TEST]` at the start of its title.
- **Do not judge the kind.** Do not write "this is easy" or "this can be automatic". The director tiers every ticket against the queue's rules; a filer's opinion anchors it.

## Reporting

End with one line per ticket filed: the id and the full path. When called from another skill, that line replaces the chip that skill would have made — the queue is the record and the director is the one who starts it.
