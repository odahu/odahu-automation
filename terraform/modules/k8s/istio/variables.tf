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
  default = "1.5.10"
}

variable "istio_namespace" {
  type        = string
  default     = "istio-system"
  description = "Istio namespace"
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

variable "helm_repo" {
  type        = string
  default     = "https://storage.googleapis.com/istio-release/releases/1.5.10/charts"
  description = "URL of used Helm chart repository"
}

variable "helm_timeout" {
  type        = number
  default     = 600
  description = "Helm charts installation timeout in seconds"
}
