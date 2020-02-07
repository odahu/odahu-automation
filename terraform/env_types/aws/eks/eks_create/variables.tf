##################
# Common
##################
variable "cluster_name" {
  default     = "odahuflow"
  description = "Odahuflow cluster name"
}

variable "root_domain" {
  description = "Odahuflow cluster root domain"
}
variable "infra_cidr" {
  description = "Infrastructure network CIDR to peering with"
}
variable "k8s_version" {
  default     = "1.13.10"
  description = "Kubernetes master version"
}
variable "allowed_ips" {
  description = "CIDR to allow access from"
}
variable "agent_cidr" {
  default     = "0.0.0.0/0"
  description = "Jenkins agent CIDR to allow access for CI jobs or your WAN address in case of locla run"
}

##################
# GCP
##################
variable "project_id" {
  description = "GCP project ID"
}
variable "region" {
  description = "GCP region"
}
variable "zone" {
  default     = ""
  description = "GCP zone"
}

##################
# AWS
##################
variable "az_list" {
  description = "AWS profile name"
}
variable "aws_credentials_file" {
  default     = "~/.aws/credentials"
  description = "AWS credentials file location"
}
variable "region_aws" {
  default     = "eu-central-1"
  description = "Region of AWS resources"
}
variable "aws_region" {
  default     = "eu-central-1"
  description = "Region of AWS resources"
}
variable "cidr" {
  default     = []
  description = "network CIDR"
}
variable "private_subnet_cidrs" {
  default     = []
  description = "network CIDR"
}
variable "public_subnet_cidrs" {
  default     = []
  description = "AWS public network CIDR, will be used to place ELB"
}
variable "nat_subnet_cidr" {
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
  default     = false
  type        = bool
  description = "Flag to install bastion host or not"
}

variable "bastion_machine_type" {
  default = "f1-micro"
}

variable "bastion_hostname" {
  default     = "bastion"
  description = "bastion hostname"
}
