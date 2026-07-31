---
name: yona-ux
description: Explore UI/UX directions before planning by building a self-contained HTML spike playground — multiple concepts side by side in the app's own visual language — verifying it renders, committing it, and stopping at a visual gate. Use when asked to brainstorm, redesign, prototype, mock up, spike, or compare UI/UX directions for a feature, component, panel, or workflow.
---

# Yona UX

## Overview

Use this skill to explore UI/UX directions **before** any planning or production
work. The output is a disposable, self-contained HTML playground — a *spike* —
that shows several distinct design concepts side by side, styled in the target
app's own visual language, with live controls to exercise states. The spike is
committed to the repo and the session stops at a visual gate for human judgment.

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
At present, Mythos-class models (Claude Fable / Mythos) are far better at this
than any other tier.

Before doing anything else, check which model you are. If you are **not** a
Mythos-class model, tell the user plainly:

> UX spikes are the single most model-sensitive task in this workflow. I'm
> running as `<model>`; a Mythos-class model (Fable) will produce noticeably
> stronger concepts. I recommend re-running `/yona-ux` on one.

Proceed only if the user says to continue anyway. Do not silently produce a
weaker exploration.

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
| Q1 | Keep the card as the unit of interaction? | Existing UI is card-based. | Yes |
| Q2 | Optimize for repeat expert use? | This panel is opened constantly. | Yes |
```

Tell the user they can answer `all yes`, `lgtm`, or specific overrides such as
`Q2 no, first-run experience matters more`. Ask discussion-style questions —
ones that change the interaction model, information architecture, or scope —
one at a time, visually set off with an `## Q3: …` heading and a suggested
answer.

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
  stating the design thesis — what is being explored and why.
- **Exploration-controls strip:** a dashed-border strip near the top with
  buttons/toggles that mutate the concepts live — cycle a status through its
  states, toggle density, swap data sets, trigger the animation. Every state
  the design must handle should be reachable from this strip, not just
  described.
- **Numbered sections** (`<h2>`) when the exploration covers multiple
  surfaces, so gate feedback can reference "section 2".
- **Concepts side by side.** 3–6 genuinely distinct concepts — different
  structures and interaction models, not color or spacing variants. Include
  the current production UX first (a faithful reproduction) when one exists,
  so "keep what we have" is a comparable option.
- **Realistic content.** Real-looking names, IDs, log lines, and data pulled
  from or modeled on the actual app. Include the awkward cases: long names,
  empty states, errors, the offline device.
- **Interactive where the design question is interactive.** If the question
  is "how does the card grow into an editor pane", the spike should animate
  the card growing into an editor pane.

Exemplars (lp2025): `spikes/device-card-panel/index.html` and
`spikes/hardware-boards/index.html`. When working in a repo with existing
spikes, read one before writing yours and match its idiom.

## Verify It Renders

Never hand over an unverified spike. In order of preference:

1. **Browser pane** (`preview_start` with the `file://` URL or a static
   server, then `read_page` / screenshots): check for overflow, blank
   sections, broken JS, and exercise the exploration controls.
2. **Headless Chrome screenshot** when no browser pane is available:

```bash
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless=new --disable-gpu \
  --screenshot="$PWD/spike-check.png" --window-size=1440,4000 \
  "file://$PWD/spikes/<short-name>/index.html"
```

Make the window height generous enough to capture the full page, read the PNG
back, and actually look at it. Fix rendering problems before presenting.
Capture per-section crops or per-section screenshots for the gate — one
4000px-tall image is evidence you rendered it, not something a human can
review on a phone.

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

If the repo has its own review-handoff skill (in lp2025:
`lp-review-handoff`), use it — it owns the mechanics of dev servers, links,
and screenshot delivery. Either way the handoff must contain:

- **Section screenshots** posted to chat (SendUserFile), cropped per concept
  or per section, framed as a decision matrix when there are competing
  options.
- **Your lean**, stated explicitly: which concept you'd pick and why.
- **Explicit gate questions**: what needs human judgment and what "pass"
  looks like. "Thoughts?" is not a gate question. "Does the tab row belong
  under the title bar (concept B) or on the right edge (concept C)?" is.
- The `file://` path or served URL so the user can open the playground and
  play with the controls themselves.

Then stop. Do not begin production work, and do not start `yona-plan`, until
the user has judged the gate.

## Converge

When the user reacts:

1. Apply feedback directly in the spike — delete losing concepts or shrink
   them to a small "rejected because…" strip if the contrast stays useful.
2. Iterate the chosen direction in place: more states, edge cases, the
   interaction polish the user asked about.
3. Commit each round; re-gate when the changes warrant judgment, otherwise
   keep iterating in the same conversation.

Make small design choices yourself; spend gate questions only on decisions
that change the interaction model, product behavior, or implementation cost.

## After the Spike: Production

The converged spike is an input, never a starting codebase.

1. Run `yona-plan` for the production implementation. The plan should link
   the spike path and name the chosen concept; the spike's states and edge
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
