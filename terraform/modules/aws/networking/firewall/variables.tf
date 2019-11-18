variable "cluster_name" {
  default     = "odahuflow"
  description = "Odahuflow cluster name"
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
