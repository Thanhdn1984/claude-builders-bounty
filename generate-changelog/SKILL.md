---
name: generate-changelog
description: Generate a structured CHANGELOG.md from git history since the latest tag.
---

# Generate Changelog

Run `bash generate-changelog/changelog.sh` from the repository root. The script finds commits since the latest git tag, categorizes commit subjects into `Added`, `Fixed`, `Changed`, and `Removed`, then writes `CHANGELOG.md`.
