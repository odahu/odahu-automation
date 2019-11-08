variable "location" {
  description = "Azure location where the resource group is located"
}

variable "resource_group" {
  description = "The name of Azure resource group"
}

variable "tags" {
  description = "Tags used for Azure resources"
  default     = {}
  type        = "map"
}

variable "cluster_name" {
  default     = "legion"
  description = "Legion cluster name"
}

variable "legion_data_bucket" {
  description = "Legion data storage bucket"
}

variable "allowed_ips" {
  description = "CIDRs to allow access from"
}

variable "ip_egress_name" {
  description = "Name of AKS cluster egress public IP-address"
}
