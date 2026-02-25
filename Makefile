LOCAL_MK ?= local.mk
-include ${LOCAL_MK}

MARKDOWNLINT_IMAGE ?= davidanson/markdownlint-cli2:latest
COMMITLINT_IMAGE   ?= commitlint/commitlint:latest
MLC_IMAGE          ?= becheran/mlc:latest
YAMLLINT_IMAGE     ?= cytopia/yamllint:latest
CHECKMAKE_IMAGE    ?= quay.io/checkmake/checkmake:latest

COMMITLINT_CONFIG ?= commitlint.config.mjs
YAMLLINT_CONFIG   ?= .yamllint.yaml

TTY_FLAG := $(if $(NO_TTY),,--tty)

DOCKER_RUN := docker run --rm --interactive $(TTY_FLAG) \
	--user ${shell id -u}:${shell id -g} \
	--volume ${CURDIR}:/workdir --workdir /workdir


.SILENT:
.PHONY: all check md-check md-fix md-links yaml-check commit-check make-check clean test help

all: check ## Run all checks (default target)
 
check: md-check md-links yaml-check commit-check make-check ## Run all checks (lint, links, commits)

clean: ## Remove generated artifacts

test: check ## Run all checks

help: ## Show available targets
	@cat ${MAKEFILE_LIST} | grep -E '^[a-zA-Z%_-]+:.*?## .*$$' | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

md-check: ## Check markdown files for linting errors
	${DOCKER_RUN} ${MARKDOWNLINT_IMAGE} "**/*.md"

md-fix: ## Fix markdown linting errors
	${DOCKER_RUN} ${MARKDOWNLINT_IMAGE} --fix "**/*.md"

md-links: ## Check markdown files for broken links
	${DOCKER_RUN} ${MLC_IMAGE} mlc

yaml-check: ## Lint YAML files
	${DOCKER_RUN} ${YAMLLINT_IMAGE} -c ${YAMLLINT_CONFIG} --strict .

make-check: ## Lint all Makefiles
	${DOCKER_RUN} --entrypoint /checkmake ${CHECKMAKE_IMAGE} \
		$$(find . -path '*/.*' -prune -o \( -name 'Makefile' -o -name '*.mk' \) -print)

commit-check: ## Lint commit messages since fork from default branch
	@db=$$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||'); \
	if [ -n "$$db" ]; then from=$$(git merge-base HEAD "origin/$$db"); \
	else echo "WARNING: default branch not set; run 'git remote set-head origin --auto' to configure it" && echo "Falling back to checking all commits" && from=$$(git rev-list --max-parents=0 HEAD); fi; \
	${DOCKER_RUN} ${COMMITLINT_IMAGE} --config ${COMMITLINT_CONFIG} --from "$$from" --to HEAD