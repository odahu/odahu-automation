variable "cluster_name" {
  type        = string
  default     = "odahuflow"
  description = "ODAHU flow cluster name"
}

variable "vpc_id" {
  type        = string
  description = "VPC Netwrok name"
}

variable "vpc_sg_id" {
  type        = string
  description = "VPC Netwrok name"
}

variable "allowed_ips" {
  type        = list(string)
  description = "Subnet ranges to whitelist on cluster"
}

variable "bastion_enabled" {
  type        = bool
  default     = false
  description = "Flag to install bastion host or not"
}
