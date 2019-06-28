Prerequisites:
 For each of the clusters you need to have have the next preconfigured items:
 - GCS Bucket for terraform state with name equal to "<CLUSTER_NAME>-tfstate"
 - SSL certs stored at S3 Bucket (path is configured in tfvars)
 - SSH key stored at S3 Bucket (path is configured in tfvars)
 - <CLUSTER_NAME>.tfvars file in env_profiles directory containing cluster variables for terraform
 - <CLUSTER_NAME>-secrets.tfvars file with sensitive terraform variables (should be specified for each terraform run as a -var-file argument)


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
# TERRAFORM INIT
CLUSTER_NAME=<CLUSTER_NAME_HERE> TF_DATA_DIR=/tmp/.terraform_${CLUSTER_NAME}_$(basename "$PWD") bash -c  'terraform init -backend-config="bucket=${CLUSTER_NAME}-tfstate"'
# TERRAFORM PLAN
CLUSTER_NAME=<CLUSTER_NAME_HERE> TF_DATA_DIR=/tmp/.terraform_${CLUSTER_NAME}_$(basename "$PWD") bash -c  'terraform plan \
-var-file=/PATH/TO/SECRET/VARIABLES.tfvars \
-var-file=../../../../env_profiles/${CLUSTER_NAME}.tfvars \
-var="agent_cidr=<YOUR_IP_HERE>/32"'
# TERRAFORM APPLY
CLUSTER_NAME=<CLUSTER_NAME_HERE> TF_DATA_DIR=/tmp/.terraform_${CLUSTER_NAME}_$(basename "$PWD") bash -c  'terraform apply \
-var-file=/PATH/TO/SECRET/VARIABLES.tfvars \
-var-file=../../../../env_profiles/${CLUSTER_NAME}.tfvars \
-var="agent_cidr=<YOUR_IP_HERE>/32"'
