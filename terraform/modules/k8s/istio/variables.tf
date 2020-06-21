variable "tls_secret_crt" {
  type        = string
  description = "ODAHU flow cluster TLS certificate"
}

variable "tls_secret_key" {
  type        = string
  description = "ODAHU flow cluster TLS key"
}

variable "istio_version" {
  type    = string
  default = "1.4.4"
}

variable "istio_namespace" {
  type        = string
  default     = "istio-system"
  description = "Istio namespace"
}

variable "monitoring_namespace" {
  type        = string
  default     = "kube-monitoring"
  description = "Monitoring namespace"
}

variable "knative_namespace" {
  type        = string
  default     = "knative-serving"
  description = "Knative namespace"
}

variable "odahu_infra_version" {
  type        = string
  description = "ODAHU flow infra release version"
}

variable "helm_repo" {
  type        = string
  description = "ODAHU flow helm repo"
}

variable "helm_timeout" {
  type        = number
  default     = 600
  description = "Helm chart deploy timeout in seconds"
}

variable "docker_repo" {
  type        = string
  default     = ""
  description = "ODAHU flow docker repo URL"
}

variable "docker_username" {
  type        = string
  default     = ""
  description = "ODAHU flow docker repo username"
}

variable "docker_password" {
  type        = string
  default     = ""
  description = "ODAHU flow docker repo password"
}
