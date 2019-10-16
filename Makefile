SHELL := /bin/bash

ROOT_DIR := terraform/env_types
SECRET_DIR := $(CURDIR)/.secrets
SECRET_FILE_NAME := cluster_profile.json
ENV_TYPE := gcp/gke
FIND_ALL_TER_MODULES_COMMAND := find terraform -name '*.tf' -printf "%h\n" | uniq | awk '!/aws/' | tr '\n' ' '

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

HIERA_KEYS_DIR :=
LEGION_PROFILES_DIR :=

MODEL_REFERENCE :=
TF_APPLY_CLI_ARGS :=

EXPORT_HIERA_DOCKER_IMAGE := legion/k8s-terraform:${BUILD_TAG}

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

## apply-cluster: Apply the cluster creation module
apply-cluster: check_variables
	cd ${ROOT_DIR}/${ENV_TYPE}/gke_create

	terraform init -backend-config="bucket=${CLUSTER_NAME}-tfstate"
	terraform apply ${TF_APPLY_CLI_ARGS} \
              -var-file=${SECRET_DIR}/${SECRET_FILE_NAME} \
              -var=agent_cidr=$$(curl http://checkip.amazonaws.com)/32

	gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${GKE_ZONE} --project ${GKE_PROJECT}

## apply-helm-init: Apply the helm initialization module
apply-helm-init: check_variables
	cd ${ROOT_DIR}/${ENV_TYPE}/helm_init

	gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${GKE_ZONE} --project ${GKE_PROJECT}

	terraform init -backend-config="bucket=${CLUSTER_NAME}-tfstate"
	terraform apply ${TF_APPLY_CLI_ARGS} \
              -var-file=${SECRET_DIR}/${SECRET_FILE_NAME} \
              -var "legion_helm_repo=${LEGION_HELM_REPO}"

## apply-k8s-setup: Apply the kubernetes setup module
apply-k8s-setup: check_variables
	cd ${ROOT_DIR}/${ENV_TYPE}/k8s_setup

	gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${GKE_ZONE} --project ${GKE_PROJECT}
	helm init --client-only

	terraform init -backend-config="bucket=${CLUSTER_NAME}-tfstate"
	terraform apply ${TF_APPLY_CLI_ARGS} \
              -var-file=${SECRET_DIR}/${SECRET_FILE_NAME} \
              -var "legion_infra_version=${LEGION_INFRA_VERSION}" \
              -var "legion_helm_repo=${LEGION_HELM_REPO}" \
              -var "docker_repo=${LEGION_DOCKER_REPO}"

## apply-legion: Apply the legion module
apply-legion: check_variables
	cd ${ROOT_DIR}/${ENV_TYPE}/legion

	gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${GKE_ZONE} --project ${GKE_PROJECT}
	helm init --client-only

	terraform init -backend-config="bucket=${CLUSTER_NAME}-tfstate"
	terraform apply ${TF_APPLY_CLI_ARGS} \
              -var-file=${SECRET_DIR}/${SECRET_FILE_NAME} \
	          -var "legion_helm_repo=${LEGION_HELM_REPO}" \
              -var "docker_repo=${LEGION_DOCKER_REPO}" \
              -var "legion_version=${LEGION_VERSION}" \
              -var "mlflow_toolchain_version=${MLFLOW_TOOLCHAIN_VERSION}" \
              -var "model_reference=${MODEL_REFERENCE}"

## destroy-cluster: Destroy the cluster creation module
destroy-cluster: check_variables
	cd ${ROOT_DIR}/${ENV_TYPE}/gke_create

	terraform init -backend-config="bucket=${CLUSTER_NAME}-tfstate"
	terraform destroy ${TF_APPLY_CLI_ARGS} \
              -var-file=${SECRET_DIR}/${SECRET_FILE_NAME} \
              -var=agent_cidr=$$(curl http://checkip.amazonaws.com)/32

## destroy-helm-init: Destroy the helm initialization module
destroy-helm-init: check_variables
	cd ${ROOT_DIR}/${ENV_TYPE}/helm_init

	gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${GKE_ZONE} --project ${GKE_PROJECT}

	terraform init -backend-config="bucket=${CLUSTER_NAME}-tfstate"
	terraform destroy ${TF_APPLY_CLI_ARGS} \
              -var-file=${SECRET_DIR}/${SECRET_FILE_NAME} \
              -var "legion_helm_repo=${LEGION_HELM_REPO}"

## destroy-k8s-setup: Destroy the kubernetes setup module
destroy-k8s-setup: check_variables
	cd ${ROOT_DIR}/${ENV_TYPE}/k8s_setup

	gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${GKE_ZONE} --project ${GKE_PROJECT}
	helm init --client-only

	terraform init -backend-config="bucket=${CLUSTER_NAME}-tfstate"
	terraform destroy ${TF_APPLY_CLI_ARGS} \
              -var-file=${SECRET_DIR}/${SECRET_FILE_NAME} \
              -var "legion_infra_version=${LEGION_INFRA_VERSION}" \
              -var "legion_helm_repo=${LEGION_HELM_REPO}" \
              -var "docker_repo=${LEGION_DOCKER_REPO}"

## destroy-legion: Destroy the legion module
destroy-legion: check_variables
	cd ${ROOT_DIR}/${ENV_TYPE}/legion

	gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${GKE_ZONE} --project ${GKE_PROJECT}
	helm init --client-only

	terraform init -backend-config="bucket=${CLUSTER_NAME}-tfstate"
	terraform destroy ${TF_APPLY_CLI_ARGS} \
              -var-file=${SECRET_DIR}/${SECRET_FILE_NAME} \
              -var "legion_helm_repo=${LEGION_HELM_REPO}" \
              -var "docker_repo=${LEGION_DOCKER_REPO}" \
              -var "legion_version=${LEGION_VERSION}" \
              -var "mlflow_toolchain_version=${MLFLOW_TOOLCHAIN_VERSION}" \
              -var "model_reference=${MODEL_REFERENCE}"

## apply-all: Apply the all terraform modules for legion infrastructure
apply-all: check_variables apply-cluster apply-helm-init apply-k8s-setup apply-legion

## destroy-all: Destroy the all terraform modules for legion infrastructure
destroy-all: check_variables destroy-legion destroy-k8s-setup destroy-helm-init destroy-cluster

define delete_crds
	kubectl get crd | cut -d' ' -f1 | grep $(1) | xargs -r kubectl delete crd
endef

## cleanup-infra-crds: Delete all 3rtpart CRDs from k8s cluster
cleanup-infra-crds:
	$(call delete_crds,knative)
	$(call delete_crds,istio)
	$(call delete_crds,coreos)
	$(call delete_crds,tekton)

## cleanup-legion-crds: Delete all legion CRDs from k8s cluster
cleanup-legion-crds:
	$(call delete_crds,legion)

## cleanup-all-crds: Delete all CRDs(3rtpart, legions) from k8s cluster
cleanup-all-crds: cleanup-infra-crds cleanup-legion-crds

## terraform-fmt: Rewrites all legion terraform modules to canonical format
terraform-fmt:
	for module_path in $$(${FIND_ALL_TER_MODULES_COMMAND}) ; do \
        terraform fmt $$module_path ; \
    done

## terraform-validate: Validate all legion terraform modules
terraform-validate:
	for module_path in $$(${FIND_ALL_TER_MODULES_COMMAND}) ; do \
	    cd $$module_path ; \
	    echo Current module: $$module_path ; \
	    terraform init -backend=false &> /dev/null && \
	    terraform validate ; \
	    cd - &> /dev/null ; \
	done

## docker-build-terraform: Build terraform docker image
docker-build-terraform:
	docker build -t legion/k8s-terraform:${BUILD_TAG} -f containers/terraform/Dockerfile .

## export-hiera: Export hiera data
export-hiera:
	set -e
	$(call verify_existence,CLUSTER_NAME)
	$(call verify_existence,HIERA_KEYS_DIR)
	$(call verify_existence,SECRET_DIR)
	$(call verify_existence,CLOUD_PROVIDER)
	$(call verify_existence,EXPORT_HIERA_DOCKER_IMAGE)
	$(call verify_existence,LEGION_PROFILES_DIR)

	mkdir -p ${SECRET_DIR}
	docker run \
	           --net host \
	           -v ${HIERA_KEYS_DIR}:/opt/legion/.hiera_keys \
	           -v ${LEGION_PROFILES_DIR}:/opt/legion/legion-profiles \
	           -v ${SECRET_DIR}:/opt/legion/.secrets \
	           -e CLUSTER_NAME=${CLUSTER_NAME} \
	           -e CLOUD_PROVIDER=${CLOUD_PROVIDER} \
	           ${EXPORT_HIERA_DOCKER_IMAGE} hiera_exporter_helper

## help: Show the help message
help: Makefile
	@echo "Choose a command run in "$(PROJECTNAME)":"
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
	@echo
