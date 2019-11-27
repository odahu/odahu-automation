variable "docker_repo" {
  description = "Odahuflow Docker repo url"
}

variable "odahu_infra_version" {
  description = "Odahuflow infra release version"
}

variable "namespace" {
  description = "Fluentd namespace"
  default     = "fluentd"
}

variable "extra_helm_values" {
  default = ""
  # TODO:
  description = ""
}