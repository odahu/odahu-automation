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

variable "helm_repo" {
  description = "Odahuflow helm repo"
}
