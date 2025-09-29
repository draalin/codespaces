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

# ------------------------------
# Template Export / Scaffolding
# ------------------------------

TEMPLATE_FILES=.devcontainer .pre-commit-config.yaml Makefile scripts .gitignore README.md .env.example .secrets.baseline .github/workflows/terraform-ci.yml infrastructure/modules infrastructure/env

export-template: ## Copy template tooling (no environment state) to TARGET=/path/to/dest (requires TARGET)
	@if [ -z "$(TARGET)" ]; then echo "TARGET not set (usage: make export-template TARGET=../new-repo)" >&2; exit 1; fi
	@mkdir -p $(TARGET)
	@for item in $(TEMPLATE_FILES); do \
	  rsync -a --exclude '*/.terraform/' --exclude '*.tfstate*' --exclude 'infrastructure/env/*/*.tfstate*' $$item $(TARGET)/ ; \
	done
	@echo "Template exported to $(TARGET). Review backend settings and update README badges." 

scaffold-new: ## Initialize a new repo directory at TARGET with minimal env structure (dev only) (usage: make scaffold-new TARGET=../my-infra)
	@if [ -z "$(TARGET)" ]; then echo "TARGET not set (usage: make scaffold-new TARGET=../my-infra)" >&2; exit 1; fi
	@mkdir -p $(TARGET)
	@rsync -a infrastructure/modules $(TARGET)/infrastructure/ 2>/dev/null || true
	@mkdir -p $(TARGET)/infrastructure/env/dev
	@if [ ! -f $(TARGET)/infrastructure/env/dev/main.tf ]; then \
	  cat infrastructure/env/dev/main.tf | sed 's/CHANGE_ME_STATE_BUCKET/REPLACE_BUCKET/' | sed 's/CHANGE_ME_LOCK_TABLE/REPLACE_LOCK_TABLE/' > $(TARGET)/infrastructure/env/dev/main.tf; \
	fi
	@cp -n .env.example $(TARGET)/ 2>/dev/null || true
	@cp -n .pre-commit-config.yaml $(TARGET)/ 2>/dev/null || true
	@cp -n .gitignore $(TARGET)/ 2>/dev/null || true
	@echo "Scaffold created at $(TARGET). Run: (cd $(TARGET)/infrastructure/env/dev && terraform init)"

what-to-copy: ## Show list of files that constitute the reusable template
	@echo "Template components:" && echo $(TEMPLATE_FILES) | tr ' ' '\n'

.PHONY: help init plan apply destroy fmt validate lint cost pre-commit-install pre-commit-run workspace-list workspace-select workspace-new show state-list export-template scaffold-new what-to-copy
