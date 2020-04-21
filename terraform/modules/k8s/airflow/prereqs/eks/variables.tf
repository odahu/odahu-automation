# Common
variable "cluster_name" {
  default     = "odahuflow"
  description = "Odahuflow cluster name"
}

variable "wine_bucket" {
  description = "Wine bucket name"
}

variable "dags_bucket" {
  description = "DAGs bucket name"
}

variable "region" {
  description = "DAGs bucket region"
}
