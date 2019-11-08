##################
# Common
##################
variable "cluster_type" {
  description = "Cluster type"
}

variable "cluster_name" {
  default     = "legion"
  description = "Legion cluster name"
}

variable "root_domain" {
  default     = ""
  description = "Legion cluster root domain"
}

variable "allowed_ips" {
  type        = list(string)
  description = "CIDR to allow access from"
}

variable "dns_zone_name" {
  default     = ""
  description = "Cluster root DNS zone name"
}

##################
# GCP
##################
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

##################
# AWS
##################
variable "az_list" {
  default = []
  type    = list(string)
}

variable "aws_lb_subnets" {
  default = []
  type    = list(string)
}

##################
# Azure
##################
variable "aks_ip_resource_group" {
  default     = ""
  description = "Azure resource group name"
}
