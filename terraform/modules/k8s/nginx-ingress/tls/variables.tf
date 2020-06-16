##################
# Common
##################
variable "cluster_name" {
  type        = string
  default     = "odahuflow"
  description = "ODAHU flow cluster name"
}

variable "tls_namespaces" {
  type        = list(string)
  default     = ["default", "kube-system"]
  description = "Default list of namespaces with TLS secret"
}

variable "tls_secret_crt" {
  type        = string
  description = "ODAHU flow cluster TLS certificate"
}

variable "tls_secret_key" {
  type        = string
  description = "ODAHU flow cluster TLS key"
}
