variable "module_dependency" {
  type        = any
  default     = null
  description = "Terraform resource the module depends of (if any)"
}

variable "odahu_infra_version" {
  type        = string
  description = "ODAHU flow infra release version"
}

variable "knative_namespace" {
  type        = string
  default     = "knative-serving"
  description = "Knative namespace"
}

variable "helm_repo" {
  type        = string
  description = "ODAHU flow helm repo"
}

variable "helm_timeout" {
  type        = number
  default     = 300
  description = "Helm charts installation timeout in seconds"
}
