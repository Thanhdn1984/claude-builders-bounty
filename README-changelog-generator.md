# Changelog Generator

Generate a structured `CHANGELOG.md` from git history.

## Setup in 3 steps

1. Copy `scripts/changelog.sh` and `skills/generate-changelog/SKILL.md` into your repo.
2. Run `bash scripts/changelog.sh` from the repo root.
3. Review `CHANGELOG.md`, then commit it.

## What it does

- Uses commits since the latest git tag (`latest-tag..HEAD`).
- Falls back to all reachable commits when the repo has no tags.
- Groups entries into `Added`, `Fixed`, `Changed`, and `Removed`.

## Examples

```bash
bash scripts/changelog.sh
bash scripts/changelog.sh docs/CHANGELOG.md
CHANGELOG_RANGE=v1.0.0..HEAD bash scripts/changelog.sh
```
