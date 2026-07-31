---
name: yona-plan
description: Create or update a planning artifact. Use for roadmap-level planning, implementation planning, small plans, and planning-oriented investigations.
---

# Yona Plan

Use this skill to turn an idea into a concrete planning artifact that another agent or human can execute.

Planning has two modes:

- Informal pre-planning: chat, code reading, and exploration before the user asks to start the process. Do not create files yet.
- Formal planning: resolve the planning location, write `notes.md`, run discovery, then write `plan.md` and phase files as needed.

## Planning Location

Resolve where planning artifacts go before writing anything.

1. Determine the repo root with `git rev-parse --show-toplevel`. If the project is not a git repo, use the current working directory.
2. Read `agent-context.toml` at the repo root when present:

```toml
[agent]
repo_slug = "lp2025"
planning_root = "~/.photomancer/planning"
planning_root_env = "PHOTOMANCER_PLANNING_ROOT"  # optional; wins over planning_root when set
```

3. Resolve the planning root, first match wins:
   - the environment variable named by `planning_root_env`, when set and non-empty
   - `planning_root` from the config, expanding `~`
   - repo-local `docs/plans/` — the default when there is no config
4. Resolve the repo slug from `repo_slug`, otherwise the git root basename.
5. Resolve the workspace root:
   - external planning root: `<planning-root>/<repo-slug>/`
   - repo-local default: `<repo-root>/docs/plans/`

If a config names a planning root that does not resolve, stop and ask. Do not guess a path, and do not silently fall back to repo-local — the difference is where the user will look for the plan.

Create active plans under:

```text
<workspace-root>/<YYYY-MM-DD-HHMM>-<name>/
```

Use the local workspace timezone. The `HHMM` segment is 24-hour time captured when formal planning starts, for example `2026-07-06-1635-versioning-core`. If a generated directory already exists for a different plan, add a short disambiguating suffix to the name.

Move completed, cancelled, or superseded plans to:

- external planning root: `<workspace-root>/_archive/<same-basename>/`
- repo-local default: `<repo-root>/docs/archive/plans/<same-basename>/`

Preserve the original basename when archiving. If a destination already exists, add a short suffix such as `-v2` rather than overwriting it.

**Legacy layouts.** Older planning directories are date-only (`2026-07-28-fw-esp32-prep`) and older phase files are plain numeric (`01-phase-title.md`) rather than ID-prefixed. Read both without complaint. Only *new* directories get the `-HHMM` segment, and only new phase files get the ID prefix; never rename existing artifacts to match the current convention.

Every formal planning directory should contain:

- `notes.md` for discovery notes, questions, user answers, and scope changes.
- `plan.md` as the final entrypoint for implementation.
- Optional phase files or phase directories when the plan size warrants them.
- `_DONE.md` only after implementation, written by `yona-implement` as the completion log.

Do not create `_DONE.md` during planning. Reserve that filename for the implementation record of what actually happened.

Do not create separate `plans/` or `roadmaps/` trees for new work. Use `plan.md` as the entrypoint and use metadata plus phase files to express size.

## Formal Planning Start

When the user asks to start planning, create the planning directory and `notes.md` immediately.

Use `notes.md` as the live discovery log. Include:

- Initial understanding and goals.
- Current state of the codebase or process.
- Relevant files, modules, services, docs, or repos inspected.
- Documentation surfaces likely to need updates.
- Questions with context and suggested answers.
- User answers and corrections.
- Scope changes from the user.
- New questions discovered during planning.
- Out-of-scope or future-work ideas when useful.

Any user statement that changes scope, constraints, priorities, acceptance criteria, or implementation direction must be reflected in `notes.md` before continuing.

## Reference IDs

Use stable short IDs for anything the user may need to reference later, including questions, discussion points, assumptions, milestones, phases, and steps.

