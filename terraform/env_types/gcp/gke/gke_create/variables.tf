##################
# Common
##################
variable "vpc_name" {
  type        = string
  default     = ""
  description = "Name of existing VPC to use"
}

variable "subnet_name" {
  type        = string
  default     = ""
  description = "Name of existing subnet to use"
}

variable "project_id" {
  type        = string
  description = "Target project id"
}

variable "zone" {
  type        = string
  description = "Compute zone (e.g. us-central1-a) for the cluster"
}

variable "region" {
  type        = string
  description = "Compute region (e.g. us-central1) for the cluster"
}

variable "cluster_name" {
  type        = string
  default     = "odahuflow"
  description = "Odahuflow cluster name"
}

variable "infra_vpc_name" {
  type        = string
  default     = "infra-vpc"
  description = "GCP infra network name"
}

variable "infra_cidr" {
  type        = string
  default     = ""
  description = "GCP infra network CIDR"
}

variable "gcp_cidr" {
  type        = string
  default     = ""
  description = "GCP network CIDR"
}

variable "pods_cidr" {
  type        = string
  description = "GKE pods CIDR"
}

variable "service_cidr" {
  type        = string
  description = "GKE service CIDR"
}

#############
# GKE
#############
variable "node_locations" {
  type        = list(string)
  description = "The list of zones in which nodes will be created, leave blank for zone cluster"
}

variable "k8s_version" {
  type        = string
  default     = "1.13.6"
  description = "Kubernetes master version"
}

variable "node_version" {
  type        = string
  default     = ""
  description = "Kubernetes worker nodes version. If no value is provided, this defaults to the value of k8s_version."
}

variable "allowed_ips" {
  type        = list(string)
  description = "CIDR to allow access from"
}

variable "ssh_key" {
  type        = string
  description = "SSH public key for Odahuflow cluster nodes and bastion host"
}

#############
# Node pool
#############
variable "nodes_sa" {
  type        = string
  default     = "default"
  description = "Service account for cluster nodes"
}

variable "node_pools" {
  type        = any
  default     = {}
  description = "Default node pools configuration"
}

variable "node_labels" {
  type        = map(string)
  default     = {}
  description = "GKE nodes GCP labels"
}

variable "node_gcp_tags" {
  type        = list(string)
  default     = []
  description = "GKE cluster nodes GCP network tags"
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
  description = "Bastion hostname"
}

variable "bastion_gcp_tags" {
  type        = list(string)
  default     = []
  description = "Bastion host GCP network tags"
}

variable "bastion_labels" {
  type        = map(string)
  default     = {}
  description = "Bastion host GCP labels"
}
