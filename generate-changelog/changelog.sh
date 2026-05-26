#!/usr/bin/env bash
set -euo pipefail

OUT=${1:-CHANGELOG.md}
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || true)
if [[ -n "$LAST_TAG" ]]; then
  RANGE="$LAST_TAG..HEAD"
  SINCE="since $LAST_TAG"
else
  RANGE="HEAD"
  SINCE="for all history"
fi

COMMITS=$(git log --no-merges --pretty=format:'%s' "$RANGE" 2>/dev/null || true)
TODAY=$(date +%Y-%m-%d)

declare -a ADDED FIXED CHANGED REMOVED
while IFS= read -r msg; do
  [[ -z "$msg" ]] && continue
  low=$(printf '%s' "$msg" | tr '[:upper:]' '[:lower:]')
  case "$low" in
    fix:*|fixed:*|bugfix:*|*fix*|*bug*) FIXED+=("$msg") ;;
    remove:*|removed:*|delete:*|deleted:*|*remove*|*delete*) REMOVED+=("$msg") ;;
    add:*|added:*|feat:*|feature:*|*add*|*implement*) ADDED+=("$msg") ;;
    change:*|changed:*|refactor:*|update:*|updated:*|*change*|*update*|*refactor*) CHANGED+=("$msg") ;;
    *) CHANGED+=("$msg") ;;
  esac
done <<< "$COMMITS"

section() {
  local title=$1
  local arr_name=$2
  local -n arr="$arr_name"
  printf '### %s\n' "$title"
  if [[ $(declare -p "$arr_name" 2>/dev/null) == "declare -a $arr_name=()" ]]; then
    printf -- '- Nothing recorded.\n\n'
  elif ((${#arr[@]} == 0)); then
    printf -- '- Nothing recorded.\n\n'
  else
    printf '%s\n' "${arr[@]}" | sed 's/^/- /'
    printf '\n'
  fi
}

{
  printf '# Changelog\n\n'
  printf '## %s — generated %s\n\n' "$TODAY" "$SINCE"
  section Added ADDED
  section Fixed FIXED
  section Changed CHANGED
  section Removed REMOVED
} > "$OUT"

echo "Generated $OUT ($SINCE)"
