---
name: yona-vision
description: Run a product/UX vision session — a grounded thinking-partner conversation ahead of any spike or plan, ending in a vision.md artifact once direction converges. Use when the user declares a vision or pre-planning session, wants to rethink a product area's direction or feel, or asks "thoughts on this vision?" rather than asking for a plan or implementation.
---

# Yona Vision

## Overview

Use this skill when the user wants to think about product direction, not
produce work. A vision session sits **before** everything else in the
pipeline:

```text
yona-vision → yona-ux (for UI directions) → yona-plan → yona-implement
```

The deliverable is in two stages, and the order matters:

1. **A substantive assessment in chat.** The user brings a proposal or a
   pile of frustrations; you respond as a thinking partner — grounded in
   the real code, willing to push back, naming tensions with standing
   decisions. The conversation is the work.
2. **A `vision.md` artifact**, written only when the user asks for it or
   the direction has clearly converged. It records what was settled and
   what remains open, so the downstream spike and plan inherit a clean
   input instead of a chat transcript.

Do not create files, planning directories, or todo lists during stage 1.
Do not jump to proposing phases or milestones — that is `yona-plan`'s
job, and a vision that arrives pre-phased locks in the first structure
anyone typed.

## Stage 1: The Conversation

### Ground in reality first

Before responding to the user's proposal, survey what actually exists.
An ungrounded vision response is generic product chatter; a grounded one
changes decisions. Use an Explore agent (or targeted `rg`/reads) plus
the project's planning artifacts and memory. You are looking for four
specific things:

- **What already exists.** Users proposing a rework often don't know (or
  forgot) that half of it is built. Finding the existing model, chip, or
  reserved hook ("the ADR explicitly reserved the logo for a future
  landing page") converts vision items from greenfield to
  surface-or-fix, which changes scope radically.
- **Tensions with standing decisions.** Check each proposal against
  ADRs, prior plan decisions, and recorded reversals. This is the core
  value-add. When you find a tension, don't just flag it — try to
  *resolve* it: often the old decision forbids a mechanism while the new
  proposal needs only metadata, and naming that distinction saves the
  decision from being relitigated.
- **The concrete code shape of the pain.** "The flow is bad" becomes
  actionable when you can say "creation hardcodes push-to-sim in
  `open_from_home_inner`; there is no target-selection moment anywhere."
- **Adjacent plans this vision should compose with.** A new page or
  format that an in-flight plan already defines (a registry, a manifest,
  a metadata milestone) should reuse it — say so, with the plan's own
  decision IDs.

### Respond as a thinking partner

Structure the assessment around judgment, not summary. The user wrote
the vision; do not read it back to them. Instead:

- Lead with your overall verdict and the strongest reframing you found.
- Distill the vision into a **north star** — one sentence of golden
  path the user can ratify ("plug in → flash → pick content → editor
  with LEDs animating"). A ratified north star settles a dozen smaller
  questions implicitly.
- Push back where you disagree, with reasons anchored in the code or
  the product's own precedents. Offer a lean, not a survey of options.
  Expect to lose some pushbacks — record the user's ruling and why.
- Separate **already exists** / **tension to resolve** / **genuinely
  new** — this triage is most of the artifact's later value.
- End with open questions and a suggested next step, but do not start
  it.

Iterate in chat. The user will rule on tensions, correct scope, and add
constraints; each ruling is a settled decision to carry into stage 2.
Ask discussion questions one at a time; batch small confirmations.

## Stage 2: The Artifact

When the user says to write it up (or asks you to "start the plan dir"):

### Location

Resolve the planning location exactly as `yona-plan` does
(`agent-context.toml` → planning root → `<workspace-root>/`), and create:

```text
<workspace-root>/<YYYY-MM-DD-HHMM>-<name>/
```

The vision session *starts* the planning directory that the later spike
and plan will fill in.

### Files

Write two files. **Deliberately do not write `plan.md`** — its absence
is what tells `yona-implement` there is nothing executable here yet, and
the vision doc should say so explicitly.

**`vision.md`** — the entrypoint:

```md
---
kind: vision
status: active
repo: <repo-slug>
created: YYYY-MM-DD-HHMM
next: <what follows — e.g. "ux-spike (yona-ux), then plan.md in this directory">
---

# <Readable title of the direction>
```

Sections, all in service of downstream agents:

- **The problem** — concrete, with the code-level shape of the pain.
- **North star** — the ratified one-sentence golden path.
- **The vision itself** — per area/page/surface, as settled in chat.
- **Data-model / architecture implications** — including the resolved
  tensions, each with its reconciliation argument spelled out (so the
  next reader doesn't reopen it).
- **Settled decisions** — a `D#` table. Every user ruling from the
  conversation lands here, including the ones that overruled you.
- **Open questions** — a `Q#` table with your leans and any known traps.
- **What exists today (grounding)** — file paths and one-line facts from
  the survey, so the spike/plan agent doesn't re-survey.
- **Next steps** — usually a `yona-ux` spike for UI visions, or
  `yona-plan` directly; scoped to where the risk actually lives.
- **Future work** — parked ideas, explicitly out of scope.

Use the shared reference-ID conventions (`D#`, `Q#`, uppercase in
artifacts, lowercase accepted from the user; never renumber).

**`notes.md`** — the discovery log: session origin, survey findings with
paths, the key arguments developed in chat, and the user's rulings
per topic, faithfully. Rulings recorded here are what make the `D#`
table trustworthy later.

### After writing

- If you maintain persistent project memory, record the vision, its
  directory, the `D#`/`Q#` headlines, and the declared next step.
- Report to the user: directory path, files written, decisions captured,
  open questions, and the suggested next command. Then stop — a vision
  session never rolls into spiking or planning on its own.

## Lifecycle

- A vision doc stays `status: active` while its directory accumulates
  the spike and `plan.md`. When the work ships, the implementing plan's
  completion covers it; when a vision is abandoned or superseded,
  archive the directory like any plan (`_archive/`, preserved basename)
  and update the superseding vision to say what it replaced.
- Visions are cheap to revisit. A follow-up session reopens `vision.md`,
  adds new `D#`/`Q#` entries, and never renumbers existing ones.

## Model note

Visioning is judgment-dense — tension-finding, reframing, and taste are
where model tiers separate. Prefer the largest available tier; if
running on a smaller model, say so and let the user decide whether the
session warrants an upgrade. No hard stop.
