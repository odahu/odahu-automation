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

variable "k8s_version" {
  type        = string
  description = "Version of Kubernetes engine"
}

variable "ssh_user" {
  type        = string
  default     = "ubuntu"
  description = "Default ssh user"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key provided to default ssh user"
}

variable "aks_dns_prefix" {
  type        = string
  default     = "k8stest"
  description = "DNS prefix specified when creating the cluster"
}

variable "aks_subnet_id" {
  type        = string
  description = "ID of subnet for the cluster nodes to run"
}

variable "aks_subnet_cidr" {
  type        = string
  description = "CIDR of AKS subnet used for nodes/pods networking"
}

variable "service_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "AKS service CIDR"
}

variable "allowed_ips" {
  type        = list(string)
  description = "CIDRs to allow access from"
}

variable "aks_tags" {
  type        = map(string)
  default     = {}
  description = "Tags used for Azure Kubernetes cluster resources labeling"
}

variable "aks_analytics_workspace_id" {
  type        = string
  default     = ""
  description = "Azure Log Analytics workspace ID"
}

variable "sp_client_id" {
  type        = string
  description = "Service Principal account ID"
}

variable "sp_secret" {
  type        = string
  description = "Service Principal account secret"
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

variable "egress_ip_name" {
  type        = string
  description = "Name of public IP-address used for AKS cluster egress"
}

variable "bastion_enabled" {
  type        = bool
  default     = false
  description = "Is bastion host enabled or not"
}

variable "bastion_privkey" {
  type        = string
  default     = ""
  description = "Bastion host private SSH key"
}

variable "bastion_ip" {
  type        = string
  default     = ""
  description = "Bastion host IP-address"
}

variable "kms_key_id" {
  type        = string
  description = "The ID of the Key Vault Key"
}

variable "kms_vault_id" {
  type        = string
  description = "Specifies the ID of the Key Vault instance where the Secret resides"
}

variable "storage_class_name" {
  default     = "azure-encrypted-disk"
  description = "Name of created storage class"
}
