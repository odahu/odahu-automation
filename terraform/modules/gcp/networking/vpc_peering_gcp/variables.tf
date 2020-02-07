variable "project_id" {
  description = "Target project id"
}

variable "gcp_network_1_name" {
  description = "VPC Network 1 name to peer with"
}

variable "gcp_network_1_range" {
  type        = list(string)
  description = "VPC Network 1 range to allow"
}

variable "gcp_network_2_name" {
  description = "VPC Network 2 name to peer with"
}

variable "gcp_network_2_range" {
  type        = list(string)
  description = "VPC Network 2 range to allow"
}
