variable "cluster_name" {
  default     = "legion"
  description = "Legion cluster name"
}

variable "region" {
  default     = "eu-central-1"
  description = "Region of resources"
}

variable "legion_data_bucket" {
  description = "Legion data storage bucket"
}
