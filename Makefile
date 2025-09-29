SHELL := /bin/bash
.DEFAULT_GOAL := help

TF ?= terraform
TG ?= terragrunt
AWS_PROFILE ?=

# Colors
YELLOW=\033[1;33m
GREEN=\033[1;32m
RESET=\033[0m

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | sed -E 's/:.*## /\t- /' | sort

init: ## Initialize Terraform (or Terragrunt if TG=1)
ifdef TG
	$(TG) init
else
	$(TF) init
endif

plan: ## Terraform plan
ifdef TG
	$(TG) plan $(ARGS)
else
	$(TF) plan $(ARGS)
endif

apply: ## Terraform apply (auto-approve if AUTO=yes)
ifdef TG
	$(TG) apply $(ARGS) $(if $(AUTO),-auto-approve,)
else
	$(TF) apply $(ARGS) $(if $(AUTO),-auto-approve,)
endif

destroy: ## Terraform destroy (auto-approve if AUTO=yes)
ifdef TG
	$(TG) destroy $(ARGS) $(if $(AUTO),-auto-approve,)
else
	$(TF) destroy $(ARGS) $(if $(AUTO),-auto-approve,)
endif

fmt: ## Format Terraform code
	$(TF) fmt -recursive

validate: ## Validate Terraform code
	$(TF) validate

lint: ## Run tflint
	tflint --enable-rule=terraform_unused_declarations || true

cost: ## Infracost breakdown (requires INFRACOST_API_KEY)
	infracost breakdown --path . --format table || true

pre-commit-install: ## Install pre-commit hooks
	pre-commit install --install-hooks

pre-commit-run: ## Run all pre-commit hooks on all files
	pre-commit run --all-files

workspace-list: ## List Terraform workspaces
	$(TF) workspace list

workspace-select: ## Select workspace (make workspace-select WS=name)
	$(TF) workspace select $(WS)

workspace-new: ## Create workspace (make workspace-new WS=name)
	$(TF) workspace new $(WS)

show: ## Terraform show
	$(TF) show

state-list: ## List state resources
	$(TF) state list

.PHONY: help init plan apply destroy fmt validate lint cost pre-commit-install pre-commit-run workspace-list workspace-select workspace-new show state-list
