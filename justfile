set quiet := true

local_dir := invocation_directory()
first_commit := `git rev-list --max-parents=0 HEAD`
uid := `id -u`
gid := `id -g`
docker_run := "docker run --tty --rm --volume " + local_dir + ":/repo --workdir /repo --user " + uid + ":" + gid
check := "check"
fix := "fix"

# Symlink config files into the invocation directory
init:
    #!/usr/bin/env sh
    rel=$(realpath --relative-to {{ local_dir }} {{ source_directory() }})
    ln --symbolic --force "$rel/.yamllint.yml" {{ local_dir }}/.yamllint.yml
    ln --symbolic --force "$rel/.markdownlint.yml" {{ local_dir }}/.markdownlint.yml
    ln --symbolic --force "$rel/.commitlintrc.yml" {{ local_dir }}/.commitlintrc.yml

# Run all linters
lint: commit-lint md-lint yaml-lint just-fmt nix-fmt nix-lint nix-dead link-check

nix_docker_run := "docker run --tty --rm --volume " + local_dir + ":/repo --workdir /repo"
nix_run := nix_docker_run + " nixos/nix nix --extra-experimental-features 'nix-command flakes'"

# Format Nix files. mode: check (default) or fix
nix-fmt mode=check:
    #!/usr/bin/env sh
    docker run --tty --rm --volume {{ local_dir }}:/repo --workdir /repo nixos/nix \
        sh -c "find . -name '*.nix' -not -path './.git/*' | xargs nix --extra-experimental-features 'nix-command flakes' run nixpkgs#nixfmt -- {{ if mode == fix { "" } else { "--check" } }}"

# Lint Nix files for antipatterns
nix-lint mode=check:
    {{ nix_run }} run nixpkgs#statix -- {{ if mode == fix { "fix" } else { "check" } }} .

# Find dead Nix code
nix-dead mode=check:
    {{ nix_run }} run nixpkgs#deadnix -- {{ if mode == fix { "--edit" } else { "--fail" } }} .

# Format justfile. mode: check (default) or fix
just-fmt mode=check:
    just --unstable {{ if mode == fix { "--fmt" } else { "--fmt --check" } }} --justfile {{ local_dir }}/justfile

# Check all commits follow Conventional Commits specification
commit-lint:
    {{ docker_run }} \
        commitlint/commitlint \
        --from {{ first_commit }} \
        --to HEAD

# Lint YAML files
yaml-lint:
    {{ docker_run }} pipelinecomponents/yamllint yamllint .

# Lint markdown files. mode: check (default) or fix
md-lint mode=check:
    {{ docker_run }} davidanson/markdownlint-cli2 {{ if mode == fix { "--fix" } else { "" } }} "**/*.md"

# Check all links in files
link-check:
    {{ docker_run }} lycheeverse/lychee --no-progress .
