variable "azure_location" {
  description = "Azure base resource group location"
}

variable "azure_resource_group" {
  description = "Azure base resource group name"
}

variable "azure_storage_account" {
  description = "Azure storage account name"
}

variable "aks_common_tags" {
  description = "Set of common tags assigned to all cluster resources"
  type        = "map"
  default     = {
    environment = "Development"
  }
}

variable "aks_public_ip_name" {
  description = "Name of public IP-address used for AKS cluster"
}

variable "aks_cidr" {
  description = "CIDR of AKS subnet used for nodes/pods networking"
}

##################
# Common
##################
variable "cluster_name" {
  default     = "legion"
  description = "Legion cluster name"
}

variable "cloud_type" {
  default = "azure"
}

variable "cluster_type" {
  default = "azure/aks"
}

variable "legion_helm_repo" {
  description = "Legion helm repo"
}

variable "root_domain" {
  description = "Legion cluster root domain"
}

variable "tiller_image" {
  default = "gcr.io/kubernetes-helm/tiller:v2.14.3"
}

variable "tls_key" {
  description = "TLS key for Legion cluster"
}

variable "tls_crt" {
  description = "TLS certificate for Legion cluster"
}

variable "allowed_ips" {
  description = "CIDRs to allow access from"
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

variable "collector_region" {
  default     = "us-east1"
  description = "Collector's storage bucket region"
}

variable "mlflow_toolchain_version" {
  description = "Version of legion-mlflow helm chart"
}

# TODO: Remove after implementation of the issue https://github.com/legion-platform/legion/issues/1008
variable "legion_connection_decrypt_token" {
  default = "Token for getting a decrypted connection"
}