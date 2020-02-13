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
  type        = map
  default = {
    env = "Development"
  }
}

variable "aks_egress_ip_name" {
  description = "Name of AKS cluster egress IP-address"
}

variable "aks_cidr" {
  description = "CIDR of AKS subnet used for nodes/pods networking"
}

##################
# Common
##################
variable "cluster_name" {
  default     = "odahuflow"
  description = "Odahuflow cluster name"
}

variable "config_context_auth_info" {
  default     = ""
  description = "Kubernetes cluster context auth"
}

variable "config_context_cluster" {
  default     = ""
  description = "Kubernetes cluster context name"
}

variable "cloud_type" {
  default = "azure"
}

variable "cluster_type" {
  default = "azure/aks"
}

variable "helm_repo" {
  description = "Odahuflow helm repo"
}

variable "root_domain" {
  description = "Odahuflow cluster root domain"
}

variable "tiller_image" {
  default = "gcr.io/kubernetes-helm/tiller:v2.14.3"
}

variable "tls_key" {
  description = "TLS key for Odahuflow cluster"
}

variable "tls_crt" {
  description = "TLS certificate for Odahuflow cluster"
}

variable "allowed_ips" {
  description = "CIDRs to allow access from"
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

variable "docker_username" {
  default     = ""
  description = "Odahuflow Docker repo username"
}

variable "docker_password" {
  default     = ""
  description = "Odahuflow Docker repo password"
}

variable "data_bucket" {
  description = "Odahuflow data storage bucket"
}

variable "mlflow_toolchain_version" {
  description = "Version of odahuflow-mlflow helm chart"
}

variable "oauth_oidc_issuer_url" {
  description = "OAuth2/OIDC provider Issuer URL"
}

variable "oauth_client_id" {
  description = "OAuth2 Client ID"
}

variable "oauth_client_secret" {
  description = "OAuth2 Client Secret"
}

variable "odahu_infra_version" {
  description = "Odahuflow infra release version"
}

variable "odahuflow_connections" {
  default     = []
  description = "TODO"
}

variable "node_pools" {
  default = {}
}

# TODO: Remove after implementation of the issue https://github.com/odahuflow-platform/legion/issues/1008
variable "odahuflow_connection_decrypt_token" {
  default = "Token for getting a decrypted connection"
}

variable "jupyterhub_enabled" {
  default     = false
  type        = bool
  description = "Flag to install JupyterHub (true) or not (false)"
}

variable "jupyterlab_version" {
  default     = "latest"
  description = "Tag of docker images used as JupyterHub notebooks"
}

variable "packager_version" {}
