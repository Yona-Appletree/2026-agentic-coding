---
name: yona-review
description: Review local changes, branches, worktrees, diffs, or GitHub pull requests with durable repo-local review artifacts.
---

# Yona Review

Use this skill when the user asks for a code review of a branch, PR, worktree, diff, staged changes, or uncommitted changes.

## Review Location

Write durable review artifacts under:

```text
docs/reviews/<YYYY-MM-DD>-<branch-or-topic>/
```

Archive resolved or obsolete reviews under:

```text
docs/archive/reviews/<YYYY-MM-DD>-<branch-or-topic>/
```

If the project is not a git repo, use the current working directory as the repo root and name the review directory from the topic the user provided.

## Review Process

1. Identify the target and base ref.
2. Reuse an existing review directory for the same branch/PR unless the user asks for a fresh review.
3. Capture changed files, diff stat, commits, and patch when useful.
4. Review for correctness, security, migration risk, public contracts, UX/accessibility, tests, and repo conventions.
5. Write a concise review summary.
6. Create numbered durable issue files for valid findings.

For git-backed reviews, collect context with commands like:

```bash
base_ref="${BASE_REF:-origin/main}"
head_ref="${HEAD_REF:-HEAD}"
review_dir="docs/reviews/$(date +%F)-$(git branch --show-current | tr -cs 'A-Za-z0-9._-' '-')"
mkdir -p "$review_dir/artifacts"
merge_base="$(git merge-base "$base_ref" "$head_ref")"
git diff --name-only "$merge_base..$head_ref" > "$review_dir/artifacts/changed-files.txt"
git diff --stat "$merge_base..$head_ref" > "$review_dir/artifacts/diff-stat.txt"
git log --oneline "$merge_base..$head_ref" > "$review_dir/artifacts/commits.txt"
git diff "$merge_base..$head_ref" > "$review_dir/artifacts/patch.diff"
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

- Severity: `P0`, `P1`, `P2`, or `P3`.
- File and line references when available.
- What is wrong.
- Why it matters.
- Suggested fix.
- Validation that would prove the fix.

## Severity

Use severity to communicate merge risk, not reviewer confidence.

- `P0`: release-stopping issue such as credential leak, exploitable security flaw, data loss, deploy breakage, broken auth, or tenant isolation failure.
- `P1`: likely user-visible or correctness failure, backwards-incompatible API or persisted-data change, or missing tests for high-risk touched behavior.
- `P2`: meaningful engineering risk, missing edge-case coverage for non-critical behavior, accessibility or responsive issue in a touched UI path, or observability gap.
- `P3`: minor tracked work such as naming, clarity, low-risk cleanup, or documentation gaps.

When uncertain, choose the lower severity and write better evidence.

## Review Passes

Use only the passes relevant to the diff.

Correctness:

- Does the implementation satisfy the apparent user story?
- Are empty, duplicate, missing, and malformed inputs handled?
- Are async, ordering, retry, or race behaviors safe?
- Does the code preserve existing wire formats and persisted data?

Tests:

- Do tests fail before the fix and pass after it?
- Are important edge cases covered at the right layer?
- Did the change weaken, skip, or over-mock existing tests?

Repo conventions:

- Does the code follow existing nearby patterns?
- Are types, schemas, factories, providers, and helpers organized like the rest of the repo?
- Did the change add avoidable global state or hidden coupling?

Backend:

- Authorization and data boundaries.
- Database transactions and migrations.
- Log redaction for credential-like values.
- Useful telemetry or debugging fields where incidents would need them.

Frontend:

- Accessible controls and keyboard behavior.
- Responsive layout with no text overlap.
- Existing component patterns.
- Feature UI for workflows, not marketing UI inside product surfaces.

Operations:

- Build, test, deploy, and rollback behavior.
- Config defaults and missing environment variables.
- Health checks and logs useful enough for incident debugging.

## ADR Candidates

If the review reveals a durable architectural or policy decision, record it as an ADR candidate in `summary.md`.

Create an ADR only when a change chooses a direction among plausible alternatives and that choice has lasting architectural, operational, security, data-model, API, workflow, or cross-repo/process consequences.

Accepted ADRs should be committed with the implementation or policy change that resolves the review.

## Final Response

Lead with findings, ordered by severity. Include file and line references when available.

Then include:

- Open questions or assumptions.
- Brief change summary as secondary context.
- Review artifact path.
- Tests or validation inspected, and any gaps.

If there are no findings, say that clearly and mention residual risk or test gaps.
