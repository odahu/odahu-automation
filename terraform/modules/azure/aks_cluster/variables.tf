variable "cluster_name" {
  description = "Odahuflow k8s cluster name"
  default     = "odahuflow"
}

variable "location" {
  description = "Azure location where the resource group should be created"
}

variable "resource_group" {
  description = "The name of the resource group, unique within Azure subscription"
}

variable "k8s_version" {
  description = "Version of Kubernetes engine"
}

variable "ssh_user" {
  default     = "ubuntu"
  description = "Default ssh user"
}

variable "ssh_public_key" {
  description = "SSH public key provided to default ssh user"
}

variable "aks_dns_prefix" {
  description = "DNS prefix specified when creating the cluster"
  default     = "k8stest"
}

variable "aks_subnet_id" {
  description = "ID of subnet for the cluster nodes to run"
}

variable "aks_subnet_cidr" {
  description = "CIDR of AKS subnet used for nodes/pods networking"
}

variable "service_cidr" {
  default     = "10.0.0.0/16"
  description = "AKS service CIDR"
}

variable "allowed_ips" {
  description = "CIDRs to allow access from"
}

variable "aks_tags" {
  description = "Tags used for Azure Kubernetes cluster definition"
  default     = {}
  type        = map
}

variable "aks_analytics_workspace_id" {
  default     = ""
  description = "Azure Log Analytics workspace ID"
}

variable "sp_client_id" {
  description = "Service Principal account ID"
}

variable "sp_secret" {
  description = "Service Principal account secret"
}

variable "node_pools" {
  description = "List of k8s node pools map definitions"
  default     = []
}

variable "egress_ip_name" {
  description = "Name of public IP-address used for AKS cluster egress"
}

variable "bastion_ip" {
  description = "Bastion host IP-address"
}
