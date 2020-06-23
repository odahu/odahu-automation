############################################################################################################

variable "azure_resource_group" {
  type        = string
  description = "Azure base resource group name"
}

############################################################################################################

variable "cluster_name" {
  type        = string
  default     = "odahuflow"
  description = "ODAHU flow k8s cluster name"
}

variable "config_context_auth_info" {
  type        = string
  description = "Kubernetes cluster context auth"
}

variable "config_context_cluster" {
  type        = string
  description = "Kubernetes cluster context name"
}

variable "helm_repo" {
  type        = string
  description = "ODAHU flow helm repo"
}
