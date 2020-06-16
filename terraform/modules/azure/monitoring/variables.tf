variable "enabled" {
  type        = bool
  default     = false
  description = "Deploy new Azure Log Analytics workspace or not"
}

variable "cluster_name" {
  type        = string
  default     = "odahuflow"
  description = "ODAHU flow k8s cluster name"
}

variable "location" {
  type        = string
  description = "Azure location where the resource group should be created"
}

variable "resource_group" {
  type        = string
  default     = "testResourceGroup1"
  description = "The name of the resource group, unique within Azure subscription"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags used for resource"
}
