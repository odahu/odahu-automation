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

variable "tiller_image" {
  default = "gcr.io/kubernetes-helm/tiller:v2.14.3"
}

variable "helm_repo" {
  description = "Odahuflow helm repo"
}

variable "istio_helm_repo" {
  default     = "https://storage.googleapis.com/istio-release/releases/1.4.3/charts"
  description = "Istio helm repo"
}
