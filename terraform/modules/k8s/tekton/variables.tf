variable "helm_repo" {
  type        = string
  description = "ODAHU flow helm repo"
}

variable "odahu_infra_version" {
  type        = string
  description = "ODAHU flow infra release version"
}

variable "namespace" {
  type        = string
  default     = "tekton-pipelines"
  description = "Tekton namespace"
}

variable "helm_timeout" {
  type        = number
  default     = 600
  description = "Helm chart deploy timeout in seconds"
}
