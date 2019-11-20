variable "location" {
  description = "Azure location where the resource group is located"
}

variable "resource_group" {
  description = "The name of Azure resource group"
}

variable "tags" {
  description = "Tags used for Azure resources"
  default     = {}
  type        = map(string)
}

variable "cluster_name" {
  default     = "odahu-flow"
  description = "Odahuflow cluster name"
}

variable "data_bucket" {
  description = "Odahuflow data storage bucket"
}

variable "allowed_ips" {
  description = "CIDRs to allow access from"
}

variable "ip_egress_name" {
  description = "Name of AKS cluster egress public IP-address"
}
