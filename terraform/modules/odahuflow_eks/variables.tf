variable "cluster_name" {
  default     = "odahuflow"
  description = "Odahuflow cluster name"
}

variable "region" {
  default     = "eu-central-1"
  description = "Region of resources"
}

variable "data_bucket" {
  description = "Odahuflow data storage bucket"
}
