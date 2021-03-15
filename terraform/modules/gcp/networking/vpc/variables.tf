variable "project_id" {
  type        = string
  description = "Target project id"
}

variable "cluster_name" {
  type        = string
  default     = "odahuflow"
  description = "ODAHU flow cluster name"
}

variable "region" {
  type        = string
  description = "Region of resources"
}

variable "subnet_cidr" {
  type        = string
  description = "Subnet range"
}

variable "vpc_name" {
  type        = string
  default     = ""
  description = "VPC name"
}

variable "subnet_name" {
  type        = string
  default     = ""
  description = "Subnet name"
}

variable "nat_enabled" {
  type        = bool
  default     = true
  description = "If NAT should be created"
}
