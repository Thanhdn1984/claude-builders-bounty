---
name: generate-changelog
description: Generate a structured CHANGELOG.md from git history since the last tag.
---

# Generate Changelog

Use this skill when a user asks to generate or refresh a changelog from a git repository.

## Command

```bash
bash changelog.sh
```

Optional args:

```bash
bash changelog.sh --since v1.2.3 --output CHANGELOG.md
```

## Behavior

- Detects the latest git tag with `git describe --tags --abbrev=0`.
- Uses all commits when no tag exists.
- Ignores merge commits.
- Categorizes commits into `Added`, `Fixed`, `Changed`, and `Removed` using commit subject keywords.
- Writes a Markdown `CHANGELOG.md` with commit hash and date.

## Setup

1. Copy `changelog.sh` into a git repo.
2. Run `bash changelog.sh`.
3. Commit the generated `CHANGELOG.md` after review.
