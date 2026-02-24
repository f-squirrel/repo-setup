
MARKDOWNLINT_IMAGE := davidanson/markdownlint-cli2:latest
COMMITLINT_IMAGE   := commitlint/commitlint:latest
MLC_IMAGE          := becheran/mlc:latest

DOCKER_RUN := docker run --rm --interactive --tty \
	--user ${shell id -u}:${shell id -g} \
	--volume ${CURDIR}:/workdir --workdir /workdir


.SILENT:
.PHONY: check md-check md-fix md-links commit-check help

check: md-check md-links commit-check ## Run all checks (lint, links, commits)

help: ## Show available targets
	@cat ${MAKEFILE_LIST} | grep -E '^[a-zA-Z%_-]+:.*?## .*$$' | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

md-check: ## Check markdown files for linting errors
	${DOCKER_RUN} ${MARKDOWNLINT_IMAGE} "**/*.md" "#.cursor"

md-fix: ## Fix markdown linting errors
	${DOCKER_RUN} ${MARKDOWNLINT_IMAGE} --fix "**/*.md" "#.cursor"

md-links: ## Check markdown files for broken links
	${DOCKER_RUN} ${MLC_IMAGE} mlc

commit-check: ## Lint commit messages since fork from default branch
	@default_branch=$$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||'); \
	if [ -n "$$default_branch" ]; then \
		from=$$(git merge-base HEAD "origin/$$default_branch"); \
	else \
		echo "WARNING: default branch not set; run 'git remote set-head origin --auto' to configure it"; \
		echo "Falling back to checking all commits"; \
		from=$$(git rev-list --max-parents=0 HEAD); \
	fi; \
	${DOCKER_RUN} ${COMMITLINT_IMAGE} --from "$$from" --to HEAD