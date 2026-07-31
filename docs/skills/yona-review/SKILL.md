---
name: yona-review
description: Review local changes, branches, worktrees, diffs, or GitHub pull requests with durable review artifacts.
---

# Yona Review

Use this skill when the user asks for a code review of a branch, PR, worktree, diff, staged changes, or uncommitted changes.

## Review Location

Resolve the workspace the same way `yona-plan` does:

1. Determine the repo root with `git rev-parse --show-toplevel`. If the project is not a git repo, use the current working directory and name the review directory from the topic the user provided.
2. Read `agent-context.toml` at the repo root when present, for `repo_slug`, `planning_root`, and `planning_root_env`.
3. Resolve the planning root, first match wins: the environment variable named by `planning_root_env` when set and non-empty, then `planning_root` from the config (expanding `~`), then repo-local.

Write durable review artifacts under:

- external planning root: `<planning-root>/<repo-slug>/_reviews/<YYYY-MM-DD-HHMM>-<branch-or-topic>/`
- repo-local default: `<repo-root>/docs/reviews/<YYYY-MM-DD-HHMM>-<branch-or-topic>/`

Archive resolved or obsolete reviews under `_reviews/_archive/` or `docs/archive/reviews/` respectively, preserving the basename.

Use the local workspace timezone for the timestamp. Reuse an existing review directory for the same branch or PR — including older date-only directories — unless the user asks for a fresh review.

After resolving context, read repo agent guides such as `AGENTS.md`, `CLAUDE.md`, or `.cursorrules`. Review against repo-specific constraints, especially product-critical architecture rules.

## Review Process

1. Identify the target and base ref.
2. Reuse an existing review directory for the same branch/PR unless the user asks for a fresh review.
3. Capture changed files, diff stat, commits, and patch when useful.
4. Run the relevant passes from `references/review-passes.md`.
5. Write a concise review summary.
6. Create numbered durable issue files for valid findings.

For git-backed reviews, `scripts/collect-review-context.sh <base-ref> <review-dir> [head-ref]` writes the artifacts below in one step. `scripts/prepare-review-worktree.sh <branch> [worktree-root]` creates or updates a worktree when the review needs the branch checked out separately.

Equivalent by hand:

```bash
base_ref="${BASE_REF:-origin/main}"
head_ref="${HEAD_REF:-HEAD}"
merge_base="$(git merge-base "$base_ref" "$head_ref")"
mkdir -p "$review_dir/artifacts"
git diff --name-only "$merge_base..$head_ref" > "$review_dir/artifacts/changed-files.txt"
git diff --stat      "$merge_base..$head_ref" > "$review_dir/artifacts/diff-stat.txt"
git log  --oneline   "$merge_base..$head_ref" > "$review_dir/artifacts/commits.txt"
git diff             "$merge_base..$head_ref" > "$review_dir/artifacts/patch.diff"
```

## Artifact Shape

Create:

- `summary.md` with the target, base, scope, overall assessment, findings table, validation notes, and residual risk.
- `artifacts/changed-files.txt`
- `artifacts/diff-stat.txt`
- `artifacts/commits.txt` when commits are relevant.
- `artifacts/patch.diff` when keeping the full patch is useful.
- `issues/001-short-title.md`, `issues/002-short-title.md`, etc. for findings that should be fixed or consciously accepted.

Each issue file should include:

- Severity: `P0`, `P1`, `P2`, or `P3` — see `references/finding-severity.md`.
- File and line references when available.
- What is wrong.
- Why it matters.
- Suggested fix.
- Validation that would prove the fix.

## Severity

Use severity to communicate merge risk, not reviewer confidence. `references/finding-severity.md` has the full rubric; the short form:

- `P0`: release-stopping — credential leak, exploitable flaw, data loss, deploy breakage, broken auth or tenant isolation, product-critical path disabled.
- `P1`: likely user-visible or correctness failure, backwards-incompatible API or persisted-data change, missing tests for high-risk touched behavior, broken target-specific build path.
- `P2`: meaningful engineering risk — pattern violation, missing edge-case coverage, accessibility or responsive issue in a touched UI path, observability gap, unmeasured performance or size regression.
- `P3`: minor tracked work — naming, clarity, low-risk cleanup, documentation gaps.

When uncertain, choose the lower severity and write better evidence.

## Review Passes

`references/review-passes.md` holds the full checklists: correctness, tests, repo conventions, embedded and runtime, security and operations, and frontend. Use only the passes relevant to the diff.

## ADR Candidates

If the review reveals a durable architectural or policy decision, record it as an ADR candidate in `summary.md`.

Create an ADR only when a change chooses a direction among plausible alternatives and that choice has lasting architectural, operational, security, data-model, API, workflow, product, embedded, or cross-repo/process consequences.

Accepted ADRs are committed with the implementation or policy change that resolves the review.

## Final Response

Lead with findings, ordered by severity. Include file and line references when available.

Then include:

- Open questions or assumptions.
- Brief change summary as secondary context.
- Review artifact path.
- Tests or validation inspected, and any gaps.

If there are no findings, say that clearly and mention residual risk or test gaps.
