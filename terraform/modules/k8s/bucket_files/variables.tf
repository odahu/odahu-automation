variable "examples_version" {
  type        = string
  default     = "develop"
  description = "ODAHU examples version"
}

variable "dag_bucket" {
  type        = string
  description = "DAGs bucket name"
}

variable "examples_urls" {
  type        = any
  default     = {}
  description = "Examples files with URLs"
}
