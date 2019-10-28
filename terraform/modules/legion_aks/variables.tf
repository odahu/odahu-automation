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

variable "public_ip_name" {
  description = "Name of public IP-address used for AKS cluster"
}

variable "aks_subnet_cidr" {
  description = "CIDR of AKS subnet used for nodes/pods networking"
}

variable "service_cidr" {
  default     = "10.0.0.0/16"
  description = "AKS service CIDR"
}
