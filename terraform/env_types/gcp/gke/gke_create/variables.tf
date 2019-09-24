##################
# Common
##################
variable "project_id" {
  description = "Target project id"
}

variable "cluster_name" {
  default     = "legion"
  description = "Legion cluster name"
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
  description = "Region of resources"
}

variable "infra_cidr" {
  default     = ""
  description = "GCP infra network CIDR"
}

variable "secrets_storage" {
  description = "Cluster secrets storage"
}

variable "root_domain" {
  description = "Legion cluster root domain"
}

variable "aws_vpc_id" {
  description = "AWS VPC id to establish peering with"
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

variable "aws_sg" {
  description = "AWS SG id for gcp access"
}

variable "aws_cidr" {
  description = "AWS network CIDR"
}

variable "aws_route_table_id" {
  description = "AWS Route table ID"
}

variable "gke_node_tag" {
  description = "GKE cluster nodes tag"
}

#############
# GKE
#############
variable "location" {
  default     = "us-east1-b"
  description = "The location (region or zone) in which the cluster master will be created"
}

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

variable "node_version" {
  description = "K8s version for Nodes. If no value is provided, this defaults to the value of k8s_version."
  default     = "1.13.6-gke.6"
}

variable "allowed_ips" {
  type        = list(string)
  description = "CIDR to allow access from"
}

variable "agent_cidr" {
  description = "Jenkins agent CIDR to allow access for CI jobs or your WAN address in case of locla run"
  default     = "0.0.0.0/0"
}

variable "dns_zone_name" {
  description = "Cluster root DNS zone name"
}

variable "ssh_key" {
  description = "SSH public key for Legion cluster nodes and bastion host"
}

#############
# Node pool
#############
variable "nodes_sa" {
  default     = "default"
  description = "Service account for cluster nodes"
}

################
# Bastion host
################
variable "bastion_machine_type" {
  default = "f1-micro"
}

variable "bastion_tag" {
  default     = ""
  description = "Bastion network tags"
}

variable "bastion_hostname" {
  default     = "bastion"
  description = "bastion hpstname"
}

