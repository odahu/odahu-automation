################## 
# Common 
################## 
variable "cluster_domain" {
  type        = string
  description = "ODAHU flow cluster FQDN"
}

variable "tls_secret_crt" {
  type        = string
  default     = ""
  description = "Ingress TLS certificate"
}

variable "tls_secret_key" {
  type        = string
  default     = ""
  description = "Ingress TLS key"
}
##################
# Minio setup
##################

variable "helm_chart_version" {
  type        = string
  default     = "4.0.5"
  description = "version of Argo Forkflows helm chart"
}

variable "helm_repo" {
  type        = string
  default     = "https://operator.min.io/"
  description = "URL of used Helm chart repository"
}

variable "helm_timeout" {
  type        = number
  default     = 600
  description = "Helm chart deploy timeout in seconds"
}

variable "configuration" {
  type = object({
    namespace = string
    tenants   = any
  })
  default = {
    namespace = "minio-operator"
    tenants   = {}
  }
  description = "Minio operator configuration"
}
