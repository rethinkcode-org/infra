TERRAFORM_CMD = terraform

env ?= null
tf_env = $(if $(filter $(env),staging prod),$(env),$(if $(filter $(env),null),staging,$(error Invalid environment: $(env))))
args ?=

.PHONY: precommit infra-init infra infra-destroy help

precommit:
	pre-commit run --all-files

infra-init:
	$(TERRAFORM_CMD) init -backend-config=backend.tfconf

infra:
	$(TERRAFORM_CMD) workspace select -or-create $(tf_env) && $(TERRAFORM_CMD) apply

infra-destroy:
	$(TERRAFORM_CMD) workspace select -or-create $(tf_env) && $(TERRAFORM_CMD) destroy

help:
	@echo "Available targets:"
	@echo "  precommit      Manually run pre-commit hooks on all files."
	@echo "  infra-init     Initialize Terraform with backend configuration."
	@echo "  infra          Apply infrastructure configuration using Terraform."
	@echo "                   Usage: make infra [env={staging|prod}(default: staging)]"
	@echo "  infra-destroy  Destroy infrastructure configured by Terraform."
	@echo "                   Usage: make infra-destroy [env={staging|prod}(default: staging)]"
	@echo ""
	@echo "Optional argument:"
	@echo "  env            Specifies the environment to target. Acceptable values are staging or prod."
