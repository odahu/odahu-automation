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
  description = "The name of the resource group, unique within Azure subscription"
}

variable "aks_subnet_id" {
  type        = string
  description = "ID of subnet for the cluster nodes"
}

variable "allowed_ips" {
  type        = list(string)
  description = "CIDRs to allow access from"
}

variable "bastion_enabled" {
  type        = bool
  default     = false
  description = "Flag to install bastion host or not"
}

variable "bastion_machine_type" {
  type        = string
  default     = "Standard_B1ls"
  description = "Bastion host machine type"
}

variable "bastion_labels" {
  type        = map(string)
  default     = {}
  description = "Bastion host Azure resource tags"
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
