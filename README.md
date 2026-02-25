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
| [checkmake][cm] | Lint Makefiles |

[mdl]: https://github.com/DavidAnson/markdownlint-cli2
[mlc]: https://github.com/becheran/mlc
[cl]: https://commitlint.js.org/
[cc]: https://www.conventionalcommits.org/
[cm]: https://github.com/checkmake/checkmake

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
make make-check     # Lint Makefiles
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

## Customization

All Makefile variables use `?=` (conditional assignment), so you can override
any of them. The Makefile includes `-include ${LOCAL_MK}` at the top (defaulting
to `local.mk`), which lets you persist overrides in a file that won't conflict
with upstream updates. You can point `LOCAL_MK` at a different path if needed.

### Overridable variables

| Variable | Default | Purpose |
| --- | --- | --- |
| `LOCAL_MK` | `local.mk` | Path to the optional overrides file |
| `COMMITLINT_CONFIG` | `commitlint.config.mjs` | Path to commitlint config |
| `YAMLLINT_CONFIG` | `.yamllint.yaml` | Path to yamllint config |
| `COMMITLINT_IMAGE` | `commitlint/commitlint:latest` | commitlint image |
| `MARKDOWNLINT_IMAGE` | `davidanson/markdownlint-cli2:latest` | mdlint image |
| `YAMLLINT_IMAGE` | `cytopia/yamllint:latest` | yamllint image |
| `MLC_IMAGE` | `becheran/mlc:latest` | link checker image |
| `CHECKMAKE_IMAGE` | `quay.io/checkmake/checkmake:latest` | checkmake image |

### Override methods

**Option A — overrides file** (recommended for persistent overrides):

Create a `local.mk` (or any custom path) in your project root:

```makefile
COMMITLINT_CONFIG = my-commitlint.config.mjs
YAMLLINT_CONFIG   = .yamllint-custom.yaml
```

To use a different file name or path, pass `LOCAL_MK`:

```sh
make check LOCAL_MK=overrides.mk
```

**Option B — command line**:

```sh
make commit-check COMMITLINT_CONFIG=my-commitlint.config.mjs
```

**Option C — environment variable**:

```sh
export COMMITLINT_CONFIG=my-commitlint.config.mjs
make commit-check
```

**Option D — replace the config file directly**: if you copied the files
(rather than using a submodule), simply edit `commitlint.config.mjs` or
`.yamllint.yaml` in place.

## Adding to a New Project

### Option 1: Copy the files

Copy the following files into your repository root:

- `Makefile`
- `commitlint.config.mjs`

Optionally, copy `.cursor/agents/` into your `.cursor/` directory to get
Cursor agent support for fixing lint issues.

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

Optionally, copy the Cursor agents into your workspace:

```sh
mkdir -p .cursor/agents
cp repo-setup/.cursor/agents/*.md .cursor/agents/
git add .cursor/agents
git commit -m "chore: add repo-setup Cursor agents"
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
