SHELL := /bin/bash

ROOT_DIR := terraform/env_types
SECRET_DIR := $(CURDIR)/.secrets
SECRET_FILE_NAME := cluster_profile.json
ENV_TYPE := gcp/gke
FIND_ALL_TF_MODULES_COMMAND := find terraform -name '*.tf' -printf "%h\n" | uniq | tr '\n' ' '
FIND_TOPLEVEL_TF_MODULES_COMMAND := find terraform/env_types -name '*.tf' -printf "%h\n" | uniq | tr '\n' ' '

GKE_PROJECT :=
GKE_ZONE :=

BUILD_TAG := latest

LEGION_INFRA_VERSION :=
LEGION_VERSION :=
MLFLOW_TOOLCHAIN_VERSION :=
LEGION_HELM_REPO :=
LEGION_DOCKER_REPO :=

CLOUD_PROVIDER :=
CLUSTER_NAME :=

MODEL_REFERENCE :=
TF_APPLY_CLI_ARGS :=

-include .env

.EXPORT_ALL_VARIABLES:
.ONESHELL:

define verify_existence
	@if [ "${$(1)}" == "" ]; then \
	    echo "$(1) is not found, please define the $(1) variable" ; exit 1 ;\
	fi
endef

check_variables:
	set -e
	$(call verify_existence,CLUSTER_NAME)
	$(call verify_existence,AWS_SECRET_ACCESS_KEY)
	$(call verify_existence,AWS_ACCESS_KEY_ID)
	$(call verify_existence,GOOGLE_CREDENTIALS)
	$(call verify_existence,GKE_PROJECT)
	$(call verify_existence,GKE_ZONE)
	$(call verify_existence,LEGION_INFRA_VERSION)
	$(call verify_existence,LEGION_HELM_REPO)
	$(call verify_existence,LEGION_DOCKER_REPO)

define delete_crds
	kubectl get crd | cut -d' ' -f1 | grep $(1) | xargs -r kubectl delete crd
endef

## cleanup-infra-crds: Delete all 3rtpart CRDs from k8s cluster
cleanup-infra-crds:
	$(call delete_crds,knative)
	$(call delete_crds,istio)
	$(call delete_crds,coreos)
	$(call delete_crds,tekton)
	$(call delete_crds,vault)

## cleanup-odahu-crds: Delete all odahu CRDs from k8s cluster
cleanup-odahu-crds:
	$(call delete_crds,odahu)

## cleanup-all-crds: Delete all CRDs(3rtpart, odahus) from k8s cluster
cleanup-all-crds: cleanup-infra-crds cleanup-odahu-crds

## terraform-fmt: Rewrites all odahu terraform modules to canonical format
terraform-fmt:
	for module_path in $$(${FIND_ALL_TF_MODULES_COMMAND}) ; do \
        terraform fmt $$module_path ; \
    done

## terraform-fmt-check: Check that terraform modules are formatted
terraform-fmt-check:
	set -e; for module_path in $$(${FIND_ALL_TF_MODULES_COMMAND}) ; do \
        terraform fmt -check $$module_path || (terraform fmt -diff $$module_path ; exit 1); \
    done

## terraform-validate: Validate all odahu terraform modules
terraform-validate:
	set -e; for module_path in $$(${FIND_TOPLEVEL_TF_MODULES_COMMAND}) ; do \
	    cd $$module_path && \
	    echo Current module: $$module_path && \
	    terraform init -backend=false && \
	    terraform validate ; \
	    cd - &> /dev/null ; \
	done

## terragrunt-fmt-check: Validates all terragrunt files
terragrunt-fmt-check:
	terragrunt hclfmt --terragrunt-check

## docker-build-terraform: Build terraform docker image
docker-build-terraform:
	docker build -t odahu/odahu-flow-automation:${BUILD_TAG} -f containers/terraform/Dockerfile .

## shellcheck: Lint the bash scripts
shellcheck:
	shellcheck scripts/*.sh

## install-vulnerabilities-checker: Install the vulnerabilities-checker
install-vulnerabilities-checker:
	./scripts/install-git-secrets-hook.sh install_binaries

## check-vulnerabilities: Сheck vulnerabilities in the source code
check-vulnerabilities:
	./scripts/install-git-secrets-hook.sh install_hooks
	git secrets --scan -r

## help: Show the help message
help: Makefile
	@echo "Choose a command run in "$(PROJECTNAME)":"
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sort | sed -e 's/\\$$//' | sed -e 's/##//'
	@echo
