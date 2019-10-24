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
  default     = "legion"
  description = "Legion cluster name"
}

###################################################################################
# Legion required
###################################################################################
variable "legion_version" {
  description = "Legion release version"
}

variable "root_domain" {
  description = "Legion cluster root domain"
}

variable "legion_helm_repo" {
  description = "Legion helm repo"
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

variable "git_examples_key" {
  description = "Git ssh key for git connection"
}

variable "legion_data_bucket" {
  description = "Legion data storage bucket"
}

variable "mlflow_toolchain_version" {
  description = "Version of legion-mlflow helm chart"
}

###################################################################################
# Legion optional
###################################################################################
variable "git_examples_uri" {
  default     = "git@github.com:legion-platform/legion.git"
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
