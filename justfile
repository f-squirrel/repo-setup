set quiet

local_dir := invocation_directory()
first_commit := `git rev-list --max-parents=0 HEAD`
uid := `id -u`
gid := `id -g`
docker_run := "docker run --tty --rm --volume " + local_dir + ":/repo --workdir /repo --user " + uid + ":" + gid

commit-lint:
    {{docker_run}} \
        commitlint/commitlint \
        --from {{first_commit}} \
        --to HEAD
