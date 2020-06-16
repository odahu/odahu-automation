variable "namespace" {
  type        = string
  default     = "default"
  description = "Syncer namespace"
}

variable "odahu_infra_version" {
  type        = string
  description = "ODAHU flow infra release version"
}

variable "extra_helm_values" {
  type        = string
  default     = ""
  description = "String variable with YAML set of Helm chart values"
}

variable "helm_timeout" {
  type        = number
  default     = 300
  description = "Helm chart deploy timeout in seconds"
}
