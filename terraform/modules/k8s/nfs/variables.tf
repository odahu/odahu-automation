# Common
variable "configuration" {
  type = object({
    enabled : bool,
    storage_size : string
  })
  description = "NFS configuration"
}

variable "helm_timeout" {
  type    = string
  default = "300"
}

variable "storage_class" {
  type        = string
  description = "Kubernetes storage class"
}
