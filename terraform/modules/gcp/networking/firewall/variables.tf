# variable needed for subnetwork creation


variable "cluster_name" {
  default     = "legion"
  description = "Legion cluster name"
}
variable "network_name" {
  description = "VPC Netwrok name"
}

variable "allowed_ips" {
  description = "Subnet ranges to whitelist on cluster"
}

variable "bastion_tag" {
  default = "{var.cluster_name}-bastion}"
  description = "Bastion network tag"
}