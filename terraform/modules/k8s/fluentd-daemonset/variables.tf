variable "docker_repo" {
  default     = ""
  description = "Odahuflow Docker repo url"
}

variable "docker_username" {
  default     = ""
  description = "Odahuflow Docker repo username"
}

variable "docker_password" {
  default     = ""
  description = "Odahuflow Docker repo password"
}

variable "odahu_infra_version" {
  description = "Odahuflow infra release version"
}

variable "namespace" {
  description = "Fluentd namespace"
  default     = "logging"
}

variable "extra_helm_values" {
  default = ""
  # TODO:
  description = ""
}
