variable "location" {
  type        = string
  description = "Azure location where the resource group is located"
}

variable "resource_group" {
  type        = string
  description = "The name of Azure resource group"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags used for Azure resources"
}

variable "cluster_name" {
  type        = string
  default     = "odahu-flow"
  description = "ODAHU flow cluster name"
}

variable "data_bucket" {
  type        = string
  description = "ODAHU flow data storage bucket"
}

variable "allowed_ips" {
  type        = list(string)
  description = "CIDRs to allow access from"
}

variable "ip_egress_name" {
  type        = string
  description = "Name of AKS cluster egress public IP-address"
}
