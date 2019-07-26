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

variable "allowed_ips" {
  type        = list(string)
  description = "CIDR to allow access from"
}

variable "dns_zone_name" {
  description = "Cluster root DNS zone name"
}

variable "network_name" {
  description = "The VPC network to host the cluster in"
}

