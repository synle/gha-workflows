# gha-workflows

Reusable GitHub Actions workflows for CI/CD. Call them from any repo via `workflow_call`.

## Workflows

| Workflow | Purpose |
| --- | --- |
| [`build-and-commit-sh.yml`](.github/workflows/build-and-commit-sh.yml) | Node.js CI: install deps, build, format, commit artifacts, test, and optionally deploy to GitHub Pages. See [step detection priority](#build-and-commit-step-detection) below. |
| [`pr-make-format.yml`](.github/workflows/pr-make-format.yml) | Run `make format`, `npm run format`, or remote `format.sh`, then commit |
| [`pr-format-and-commit-code.yml`](.github/workflows/pr-format-and-commit-code.yml) | Lightweight: run `npx --yes prettier --write` on HTML/MD files, then commit |
| [`pr-js-yarn.yml`](.github/workflows/pr-js-yarn.yml) | Yarn-based: install, format, test, build, commit |
| [`pr-js-yarn-16.yml`](.github/workflows/pr-js-yarn-16.yml) / [`pr-js-yarn-16-v2.yml`](.github/workflows/pr-js-yarn-16-v2.yml) | Yarn variants pinned to Node 16 |

## Usage

Reference a workflow from your repo:

```yaml
name: build-main

on:
  push:
    branches: [master, main]
  pull_request:
    branches: [master, main]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  build:
    uses: synle/gha-workflows/.github/workflows/build-and-commit-sh.yml@main
    permissions:
      contents: write
      pages: write
      id-token: write
    with:
      node-version: "24.x"
```

See the `*.yml.template` files for more examples.

## Common Inputs

Most workflows accept:

| Input | Default | Description |
| --- | --- | --- |
| `node-version` | `"24.x"` | Node.js version |
| `os` | `"ubuntu-latest"` | Runner OS |
| `ignore-commit-pattern` | `"^dist/sw.*\\.js$"` | Regex for files to exclude from commit checks |

`build-and-commit-sh.yml` also supports:

| Input | Default | Description |
| --- | --- | --- |
| `early-exit-on-commit` | `false` | Exit with failure after committing so the workflow re-triggers |
| `deploy-to-pages` | `false` | Deploy to GitHub Pages after build (push to main/master only) |

## Build and Commit Step Detection

`build-and-commit-sh.yml` auto-detects which commands to run for each step using a priority order. It tries each option top-to-bottom and uses the first match:

| Step | Priority |
| --- | --- |
| **Build** | `Makefile` → `build.sh` → `npm run build` (if script exists in package.json) → skip |
| **Format** | `Makefile` → `npm run format` (if script exists in package.json) → remote `format.sh` fallback |
| **Test** | `Makefile` → `test.sh` → `npm run test-ci` → `npm run test:ci` → `npm run test` → skip |

A **Job Summary** table is produced at the end of each run showing pass/fail/skip status for every step.

## Helper Scripts

- **`format.sh`** - Parameterized code formatter. Sources format functions from [`synle/bashrc`](https://github.com/synle/bashrc) and runs configurable steps (`format_cleanup`, `format_python`, `format_js`, etc.).
- **`dev.sh`** - File watcher that polls for changes every 3 seconds and runs `build.sh` on change. Cross-platform (GNU/BSD).
- **`setup-repo-node.sh`** - Bootstrap a Node repo with `.gitattributes`, `.gitignore`, `.prettierignore`, `dependabot.yml`, and Prettier.

```bash
# Run format.sh remotely
curl -fsSL https://raw.githubusercontent.com/synle/gha-workflows/refs/heads/main/format.sh | bash

# Bootstrap a new Node repo
curl -fsSL https://raw.githubusercontent.com/synle/gha-workflows/refs/heads/main/setup-repo-node.sh | bash
```
