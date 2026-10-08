---
name: yona-ux
description: Explore UI/UX directions before planning by building a self-contained HTML spike playground — one section per gate question, lettered options side by side in the app's own visual language — verifying it renders, committing it, and stopping at a visual gate. Use when asked to brainstorm, redesign, prototype, mock up, spike, or compare UI/UX directions for a feature, component, panel, or workflow.
---

# Yona UX

## Overview

Use this skill to explore UI/UX directions **before** any planning or production
work. The output is a disposable, self-contained HTML playground — a *spike* —
that shows distinct design options side by side, styled in the target app's
own visual language and organized as one section per gate question, so the
user can answer in a line. The spike is committed to the repo and the session
stops at a visual gate for human judgment.

The pipeline position matters: `yona-ux` comes **before** `yona-plan`. A UI
feature that starts with a plan tends to lock in the first layout anyone typed.
A feature that starts with a spike lets the human compare real, rendered
alternatives cheaply, and the winning direction becomes an input to the plan.

Spike code is **throwaway by design**. It never gets imported, ported
wholesale, or "cleaned up into" production. Production implementation happens
afterwards through `yona-plan` → `yona-implement`, using the spike only as a
visual reference.

## Model Check — do this first

UX spike quality is strongly model-dependent, more than most coding work:
inventing distinct concepts, judging spatial composition, and writing dense
hand-rolled CSS that actually looks good are where model tiers separate.
Run spikes on the top tier: the current Opus or anything above it. Smaller
tiers (Sonnet, Haiku) produce noticeably weaker explorations.

Before doing anything else, check which model you are. If you are below the
Opus tier, tell the user plainly:

> UX spikes are the single most model-sensitive task in this workflow. I'm
> running as `<model>`; an Opus-tier or larger model will produce noticeably
> stronger concepts. I recommend re-running `/yona-ux` on one.

Proceed only if the user says to continue anyway. Do not silently produce a
weaker exploration. If the harness has a spawn-task tool (`spawn_task` in
Claude Code desktop), also create a chip that re-runs this exact request on
an Opus-tier model, so switching is one click rather than a retyped prompt.

## Discovery

Inspect enough real code to design against reality, not against a guess.
Prefer `rg` and targeted reads. Look for:

- The existing UI for this area: components, routes, panels, state handling,
  and the data shapes that will feed the design.
- The app's visual language: palette, typography, spacing, control styles,
  status-color conventions. Find the actual CSS/tokens — the spike must read
  as a native screen of the app, not a generic mockup.
- Prior spikes in the repo (see below) — they are both palette source and
  structural exemplars.
- Product context: who uses this surface, how often, what states exist
  (empty, loading, error, permission, offline), what adjacent UI it must sit
  beside.

After initial discovery, present assumptions as a batched table in chat:

```md
| ID | Question | Context | Suggested answer |
|---|---|---|---|
| A1 | Keep the card as the unit of interaction? | Existing UI is card-based. | Yes |
| A2 | Optimize for repeat expert use? | This panel is opened constantly. | Yes |
```

Tell the user they can answer `all yes`, `lgtm`, or specific overrides such as
`A2 no, first-run experience matters more`. Ask discussion-style questions —
ones that change the interaction model, information architecture, or scope —
one at a time, visually set off with an `## A3: …` heading and a suggested
answer. (`A` for assumptions; `Q` numbers are kept for the spike's gate
questions, below.)

Keep the decision log in chat and in the spike itself (its hint text and
commit messages). Do not create planning directories or `notes.md` files —
that machinery belongs to `yona-plan`, which runs after the spike converges.

## The Spike Playground

Build one self-contained file:

```text
spikes/<short-name>/index.html
```

in the target repo. Rules:

- **Raw HTML + CSS + vanilla JS in one file.** No build step, no framework,
  no external dependencies. It must open directly via `file://`.
- **The app's palette, verbatim.** Start the stylesheet with a `:root` block
  of CSS variables copied or distilled from the real app (or from an existing
  spike, which will already have one). In lp2025 this is the studio dark
  palette. If the spike doesn't look like the app, comparisons made on it
  don't transfer.
- **Header:** an `<h1>` naming the exploration and a short `p.hint` paragraph
  stating the design thesis — what is being explored and why — and which
  round this is.
- **The spike is organized by question.** Every gate question in chat is one
  section of the spike, with the same number and the same lettered options,
  in the same order, so the user can answer in one line: `Q1 A, Q2 B, Q3 B`.
  The user should never have to hunt for what a question refers to.
- **No exploration-controls strip.** Don't build a strip of toggles that
  swap data sets, cycle states or trigger events. Users don't drive it, and
  an option that only appears after pressing the right buttons is an option
  nobody compares. Render every state that matters statically, in the
  section it belongs to. The product's own controls (a view switch, a menu,
  a connect button) stay live inside the renders.
- **Round 1 is usually one question: which structure?** `Q1` with 3–5
  genuinely distinct concepts as its options (`Q1-A`, `Q1-B`, …) — different
  structures and interaction models, not color or spacing variants. When
  production already has this UX, a faithful reproduction of it is one of
  the options, so "keep what we have" is comparable.
- **Later rounds open with the page so far.** The whole surface as it
  stands, with every lean applied and labelled with the options it uses
  ("uses Q1-A, Q2-B, Q3-B"). Then one section per open question
  (`<section id="q2">`, so a link can land on it): a `Q2` badge, the
  question in one sentence, and its options.
