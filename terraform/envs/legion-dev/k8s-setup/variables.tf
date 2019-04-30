##################
# Common
##################


variable "project_id" {
  description = "Target project id"
}

variable "tls_name" {
  description = "Cluster TLS certificate name"
}

variable "secrets_storage" {
  description = "Cluster secrets storage"
}

variable "cluster_name" {
  default     = "legion"
  description = "Legion cluster name"
}

variable "allowed_ips" {
  description = "CIDR to allow access from"
}
