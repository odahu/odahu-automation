variable "helm_repo" {
  type        = string
  description = "ODAHU flow helm repo"
}

variable "istio_helm_repo" {
  type        = string
  default     = "https://storage.googleapis.com/istio-release/releases/1.4.4/charts"
  description = "Istio helm repo"
}
