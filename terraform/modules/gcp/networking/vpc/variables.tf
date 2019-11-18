variable "project_id" {
  description = "Target project id"
}

variable "cluster_name" {
  default     = "odahuflow"
  description = "Odahuflow cluster name"
}

variable "region" {
  description = "Region of resources"
}

variable "subnet_cidr" {
  description = "Subnet range"
}
