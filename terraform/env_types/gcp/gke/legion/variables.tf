##################
# Common
##################
variable "project_id" {
  description = "Target project id"
}

variable "cloud_type" {}

variable "cluster_type" {}

variable "cluster_name" {
  default     = "legion"
  description = "Legion cluster name"
}

variable "config_context_auth_info" {
  description = "Legion cluster context auth"
}

variable "config_context_cluster" {
  description = "Legion cluster context name"
}

variable "zone" {
  default     = "us-east1-b"
  description = "Default zone"
}

variable "region" {
  default     = "us-east1"
  description = "Region of resources"
}

variable "legion_helm_repo" {
  description = "Legion helm repo"
}

variable "tiller_image" {
  default     = "gcr.io/kubernetes-helm/tiller:v2.14.3"
}

variable "root_domain" {
  description = "Legion cluster root domain"
}

variable "tls_key" {
  description = "TLS key for Legion cluster"
}

variable "tls_crt" {
  description = "TLS certificate file for Legion cluster"
}

##################
# Legion app
##################
variable "legion_version" {
  description = "Legion release version"
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

variable "model_docker_url" {
  description = "Model docker url"
}

variable "git_examples_uri" {
  default     = "git@github.com:legion-platform/legion.git"
  description = "Model examples git url"
}

variable "git_examples_reference" {
  default     = "origin/develop"
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
  default     = "256m"
  description = "Model pod cpu limit"
}

variable "model_resources_mem" {
  default     = "256Mi"
  description = "Model pod mem limit"
}

variable "git_examples_key" {
  description = "Git ssh key for git connection"
}

variable "legion_data_bucket" {
  description = "Legion data storage bucket"
}

variable "mlflow_toolchain_version" {
  description = "Version of legion-mlflow helm chart"
}

variable "keycloak_realm" {
  description = "Keycloak realm"
}

variable "keycloak_url" {
  description = "Keycloak URL"
}

variable "model_authorization_enabled" {
  description = "Is model authorization enabled"
  default     = "false"
}

# TODO: Remove after implementation of the issue https://github.com/legion-platform/legion/issues/1008
variable "legion_connection_decrypt_token" {
  default = "Token for getting a decrypted connection"
}