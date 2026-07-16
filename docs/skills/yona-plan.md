---
name: yona-plan
description: Create or update a repo-local planning artifact. Use for roadmap-level planning, implementation planning, small plans, and planning-oriented investigations.
---

# Yona Plan

Use this skill to turn an idea into a concrete planning artifact that another agent or human can execute.

Planning has two modes:

- Informal pre-planning: chat, code reading, and exploration before the user asks to start the process. Do not create files yet.
- Formal planning: create the repo-local planning directory, write `notes.md`, run discovery, then write `plan.md` and phase files as needed.

## Planning Location

Use repo-local planning artifacts by default.

1. Determine the repo root with `git rev-parse --show-toplevel`. If the project is not a git repo, use the current working directory.
2. Create active plans under:

```text
docs/plans/<YYYY-MM-DD>-<name>/
```

3. Move completed, cancelled, or superseded plans to:

```text
docs/archive/plans/<YYYY-MM-DD>-<name>/
```

Every formal planning directory should contain:

- `notes.md` for discovery notes, questions, user answers, and scope changes.
- `plan.md` as the final entrypoint for implementation.
- Optional phase files or phase directories when the plan size warrants them.
- `_DONE.md` only after implementation, written by `yona-implement` as the completion log.

Do not create `_DONE.md` during planning. Reserve that filename for the implementation record of what actually happened.

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

## Discovery Phase

Discovery happens before writing final plan files. Inspect enough code, docs, and tests to make the plan concrete. Prefer `rg`, targeted file reads, and existing project docs.

After initial discovery, summarize questions and decisions for the user. Triage them into:

- Confirmation-style questions: small questions where you have a probable answer.
- Discussion-style questions: big, ambiguous, architectural, scope-changing, or tradeoff-heavy questions.

For confirmation-style questions, batch them in chat as a table:

```md
| # | Question | Context | Suggested answer |
|---|---|---|---|
| Q1 | Use the existing provider pattern? | Similar services already do this. | Yes |
| Q2 | Keep this route behind admin auth? | It exposes sensitive data. | Yes |
```

Tell the user they can answer with `all yes`, `lgtm`, or specific overrides such as `Q2 no, use project admin`.

For discussion-style questions, ask one question at a time. Make the question visually obvious:

```md
---

## Q3: Should this be a shared primitive or route-local implementation?

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
- `.github/copilot-instructions.md`
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

## Work Item IDs And Review Gates

Keep phase and milestone filenames sortable and stable, such as `01-*.md`, `02-*.md`, etc. Use human-friendly IDs in tables, headings, and references:

- Medium plans use phase IDs: `P1`, `P2`, `P3`.
- Large plans use milestone IDs: `M1`, `M2`, `M3`.
- Small plans do not need IDs beyond the one-shot `plan.md`.

Design phase boundaries to minimize human-review interactions. Group decisions that need human judgment early or at natural boundaries so later work can run without mid-phase user input when possible.

For medium plans, include review gates only when warranted by product, API, architecture, security, migration, UX, or scope decisions. Prefer an end-of-phase stop with specific review questions or artifacts over a dedicated review-only phase.

## Size-Specific Planning

### Small (`sm`)

Use one `plan.md`. Summarize:

- Scope and explicit out-of-scope boundaries.
- Files/modules likely affected.
- Docs likely affected, especially package/module `README.md` files, or why no docs updates are expected.
- Important data type, API, architecture, security, or process changes.
- Validation commands.
- ADR expectation: `expected`, `possible`, or `none`.

Do not create phase files unless discovery shows the work is actually medium.

### Medium (`md`)

Use `plan.md` plus `01-*.md`, `02-*.md`, etc. Phase files should each be `sm` sized. Refer to phases as `P1`, `P2`, etc. in the plan and headings while keeping numeric filenames.

Before writing phase files, present a phase table for user review:

```md
| Phase | Size | Summary | Files/modules | Agent guidance | Review gate | Notes |
|---|---|---|---|---|---|---|
| P1 | sm | Add schema and migration | `packages/...` | small/medium agent | None | Must run DB tests |
| P2 | sm | Wire UI route | `apps/...` | medium agent | End-of-phase UX review | Can run after P1 |
```

Also summarize:

- General work to be done.
- Files/modules expected to change.
- Big data type, API, architecture, security, or process changes.
- Parallelization opportunities.
- Review gates, if any, with the specific questions or artifacts to review.

Adjust the phase table based on user feedback. When the user says `ok`, `good`, `lgtm`, or equivalent, write the phase files.

### Large (`lg`)

Use `plan.md` as a roadmap-level plan. Refer to roadmap work items as milestones: `M1`, `M2`, etc. Some milestones may be `md` or `lg` and may need their own planning process later.

Before writing phase or milestone files, present a review table:

```md
| Milestone | Size | Summary | Why this size | Needs own planning? | Notes |
|---|---|---|---|---|---|
| M1 | sm | Establish shared primitive | Self-contained | No | Can execute directly |
| M2 | md | Migrate existing flows | Several routes/tests | Maybe | Break into sm sub-phases |
| M3 | lg | Cross-repo rollout | Multiple repos | Yes | Needs separate plan |
```

Adjust based on user feedback. When approved, write roadmap or phase files. Each executable phase file should still be self-contained. If a phase is `md` or `lg`, its file should say whether a follow-up `yona-plan` run is required before implementation.

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
created: YYYY-MM-DD
adr: expected | possible | none
---
```

