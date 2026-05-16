#!/usr/bin/env bash
set -euo pipefail

out=${1:-CHANGELOG.md}
repo_url=$(git config --get remote.origin.url 2>/dev/null || printf '')
repo_url=${repo_url%.git}
repo_url=${repo_url/git@github.com:/https://github.com/}

last_tag=$(git describe --tags --abbrev=0 2>/dev/null || true)
if [[ -n "$last_tag" ]]; then
  range="$last_tag..HEAD"
  since="since $last_tag"
else
  range="HEAD"
  since="from project start"
fi

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
git log --reverse --no-merges --date=short --pretty=format:'%h%x09%ad%x09%s' $range > "$tmp"

section() {
  local title=$1 pattern=$2 found=0
  printf '### %s\n' "$title"
  while IFS=$'\t' read -r hash date subject || [[ -n "${hash:-}" ]]; do
    if [[ "$subject" =~ $pattern ]]; then
      found=1
      if [[ -n "$repo_url" && "$repo_url" == https://github.com/* ]]; then
        printf -- '- %s ([%s](%s/commit/%s), %s)\n' "$subject" "$hash" "$repo_url" "$hash" "$date"
      else
        printf -- '- %s (%s, %s)\n' "$subject" "$hash" "$date"
      fi
    fi
  done < "$tmp"
  if [[ "$found" -eq 0 ]]; then
    printf -- '- None\n'
  fi
  printf '\n'
}

{
  printf '# Changelog\n\n'
  printf 'Generated from git history %s on %s.\n\n' "$since" "$(date -u +%Y-%m-%d)"
  if [[ ! -s "$tmp" ]]; then
    printf 'No commits found for this range.\n'
    exit 0
  fi
  section Added '^(feat|feature|add|added)(\(.+\))?[: ]'
  section Fixed '^(fix|fixed|bugfix|hotfix)(\(.+\))?[: ]'
  section Changed '^(change|changed|update|updated|refactor|perf|docs|test|ci|build|chore)(\(.+\))?[: ]'
  section Removed '^(remove|removed|delete|deleted|drop|dropped)(\(.+\))?[: ]'
} > "$out"

printf 'Wrote %s\n' "$out"
