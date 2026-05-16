# Git Changelog Generator

Generate a structured `CHANGELOG.md` from commits since the latest git tag.

## Usage

1. Copy `changelog.sh` into any git repository.
2. Run `bash changelog.sh` (or `bash changelog.sh docs/CHANGELOG.md`).
3. Review the generated Added / Fixed / Changed / Removed sections before release.

## Categorization

Commits are grouped by conventional prefixes:

- `feat`, `feature`, `add`, `added` → Added
- `fix`, `fixed`, `bugfix`, `hotfix` → Fixed
- `change`, `update`, `refactor`, `perf`, `docs`, `test`, `ci`, `build`, `chore` → Changed
- `remove`, `delete`, `drop` → Removed

If a repository has tags, only commits after the latest tag are included. Without tags, the full history is used.
