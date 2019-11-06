variable "namespace" {
  description = "Vault namespace"
  default     = "vault"
}

variable "vault_pvc_storage_class" {
  default     = "standard"
  description = "PVC storage class for vault deployment"
}