# Common
variable "cluster_name" {
  default     = "odahuflow"
  description = "ODAHU flow cluster name"
  type        = string
}

variable "wine_bucket" {
  description = "Wine bucket name"
  type        = string
}

variable "dag_bucket" {
  description = "DAGs bucket name"
  type        = string
}

variable "dag_bucket_path" {
  description = "DAGs bucket subpath"
  type        = string
}

variable "region" {
  description = "DAGs bucket region"
  type        = string
}
