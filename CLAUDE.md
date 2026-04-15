# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Reusable GitHub Actions workflows repository (`synle/gha-workflows`). Provides shared CI/CD workflow templates that other repositories call via `workflow_call`. Also includes helper shell scripts for formatting and dev file-watching.

## Important Rules

- **Always use `curl -fsSL` for curl commands.** Standard curl flag convention across all scripts.
- **Bash functions must use the `function` keyword**: Write `function foo() {` not `foo() {`.
- **Always run `bash format.sh` after making changes.**
- **URLs must use `synle/gha-workflows/`** (plural). The repo was renamed from `gha-workflow` to `gha-workflows`. Never use the old `synle/gha-workflow/` URL.

## Commands

```bash
npm run format          # Run Prettier (--write --print-width 140)
bash format.sh          # Full format pipeline: sources remote format functions from bashrc repo, runs cleanup/python/JS/custom steps
bash dev.sh             # File watcher: runs build.sh on changes, starts dev server
bash setup-repo-node.sh # Bootstrap a new Node repo with .gitattributes, .gitignore, .prettierignore, dependabot, prettier
```

## Architecture

### Reusable Workflows (`.github/workflows/`)

All `*.yml` files are reusable workflows triggered via `workflow_call`. Each has a matching `*.yml.template` showing how consumers should reference it.

| Workflow                                     | Purpose                                                                                                                         |
| -------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| `build-and-commit-sh.yml`                    | Full Node.js CI: install deps, `make build` or `build.sh`, format, commit artifacts, optionally test and deploy to GitHub Pages |
| `cleanup-pr-artifacts.yml`                   | Delete artifacts (and optionally workflow runs) when a PR is closed or merged                                                   |
| `cleanup-releases.yml`                       | Cleanup GitHub releases: delete old drafts and incomplete releases (missing assets) with dry-run support                        |
| `pr-format-and-commit-code.yml`              | Lightweight: runs `npx --yes prettier --write` on HTML/MD files, then commits                                                   |
| `pr-js-yarn.yml`                             | Yarn-based: `yarn install`, format, test-ci, build, commit                                                                      |
| `pr-js-yarn-16.yml` / `pr-js-yarn-16-v2.yml` | Yarn variants for Node 16                                                                                                       |
| `pr-make-format.yml`                         | Format-only: runs `make format`, `npm run format`, or remote `format.sh`, then commits                                          |

### Common Patterns Across Workflows

- **Commit gating**: All workflows use a "Check for Meaningful Changes" step that filters diffs against `ignore-commit-pattern` (default: `^dist/sw.*\.js$`). Only commits if meaningful files changed.
- **Auto-commit**: Uses `EndBug/add-and-commit@v9` with `default_author: github_actions`.
- **Checkout**: Always checks out `github.head_ref || github.ref_name` to work on the correct branch for both PRs and pushes.
- **Concurrency**: Templates include `cancel-in-progress: true` grouped by workflow + ref.

### Template Files (`*.yml.template`)

Show consumers how to reference each workflow. The pattern is:

```yaml
uses: synle/gha-workflows/.github/workflows/<workflow>.yml@main
```

### Helper Scripts

- **`format.sh`** — Parameterized formatter. Args: `$1` = format command (default `npm run format`), `$2` = timeout in seconds (default 20), remaining args = format steps. Sources the actual format functions from `synle/bashrc` repo's `.build/format.sh` via curl. Available steps: `format_cleanup`, `format_cleanup_light`, `format_other_text_based_files`, `format_python`, `format_js`.
- **`dev.sh`** — File watcher with configurable patterns. Args: `$1` = glob patterns, `$2` = start command, `$3` = max file size KB. Polls every 3 seconds using `find` + `stat`, runs `build.sh` on changes. Cross-platform stat detection (GNU vs BSD).
- **`setup-repo-node.sh`** — One-shot repo bootstrapper. Sets up `.gitattributes` (LF line endings), `.gitignore`, `.prettierignore`, `dependabot.yml` (monthly npm updates), and adds `prettier` + format script to `package.json`.
