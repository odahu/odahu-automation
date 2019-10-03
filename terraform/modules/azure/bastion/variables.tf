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

variable "aks_subnet_id" {
  description = "ID of subnet for the cluster nodes to run"
}

variable "public_ip_id" {
  description = "ID of Public IP address that will be used for bastion SSH access"
}

variable "bastion_machine_type" {
  default = "Standard_B1ls"
}

variable "bastion_tags" {
  default     = {}
  description = "Bastion host tags"
  type        = "map"
}

variable "bastion_hostname" {
  default     = "bastion"
  description = "bastion hostname"
}

variable "bastion_ssh_user" {
  default     = "ubuntu"
  description = "bastion hostname"
}