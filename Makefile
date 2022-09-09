# Makefile basic env setting
.DEFAULT_GOAL := help
## add pipefail support for default shell
SHELL := /bin/bash -o pipefail

project_ci_runner ?= $(CURDIR)/ci/utils/linux-common-runnner.sh


# Makefile target
### help: Show Makefile rules
.PHONY: help
help:
	@echo Makefile rules:
	@echo
	@grep -E '^### [-A-Za-z0-9_]+:' Makefile | sed 's/###/   /'


### init_apisix: Fetch apisix code
.PHONY: init_apisix
init_apisix:
	$(project_ci_runner) get_apisix_code


### patch_apisix: Patch apisix code
.PHONY: patch_apisix
patch_apisix:
	$(project_ci_runner) patch_apisix_code


### install: Install custom plugin
.PHONY: install
install:
	$(project_ci_runner) install_module
