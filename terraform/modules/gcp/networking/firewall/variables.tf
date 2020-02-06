variable "cluster_name" {
  default     = "odahuflow"
  description = "Odahuflow cluster name"
}

variable "network_name" {
  default     = ""
  description = "VPC Netwrok name"
}

variable "allowed_ips" {
  description = "Subnet ranges to whitelist on cluster"
}

variable "bastion_enabled" {
  default     = false
  type        = bool
  description = "Flag to install bastion host or not"
}

variable "bastion_gcp_tags" {
  default     = []
  description = "Bastion host GCP network tags"
  type        = list(string)
}

variable "node_gcp_tags" {
  default     = []
  description = "GKE cluster nodes GCP network tags"
  type        = list(string)
}

variable "master_ipv4_cidr_block" {
  default     = "172.25.100.0/28"
  description = "GKE master CIDR"
}

