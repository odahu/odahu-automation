# Common
variable "configuration" {
  type = object({
    enabled       = bool
    storage_size  = string
    storage_class = string
  })
  description = "NFS configuration"
}

variable "helm_repo" {
  type        = string
  default     = "https://charts.helm.sh/stable"
  description = "URL of used Helm chart repository"
}

variable "helm_timeout" {
  type        = number
  default     = 300
  description = "Helm chart deploy timeout in seconds"
}
