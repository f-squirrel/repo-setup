# repo-setup

A template repository for sharing common linter and code quality tool configurations across projects via git submodules.

## Concept

Instead of duplicating linter configs, tool versions, and check scripts in every project,
this repo acts as a single source of truth.
Projects include it as a submodule and delegate their checks to it.
All checks run in Docker — no tools need to be installed on the host.

## Usage

### Add to a project

```bash
git submodule add <repo-url> repo-setup
git submodule update --init
```

### Update to latest

```bash
git submodule update --remote repo-setup
```

### Remove from a project

```bash
git submodule deinit repo-setup
git rm repo-setup
```

## Available checks

Run checks from the root of the parent project:

```bash
just -f repo-setup/justfile <target>
```

| Target        | Description                                                     |
|---------------|-----------------------------------------------------------------|
| `commit-lint` | Check all commits follow the Conventional Commits specification |
| `md-lint`     | Check markdown files for style issues                           |
| `md-lint fix` | Auto-fix markdown style issues                                  |

## Configuration

| File                | Purpose                                                      |
|---------------------|--------------------------------------------------------------|
| `.commitlintrc.yml` | Commitlint rules (extends `@commitlint/config-conventional`) |
| `.markdownlint.yml` | Markdownlint rules                                           |
