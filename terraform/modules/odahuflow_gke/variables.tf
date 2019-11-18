variable "project_id" {
  default     = ""
  description = "Target project id"
}

variable "cluster_name" {
  default     = "odahuflow"
  description = "Odahuflow cluster name"
}

variable "region" {
  default     = "us-east1"
  description = "Region of resources"
}

variable "data_bucket" {
  description = "Odahuflow data storage bucket"
}