- Use canonical uppercase IDs in artifacts and agent messages: `Q1`, `D1`, `A1`, `M1`, `P1`, `S1`.
- Accept lowercase user references as equivalent: `q1` means `Q1`, `m08` means `M08`.
- Use lowercase ID prefixes in filenames, such as `p1-model-foundation.md` or `m09-validation.md`.
- Do not renumber an ID after showing it to the user. Add new IDs instead.
- Use an `ID` column in tables instead of `#`.
- Do not label every bullet. Add IDs where follow-up, approval, discussion, implementation, or later reference is plausible.
- `Q#` — confirmation or clarification questions.
- `D#` — discussion points: big, ambiguous, architectural, scope-changing, or tradeoff-heavy topics.
- `A#` — important assumptions when they may need confirmation or later tracking.
- `M#` — large-plan milestones.
- `P#` — medium-plan phases.
- `S#` — small-plan implementation steps when steps are useful.

## Discovery Phase

Discovery happens before writing final plan files. Inspect enough code, docs, and tests to make the plan concrete. Prefer `rg`, targeted file reads, and existing project docs.

After initial discovery, summarize questions and decisions for the user. Triage them into:

- Confirmation-style questions: small questions where you have a probable answer.
- Discussion-style questions: big, ambiguous, architectural, scope-changing, or tradeoff-heavy questions.

For confirmation-style questions, batch them in chat as a table:

```md
| ID | Question | Context | Suggested answer |
|---|---|---|---|
| Q1 | Use the existing provider pattern? | Similar services already do this. | Yes |
| Q2 | Keep this route behind admin auth? | It exposes sensitive data. | Yes |
```

Tell the user they can answer with `all yes`, `lgtm`, or specific overrides such as `Q2 no, use project admin`. Treat lowercase references such as `q2 no` the same way.

For discussion-style questions, ask one question at a time. Make the question visually obvious:

```md
---

## D3: Should this be a shared primitive or a route-local implementation?

<short context from code/docs>

**Suggested answer:** <recommended direction and why>
```

When the user answers:

1. Update `notes.md` with the answer.
2. Update scope, assumptions, and acceptance criteria if needed.
3. Add any new questions that follow from the answer.
4. Continue with the next unresolved big question, one at a time.

End discovery when major questions are answered, the remaining unknowns are safe assumptions, or the user asks to proceed.

## Convention Review

Before proposing final phases, inspect relevant repo conventions. Look for files such as:

- `README.md`
- `CONTRIBUTING.md`
- `AGENTS.md`
- `CLAUDE.md`
- `.cursorrules`
- `docs/style/`
- nearby files and tests that establish local patterns

Carry relevant conventions into `plan.md` and each phase file so later implementation agents do not need to rediscover them.

## Plan Sizing

After discovery, propose the plan size and general flow before writing final phase files.

Use these sizes:

- `sm`: one-shot work that can be executed by one agent in one pass.
- `md`: phased work that one agent can mostly execute end-to-end, but benefits from separate phases, checkpoints, tests, or user review.
- `lg`: roadmap-level work where at least some phases likely need their own planning process.

Record the selected size in `plan.md` frontmatter as `size: sm | md | lg`.

Map size to depth:

- `sm` -> `small`
- `md` -> `implementation`
- `lg` -> `roadmap` or `program`

## Phase Agent Models

Every phase gets a suggested execution model so implementation does not default to the most expensive agent. Record it in the phase table (`Model` column) and as a `Model:` line near the top of each phase file.

Model ladder, smallest to largest: `haiku` -> `sonnet` -> `opus` -> `fable`.

Pick the smallest model whose plausible mistakes the phase's validation would catch cheaply:

- `haiku`: mechanical, well-oracled work — renames, formatting, doc sweeps, config plumbing, running scripted validation.
- `sonnet`: well-specified implementation where tests/compilers give fast trustworthy feedback and ambiguity is low.
- `opus`: the default for ordinary implementation phases — multi-file changes, moderate ambiguity, design details left to the implementer.
- `fable`: reserve for exploratory or debugging-heavy phases — undocumented APIs, hardware bring-up, subtle concurrency, or anywhere a wrong-but-plausible result would slip past validation. Fable tokens are scarce; a phase earns `fable` by failure mode, not by importance.

Rules:

- Do not suggest a model larger than the model doing the planning. If a phase seems to genuinely need one, flag it in the phase table for the user to decide rather than suggesting it silently.
- If validation is too weak to catch a smaller model's plausible mistakes, first try strengthening the validation (a better oracle or tighter tests often unlocks a smaller model); upgrade the model only when that fails.
- For large plans, executable `sm` milestones carry a model like phases do; `md`/`lg` milestones get models when their own planning runs.

