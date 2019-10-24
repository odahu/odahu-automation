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
  default = ""
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

variable "legion_collector_iam_role" { default = "" }

variable "legion_collector_sa" { default = "" }

variable "azure_storage_account" { default = "" }

variable "azure_storage_access_key" { default = "" }

##################
# Common
##################

variable "cluster_name" {
  default     = "legion"
  description = "Legion cluster name"
}

variable "legion_helm_repo" {
  description = "Legion helm repo"
}

variable "root_domain" {
  description = "Legion cluster root domain"
}

variable "tls_secret_crt" {
  description = "Legion cluster TLS certificate"
}

variable "tls_secret_key" {
  description = "Legion cluster TLS key"
}

##################
# Legion app
##################
variable "legion_version" {
  description = "Legion release version"
}

variable "legion_namespace" {
  default     = "legion"
  description = "Legion k8s namespace"
}

variable "legion_training_namespace" {
  default     = "legion-training"
  description = "Legion training k8s namespace"
}

variable "legion_packaging_namespace" {
  default     = "legion-packaging"
  description = "Legion packaging k8s namespace"
}

variable "legion_deployment_namespace" {
  default     = "legion-deployment"
  description = "Legion deployment k8s namespace"
}

variable "docker_repo" {
  description = "Legion Docker repo url"
}

variable "docker_user" {
  description = "Legion Docker repo user"
}

variable "docker_password" {
  description = "Legion Docker repo password"
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
  description = "Git examples web UI Link for Legion connection"
  default     = ""
}

variable "git_examples_description" {
  description = "Git examples description for Legion connection"
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

variable "legion_data_bucket" {
  description = "Legion data storage bucket"
}

variable "legion_data_bucket_region" {
  default     = ""
  description = "Legion data storage bucket region"
}

variable "collector_region" {
  default     = ""
  description = "Collector's storage bucket region"
}

variable "mlflow_toolchain_version" {
  description = "Version of legion-mlflow helm chart"
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
