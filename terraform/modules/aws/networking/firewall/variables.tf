variable "cluster_name" {
  default     = "legion"
  description = "Legion cluster name"
}

variable "vpc_id" {
  description = "VPC Netwrok name"
}

variable "vpc_sg_id" {
  description = "VPC Netwrok name"
}

variable "allowed_ips" {
  description = "Subnet ranges to whitelist on cluster"
}
