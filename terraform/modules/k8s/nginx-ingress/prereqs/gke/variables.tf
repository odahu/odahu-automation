variable "cluster_name" {
  type        = string
  default     = "odahuflow"
  description = "ODAHU flow cluster name"
}

variable "allowed_ips" {
  type        = list(string)
  description = "CIDR to allow access from"
}

variable "project_id" {
  type        = string
  default     = ""
  description = "Target project id"
}

variable "region" {
  type        = string
  default     = ""
  description = "Region of resources"
}

variable "network_name" {
  type        = string
  default     = ""
  description = "The VPC network to host the cluster in"
}
