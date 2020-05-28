variable "namespace" {
  type        = string
  default     = "vault"
  description = "Vault namespace"
}

variable "storage_class" {
  type        = string
  default     = "standard"
  description = "PVC storage class for vault deployment"
}

variable "storage_size" {
  type        = string
  default     = "10Gi"
  description = "Vault PVC storage size"
}

variable "configuration" {
  type = object({
    enabled : bool
  })
  description = "Vault configuration"
}

variable "helm_timeout" {
  type    = string
  default = "600"
}