`plan.md` should include:

- Planning size and why it was selected.
- Goal and acceptance criteria.
- Scope and out-of-scope boundaries.
- Discovery summary with link to `notes.md`.
- Files/modules expected to change.
- Documentation expected to change, including package/module `README.md` files when the package purpose or boundaries change.
- Architecture, data type, API, security, or process decisions.
- ADR expectations or candidates.
- Validation strategy.
- Phase table or one-shot implementation instructions.

`status` starts as `active`. After implementation, `yona-implement` may update frontmatter to:

```md
status: done
completed: YYYY-MM-DD
commit: <sha>
```

The implementation agent should not rename `plan.md` after completion.

## Phase Files

The main planning agent writes every phase file. Do not delegate phase-file authoring unless the user explicitly asks.

Use names like:

```text
01-phase-title.md
02-phase-title.md
```

Every executable phase file must be self-contained. Another agent may read only that file plus referenced files.

Include:

- Work item ID when applicable: `P#` for medium phases or `M#` for large milestones.
- Scope of phase and explicit out-of-scope boundaries.
- Size: usually `sm`; if `md` or `lg`, say whether another `yona-plan` run is required.
- Dependencies and parallelization notes.
- Files/modules likely affected.
- Docs likely affected and what should be updated, including nearby package/module `README.md` files.
- Implementation details, with code examples when helpful.
- Relevant style rules or repo conventions.
- ADR expectation for the phase.
- Review gate: `none` unless the implementer should stop at the end of the phase for human review. If present, include the exact questions or artifacts to review before continuing.
- Agent reminders:
  - Do not commit unless the user asked.
  - Do not expand scope.
  - Do not suppress warnings or disable tests.
  - Stop and report back if blocked by ambiguity or unexpected design issues.
  - Report what changed, what was validated, and any deviations.
- Validation commands.
- Definition of done.

The final phase of medium and large plans should include cleanup, docs, and validation. It should grep for TODOs, debug prints, commented-out code, scratch files, suppressed warnings, disabled tests, stale docs, missing docs, and scope creep.

Do not plan to rename phase files after completion. Keep names such as `01-phase-title.md` stable so links and agent references remain valid. If phase-level traceability is useful, `yona-implement` may append a short `Implementation Result` section to the phase file after that phase is complete.

## ADR Expectations

Create an ADR when a change chooses a direction among plausible alternatives and that choice has lasting architectural, operational, security, data-model, API, workflow, or cross-repo/process consequences.

Usually create ADRs for new domain models, resource patterns, schema/database shapes, public API contracts, auth/security boundaries, external integrations, infrastructure dependencies, or cross-repo/process conventions.

Usually do not create ADRs for straightforward feature implementation, bug fixes, UI copy/layout changes, mechanical refactors, tests, scripts, helpers, or phase sequencing unless they set a broader precedent.

## Future Work

If useful ideas come up that are outside current scope, record them in `notes.md` under future work. Create a separate `future.md` only when the future-work list becomes substantial enough to deserve its own file.

## Implementation Log Convention

Implementation completion is recorded in `_DONE.md` in the planning directory, not in `summary.md`.

`_DONE.md` is the record of what was actually done. It should include:

- Outcome.
- Completed work.
- Validation commands and results.
- Deviations from the plan.
- Documentation updated, or why no docs were needed.
- ADRs created, or why no ADR was warranted.
- Follow-up work that remains outside the completed scope.

Planning agents should mention this convention when useful, but should not write `_DONE.md`.

## Completion

Stop after writing the planning artifacts unless the user also asked to implement.

Before stopping, tell the user:

- Planning directory path.
- Selected size and depth.
- Files written.
- Any unresolved assumptions.
- Suggested next command, usually `yona-implement`.

If implementation is requested, use the `yona-implement` workflow against the finished `plan.md`.
