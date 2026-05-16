#!/usr/bin/env bash
set -euo pipefail

last_tag="$(git describe --tags --abbrev=0 2>/dev/null || true)"
if [ -n "$last_tag" ]; then
  range="$last_tag..HEAD"
  since="since $last_tag"
else
  range="HEAD"
  since="from initial commit"
fi

version="${1:-Unreleased}"
date="$(date +%Y-%m-%d)"
tmp="$(mktemp)"

categorize() {
  local subject="$1"
  shopt -s nocasematch
  if [[ "$subject" =~ ^(feat|feature)(\(.+\))?:|add|new ]]; then echo "Added"
  elif [[ "$subject" =~ ^fix(\(.+\))?:|bug|repair ]]; then echo "Fixed"
  elif [[ "$subject" =~ ^(refactor|perf|style|chore|build|ci)(\(.+\))?:|change|update|improve ]]; then echo "Changed"
  elif [[ "$subject" =~ ^(remove|delete|drop|deprecate) ]]; then echo "Removed"
  else echo "Changed"
  fi
}

printf '# Changelog\n\n## %s - %s\n\n' "$version" "$date" > "$tmp"
for section in Added Fixed Changed Removed; do
  mapfile -t commits < <(git log --no-merges --format='%s' "$range" | while read -r subject; do
    [ "$(categorize "$subject")" = "$section" ] && printf '%s\n' "$subject"
  done)
  printf '### %s\n' "$section" >> "$tmp"
  if [ "${#commits[@]}" -eq 0 ]; then
    printf -- '- None\n\n' >> "$tmp"
  else
    for c in "${commits[@]}"; do printf -- '- %s\n' "$c" >> "$tmp"; done
    printf '\n' >> "$tmp"
  fi
done

if [ -f CHANGELOG.md ]; then
  tail -n +2 CHANGELOG.md >> "$tmp"
fi
mv "$tmp" CHANGELOG.md
printf 'Generated CHANGELOG.md for commits %s.\n' "$since"
