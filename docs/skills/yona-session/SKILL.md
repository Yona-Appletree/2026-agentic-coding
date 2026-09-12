---
name: yona-session
description: Title the current session as `<stage>: <slug>` so the sidebar reads as an index of work, not a list of opening prompts. Every other yona skill applies this convention on entry and at stage changes; invoke it by hand for a session that started without one, or after the scope changed.
---

# Yona Session

The session list is the only index the user has of what is in flight. The harness titles each session with a sentence summarising its opening prompt, which is fine for one session and useless for twelve: "Plan the emulator-loop and MMIO refactor milestone (post-M7b)" next to "Plan the perf lab from vision.md" tells the user nothing at a glance about which sessions belong together or what stage each is at.

So the yona skills title sessions themselves. This file is the convention, the single source the other skills read, and the skill to invoke by hand.

## The Form

```text
<stage>: <slug>
<stage>: <project>/<slug>      when the repo declares a project tag
```

```text
vision: device-onboarding
plan: esp32v3-emu
impl: esp32v3-emu
ship: esp32v3-emu
direct: emu-in-tab
ux: device-card-panel
blog: provider-pattern
plan: lp/esp32v3-emu
```

Lowercase throughout. One stage word, a colon, a space, the slug. Nothing else — no dates, no PR numbers, no phase counts.

## The Stage

The stage names what the session is doing right now. It is the first word because the sidebar truncates from the right, and because grouping by eye works on prefixes.

| Stage | Owner |
|---|---|
| `vision` | `yona-vision` |
| `ux` | `yona-ux` |
| `plan` | `yona-plan` |
| `impl` | `yona-implement` |
| `ship` | `yona-ship` |
| `direct` | `yona-direct` |
| `blog` | `yona-blog` |

For a session that is none of these — a fix with no plan, an investigation, a conversation — use `fix`, `explore`, or `chat`. Reuse a word from this table before inventing one; the vocabulary only helps while it stays small.

## The Slug

The slug is the stable identity of one piece of work. Every session that touches that work carries the same slug, at every stage, across days. That is the whole point: `plan: esp32v3-emu`, `impl: esp32v3-emu`, and `ship: esp32v3-emu` are visibly one effort, and a second `impl: esp32v3-emu` a week later is visibly a return to it.

Shape: lowercase, hyphenated, two to four words, about twenty characters. Name the thing, not the action — the stage already carries the action. `esp32v3-emu`, not `build-esp32v3-emulator`. `device-card-panel`, not `redesign-cards`.

Rules:

- **Decided once, early.** The first yona stage the work passes through — `vision`, `ux`, or `plan` — picks the slug as soon as the subject is clear, usually within the first exchange. Do not wait for the artifact to be finished; a session that is untitled for an hour is the problem this skill exists to fix.
- **Recorded in the artifact.** `vision.md` and `plan.md` carry `slug:` in their frontmatter. A blog brief records it beside the title and URL slug candidates. A UX spike's directory name is its slug. The artifact, not the conversation, is where the next session finds it.
- **Reused, never reinvented.** Every later stage reads the slug from the artifact. If `plan.md` says `slug: esp32v3-emu`, the implementing session is `impl: esp32v3-emu` even if a shorter name comes to mind. Two slugs for one piece of work is worse than one awkward slug.
- **Derived when missing.** An older artifact with no `slug:` line gets one from its planning directory basename with the timestamp prefix removed — `2026-07-06-1635-versioning-core` yields `versioning-core` — shortened to fit the shape if needed. Write the result back into the frontmatter as `slug:` so the next session agrees with this one.

## The Project Tag

Most of the time every active session is in one repo, and the sidebar already shows the directory. A project tag earns its place only when several projects are active at once and the slugs alone no longer say which is which.

It is per-repo configuration, in `agent-context.toml` at the repo root:

```toml
[agent]
project_tag = "lp"
```

When set, every title from that repo reads `<stage>: <project>/<slug>`. When unset, the tag is omitted. Never guess a tag: no config, no tag.

## No Status In The Title

The sidebar shows the PR number and whether it is open, merged, or closed. The title does not repeat that. No `[done]`, no `WIP`, no `merged`, no `✅`.

Two markers are the whole exception, and neither is a stage word:

- **`[HANDOFF] `** as a prefix — `yona-handoff` applies it when work is parked for another agent, and the agent that picks the work up removes it. It means "nobody has this", which nothing else in the sidebar can say.
- **` (hold)`** as a suffix — work the user has deliberately paused. The user adds it; the skills leave it alone and carry it through stage changes.

## When To Rename

- **On skill entry**, once the slug is known. For `vision`, `ux`, and `plan` that is the moment the subject is clear, not the moment the artifact is written. For `impl`, `ship`, `direct`, and `blog` the slug is already in the artifact, so rename during setup.
- **When the stage changes within a session.** `yona-ship` runs in the same session as `yona-implement`; the title moves from `impl:` to `ship:` and the slug stays. A plan that rolls into implementation in one session does the same.
- **When invoked by hand.** The user runs `/yona-session` on a session that never went through a stage skill, or whose scope drifted. Work out the stage and slug from the conversation and any artifact it touched, and rename.

## How

Read the current title with the harness's session tools — `get_session` with the literal id `self` — and set it with `set_session_title`, again on `self`. Both are cheap; do not hunt for the session on disk.

If the harness has no session tools, print one line at the end of the response and move on:

```text
Rename this session to: <stage>: <slug>
```

### Whose title is it

`set_session_title` overwrites whatever is there, including a title the user typed. So decide before renaming:

- **Rename** when the current title is already in this form (a stage change or a slug correction), or is the harness's automatic title — a sentence-case summary of the opening prompt.
- **Leave it** when the title is clearly hand-written and outside this form: a numbering scheme, a status marker, a label that is neither a sentence nor `<stage>: <slug>`. The user set it on purpose. Say in one line what the convention would have called it, and move on.
- **Always say what you did.** One line in the response — `Session titled impl: esp32v3-emu.` — so the rename is visible and reversible.
- **Never rename another session** on your own initiative. The one exception is written into `yona-handoff`: the agent picking up parked work strips the `[HANDOFF] ` marker from the session that parked it.
