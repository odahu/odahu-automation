variable "docker_repo" {
  type        = string
  description = "ODAHU flow Docker repo url"
}

variable "docker_username" {
  type        = string
  default     = ""
  description = "ODAHU flow Docker repo username"
}

variable "docker_password" {
  type        = string
  default     = ""
  description = "ODAHU flow Docker repo password"
}

variable "docker_secret_name" {
  type        = string
  default     = "repo-json-key"
  description = "Name of k8s secret in which Docker registry password is stored"
}

variable "odahu_infra_version" {
  type        = string
  description = "ODAHU flow infra release version"
}

variable "namespace" {
  type        = string
  default     = "fluentd"
  description = "Fluentd namespace"
}

variable "extra_helm_values" {
  type        = string
  default     = ""
  description = "String variable with YAML set of Helm chart values"
}

variable "helm_repo" {
  type        = string
  description = "ODAHU flow helm repo"
}

variable "helm_timeout" {
  type        = number
  default     = 300
  description = "Helm chart deploy timeout in seconds"
}
