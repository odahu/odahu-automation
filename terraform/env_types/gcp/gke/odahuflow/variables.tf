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

variable "odahu_infra_version" {
  description = "Odahuflow infra release version"
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

variable "odahuflow_connections" {
  default     = []
  description = "TODO"
}
variable "jupyterhub_chart_version" {}
