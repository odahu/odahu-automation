##################
# Common
##################
variable "vpc_name" {
  default     = ""
  description = "Name of existing VPC to use"
}

variable "subnet_name" {
  default     = ""
  description = "Name of existing subnet to use"
}

variable "project_id" {
  description = "Target project id"
}

variable "cluster_name" {
  default     = "odahuflow"
  description = "Odahuflow cluster name"
}

variable "zone" {
  default     = "us-east1-b"
  description = "Default zone"
}

variable "region" {
  default     = "us-east1"
  description = "Region of resources"
}

variable "infra_vpc_name" {
  default     = "infra-vpc"
  description = "GCP infra network name"
}

variable "infra_cidr" {
  default     = ""
  description = "GCP infra network CIDR"
}

variable "gcp_cidr" {
  description = "GCP network CIDR"
}

variable "pods_cidr" {
  description = "GKE pods CIDR"
}

variable "service_cidr" {
  description = "GKE service CIDR"
}

#############
# GKE
#############
variable "node_locations" {
  default     = []
  description = "The list of zones in which nodes will be created, leave blank for zone cluster"
}

variable "k8s_version" {
  default     = "1.13.6"
  description = "Kubernetes master version"
}

variable "node_version" {
  default     = ""
  description = "Kubernetes worker nodes version. If no value is provided, this defaults to the value of k8s_version."
}

variable "allowed_ips" {
  type        = list(string)
  description = "CIDR to allow access from"
}

variable "agent_cidr" {
  description = "Jenkins agent CIDR to allow access for CI jobs or your WAN address in case of locla run"
  default     = "0.0.0.0/0"
}

variable "ssh_key" {
  description = "SSH public key for Odahuflow cluster nodes and bastion host"
}

#############
# Node pool
#############
variable "nodes_sa" {
  default     = "default"
  description = "Service account for cluster nodes"
}

variable "node_pools" {
  default     = {}
  description = "Default node pools configuration"
}

variable "node_labels" {
  default     = {}
  description = "GKE nodes GCP labels"
  type        = map(string)
}

variable "node_gcp_tags" {
  default     = []
  description = "GKE cluster nodes GCP network tags"
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
  description = "Bastion hostname"
}

variable "bastion_gcp_tags" {
  default     = []
  description = "Bastion host GCP network tags"
  type        = list(string)
}

variable "bastion_labels" {
  default     = {}
  description = "Bastion host GCP labels"
  type        = map(string)
}
