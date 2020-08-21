# Common
variable "configuration" {
  type = object({
    enabled      = bool
    storage_size = string
  })
  description = "NFS configuration"
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
