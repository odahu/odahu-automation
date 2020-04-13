variable "helm_values" {
  type        = map(any)
  description = "Extra helm nignx values"
}

variable "dependencies" {
  type        = any
  default     = null
  description = "Terraform resource dependencies from one of modules"
}
