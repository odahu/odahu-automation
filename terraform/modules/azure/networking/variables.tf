variable "cluster_name" {
  description = "Legion cluster name"
  default     = "legion"
}

variable "location" {
  description = "Azure location where the resource group is created"
}

variable "resource_group" {
  description = "Azure resource group name"
}

variable "subnet_cidr" {
  description = "AKS worker nodes subnet range"
}

variable "public_ip_name" {
  description = "Name of public IP-address used for AKS cluster"
}

variable "allowed_ips" {
  description = "CIDRs list to allow access from"
}

variable "tags" {
  description = "Tags used for virtual network"
  default     = {}
  type        = "map"
}