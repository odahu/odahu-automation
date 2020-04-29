variable "helm_repo" {
  description = "Odahuflow helm repo"
}

variable "odahu_infra_version" {
  description = "Odahuflow infra release version"
}

variable "namespace" {
  description = "Tekton namespace"
  default     = "tekton-pipelines"
}

variable "helm_timeout" {
  default = "600"
}
