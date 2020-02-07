variable "azure_location" {
  default     = ""
  description = "Azure location in which the resource group will be created"
}

variable "azure_resource_group" {
  default     = ""
  description = "Azure base resource group name"
}

variable "aks_analytics_deploy" {
  type        = bool
  default     = false
  description = "Deploy new Azure Log Analytics workspace or not"
}

variable "aks_analytics_workspace_id" {
  default     = ""
  description = "Azure Log Analytics workspace ID"
}

variable "cluster_name" {
  default     = "odahuflow"
  description = "Odahuflow k8s cluster name"
}

variable "aks_common_tags" {
  description = "Set of common tags assigned to all cluster resources"
  type        = map
  default = {
    env     = "Development"
    purpose = "Kubernetes Cluster"
  }
}

variable "aks_egress_ip_name" {
  description = "Name of AKS cluster egress IP-address"
}

variable "aks_dns_prefix" {
  default     = ""
  description = "DNS prefix for Kubernetes cluster"
}

variable "aks_cidr" {
  default     = "10.255.255.0/24"
  description = "Overall VPC address space for all subnets in it"
}

variable "k8s_version" {
  default     = "1.13.10"
  description = "Kubernetes master version"
}

variable "allowed_ips" {
  description = "CIDRs to allow access from"
}

variable "ssh_key" {
  description = "SSH public key for Odahuflow cluster nodes and bastion host"
}

################
# Bastion host
################
variable "bastion_enabled" {
  default     = false
  type        = bool
  description = "Flag to install bastion host or not"
}

variable "bastion_machine_type" {
  default = "Standard_B1ls"
}

variable "bastion_labels" {
  default     = {}
  description = "Bastion host Azure tags"
  type        = map
}

variable "bastion_hostname" {
  default     = "bastion"
  description = "bastion hostname"
}

variable "node_pools" {
  default = {
    main = {
      init_node_count = 3
      min_node_count  = 1
      max_node_count  = 5
    }
  }
  description = "Default node pools configuration"
}

variable "node_labels" {
  default     = {}
  description = "AKS nodes Azure tags"
  type        = map
}
