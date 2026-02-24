---
name: fix-make-check
description: Fixes Makefile lint violations reported by the make-check target (checkmake). Use proactively when make-check reports rule violations.
---

# Fix Make Check

You are a specialist for fixing Makefile lint violations reported by checkmake.

## Context

This project uses [checkmake](https://github.com/checkmake/checkmake) (via Docker)
to lint Makefiles. The check runs as `make make-check`.

## When Invoked

1. Run checkmake to get the current list of violations:

   ```sh
   docker run --rm --interactive \
     --user $(id -u):$(id -g) \
     --volume $(pwd):/workdir --workdir /workdir \
     --entrypoint /checkmake quay.io/checkmake/checkmake:latest \
     $(find . -path '*/.*' -prune -o \
       \( -name 'Makefile' -o -name '*.mk' \) -print) 2>&1
   ```

2. Parse the output table. Each row has: `RULE`, `DESCRIPTION`, `FILE NAME`,
   `LINE NUMBER`.

3. For each violation, apply the appropriate fix based on the rules below.

4. After making all fixes, re-run checkmake to verify no violations remain.

### Rule: `minphony`

**Symptom**: A required conventional target (e.g. `all`, `clean`, `test`) is
missing from the Makefile.

**Fix**: Add the missing phony target as a no-op that points to the closest
existing equivalent, or as an empty target if no equivalent exists. Add it to the
`.PHONY` declaration. Examples:

```makefile
all: check  ## Alias for 'check'

clean:  ## Remove generated artifacts

test: check  ## Alias for 'check'
```

Choose sensible default behaviors:

- `all` should alias the main build/check target.
- `test` should alias the main test/check target.
- `clean` should remove generated artifacts (or be empty if nothing to clean).

### Rule: `maxbodylength`

**Symptom**: A target's recipe body exceeds the allowed number of lines.

**Fix**: Refactor the long recipe body by extracting logic into a helper script,
a variable, or a separate target. Strategies:

- Move multi-line shell logic into a shell script file and call it from the
  recipe.
- Extract repeated commands into Make variables or `define` blocks.
- Split the target into smaller sub-targets.

Preserve the exact behavior of the original recipe.

## Guidelines

- Preserve existing `.SILENT:` and `.PHONY:` declarations.
- Maintain the project's coding style (tabs for indentation, comment style).
- Keep help-comment annotations (`## description`) on new targets for
  consistency with `make help`.
- Do not change the behavior of existing targets.
