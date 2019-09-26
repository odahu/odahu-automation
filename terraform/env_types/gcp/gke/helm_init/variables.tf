variable "config_context_auth_info" {
  description = "Legion cluster context auth"
}

variable "config_context_cluster" {
  description = "Legion cluster context name"
}

variable "legion_helm_repo" {
  description = "Legion helm repo"
}

variable "istio_helm_repo" {
  description = "Istio helm repo"
}

variable "tiller_image" {
  default = "gcr.io/kubernetes-helm/tiller:v2.14.0"
}