#!/usr/bin/env bash
set -euo pipefail

OUT=${1:-CHANGELOG.md}
RANGE=${CHANGELOG_RANGE:-}
if [ -z "$RANGE" ]; then
  last_tag=$(git describe --tags --abbrev=0 2>/dev/null || true)
  if [ -n "$last_tag" ]; then
    RANGE="$last_tag..HEAD"
  else
    RANGE="HEAD"
  fi
fi

mapfile -t commits < <(git log --no-merges --pretty=format:'%s%x09%h' "$RANGE" 2>/dev/null || true)
today=$(date +%Y-%m-%d)

category_for() {
  subject=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')
  case "$subject" in
    feat:*|feat\(*|add:*|add\(*|*add*|*introduce*) echo Added ;;
    fix:*|fix\(*|bug:*|bug\(*|*fix*|*bug*) echo Fixed ;;
    remove:*|remove\(*|delete:*|delete\(*|drop:*|drop\(*|*remove*|*delete*) echo Removed ;;
    *) echo Changed ;;
  esac
}

clean_subject() {
  printf '%s' "$1" | sed -E 's/^[a-zA-Z]+(\([^)]*\))?!?:[[:space:]]*//'
}

{
  echo '# Changelog'
  echo
  echo "## Unreleased - $today"
  echo
  for section in Added Fixed Changed Removed; do
    echo "### $section"
    matched=0
    for line in "${commits[@]}"; do
      [ -n "$line" ] || continue
      subject=${line%$'\t'*}
      hash=${line##*$'\t'}
      if [ "$(category_for "$subject")" = "$section" ]; then
        printf -- '- %s (%s)\n' "$(clean_subject "$subject")" "$hash"
        matched=1
      fi
    done
    [ "$matched" = 1 ] || echo '- No changes.'
    echo
  done
} > "$OUT"

echo "Wrote $OUT from range: $RANGE"
