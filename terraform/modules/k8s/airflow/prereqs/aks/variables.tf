# Common
variable "sa_name" {
  description = "Azure Storage Account name"
  type        = string
}

variable "resource_group" {
  description = "Azure Resouce Group name"
  type        = string
}

variable "sas_token" {
  description = "Azure SAS token"
  type        = string
}

variable "cluster_name" {
  default     = "odahuflow"
  description = "ODAHU flow cluster name"
  type        = string
}

variable "wine_bucket" {
  description = "Wine bucket name"
  type        = string
}

variable "dag_bucket_path" {
  description = "DAGs bucket subpath"
  type        = string
}

variable "dag_bucket" {
  description = "DAGs bucket name"
  type        = string
}
