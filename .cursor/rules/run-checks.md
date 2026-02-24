---
description: Always run `make check` after modifying any file and fix reported errors.
globs:
alwaysApply: true
---

# Run Checks After Every Change

After modifying or creating any file in this repository, you **must** run:

```sh
make check NO_TTY=1 2>&1
```

## Handling Failures

If `make check` reports errors, fix them using the appropriate agent:

- **Markdown lint errors** (`md-check`): fix them directly — they are usually
  straightforward formatting issues (line length, trailing whitespace, heading
  style, etc.).
- **Broken or redirected links** (`md-links`): delegate to the `fix-md-links`
  agent.
- **Makefile lint violations** (`make-check`): delegate to the `fix-make-check`
  agent.
- **Commit lint errors** (`commit-check`): fix the commit message to comply with
  [Conventional Commits](https://www.conventionalcommits.org/).

After fixing, re-run `make check NO_TTY=1 2>&1` to confirm all checks pass.
Repeat until the full suite is green.
