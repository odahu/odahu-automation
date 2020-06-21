variable "namespace" {
  type        = string
  default     = "vault"
  description = "Vault namespace"
}

variable "vault_pvc_storage_class" {
  type        = string
  default     = "standard"
  description = "PVC storage class for vault deployment"
}

variable "configuration" {
  type = object({
    enabled = bool
  })
  description = "Vault configuration"
}

variable "helm_timeout" {
  type        = number
  default     = 600
  description = "Helm chart deploy timeout in seconds"
}
