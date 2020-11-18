variable "azure_location" {
  type        = string
  description = "Azure location in which the resource group will be created"
}

variable "azure_resource_group" {
  type        = string
  description = "Azure base resource group name"
}

variable "aks_sp_client_id" {
  type        = string
  description = "Service Principal account ID"
}

variable "aks_sp_secret" {
  type        = string
  description = "Service Principal account secret"
}

variable "aks_analytics_deploy" {
  type        = bool
  default     = false
  description = "Deploy new Azure Log Analytics workspace or not"
}

variable "aks_analytics_workspace_id" {
  type        = string
  default     = ""
  description = "Azure Log Analytics workspace ID"
}

variable "cluster_name" {
  type        = string
  default     = "odahuflow"
  description = "ODAHU flow k8s cluster name"
}

variable "aks_common_tags" {
  type = map(string)
  default = {
    env     = "Development"
    purpose = "Kubernetes Cluster"
  }
  description = "Set of common tags assigned to all cluster resources"
}

variable "aks_egress_ip_name" {
  type        = string
  description = "Name of AKS cluster egress IP-address"
}

variable "aks_dns_prefix" {
  type        = string
  default     = ""
  description = "DNS prefix for Kubernetes cluster"
}

variable "aks_cidr" {
  type        = string
  default     = "10.255.255.0/24"
  description = "Overall VPC address space for all subnets in it"
}

variable "k8s_version" {
  type        = string
  default     = "1.13.10"
  description = "Kubernetes master version"
}

variable "allowed_ips" {
  type        = list(string)
  description = "CIDRs to allow access from"
}

variable "ssh_key" {
  type        = string
  description = "SSH public key for ODAHU flow cluster nodes and bastion host"
}

variable "kms_key_id" {
  type        = string
  description = "The ID of the Key Vault Key"
}

variable "kms_vault_id" {
  type        = string
  description = "Specifies the ID of the Key Vault instance where the Secret resides"
}

################
# Bastion host
################
variable "bastion_enabled" {
  type        = bool
  default     = false
  description = "Flag to install bastion host or not"
}

variable "bastion_machine_type" {
  type        = string
  default     = "Standard_B1ls"
  description = "Bastion host VM type"
}

variable "bastion_labels" {
  type        = map(string)
  default     = {}
  description = "Bastion host Azure tags"
}

variable "bastion_hostname" {
  type        = string
  default     = "bastion"
  description = "bastion hostname"
}

variable "node_pools" {
  type = any
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
  type        = map(string)
  default     = {}
  description = "AKS nodes Azure tags"
}
