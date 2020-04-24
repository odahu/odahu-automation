# Common
variable "sa_name" {
  description = "Azure Storage Account name"
}

variable "resource_group" {
  description = "Azure Resouce Group name"
}

variable "sas_token" {
  description = "Azure SAS token"
}

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
