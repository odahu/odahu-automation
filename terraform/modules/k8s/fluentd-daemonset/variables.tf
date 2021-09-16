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
  default     = "logging"
  description = "fluentd-daemonset namespace"
}

variable "configuration" {
  type = map
  default = {
    elastic_hosts     = ""
    use_cloud_storage = true
  }
  description = "Save logs to cloud storage. If `false` - logs will be sent directly to elasticsearch"
}

variable "pod_prefixes" {
  type = list(string)
  default = [
    "odahu-flow**",
    "**_odahu-flow-training_**",
    "**_odahu-flow-packaging_**",
    "**_odahu-flow-deployment_**",
    "**_knative-serving_**",
    "activator**",
    "nginx-ingress**"
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
    config         = string
    annotations    = map(string)
    sa_annotations = map(string)
    envs           = list(any)
    secrets        = list(any)
  })
  description = "Set of input extra variables with Helm chart values"
}
