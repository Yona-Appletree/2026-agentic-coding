#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: prepare-review-worktree.sh <branch> [worktree-root]

Creates or updates a git worktree for reviewing <branch>.

Default worktree root:
  ../reviews
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || $# -lt 1 ]]; then
  usage
  exit 0
fi

branch="$1"
root="${2:-../reviews}"
repo_root="$(git rev-parse --show-toplevel)"
slug="$(printf '%s' "$branch" | sed -E 's#[^A-Za-z0-9._-]+#-#g; s#-+#-#g; s#^-|-$##g')"
target="$root/$slug"

mkdir -p "$root"

if git worktree list --porcelain | grep -Fqx "worktree $target"; then
  git -C "$target" fetch --all --prune
  git -C "$target" checkout "$branch"
  git -C "$target" pull --ff-only || true
else
  git -C "$repo_root" fetch --all --prune
  git -C "$repo_root" worktree add "$target" "$branch"
fi

printf '%s\n' "$target"
