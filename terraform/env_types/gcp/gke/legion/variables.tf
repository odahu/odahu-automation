##################
# Common
##################
variable "project_id" {
  description = "Target project id"
}

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

variable "aws_profile" {
  description = "AWS profile name"
}

variable "aws_credentials_file" {
  default     = "~/.aws/config"
  description = "AWS credentials file location"
}

variable "zone" {
  default     = "us-east1-b"
  description = "Default zone"
}

variable "region" {
  default     = "us-east1"
  description = "Region of resources"
}

variable "region_aws" {
  default     = "us-east-2"
  description = "Region of AWS resources"
}

variable "secrets_storage" {
  description = "Cluster secrets storage"
}

variable "legion_helm_repo" {
  description = "Legion helm repo"
}

variable "root_domain" {
  description = "Legion cluster root domain"
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

variable "api_private_key" {
  description = "RSA model private key. It is used for generation of JWT tokens."
}

variable "api_public_key" {
  description = "RSA model public key. It is used for verification of JWT tokens."
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

variable "collector_region" {
  default     = "us-east1"
  description = "Collector's storage bucket region"
}

variable "mlflow_toolchain_version" {
  description = "Version of legion-mlflow helm chart"
}