variable "cluster_name" {
  type        = string
  default     = "odahuflow"
  description = "ODAHU flow cluster name"
}

variable "network_name" {
  type        = string
  default     = ""
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

variable "bastion_gcp_tags" {
  type        = list(string)
  default     = []
  description = "Bastion host GCP network tags"
}

variable "node_gcp_tags" {
  type        = list(string)
  default     = []
  description = "GKE cluster nodes GCP network tags"
}

variable "master_ipv4_cidr_block" {
  type        = string
  default     = "172.25.100.0/28"
  description = "GKE master CIDR"
}

