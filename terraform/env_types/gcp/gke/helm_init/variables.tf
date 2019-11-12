variable "config_context_auth_info" {
  description = "Odahuflow cluster context auth"
}

variable "config_context_cluster" {
  description = "Odahuflow cluster context name"
}

variable "helm_repo" {
  description = "Odahuflow helm repo"
}

variable "istio_helm_repo" {
  description = "Istio helm repo"
}

variable "tiller_image" {
  default = "gcr.io/kubernetes-helm/tiller:v2.14.3"
}