- **Each option is a self-contained panel:** a big `Q2-B` label, a name of
  two to four words, one line on what it is, one line each of For and
  Against, and its render. Outline the lean and badge it "lean". Render only
  the part of the surface the option changes, cropped, with the same data in
  every option of the question, so the options differ in exactly one thing.
  When the answer depends on a viewport or a mode the product has (phone
  width, cards vs list), show both inside the option, side by side. Two or
  three options per question, four at most.
- **Numbers are never reused.** A question raised in a later round takes the
  next number; answered questions leave the page, and their answers go into
  a short "Decided so far" list at the bottom (round, question, answer).
- **Reference states go last.** States that need no decision (empty,
  welcome, signed out, error, phone width) sit in a final section that asks
  nothing.
- **Realistic content.** Real-looking names, IDs, log lines, and data pulled
  from or modeled on the actual app. Include the awkward cases: long names,
  empty states, errors, the offline device.
- **Interactive where the design question is interactive.** If the question
  is "how does the card grow into an editor pane", the spike should animate
  the card growing into an editor pane.

Exemplars (lp2025): `spikes/one-home-page/index.html` (round 2) is the
question format. `spikes/device-card-panel/index.html` and
`spikes/hardware-boards/index.html` are good palette and component sources,
but they predate it and still use a controls strip. When working in a repo
with existing spikes, read one before writing yours and match its visual
idiom.

## Verify It Renders

Never hand over an unverified spike. In order of preference:

1. **Browser pane** (`preview_start` with the `file://` URL or a static
   server, then `read_page` / screenshots): check for overflow, blank
   sections, broken JS, and press the product controls inside the renders.
2. **Headless Chrome screenshot** when no browser pane is available:

```bash
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless=new --disable-gpu \
  --screenshot="$PWD/spike-check.png" --window-size=1440,4000 \
  "file://$PWD/spikes/<short-name>/index.html"
```

Make the window height generous enough to capture the full page, read the PNG
back, and actually look at it. Fix rendering problems before presenting.
Check **every section**: capture one screenshot per section — the page so
far, each question with all its options, the reference states — at 2×
device scale (`--force-device-scale-factor=2`) and look at each one. A
`?shot=<section-id>` query that hides every other section makes this a loop
over section ids. One 4000px-tall image only proves it rendered. These
screenshots are your check, not the handoff: don't post them at the gate.

## Commit

Commit the spike as soon as it renders, before the gate:

```text
spike(<area>): <what the playground explores>
```

Spikes are committed to the repo deliberately — they are reviewable in the PR,
they serve as the design record the plan will cite, and future spikes borrow
their palette blocks. Small follow-up commits per iteration round, per the
usual commit-granularity preference.

## Visual Gate

A spike always ends at a visual gate — this is a stop, not a status update.

The user reviews in the spike, not in chat: **the handoff is a link, not
screenshots.** Screenshots posted to chat proved less useful than opening
the page (Yona, 2026-10-08), so don't send them, even when a repo
review-handoff skill (in lp2025: `lp-review-handoff`) would. The handoff
contains:

- **A clickable link to the spike**: the `file://` URL of the committed
  file, or the served URL when a server is needed. Each question's section
  has an id, so a question can link straight to it (`index.html#q2`).
- **The gate questions, numbered and lettered exactly as the spike's
  sections**, one line each, with the lean marked: "Q1 · The top of the
  page: A first card (lean) · B a stage". "Thoughts?" is not a gate
  question. Close with the one-line answer format: `Q1 A, Q2 B, …`.
- **Your lean** per question, with its reason in a clause.

Then stop. Do not begin production work, and do not start `yona-plan`, until
the user has judged the gate.

## Converge

When the user reacts:

1. Apply the answers: fold each chosen option into the page so far, delete
   the answered sections, and add each answer to "Decided so far".
2. Feedback that isn't a letter becomes a new question when it leaves a real
   choice (the user's own wording makes good options), with the next number.
   Decide small things yourself and say so in chat.
3. Iterate the chosen direction in place: more states, edge cases, the
   interaction polish the user asked about.
4. Commit each round; re-gate when the changes warrant judgment, otherwise
   keep iterating in the same conversation.

Make small design choices yourself; spend gate questions only on decisions
that change the interaction model, product behavior, or implementation cost.

## After the Spike: Production

The converged spike is an input, never a starting codebase.

Planning runs in a **new session**. The committed spike plus the chosen
concept is the plan's whole input; the reasoning that picked the concept
belongs in the spike's hint text and commit messages, and this session's
context is full of the concepts that lost. So when the user has picked a
direction and the last iteration round is committed, create the chip
**without being asked**: the harness's spawn-task tool (`spawn_task` in
Claude Code desktop) when it has one, plus the same prompt in a fenced
block either way. The prompt stands alone — `yona-plan`, the spike path,
the answers (`Q1 A, Q2 B, …` and what each means), the states and edge
cases that became acceptance criteria, and the repo directory.

Chip out-of-scope discoveries the same way: a bug in the production UI you
reproduced while building the faithful copy, a state the current app
mishandles. One chip each, the moment you notice it, not a note at the end.

1. Run `yona-plan` for the production implementation. The plan should link
   the spike path and name the answers; the spike's states and edge
   cases become acceptance criteria and phase-gate questions.
2. `yona-implement` executes the plan in the app's real framework, with real
   data flow, accessibility, and tests. Production code must never import
   from `spikes/`.
3. **Projects with Storybook or a story/capture system** (lp2025 has one):
   the standalone spike still comes first — it is faster to iterate and needs
   no build. But once a direction has converged, rebuilding the chosen
   concept as stories in the real component system is the natural next step,
   and the plan should include it: stories are where the design meets real
   components, and where visual regression coverage lives afterwards.
4. The spike stays in `spikes/` as the design record. Delete it later only if
   it becomes misleading relative to what shipped.
