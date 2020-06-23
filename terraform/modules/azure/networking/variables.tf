variable "cluster_name" {
  type        = string
  default     = "odahuflow"
  description = "ODAHU flow cluster name"
}

variable "location" {
  type        = string
  description = "Azure location"
}

variable "resource_group" {
  type        = string
  description = "Azure resource group name"
}

variable "subnet_cidr" {
  type        = string
  description = "AKS worker nodes subnet range"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags used for virtual network"
}
