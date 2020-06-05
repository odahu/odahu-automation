variable "tls_secret_crt" {
  description = "ODAHU flow cluster TLS certificate"
  type        = string
}

variable "tls_secret_key" {
  description = "ODAHU flow cluster TLS key"
  type        = string
}

variable "istio_version" {
  default = "1.4.4"
  type    = string
}

variable "istio_namespace" {
  default     = "istio-system"
  description = "Istio namespace"
  type        = string
}

variable "monitoring_namespace" {
  default     = "kube-monitoring"
  description = "Monitoring namespace"
  type        = string
}

variable "knative_namespace" {
  default     = "knative-serving"
  description = "Knative namespace"
  type        = string
}

variable "odahu_infra_version" {
  description = "ODAHU flow infra release version"
  type        = string
}

variable "helm_repo" {
  description = "ODAHU flow helm repo"
  type        = string
}

variable "docker_repo" {
  default     = ""
  description = "ODAHU flow docker repo URL"
  type        = string
}

variable "docker_username" {
  default     = ""
  description = "ODAHU flow docker repo username"
  type        = string
}

variable "docker_password" {
  default     = ""
  description = "ODAHU flow docker repo password"
  type        = string
}

variable "helm_timeout" {
  default     = "600"
  description = "Helm charts installation timeout in seconds"
  type        = string
}
