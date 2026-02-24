# repo-setup

A lightweight repository scaffolding that enforces consistent quality standards
across projects. All checks run inside Docker containers, so the only local
dependency is Docker itself.

## What's Included

| Tool | Purpose |
| --- | --- |
| [markdownlint-cli2][mdl] | Lint and auto-fix Markdown |
| [mlc][mlc] | Detect broken links in Markdown |
| [commitlint][cl] | Enforce [Conventional Commits][cc] |

[mdl]: https://github.com/DavidAnson/markdownlint-cli2
[mlc]: https://github.com/becheran/mlc
[cl]: https://commitlint.js.org/
[cc]: https://www.conventionalcommits.org/

## Prerequisites

- [Docker](https://docs.docker.com/get-started/get-docker/)
- GNU Make

## Usage

Run all checks at once:

```sh
make check
```

Or run individual targets:

```sh
make md-check       # Lint Markdown files
make md-fix         # Auto-fix Markdown lint errors
make md-links       # Check for broken links in Markdown
make commit-check   # Lint commit messages since fork from default branch
```

List all available targets:

```sh
make help
```

## Commit Convention

Commit messages must follow the
[Conventional Commits](https://www.conventionalcommits.org/) specification,
enforced via commitlint with the `@commitlint/config-conventional` preset.

Examples of valid commit messages:

```text
feat: add user authentication
fix: resolve null pointer in parser
docs: update installation instructions
chore: upgrade dependencies
```

## Adding to a New Project

### Option 1: Copy the files

Copy the following files into your repository root:

- `Makefile`
- `commitlint.config.mjs`

### Option 2: Add as a Git submodule

This keeps the setup linked to the upstream repository so you can pull updates.

Add the submodule:

```sh
git submodule add git@github.com:f-squirrel/repo-setup.git repo-setup
git commit -m "chore: add repo-setup submodule"
```

Then symlink (or copy) the files you need into your project root:

```sh
ln -s repo-setup/Makefile Makefile
ln -s repo-setup/commitlint.config.mjs commitlint.config.mjs
git add Makefile commitlint.config.mjs
git commit -m "chore: link repo-setup config files"
```

To pull the latest changes later:

```sh
git submodule update --remote repo-setup
git add repo-setup
git commit -m "chore: update repo-setup submodule"
```

When cloning a repository that already contains the submodule, initialize it
with:

```sh
git clone --recurse-submodules <your-repo-url>
```

Or, if already cloned without `--recurse-submodules`:

```sh
git submodule update --init
```
