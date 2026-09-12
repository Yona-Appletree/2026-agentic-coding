---
name: yona-blog
description: Write a technical blog post end to end — grounded discovery, an editorial brief with an approval gate, a leading example built before any prose, then drafting, revision argued against the brief, and shipping. Use when the user wants to write, restructure, or substantially revise a blog post or article.
---

# Yona Blog

## Overview

Use this skill when the deliverable is a published blog post. It sits
beside the coding pipeline and ships through `yona-ship`:

```text
yona-blog (brief → example → draft) → yona-ship
```

The work produces two artifacts, and the order matters:

1. **An editorial brief** — the architecture of the piece: thesis,
   reader, lede strategy, beat sheet, open decisions. It lives in the
   blog repo's planning directory and is the surface that later
   structural arguments happen against.
2. **The post itself**, written only after the brief's decisions are
   settled and the leading example exists.

Do not draft prose before the brief is approved. The most expensive
failure mode in post-writing is discovering after a full draft that the
story is told mechanism-first when the payoff should lead (or the
reverse). That is a five-minute conversation at the brief stage and a
full restructure afterward.

## Stage 1: Discovery

Ground in three places before proposing anything:

- **The subject.** Read the actual code, repo, or system the post is
  about — not a summary of it. If the post makes provenance claims
  ("used in production", "hundreds of call sites"), gather the real
  numbers now; grounded specifics are what separate a post from
  product chatter.
- **The blog.** Read one or two existing posts for voice. Find the
  post format (plain Markdown vs. checked/compiled posts), the
  validation pipeline, the front-matter conventions, and how URLs are
  derived (filename slug? front matter?). These constrain everything
  downstream.
- **The reader.** If the user has not named one, ask. The useful form
  is a specific person: what do they run today, what do they believe,
  what pain do they feel, what should they do after reading. "Anyone
  interested in X" is not a reader.

Also collect what is already public to link to (repos, READMEs, docs),
since links change what the post must explain versus reference.

## Stage 2: The Editorial Brief (gate)

Write the brief as a file in the blog repo's planning directory
(`docs/plans/YYYY-MM-DD-<slug>-outline.md` unless the repo says
otherwise). It contains:

- **Thesis in one sentence.** Force the choice between payoff-first
  and mechanism-first framing. A useful test: what is the payoff, and
  what is the price? The thesis usually belongs to the payoff; the
  mechanism is the price, and the story is how small the price is.
- **Reader profile.** The specific person from discovery.
- **The move.** How the piece opens and closes: demo-first cold open,
  ring composition back to the lede, nut graf naming what is absent
  and what it costs. The reader should hit the load-bearing example
  inside the first screen.
- **Beat sheet.** Numbered beats, each with its job stated ("reframed
  as the negative image of the cold open"), not just its topic.
- **Title and slug candidates.** Slugs are hard to change after
  publish — a rename needs redirects — so surface this decision now
  even if it stays open until ship. Pick a working slug here too and
  title the session `blog: <slug>` per `yona-session`; the session slug
  is the piece's stable name and need not match the URL slug the user
  eventually settles on.
- **Open decisions.** Anything genuinely the user's call.

Then the gate: put each open decision to the user as a short, concrete
choice with a recommendation. Do not proceed to prose until they
answer. Record the answers in the brief — a "Decisions" section with
the date — so later sessions argue with the brief instead of
re-deriving intent from the prose.

## Stage 3: The Leading Example

Build the cold-open example before writing prose around it. It is the
keystone: the middle of the post exists to assemble it, so its shape
dictates the beats, not the other way around.

The example must be honest:

- It runs. If the blog supports checked posts (examples compiled and
  tested as part of the build), the leading example is real code with
  real assertions, and the post can truthfully say "this ran before
  you read it."
- Watch source-order mechanics in compiled formats: a cold open that
  references definitions made later in the file needs hoisted
  `function` declarations, not `const` arrows.
- Prefer a small domain whose names explain themselves (`config`,
  `logger`, `users`). The cold open gets no preamble, so the code must
  be legible to a reader who knows nothing yet.

If the leading example cannot be made honest and compelling, the
thesis is wrong. Go back to the brief — do not paper over it with
prose.

## Stage 4: Drafting

Write the post beat by beat from the brief.

- Match the blog's voice by imitating its existing posts, not a house
  style you carry between projects. Default virtues: first person,
  short paragraphs, named tradeoffs, numbered failure modes, no
  hedging adjectives.
- Write in a plain professional register. The reader is a working
  engineer; the post should read like a colleague explaining a pattern
  they use, not like a model performing expertise. "The shape is
  simple:", not "The shape of the code is almost suspiciously
  simple:". The full catalog of patterns to remove, what to keep, and
  the audit pass are in `references/prose.md`. If the target repo has
  its own prose rules in `AGENTS.md` or `CLAUDE.md`, those win.
- Skimmers read only the code. The code blocks alone should carry the
  argument in order; prose earns its place by saying what the code
  cannot.
- Show expected type failures (or equivalent negative space) where
  the format supports it — what the pattern prevents is half the
  argument.
- Run the blog's own validation pipeline; fix until green. Commit in
  the repo's conventional style.

## Stage 5: Revision

Structural feedback ("move X up", "the real story is Y") goes through
the brief first: update the thesis, beats, or decisions, get agreement
if the change is significant, then rework the prose to match. Update
the brief's Decisions section when a settled decision changes —
including after publish, so the record explains renames and redirects.

Line-level feedback goes straight into the prose. Re-run validation on
every pass.

Before handing back any draft or revision, run the audit pass in
`references/prose.md`. Rewriting introduces new instances of the same
patterns, so the audit runs after every pass, not once.

## Stage 6: Shipping

- Pre-ship check: title, slug, and description are final; links
  resolve; provenance claims still match reality.
- Ship via `yona-ship` (branch, PR, checks, merge). Merging is
  publishing, so a post always carries a ship gate: hold at the ship
  report unless the user has already said to merge.
- After the post is live, confirm the real URL renders.
- If a published post must be retitled or its slug changed, keep the
  old URL working (Hugo `aliases` or the platform's redirect
  mechanism) — assume the link has already been shared.
