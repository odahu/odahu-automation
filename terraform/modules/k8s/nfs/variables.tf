# Common
variable "configuration" {
  type = object({
    enabled : bool,
    storage_size : string
  })
  description = "NFS configuration"
}

variable "helm_timeout" {
  default = "300"
}
