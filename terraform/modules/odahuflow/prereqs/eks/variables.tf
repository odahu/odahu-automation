variable "cluster_name" {
  default     = "odahu-flow-"
  description = "Odahuflow cluster name"
}

variable "region" {
  default     = "eu-central-1"
  description = "Region of resources"
}

variable "data_bucket" {
  description = "Odahuflow data storage bucket"
}
