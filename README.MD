
## Overview
This repository contains automation for platform provisioning and configuration for Legion project.
For more details and technical documentation see the Legion project repository https://github.com/legion-platform/legion


## Legion infrastructure setup with Terraform
Prerequisites:
 For each of the clusters you need to have have the next preconfigured items:
 - GCS Bucket for terraform state with name equal to "<CLUSTER_NAME>-tfstate"
 - SSL certs stored at S3 Bucket (path is configured in vars file)
 - SSH key stored at S3 Bucket (path is configured in vars file)
 - Reserve Static IP "<CLUSTER_NAME>-nat-gw" and add this IP to Oauth provider (Keycloak for example)
 - cluster_profile.json file with terraform variables (should be specified for each terraform run as a -var-file argument)

In order to setup legion cluster at GCP with provided modules you have to trigger terraform for each of the Legion infrastructure layer.
The order of infrastructure components provisioning is the next:
GKE cluster:
 - gke_create: creates all components at GCP including GKE Kubernetes cluster itself
 - helm_init: setup Helm with required permissions on GKE cluster
 - k8s_setup: setup all Kubernetes components and dependencies required for Legion platform
 - legion: install Legion Helm chart itself with required platform components
EKS cluster:
 - TBC

Terraform modules for each of the layer could be applied by running the set of command below from the corresponding module directory:
### TERRAFORM INIT
CLUSTER_NAME=<CLUSTER_NAME_HERE> TF_DATA_DIR=/tmp/.terraform_${CLUSTER_NAME}_$(basename "$PWD") bash -c  'terraform init -backend-config="bucket=${CLUSTER_NAME}-tfstate"'
### TERRAFORM PLAN
CLUSTER_NAME=<CLUSTER_NAME_HERE> TF_DATA_DIR=/tmp/.terraform_${CLUSTER_NAME}_$(basename "$PWD") bash -c  'terraform plan \
-var-file=/PATH/TO/VARIABLES.json \
-var="agent_cidr=<YOUR_IP_HERE>/32"'
### TERRAFORM APPLY
CLUSTER_NAME=<CLUSTER_NAME_HERE> TF_DATA_DIR=/tmp/.terraform_${CLUSTER_NAME}_$(basename "$PWD") bash -c  'terraform apply \
-var-file=/PATH/TO/VARIABLES.json \
-var="agent_cidr=<YOUR_IP_HERE>/32"'


## Cluster profile preparation
In order to setup Legion cluster with all components you should have cluster profile with all parameters required for platform setup.
The file should be provided as a json file to terraform modules with -var-file argument. All required variables with their purposes 
could be find in vars_template.yaml file in this repository. 
You may want to create cluster profile manually or use hiera_exporter helper script to pull the data from hiera data storage.

# Hiera data export
Hiera allows you to store hierarchical data in yaml format and request required data structures matching request filters.
For Legion CI/CD purposes we use separate profiles repository (as you may want to do as well) with yaml files describing clusters setup.
Place private_key.pkcs7.pem and public_key.pkcs7.pem keys to expected location (/etc/puppetlabs/puppet/eyaml/ by default) and trigger hiera_exporter script from hieradata directory with proper arguments.
This will generate Terraform compatible variables json file which should be used with Terraform modules for clusters setup.
