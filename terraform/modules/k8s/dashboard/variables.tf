##################
# Common
##################
variable "cluster_name" {
  default     = "odahuflow"
  description = "Odahuflow cluster name"
}

variable "root_domain" {
  description = "Odahuflow cluster root domain"
}

variable "tls_secret_crt" {
  description = "Odahuflow cluster TLS certificate"
}

variable "tls_secret_key" {
  description = "Odahuflow cluster TLS key"
}

########################
# Kubernetes Dashboard
########################
variable "dashboard_tls_secret_name" {
  default     = "kubernetes-dashboard-certs"
  description = "Cluster root DNS zone name"
}