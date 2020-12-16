variable "helm_values" {
  type        = map(any)
  description = "Extra helm nignx values"
}

variable "helm_repo" {
  type        = string
  default     = "https://charts.helm.sh/stable"
  description = "URL of used Helm chart repository"
}

variable "dependencies" {
  type        = any
  default     = null
  description = "Terraform resource dependencies from one of modules"
}
