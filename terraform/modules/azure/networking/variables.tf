variable "cluster_name" {
  description = "Odahuflow cluster name"
  default     = "odahuflow"
}

variable "location" {
  description = "Azure location"
}

variable "resource_group" {
  description = "Azure resource group name"
}

variable "subnet_cidr" {
  description = "AKS worker nodes subnet range"
}

variable "tags" {
  description = "Tags used for virtual network"
  default     = {}
  type        = map
}
