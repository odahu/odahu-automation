##################
# Cloud-specific
##################
variable "cluster_type" {
  description = "gcp/gke, aws/eks, azure/aks"
}

variable "cloud_type" {
  description = "gcp, aws, azure"
}

variable "project_id" {
  default     = ""
  description = "Target GCP project id"
}

variable "region" {
  default     = ""
  description = "Region of GCP resources"
}

variable "aws_region" {
  default     = ""
  description = "Region of AWS resources"
}

variable "odahuflow_collector_iam_role" { default = "" }

variable "odahuflow_collector_sa" { default = "" }

variable "azure_storage_account" { default = "" }

##################
# Common
##################

variable "cluster_name" {
  default     = "odahuflow"
  description = "Odahuflow cluster name"
}

variable "helm_repo" {
  description = "Odahuflow helm repo"
}

variable "root_domain" {
  description = "Odahuflow cluster root domain"
}

variable "tls_secret_crt" {
  description = "Odahuflow cluster TLS certificate"
}

variable "tls_secret_key" {
  description = "Odahuflow cluster TLS key"
}

##################
# Odahuflow app
##################
variable "odahuflow_version" {
  description = "Odahuflow release version"
}

variable "odahuflow_namespace" {
  default     = "odahuflow"
  description = "Odahuflow k8s namespace"
}

variable "odahuflow_training_namespace" {
  default     = "odahuflow-training"
  description = "Odahuflow training k8s namespace"
}

variable "odahuflow_packaging_namespace" {
  default     = "odahuflow-packaging"
  description = "Odahuflow packaging k8s namespace"
}

variable "odahuflow_deployment_namespace" {
  default     = "odahuflow-deployment"
  description = "Odahuflow deployment k8s namespace"
}

variable "vault_namespace" {
  default     = "vault"
  description = "Vault namespace"
}

variable "docker_repo" {
  description = "Odahuflow Docker repo url"
}

variable "docker_user" {
  description = "Odahuflow Docker repo user"
}

variable "docker_password" {
  description = "Odahuflow Docker repo password"
}

variable "model_docker_protocol" {
  default     = "https"
  description = "Model docker protocol"
}

variable "model_docker_url" {
  description = "Model docker url"
}

variable "git_examples_uri" {
  description = "Model examples git url"
}

variable "git_examples_reference" {
  description = "Model reference"
}

variable "git_examples_web_ui_link" {
  description = "Git examples web UI Link for Odahuflow connection"
  default     = ""
}

variable "git_examples_description" {
  description = "Git examples description for Odahuflow connection"
  default     = ""
}

variable "model_resources_cpu" {
  description = "Model pod cpu limit"
}

variable "model_resources_mem" {
  description = "Model pod mem limit"
}

variable "git_examples_key" {
  description = "Git ssh key for git connection"
}

variable "data_bucket" {
  description = "Odahuflow data storage bucket"
}

variable "data_bucket_region" {
  default     = ""
  description = "Odahuflow data storage bucket region"
}

variable "collector_region" {
  default     = ""
  description = "Collector's storage bucket region"
}

variable "mlflow_toolchain_version" {
  description = "Version of odahuflow-mlflow helm chart"
}

variable "model_authorization_enabled" {
  description = "Is model authorization enabled"
  default     = "false"
}

variable "model_oidc_jwks_url" {
  description = "Jwks url for mode authorization"
  default     = ""
}

variable "model_oidc_issuer" {
  description = "The Issuer Identifier"
  default     = ""
}

variable "model_docker_user" {}

variable "model_docker_password" {}

variable "model_docker_repo" {}

variable "model_docker_web_ui_link" {}

variable "dockercfg" {}

variable "model_output_bucket" {}

variable "model_output_region" { default = "" }

variable "model_output_secret" {}

variable "model_output_web_ui_link" {}

variable "model_output_secret_key" {
  default = ""
}

variable "bucket_registry_name" {
  default = ""
}

variable "feedback_storage_link" {}

# TODO: Remove after implementation of the issue https://github.com/legion-platform/legion/issues/1008
variable "odahuflow_connection_decrypt_token" {
  description = "Token for getting a decrypted connection"
}

variable "jupyterlab_version" {}
variable "packager_version" {}