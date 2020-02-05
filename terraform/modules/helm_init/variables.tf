variable "helm_repo" {
  description = "Odahuflow helm repo"
}

variable "istio_helm_repo" {
  description = "Istio helm repo"
  default     = "https://storage.googleapis.com/istio-release/releases/1.4.3/charts"
}

variable "tiller_image" {
  default = "gcr.io/kubernetes-helm/tiller:v2.14.3"
}
