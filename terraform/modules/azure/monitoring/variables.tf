variable "enabled" {
  type        = bool
  default     = false
  description = "Deploy new Azure Log Analytics workspace or not"
}

variable "cluster_name" {
  description = "Legion k8s cluster name"
  default     = "legion"
}

variable "location" {
  description = "Azure location where the resource group should be created"
}

variable "resource_group" {
  description = "The name of the resource group, unique within Azure subscription"
  default     = "testResourceGroup1"
}

variable "tags" {
  description = "Tags used for resource"
  default     = {}
  type        = "map"
}
