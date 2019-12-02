variable "cluster_name" {
  default     = "odahuflow"
  description = "Odahuflow cluster name"
}

variable "root_domain" {
  default     = ""
  description = "Odahuflow cluster root domain"
}

variable "dns_zone_name" {
  default     = ""
  description = "Cluster root DNS zone name"
}

variable "allowed_ips" {
  type        = list(string)
  description = "CIDR to allow access from"
}

variable "project_id" {
  default     = ""
  description = "Target project id"
}

variable "region" {
  default     = ""
  description = "Region of resources"
}

variable "network_name" {
  default     = ""
  description = "The VPC network to host the cluster in"
}