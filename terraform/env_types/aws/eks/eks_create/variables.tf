##################
# Common
##################
variable "cluster_name" {
  type        = string
  description = "Odahuflow cluster name"
}

variable "infra_cidr" {
  type        = string
  description = "Infrastructure network CIDR to peering with"
}

variable "k8s_version" {
  type        = string
  default     = "1.13.10"
  description = "Kubernetes master version"
}

variable "allowed_ips" {
  type        = list(string)
  description = "CIDR list to allow access from"
}

variable "agent_cidr" {
  type        = string
  default     = "0.0.0.0/0"
  description = "Jenkins agent CIDR to allow access for CI jobs or your WAN address in case of locla run"
}

##################
# AWS
##################
variable "az_list" {
  type        = list(string)
  description = "EKS Availability zones list"
}

variable "aws_region" {
  type        = string
  description = "Region of AWS resources"
}

variable "cidr" {
  type        = string
  default     = ""
  description = "network CIDR"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  default     = []
  description = "network CIDR"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  default     = []
  description = "AWS public network CIDR, will be used to place ELB"
}

variable "nat_subnet_cidr" {
  type        = string
  default     = ""
  description = "AWS NAT network CIDR, will be used to place bastion host"
}

#############
# Node pool
#############
variable "node_pools" {
  default     = {}
  description = "Default node pool configuration"
}

################
# Bastion host
################
variable "bastion_enabled" {
  type        = bool
  default     = false
  description = "Flag to install bastion host or not"
}

variable "bastion_machine_type" {
  type    = string
  default = "f1-micro"
}

variable "bastion_hostname" {
  type        = string
  default     = "bastion"
  description = "bastion hostname"
}
