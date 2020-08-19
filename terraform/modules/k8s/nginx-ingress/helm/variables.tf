variable "helm_values" {
  type        = map(any)
  description = "Extra helm nignx values"
}

variable "helm_repo" {
  type        = string
  default     = "https://kubernetes-charts.storage.googleapis.com"
  description = "URL of used Helm chart repository"
}

variable "dependencies" {
  type        = any
  default     = null
  description = "Terraform resource dependencies from one of modules"
}
