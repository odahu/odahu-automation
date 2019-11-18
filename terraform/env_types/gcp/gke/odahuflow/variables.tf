##################
# Common
##################
variable "project_id" {
  description = "Target project id"
}

variable "cloud_type" {}

variable "cluster_type" {}

variable "cluster_name" {
  default     = "odahuflow"
  description = "Odahuflow cluster name"
}

variable "config_context_auth_info" {
  description = "Odahuflow cluster context auth"
}

variable "config_context_cluster" {
  description = "Odahuflow cluster context name"
}

variable "zone" {
  default     = "us-east1-b"
  description = "Default zone"
}

variable "region" {
  default     = "us-east1"
  description = "Region of resources"
}

variable "helm_repo" {
  description = "Odahuflow helm repo"
}

variable "tiller_image" {
  default = "gcr.io/kubernetes-helm/tiller:v2.14.3"
}

variable "root_domain" {
  description = "Odahuflow cluster root domain"
}

variable "tls_key" {
  description = "TLS key for Odahuflow cluster"
}

variable "tls_crt" {
  description = "TLS certificate file for Odahuflow cluster"
}

##################
# Odahuflow app
##################
variable "odahuflow_version" {
  description = "Odahuflow release version"
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

variable "model_docker_url" {
  description = "Model docker url"
}

variable "git_examples_uri" {
  default     = "git@github.com:odahuflow-platform/odahuflow.git"
  description = "Model examples git url"
}

variable "git_examples_reference" {
  default     = "origin/develop"
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

variable "data_bucket" {
  description = "Odahuflow data storage bucket"
}

variable "mlflow_toolchain_version" {
  description = "Version of odahuflow-mlflow helm chart"
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
variable "odahuflow_connection_decrypt_token" {
  default = "Token for getting a decrypted connection"
}

variable "jupyterlab_version" {}
variable "packager_version" {}