##################
# Common
##################
variable "cluster_name" {
  default     = "legion"
  description = "Legion cluster name"
}

variable "tls_namespaces" {
  default     = ["default", "kube-system"]
  description = "Default namespaces with TLS secret"
}

variable "tls_secret_crt" {
  description = "Legion cluster TLS certificate"
}

variable "tls_secret_key" {
  description = "Legion cluster TLS key"
}
