variable "cluster_name" {
  description = "Odahuflow k8s cluster name"
  default     = "odahuflow"
  type        = string
}

variable "location" {
  type        = string
  description = "Azure location where the resource group should be created"
}

variable "resource_group" {
  type        = string
  description = "The name of the resource group, unique within Azure subscription"
}

variable "aks_subnet_id" {
  type        = string
  description = "ID of subnet for the cluster nodes"
}

variable "allowed_ips" {
  description = "CIDRs to allow access from"
}

variable "bastion_enabled" {
  default     = false
  type        = bool
  description = "Flag to install bastion host or not"
}

variable "bastion_machine_type" {
  type        = string
  default     = "Standard_B1ls"
  description = ""
}

variable "bastion_labels" {
  default     = {}
  description = "Bastion host Azure resource tags"
  type        = map
}

variable "bastion_hostname" {
  type        = string
  default     = "bastion"
  description = "bastion hostname"
}

variable "bastion_ssh_user" {
  type        = string
  default     = "ubuntu"
  description = "bastion hostname"
}
