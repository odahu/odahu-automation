# Common
variable "configuration" {
  type = object({
    enabled      = bool
    storage_size = string
  })
  description = "NFS configuration"
}

variable "helm_timeout" {
  type        = number
  default     = 300
  description = "Helm chart deploy timeout in seconds"
}
