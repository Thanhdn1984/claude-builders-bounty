#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bash changelog.sh [--since <ref>] [--output <file>]

Generate a structured CHANGELOG.md from git commits since the last tag.
Categories: Added, Fixed, Changed, Removed.
EOF
}

output="CHANGELOG.md"
since=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --since) since="${2:-}"; shift 2 ;;
    --output|-o) output="${2:-}"; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: run inside a git repository" >&2
  exit 1
fi

if [[ -z "$since" ]]; then
  since="$(git describe --tags --abbrev=0 2>/dev/null || true)"
fi

if [[ -n "$since" ]]; then
  range="$since..HEAD"
  title_range="since $since"
else
  range="HEAD"
  title_range="from repository history"
fi

mapfile -t commits < <(git log --no-merges --date=short --pretty=format:'%h%x09%ad%x09%s' "$range" 2>/dev/null || true)

declare -a added fixed changed removed
add_line() {
  local bucket="$1" line="$2"
  case "$bucket" in
    Added) added+=("$line") ;;
    Fixed) fixed+=("$line") ;;
    Changed) changed+=("$line") ;;
    Removed) removed+=("$line") ;;
  esac
}

for row in "${commits[@]}"; do
  IFS=$'\t' read -r hash date subject <<< "$row"
  lower="$(printf '%s' "$subject" | tr '[:upper:]' '[:lower:]')"
  line="- $subject ($hash, $date)"
  case "$lower" in
    feat:*|feat\(*|add:*|added:*|*' add '*|*' adds '*|*' new '*) add_line Added "$line" ;;
    fix:*|fix\(*|bug:*|*fix*|*bug*|*patch*) add_line Fixed "$line" ;;
    remove:*|removed:*|delete:*|deleted:*|drop:*|*remove*|*delete*|*deprecat*) add_line Removed "$line" ;;
    *) add_line Changed "$line" ;;
  esac
done

{
  echo "# Changelog"
  echo
  echo "Generated on $(date -u +%Y-%m-%d) from commits $title_range."
  echo
  for section in Added Fixed Changed Removed; do
    echo "## $section"
    echo
    case "$section" in
      Added) arr=("${added[@]:-}") ;;
      Fixed) arr=("${fixed[@]:-}") ;;
      Changed) arr=("${changed[@]:-}") ;;
      Removed) arr=("${removed[@]:-}") ;;
    esac
    if [[ ${#arr[@]} -eq 0 || -z "${arr[0]:-}" ]]; then
      echo "- No entries."
    else
      printf '%s\n' "${arr[@]}"
    fi
    echo
  done
} > "$output"

echo "Wrote $output (${#commits[@]} commits)."
