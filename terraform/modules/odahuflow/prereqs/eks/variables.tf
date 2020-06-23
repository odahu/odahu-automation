variable "cluster_name" {
  type        = string
  default     = "odahu-flow"
  description = "ODAHU flow cluster name"
}

variable "region" {
  type        = string
  default     = "eu-central-1"
  description = "Region of resources"
}

variable "data_bucket" {
  type        = string
  description = "ODAHU flow data storage bucket"
}
