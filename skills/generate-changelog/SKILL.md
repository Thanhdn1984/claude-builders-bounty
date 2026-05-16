---
name: generate-changelog
description: Generate a structured CHANGELOG.md from git commits since the latest tag.
---

# Generate Changelog

Use this skill when the user asks Claude Code to create or refresh a changelog from git history.

## Command

```bash
bash scripts/changelog.sh
```

Optional output path:

```bash
bash scripts/changelog.sh docs/CHANGELOG.md
```

Optional custom range:

```bash
CHANGELOG_RANGE=v1.2.0..HEAD bash scripts/changelog.sh
```

## Behavior

- Finds the latest git tag with `git describe --tags --abbrev=0`.
- Reads non-merge commits from `latest-tag..HEAD`.
- If no tag exists, reads reachable commits from `HEAD`.
- Writes `CHANGELOG.md` with `Added`, `Fixed`, `Changed`, and `Removed` sections.
- Classifies common Conventional Commit prefixes plus natural words like add, fix, update, remove.

## Review Checklist

1. Run `bash scripts/changelog.sh` at the repo root.
2. Open `CHANGELOG.md` and verify every recent user-facing commit appears once.
3. Move any ambiguous item manually if the commit subject was unclear.
