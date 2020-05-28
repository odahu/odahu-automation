variable "storage_class_name" {
  type        = string
  default     = "odahu-regular"
  description = "Name of k8s storage class to be created"
}

variable "storage_class_settings" {
  type = object({
    parameters      = map(string)
    provisioner     = string
    allow_expansion = bool
    binding_mode    = string
    reclaim_policy  = string
  })
  description = "k8s storage class settings"
}
