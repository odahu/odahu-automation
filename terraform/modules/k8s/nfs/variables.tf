# Common
variable "configuration" {
  type = object({
    enabled      = bool
    storage_size = string
  })
  description = "NFS configuration"
}

variable "namespace" {
  type        = string
  default     = "kube-system"
  description = "NFS namespace"
}

variable "helm_repo" {
  type        = string
  default     = "https://kubernetes-charts.storage.googleapis.com"
  description = "URL of used Helm chart repository"
}

variable "helm_timeout" {
  type        = number
  default     = 300
  description = "Helm chart deploy timeout in seconds"
}

variable "module_dependency" {
  type        = any
  default     = null
  description = "Dependency of this module (https://discuss.hashicorp.com/t/tips-howto-implement-module-depends-on-emulation/2305)"
}
