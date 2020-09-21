variable "docker_repo" {
  type        = string
  default     = ""
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

variable "odahu_infra_version" {
  type        = string
  description = "ODAHU flow infra release version"
}

variable "namespace" {
  type        = string
  default     = "logging"
  description = "fluentd-daemonset namespace"
}

variable "pod_prefixes" {
  type = list(string)
  default = [
    "odahu-flow**",
    "**_odahu-flow-training_**",
    "**_odahu-flow-packaging_**",
    "**_odahu-flow-deployment_**",
    "**_nginx-ingress_**"
  ]
  description = <<EOF
    List of pod names prefixes to be matched in Fluent daemonset for further processing.
    Examples in Fluent documentation:
    https://docs.fluentd.org/configuration/config-file#2-match-tell-fluentd-what-to-do
  EOF
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

variable "extra_helm_values" {
  type = object({
    config      = string
    annotations = map(string)
    envs        = list(any)
    secrets     = list(any)
  })
  description = "Set of input extra variables with Helm chart values"
}
