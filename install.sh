#!/usr/bin/env bash
# Install the yona-* skills into Claude Code's personal skills directory,
# making them available as /yona-ux, /yona-plan, /yona-implement,
# /yona-review, and /yona-ship in every project.
#
# Each skill is installed as a SYMLINK to its directory in this repo, so there
# is exactly one editable copy of every skill. Edit the files here; `git pull`
# is all it takes to update. Never edit the installed path — it is this repo.
#
# Usage:
#   ./install.sh          # symlink (default)
#   ./install.sh --copy   # copy instead, for setups that cannot follow symlinks
#
# Set CLAUDE_SKILLS_DIR to install somewhere other than ~/.claude/skills.
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
skills_dir="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
mode="link"

case "${1:-}" in
  --copy) mode="copy" ;;
  -h|--help) sed -n '2,14p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
  "") ;;
  *) printf 'Unknown argument: %s\n' "$1" >&2; exit 2 ;;
esac

mkdir -p "$skills_dir"

installed=()
for src in "$repo_dir"/docs/skills/*/; do
  [[ -f "$src/SKILL.md" ]] || continue
  name="$(basename "$src")"
  target="$skills_dir/$name"

  # Replace an existing install. A symlink is ours to drop; a real directory
  # may hold hand edits, so it gets moved aside rather than deleted.
  if [[ -L "$target" ]]; then
    rm "$target"
  elif [[ -e "$target" ]]; then
    backup="$target.backup.$(date -u +%Y%m%dT%H%M%SZ)"
    mv "$target" "$backup"
    printf 'Backed up existing %s -> %s\n' "$target" "$backup"
  fi

  if [[ "$mode" == "copy" ]]; then
    cp -R "${src%/}" "$target"
  else
    ln -s "${src%/}" "$target"
  fi
  installed+=("$name")
done

if [[ ${#installed[@]} -eq 0 ]]; then
  printf 'No skills found under %s/docs/skills/\n' "$repo_dir" >&2
  exit 1
fi

printf 'Installed %d skills to %s (%s):\n' "${#installed[@]}" "$skills_dir" "$mode"
for name in "${installed[@]}"; do
  printf '  /%s\n' "$name"
done
printf '\n'
if [[ "$mode" == "link" ]]; then
  printf 'These are symlinks into %s — edit the skills there.\n' "$repo_dir"
  printf 'To update: git pull (no reinstall needed).\n'
else
  printf 'To update later: git pull && ./install.sh --copy\n'
fi
printf '\nStart a new Claude Code session and try: /yona-plan\n'
