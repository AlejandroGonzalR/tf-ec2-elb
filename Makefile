SHELL := /bin/bash
PACKAGES := pre-commit tflint terraform-docs tfsec checkov

#######################################
## Bash Colors
#######################################

RED = $(shell echo '\033[0;31m')
GREEN = $(shell echo '\033[0;32m')
BLUE = $(shell echo '\033[0;34m')

# Reset color
NC = $(shell echo '\033[0m')

#######################################
## Packages
#######################################

.PHONY: $(PACKAGES)
packages/install: ## Prepare environment installing all required packages, mainly to execute pre-commit hooks
	@for package in $(PACKAGES); do \
        install_path=$$(which $$package); \
		if [ "$$install_path" != "" ]; then \
			echo -e "Package $(BLUE)$$package$(NC) already installed on $(GREEN)$$install_path$(NC). Skipping..."; \
		else \
			$(MAKE) packages/install/$$package; \
		fi; \
	done

.PHONY: $(PACKAGES)
packages/install/pre-commit: ## Installs `pre-commit`
	pip install pre-commit

.PHONY: $(PACKAGES)
packages/install/tflint: ## Installs `tflint`
	@curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

.PHONY: $(PACKAGES)
packages/install/terraform-docs: ## Installs `terraform-docs`
	$(eval temp_src_dir := $(shell mktemp -d))
	curl -sSLo $(temp_src_dir)/terraform-docs.tar.gz "https://terraform-docs.io/dl/v0.16.0/terraform-docs-v0.16.0-$(shell uname)-amd64.tar.gz"; \
    tar -xzf $(temp_src_dir)/terraform-docs.tar.gz -C $(temp_src_dir); \
    chmod +x $(temp_src_dir)/terraform-docs; \
    mv $(temp_src_dir)/terraform-docs /usr/local/bin/terraform-docs;

.PHONY: $(PACKAGES)
packages/install/tfsec: ## Installs `tfsec`
	@curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash

.PHONY: $(PACKAGES)
packages/install/checkov: ## Installs `checkov`
	pip install checkov

#######################################
## Pre commit
#######################################

.PHONY: pre-commit/ensure
pre-commit/ensure: packages/install .git/hooks/pre-commit ## Install and configure pre-commit on current repository
.git/hooks/pre-commit:
	pre-commit install
	pre-commit install-hooks

.PHONY: pre-commit/tests
pre-commit/tests: pre-commit/ensure ## Run all pre-commit hooks
	pre-commit run --all-files --show-diff-on-failure

.PHONY: pre-commit/uninstall
pre-commit/uninstall: ## Uninstall the pre-commit script. This is intended to run on CI due to automated commits by a bot
	pre-commit uninstall

#######################################
## Self-documented Help
#######################################

.PHONY: help
help:
	@printf "\nAvailable targets:\n"
	@$(MAKE) help/generate

## Display all available targets with description, this looks for a `##` after every target definition
.PHONY: help/generate
help/generate:
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | \
		awk \
		'BEGIN { \
			FS = ":.*?## " ; \
		}; \
		{ \
			printf "\tmake $(BLUE) %-35s $(NC) %s\n", $$1, $$2 \
		}'
