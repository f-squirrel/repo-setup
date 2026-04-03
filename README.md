# repo-setup

A template repository for sharing common linter and code quality tool
configurations across projects via git submodules.

## Concept

Instead of duplicating linter configs, tool versions, and check scripts
in every project, this repo acts as a single source of truth.
Projects include it as a submodule and delegate their checks to it.
All checks run in Docker — no tools need to be installed on the host,
except `just` and `docker`.

## Usage

### Add to a project

```bash
git submodule add <repo-url> repo-setup
git submodule update --init
```

### First-time setup

Symlink config files into the repo root so linters can find them:

```bash
just init
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

## Available targets

Run targets from the root of the parent project:

```bash
just <target>
```

| Target          | Description                                                     |
|-----------------|-----------------------------------------------------------------|
| `init`          | Symlink linter configs into the repo root                       |
| `lint`          | Run all linters                                                 |
| `commit-lint`   | Check all commits follow the Conventional Commits specification |
| `md-lint`       | Check Markdown files for style issues                           |
| `md-lint fix`   | Auto-fix Markdown style issues                                  |
| `yaml-lint`     | Lint YAML files                                                 |
| `just-fmt`      | Check justfile formatting                                       |
| `just-fmt fix`  | Auto-fix justfile formatting                                    |
| `nix-fmt`       | Check Nix file formatting                                       |
| `nix-fmt fix`   | Auto-fix Nix file formatting                                    |
| `nix-lint`      | Lint Nix files for antipatterns                                 |
| `nix-lint fix`  | Auto-fix Nix antipatterns                                       |
| `nix-dead`      | Find dead Nix code                                              |
| `nix-dead fix`  | Remove dead Nix code                                            |
| `link-check`    | Check all links in files                                        |

## Configuration files

| File                | Purpose                                                      |
|---------------------|--------------------------------------------------------------|
| `.commitlintrc.yml` | Commitlint rules (extends `@commitlint/config-conventional`) |
| `.markdownlint.yml` | Markdownlint rules                                           |
| `.yamllint.yml`     | Yamllint rules                                               |
