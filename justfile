set quiet

local_dir := invocation_directory()
first_commit := `git rev-list --max-parents=0 HEAD`
uid := `id -u`
gid := `id -g`
docker_run := "docker run --tty --rm --volume " + local_dir + ":/repo --workdir /repo --user " + uid + ":" + gid

# Check all commits follow Conventional Commits specification
commit-lint:
    {{docker_run}} \
        commitlint/commitlint \
        --from {{first_commit}} \
        --to HEAD

# Lint markdown files. mode: check (default) or fix
md-lint mode="check":
    {{docker_run}} davidanson/markdownlint-cli2 {{if mode == "fix" { "--fix" } else { "" }}} "**/*.md"
