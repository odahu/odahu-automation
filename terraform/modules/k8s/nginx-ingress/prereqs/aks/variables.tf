variable "cluster_name" {
  type        = string
  default     = "odahuflow"
  description = "ODAHU flow cluster name"
}

variable "resource_group" {
  type        = string
  description = "Azure resource group name"
}

variable "location" {
  type        = string
  description = "Azure location"
}

variable "allowed_ips" {
  type        = list(string)
  description = "CIDR to allow access from"
}

variable "network_name" {
  type        = string
  description = "Name of existing VPC to use"
}

variable "subnet_name" {
  type        = string
  description = "Name of existing subnet to use"
}
