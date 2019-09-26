##################
# Common
##################
variable "project_id" {
  description = "Target project id"
}

variable "cluster_name" {
  default     = "legion"
  description = "Legion cluster name"
}

variable "zone" {
  description = "Default zone"
}

variable "region" {
  description = "Region of resources"
}

variable "root_domain" {
  description = "Legion cluster root domain"
}

variable "tls_secret_crt" {
  description = "Legion cluster TLS certificate"
}

variable "tls_secret_key" {
  description = "Legion cluster TLS key"
}

########################
# Kubernetes Dashboard
########################
variable "dashboard_tls_secret_name" {
  default     = "kubernetes-dashboard-certs"
  description = "Cluster root DNS zone name"
}