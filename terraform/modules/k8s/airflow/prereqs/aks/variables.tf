# Common
variable "sa_name" {
  type        = string
  description = "Azure Storage Account name"
}

variable "resource_group" {
  type        = string
  description = "Azure Resouce Group name"
}

variable "sas_token" {
  type        = string
  description = "Azure SAS token"
}

variable "cluster_name" {
  type        = string
  default     = "odahuflow"
  description = "ODAHU flow cluster name"
}

variable "wine_bucket" {
  type        = string
  description = "Wine bucket name"
}

variable "dag_bucket_path" {
  type        = string
  description = "DAGs bucket subpath"
}

variable "dag_bucket" {
  type        = string
  description = "DAGs bucket name"
}
