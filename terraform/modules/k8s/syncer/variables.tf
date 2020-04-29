variable "namespace" {
  description = "Syncer namespace"
  default     = "default"
}

variable "odahu_infra_version" {
  description = "Odahuflow infra release version"
}

variable "extra_helm_values" {
  default = ""
  # TODO:
  description = ""
}

variable "helm_timeout" {
  default = "300"
}