## Review Gates

A **review gate** is a point where implementation stops for human judgment: a visual or feel gate on UI work, a hardware walk, approval of a direction, or a final pre-merge review.

Gates are the *only* planned stopping points. `yona-implement` runs from the start of the plan to the first gate, and from the last gate to the pull request, without checking in. That makes gate declaration a planning responsibility: a gate you forget to declare will not happen, and a gate you add casually costs the user an interaction.

Rules:

- Every phase carries an explicit `Review gate:` value. Use `none` when implementation should continue straight through.
- `plan.md` carries a **Gates** section listing every gate in the plan with its exact questions. When there are none, write the literal line `Gates: none — run to PR`.
- A gate without questions is a status update, not a gate. Write what needs human judgment and what "pass" looks like.
- Prefer an end-of-phase gate with specific questions over a dedicated review-only phase.
- Design phase boundaries to minimize gates. Group decisions that need human judgment early or at natural boundaries so later work can run without mid-plan user input.
- Include a gate only when warranted by product, API, architecture, security, migration, UX, or scope judgment. "Check my work" is not a gate; validation and code review cover that.

If the repo documents its own handoff procedure (for example a `docs/process/review-gates.md`), reference it from the plan so the implementer follows it at each gate.

## Size-Specific Planning

### Small (`sm`)

Use one `plan.md`. Summarize:

- Scope and explicit out-of-scope boundaries.
- Files/modules likely affected.
- Docs likely affected, especially package/module `README.md` files, or why no docs updates are expected.
- Important data type, API, architecture, security, performance, embedded, or process changes.
- Validation commands.
- ADR expectation: `expected`, `possible`, or `none`.
- Gates, usually `none — run to PR`.

Do not create phase files unless discovery shows the work is actually medium.

### Medium (`md`)

Use `plan.md` plus `p1-*.md`, `p2-*.md` phase files. Use one digit for up to 8 phases; when there may be 9 or more, use two digits (`p09-cleanup.md`, `p10-follow-through.md`) so they sort. Treat `P8` and `P08` as equivalent in user references. Phase files should each be `sm` sized.

Before writing phase files, present a phase table for user review:

```md
| ID | Size | Model | Summary | Files/modules | Agent guidance | Review gate | Notes |
|---|---|---|---|---|---|---|---|
| P1 | sm | sonnet | Add schema and migration | `packages/...` | small/medium agent | none | Must run DB tests |
| P2 | sm | opus | Wire UI route | `apps/...` | medium agent | Visual: layout + empty state | Can run after P1 |
```

Also summarize:

- General work to be done.
- Files/modules expected to change.
- Big data type, API, architecture, security, performance, or process changes.
- Parallelization opportunities.
- Gates, with the specific questions or artifacts to review.

Adjust the phase table based on user feedback. When the user says `ok`, `good`, `lgtm`, or equivalent, write the phase files.

### Large (`lg`)

Use `plan.md` as a roadmap-level plan. Refer to roadmap work items as milestones: `M1`, `M2`. Some milestones may be `md` or `lg` and may need their own planning process later.

Use `m1-*.md` milestone files when separate files are useful, with the same two-digit rule as phases.

Before writing milestone files, present a review table:

```md
| ID | Size | Summary | Why this size | Needs own planning? | Notes |
|---|---|---|---|---|---|
| M1 | sm | Establish shared primitive | Self-contained | No | Can execute directly |
| M2 | md | Migrate existing flows | Several routes/tests | Maybe | Break into sm sub-phases |
| M3 | lg | Cross-repo rollout | Multiple repos | Yes | Needs separate plan |
```

Adjust based on user feedback. When approved, write roadmap or milestone files. Each executable file should still be self-contained. If a milestone is `md` or `lg`, its file should say whether a follow-up `yona-plan` run is required before implementation.

## `plan.md`

Every planning directory has `plan.md` as its implementation entrypoint.

Use frontmatter:

```md
---
kind: plan
size: sm | md | lg
depth: small | implementation | roadmap | program
status: active
repo: <repo-slug>
created: YYYY-MM-DD-HHMM
adr: expected | possible | none
pr: pending
---
```

