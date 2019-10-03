############################################################################################################

variable "azure_resource_group" {
  description = "Azure base resource group name"
  default     = "legion-rg"
}

############################################################################################################

variable "cluster_name" {
  description = "Legion k8s cluster name"
  default     = "legion"
}

variable "tiller_image" {
  default = "gcr.io/kubernetes-helm/tiller:v2.14.3"
}

variable "legion_helm_repo" {
  description = "Legion helm repo"
}

variable "istio_helm_repo" {
  description = "Istio helm repo"
}