variable "location" {
  type        = string
  description = "Azure location where the resource group is located"
}

variable "resource_group" {
  type        = string
  description = "The name of Azure resource group"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags used for Azure resources"
}

variable "cluster_name" {
  type        = string
  default     = "odahu-flow"
  description = "ODAHU flow cluster name"
}

variable "data_bucket" {
  type        = string
  description = "ODAHU flow data storage bucket"
}

variable "log_bucket" {
  type        = string
  default     = ""
  description = "ODAHU flow logs storage bucket"
}

variable "log_expiration_days" {
  type        = number
  default     = 1
  description = "ODAHU flow logs expiration days"
}

variable "allowed_ips" {
  type        = list(string)
  description = "CIDRs to allow access from"
}

variable "ip_egress_name" {
  type        = string
  description = "Name of AKS cluster egress public IP-address"
}

variable "kms_key_id" {
  type        = string
  description = "The ID of the Key Vault Key"
}

variable "kms_vault_id" {
  type        = string
  description = "Specifies the ID of the Key Vault instance where the Secret resides"
}

variable "vital_enable" {
  type        = bool
  default     = true
  description = "Enable vital parameter in odahuflow connections"
}

variable "fluentd_resources" {
  type = object({
    cpu_requests    = string
    memory_requests = string
    cpu_limits      = string
    memory_limits   = string
  })
  default = {
    cpu_requests    = "300m"
    memory_requests = "1Gi"
    cpu_limits      = "2"
    memory_limits   = "3Gi"
  }
  description = "Fluentd container resources"
}
