###################################################################################
# Common required
###################################################################################
variable "tls_crt" {
  description = "TLS certificate to use for SSL termination"
}

variable "tls_key" {
  description = "TLS certificate private key to use for SSL termination"
}

variable "aws_region" {
  description = "Region of AWS resources"
}

###################################################################################
# Common optional
###################################################################################
variable "cluster_name" {
  default     = "odahuflow"
  description = "Odahuflow cluster name"
}

###################################################################################
# Odahuflow required
###################################################################################
variable "odahuflow_version" {
  description = "Odahuflow release version"
}

variable "root_domain" {
  description = "Odahuflow cluster root domain"
}

variable "helm_repo" {
  description = "Odahuflow helm repo"
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

variable "git_examples_key" {
  description = "Git ssh key for git connection"
}

variable "data_bucket" {
  description = "Odahuflow data storage bucket"
}

variable "mlflow_toolchain_version" {
  description = "Version of odahuflow-mlflow helm chart"
}

###################################################################################
# Odahuflow optional
###################################################################################
variable "git_examples_uri" {
  default     = "git@github.com:odahuflow-platform/odahuflow.git"
  description = "Model examples git url"
}

variable "git_examples_reference" {
  default     = "origin/develop"
  description = "Model reference"
}

variable "model_resources_cpu" {
  default     = "256m"
  description = "Model pod cpu limit"
}

variable "model_resources_mem" {
  default     = "256Mi"
  description = "Model pod mem limit"
}

variable "collector_region" {
  default     = "us-east1"
  description = "Collector's storage bucket region"
}

# TODO: Remove after implementation of the issue https://github.com/odahuflow-platform/odahuflow/issues/1008
variable "odahuflow_connection_decrypt_token" {
  default = "Token for getting a decrypted connection"
}

variable "jupyterlab_version" {}
variable "packager_version" {}