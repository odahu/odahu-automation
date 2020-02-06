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

variable "cluster_name" {
  default     = "odahuflow"
  description = "Odahuflow cluster name"
}

variable "gcp_project_id" {
  default     = ""
  description = "Target Google Cloud project ID"
}

variable "gcp_zone" {
  default     = "us-east1-b"
  description = "Google Cloud zone"
}

variable "gcp_region" {
  default     = "us-east1"
  description = "Google Cloud region"
}

variable "infra_vpc_name" {
  default     = "infra-vpc"
  description = "Region of resources"
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

variable "gke_node_tags" {
  default     = []
  description = "GKE cluster nodes network tags"
  type        = list(string)
}

variable "gke_node_labels" {
  default     = {}
  description = "GKE cluster nodes GCP labels"
  type        = map
}

#############
# GKE
#############
variable "node_locations" {
  default     = []
  description = "The list of zones in which nodes will be created, leave blank for zone cluster"
}

variable "initial_node_count" {
  default     = "1"
  description = "Initial node count"
}

variable "k8s_version" {
  default     = "1.13.6"
  description = "Kubernetes master version"
}

variable "allowed_ips" {
  type        = list(string)
  description = "CIDR to allow access from"
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

variable "node_version" {
  default     = ""
  description = "Version of Kubernetes Worker nodes. If no value is provided, this defaults to the value of k8s_version."
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

variable "bastion_tags" {
  default     = []
  description = "Bastion host network tags"
  type        = list(string)
}

variable "bastion_labels" {
  default     = {}
  description = "Bastion host GCP labels"
  type        = map
}
