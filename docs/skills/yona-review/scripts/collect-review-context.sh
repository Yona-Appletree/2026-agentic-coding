#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: collect-review-context.sh <base-ref> <review-dir> [head-ref]

Writes changed-files.txt, diff-stat.txt, commits.txt, and patch.diff to:
  <review-dir>/artifacts/
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || $# -lt 2 ]]; then
  usage
  exit 0
fi

base_ref="$1"
review_dir="$2"
head_ref="${3:-HEAD}"
artifacts="$review_dir/artifacts"

mkdir -p "$artifacts"

merge_base="$(git merge-base "$base_ref" "$head_ref")"

git diff --name-only "$merge_base..$head_ref" > "$artifacts/changed-files.txt"
git diff --stat "$merge_base..$head_ref" > "$artifacts/diff-stat.txt"
git log --oneline "$merge_base..$head_ref" > "$artifacts/commits.txt"
git diff "$merge_base..$head_ref" > "$artifacts/patch.diff"

cat > "$artifacts/review-context.txt" <<EOF
base_ref=$base_ref
head_ref=$head_ref
merge_base=$merge_base
generated_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
EOF
