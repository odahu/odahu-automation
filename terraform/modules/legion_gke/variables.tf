variable "project_id" {
  default = ""
  description = "Target project id"
}

variable "cluster_name" {
  default     = "legion"
  description = "Legion cluster name"
}

variable "region" {
  default     = "us-east1"
  description = "Region of resources"
}

variable "legion_data_bucket" {
  description = "Legion data storage bucket"
}
