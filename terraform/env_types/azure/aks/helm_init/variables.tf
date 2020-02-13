############################################################################################################

variable "azure_resource_group" {
  description = "Azure base resource group name"
  default     = "odahuflow-rg"
}

############################################################################################################

variable "cluster_name" {
  description = "Odahuflow k8s cluster name"
  default     = "odahuflow"
}

variable "config_context_auth_info" {
  default     = ""
  description = "Kubernetes cluster context auth"
}

variable "config_context_cluster" {
  default     = ""
  description = "Kubernetes cluster context name"
}

variable "helm_repo" {
  description = "Odahuflow helm repo"
}