The `# H1` immediately below the frontmatter is the plan title. `yona-implement` uses it as the pull request title, so write it as a short readable summary of the work rather than an echo of the directory name.

`plan.md` should include:

- Planning size and why it was selected.
- Goal and acceptance criteria.
- Scope and out-of-scope boundaries.
- Discovery summary with link to `notes.md`.
- Files/modules expected to change.
- Documentation expected to change, including package/module `README.md` files when package purpose or boundaries change.
- Repo-specific conventions and constraints that implementation must preserve.
- Architecture, data type, API, security, product, performance, embedded, or process decisions.
- ADR expectations or candidates.
- Validation strategy.
- **Gates** — every gate with its questions, or `Gates: none — run to PR`.
- Phase table or one-shot implementation instructions.

`status` starts as `active`. After implementation, `yona-implement` updates frontmatter to `status: done` plus `completed:`, `commit:`, and `pr:`.

The implementation agent should not rename `plan.md` after completion.

### Decisions need a phase home

Before finishing, cross-check every settled decision in `plan.md` against the union of the phase scopes. A decision recorded only in `plan.md`, with no phase that owns implementing it, silently does not happen. Either assign it to a phase or state explicitly that it is context rather than work.

## Phase Files

The main planning agent writes every phase file. Do not delegate phase-file authoring unless the user explicitly asks.

Every executable phase file must be self-contained. Another agent may read only that file plus referenced files.

Include:

- Work item ID: `P#` for medium phases or `M#` for large milestones.
- Scope of phase and explicit out-of-scope boundaries.
- Size: usually `sm`; if `md` or `lg`, say whether another `yona-plan` run is required.
- Suggested execution model: a `Model: haiku | sonnet | opus | fable` line (see Phase Agent Models).
- Dependencies and parallelization notes.
- Files/modules likely affected.
- Docs likely affected and what should be updated, including nearby package/module `README.md` files.
- Implementation details, with code examples when helpful.
- Relevant style rules or repo conventions.
- ADR expectation for the phase.
- `Review gate:` — `none`, or the exact questions and artifacts the human must review before the next phase starts.
- Agent reminders:
  - Do not expand scope.
  - Do not suppress warnings or disable tests.
  - Delegated agents do not commit.
  - Stop and report back if blocked by ambiguity or an unexpected design issue.
  - Report what changed, what was validated, and any deviations.
- Validation commands.
- Definition of done.

The final phase of medium and large plans should include cleanup, docs, and validation. It should check for TODOs, debug prints, commented-out code, scratch files, suppressed warnings, disabled tests, stale docs, missing docs, and scope creep.

Do not plan to rename phase files after completion. `yona-implement` appends a short `Implementation Result` section instead.

## ADR Expectations

Create an ADR when a change chooses a direction among plausible alternatives and that choice has lasting architectural, operational, security, data-model, API, workflow, product, embedded, or cross-repo/process consequences.

Usually create ADRs for new domain models, resource patterns, storage/schema shapes, public API contracts, auth/security boundaries, external integrations, infrastructure dependencies, compiler/runtime contracts, embedded constraints, or cross-repo/process conventions.

Usually do not create ADRs for straightforward feature implementation, bug fixes, UI copy/layout changes, mechanical refactors, tests, scripts, helpers, or phase sequencing unless they set a broader precedent.

## Future Work

If useful ideas come up that are outside current scope, record them in `notes.md` under future work. Create a separate `future.md` only when the list becomes substantial enough to deserve its own file.

## Implementation Log Convention

Implementation completion is recorded in `_DONE.md` in the planning directory, not in `summary.md`.

`_DONE.md` is the record of what was actually done: outcome, completed work, PR URL, validation commands and results, deviations, documentation updated, ADRs created, and remaining follow-up.

Planning agents should mention this convention when useful, but should not write `_DONE.md`.

## Completion

Stop after writing the planning artifacts unless the user also asked to implement.

Before stopping, tell the user:

- Planning directory path.
- Selected size and depth.
- Files written.
- Gates declared, or that there are none.
- Any unresolved assumptions.
- Suggested next command, usually `yona-implement`.

Say plainly that `yona-implement` will run to the first gate — or to a pull request if there are no gates — so the user knows what they are approving.

If implementation is requested, use the `yona-implement` workflow against the finished `plan.md`.
