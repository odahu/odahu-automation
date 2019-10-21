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
