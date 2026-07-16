#!/usr/bin/env bash
# Install the yona-* skills into Claude Code's personal skills directory,
# making them available as /yona-plan, /yona-implement, /yona-review, and
# /yona-push in every project.
#
# Usage:
#   ./install.sh
#
# Re-run after `git pull` to update. Set CLAUDE_SKILLS_DIR to install
# somewhere other than ~/.claude/skills.
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skills_dir="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

installed=()
for src in "$repo_dir"/docs/skills/*.md; do
  name="$(basename "$src" .md)"
  mkdir -p "$skills_dir/$name"
  cp "$src" "$skills_dir/$name/SKILL.md"
  installed+=("$name")
done

echo "Installed ${#installed[@]} skills to $skills_dir:"
for name in "${installed[@]}"; do
  echo "  /$name"
done
echo
echo "Start a new Claude Code session and try: /yona-plan"
echo "To update later: git pull && ./install.sh"
