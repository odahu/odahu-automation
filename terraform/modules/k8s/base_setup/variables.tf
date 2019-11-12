##################
# Common
##################
variable "cluster_name" {
  default     = "odahuflow"
  description = "Odahuflow cluster name"
}

variable "tls_namespaces" {
  default     = ["default", "kube-system"]
  description = "Default namespaces with TLS secret"
}

variable "tls_secret_crt" {
  description = "Odahuflow cluster TLS certificate"
}

variable "tls_secret_key" {
  description = "Odahuflow cluster TLS key"
}
