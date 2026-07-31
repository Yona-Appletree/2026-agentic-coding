# 2026 AI Teaching

This repo contains a small set of agent workflow skills for teaching newer coders how to use AI coding agents with more structure.

The skills are plain Markdown files. They are written so you can point an agent at this repo, tell it which skill to use, and have it follow a repeatable workflow for planning, implementation, review, and pull-request cleanup.

## Quick Install (Claude Code)

Copy and paste this into a terminal:

```bash
git clone https://github.com/Yona-Appletree/2026-ai-teaching.git
cd 2026-ai-teaching
./install.sh
```

That symlinks the skills into `~/.claude/skills/`, so they are available in every project. Start a new Claude Code session in any project and use them as slash commands:

```text
/yona-plan add user profiles to this app
/yona-implement docs/plans/2026-06-09-user-profiles/plan.md
/yona-review my current branch against main
/yona-push
```

Because the install is a symlink, updating is just:

```bash
cd 2026-ai-teaching
git pull
```

There is exactly one copy of each skill — the one in this repo. Edit them here. (If your setup cannot follow symlinks, `./install.sh --copy` installs copies instead, and you re-run it after each pull.)

## What Is In Here

- `docs/principles.md`: the way of working behind the skills — start here.
- `docs/skills/yona-plan/`: turns an idea into a concrete plan with declared review gates.
- `docs/skills/yona-implement/`: executes a plan end to end — implements, validates, opens and drives a pull request, watches CI, records what happened, and archives the plan.
- `docs/skills/yona-review/`: reviews a branch, PR, diff, or local changes and writes durable review notes.
- `docs/skills/yona-push/`: pushes a branch that already has the work on it, creates or updates a GitHub PR, watches CI, and fixes focused CI failures.

Each skill is a directory containing `SKILL.md`, plus `references/` and `scripts/` where they help.

The repo also includes empty directories for artifacts created by those workflows:

- `docs/plans/`: active plans.
- `docs/reviews/`: active review artifacts.
- `docs/archive/plans/`: completed, cancelled, or superseded plans.
- `docs/archive/reviews/`: resolved or obsolete reviews.

## Using Without Installing

If you are not using Claude Code, or you do not want to install anything, clone or add this repo somewhere your AI tool can read. Then point the agent at the relevant skill file and ask it to follow that workflow.

Example prompts:

```text
Read docs/skills/yona-plan/SKILL.md and use it to create a plan for adding user profiles to this app.
```

```text
Use docs/skills/yona-implement/SKILL.md to implement the plan in docs/plans/2026-06-09-user-profiles/plan.md.
```

```text
Use docs/skills/yona-review/SKILL.md to review my current branch against main.
```

```text
Use docs/skills/yona-push/SKILL.md to push this branch, create a PR, and watch CI.
```

If your agent supports custom skills or commands directly, install or register the directories in `docs/skills/`. If it does not, paste the relevant skill into the chat or tell the agent to read the file before it starts.

## Suggested Workflow

1. Start with `yona-plan` for anything bigger than a tiny fix.
2. Review the plan with the human before implementation.
3. Use `yona-implement` to execute the plan. It runs to the first review gate the plan declared, or to a pull request if the plan declared none.
4. Use `yona-review` before merging, especially for risky changes.
5. Use `yona-push` for a branch that already has the work on it but no PR yet.

The point is not ceremony for its own sake. The point is to teach agents to leave useful artifacts behind: what was decided, what changed, how it was validated, and what still needs a human call.

## Gates, And Running To The End

The most common way this workflow goes wrong is an agent that stops every time it finishes a piece — "phase 2 is done, shall I continue?" — and leaves you shepherding a branch you thought was handled.

So the skills draw one line. `yona-plan` declares **review gates**: the specific points where a human needs to judge something, each with its questions written down. `yona-implement` then runs from the start of the plan to the first gate, and from the last gate to a pull request, without checking in anywhere else. A phase boundary is not a gate. A commit is not a gate. "Implementation is finished" is not a gate.

The pull request is part of the pipeline, not a follow-up step. `yona-implement` opens it as a draft as soon as there is a first commit — before the work is done — so CI starts giving you signal early. It goes ready for review when the work is complete, CI is green, and no gate is pending. If the plan ends at a gate, the PR stays draft and the handoff says so.

## Where Artifacts Live

By default the skills store their working artifacts inside the repo, which makes the workflow portable and keeps a plan next to the code it describes:

```text
docs/
  skills/
  plans/
  reviews/
  archive/
    plans/
    reviews/
```

If you would rather keep plans outside the repo — a personal notes directory, a shared drive, anywhere the repo should not carry them — add an `agent-context.toml` at the repo root:

```toml
[agent]
repo_slug = "my-project"
planning_root = "~/notes/planning"
planning_root_env = "MY_PLANNING_ROOT"  # optional; this env var wins when set
```

Plans then land in `<planning-root>/<repo-slug>/`, archives in `<planning-root>/<repo-slug>/_archive/`, and reviews in `<planning-root>/<repo-slug>/_reviews/`. With no config file, everything stays repo-local. The skills are identical either way — only the destination changes.

Plans are meant to be active while work is in progress, then archived after implementation. Reviews can be kept while findings are being resolved, then archived once they are no longer active.

## Notes For New Coders

These skills work best when you ask the agent to show its work in files, not just in chat. A good planning file makes implementation easier. A good review file makes feedback less mysterious. A good completion log helps you remember what actually happened after the code is done.

## License

This repo is released into the public domain under The Unlicense. See `UNLICENSE` for the full public domain dedication and no-warranty terms.
