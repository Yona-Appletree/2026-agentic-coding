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

That installs the skills into `~/.claude/skills/`, so they are available in every project. Start a new Claude Code session in any project and use them as slash commands:

```text
/yona-plan add user profiles to this app
/yona-implement docs/plans/2026-06-09-user-profiles/plan.md
/yona-review my current branch against main
/yona-push
```

To update to the latest versions later:

```bash
cd 2026-ai-teaching
git pull
./install.sh
```

## What Is In Here

- `docs/skills/yona-plan.md`: turns an idea into a concrete repo-local plan.
- `docs/skills/yona-implement.md`: executes an existing plan, validates the work, records what happened, and archives the plan.
- `docs/skills/yona-review.md`: reviews a branch, PR, diff, or local changes and writes durable review notes.
- `docs/skills/yona-push.md`: pushes a finished branch, creates or updates a GitHub PR, watches CI, and fixes focused CI failures.

The repo also includes empty directories for artifacts created by those workflows:

- `docs/plans/`: active plans.
- `docs/reviews/`: active review artifacts.
- `docs/archive/plans/`: completed, cancelled, or superseded plans.
- `docs/archive/reviews/`: resolved or obsolete reviews.

## Using Without Installing

If you are not using Claude Code, or you do not want to install anything, clone or add this repo somewhere your AI tool can read. Then point the agent at the relevant skill file and ask it to follow that workflow.

Example prompts:

```text
Read docs/skills/yona-plan.md and use it to create a plan for adding user profiles to this app.
```

```text
Use docs/skills/yona-implement.md to implement the plan in docs/plans/2026-06-09-user-profiles/plan.md.
```

```text
Use docs/skills/yona-review.md to review my current branch against main.
```

```text
Use docs/skills/yona-push.md to push this finished branch, create a PR, and watch CI.
```

If your agent supports custom skills or commands directly, install or register the Markdown files in `docs/skills/`. If it does not, paste the relevant skill into the chat or tell the agent to read the file before it starts.

## Suggested Workflow

1. Start with `yona-plan` for anything bigger than a tiny fix.
2. Review the plan with the human before implementation.
3. Use `yona-implement` to execute the plan.
4. Use `yona-review` before merging, especially for risky changes.
5. Use `yona-push` once local validation is done and the branch is ready for GitHub.

The point is not ceremony for its own sake. The point is to teach agents to leave useful artifacts behind: what was decided, what changed, how it was validated, and what still needs a human call.

## Repo-Local Artifacts

The skills intentionally store their working artifacts inside the repo instead of in a personal notes directory or company shared drive. That makes the workflow portable for students and friends:

```text
docs/
  skills/
  plans/
  reviews/
  archive/
    plans/
    reviews/
```

Plans are meant to be active while work is in progress, then archived after implementation. Reviews can be kept while findings are being resolved, then archived once they are no longer active.

## Notes For New Coders

These skills work best when you ask the agent to show its work in files, not just in chat. A good planning file makes implementation easier. A good review file makes feedback less mysterious. A good completion log helps you remember what actually happened after the code is done.

## License

This repo is released into the public domain under The Unlicense. See `UNLICENSE` for the full public domain dedication and no-warranty terms.
