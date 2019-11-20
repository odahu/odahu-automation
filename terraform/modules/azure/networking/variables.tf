variable "cluster_name" {
  description = "Odahuflow cluster name"
  default     = "odahuflow"
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

variable "allowed_ips" {
  description = "CIDRs list to allow access from"
}

variable "tags" {
  description = "Tags used for virtual network"
  default     = {}
  type        = map
}
