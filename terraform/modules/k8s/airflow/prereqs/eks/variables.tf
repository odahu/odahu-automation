# Common
variable "cluster_name" {
  type        = string
  default     = "odahuflow"
  description = "ODAHU flow cluster name"
}

variable "wine_bucket" {
  type        = string
  description = "Wine bucket name"
}

variable "dag_bucket" {
  type        = string
  description = "DAGs bucket name"
}

variable "dag_bucket_path" {
  type        = string
  description = "DAGs bucket subpath"
}

variable "region" {
  type        = string
  description = "DAGs bucket region"
}
