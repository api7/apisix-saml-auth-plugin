# Makefile basic env setting
.DEFAULT_GOAL := help
## add pipefail support for default shell
SHELL := /bin/bash -o pipefail

# Project basic setting
project_name      ?= apisix-saml-auth-plugin
project_version   ?= 0.0.1
project_ci_runner ?= $(CURDIR)/ci/utils/linux-common-runnner.sh

# Makefile basic extension function
_color_red    =\E[1;31m
_color_green  =\E[1;32m
_color_yellow =\E[1;33m
_color_blue   =\E[1;34m
_color_wipe   =\E[0m
_echo_format  ="[%b info %b] %s\n"


define func_echo_status
	printf $(_echo_format) "$(_color_blue)" "$(_color_wipe)" $(1)
endef


define func_echo_warn_status
	printf $(_echo_format) "$(_color_yellow)" "$(_color_wipe)" $(1)
endef


define func_echo_success_status
	printf $(_echo_format) "$(_color_green)" "$(_color_wipe)" $(1)
endef


define func_echo_error_status
	printf $(_echo_format) "$(_color_red)" "$(_color_wipe)" $(1)
endef


# Makefile target
### help: Show Makefile rules
.PHONY: help
help:
	@$(call func_echo_success_status, "Makefile rules:")
	@echo
	@grep -E '^### [-A-Za-z0-9_]+:' Makefile | sed 's/###/   /'
	@echo


### init_apisix: Fetch apisix code
.PHONY: init_apisix
init_apisix:
	@$(call func_echo_status, "$@ -> [ Start ]")
	$(project_ci_runner) get_apisix_code
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### patch_apisix: Patch apisix code
.PHONY: patch_apisix
patch_apisix:
	@$(call func_echo_status, "$@ -> [ Start ]")
	$(project_ci_runner) patch_apisix_code
	@$(call func_echo_success_status, "$@ -> [ Done ]")


### install: Install custom plugin
.PHONY: install
install:
	@$(call func_echo_status, "$@ -> [ Start ]")
	$(project_ci_runner) install_module
	@$(call func_echo_success_status, "$@ -> [ Done ]")
