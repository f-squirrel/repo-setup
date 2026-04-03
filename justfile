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
lint: commit-lint md-lint yaml-lint just-fmt

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
