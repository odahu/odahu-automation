##################
# Common
##################
variable "project_id" {
  description = "Target project id"
}

variable "cluster_name" {
  default     = "odahuflow"
  description = "Odahuflow cluster name"
}

variable "zone" {
  description = "Default zone"
}

################
# GKE variables
################
variable "location" {
  description = "The location (region or zone) in which the cluster master will be created"
}

variable "initial_node_count" {
  type        = string
  description = "Initial node count, use it to warm up master"
}

variable "node_locations" {
  type        = list(string)
  description = "The list of zones in which nodes will be created"
}

variable "network" {
  description = "The VPC network to host the cluster in"
}

variable "subnetwork" {
  description = "The subnetwork to host the cluster in"
}

variable "k8s_version" {
  default     = "1.13.6 "
  description = "Kubernetes master version"
}

variable "node_version" {
  description = "K8s version for Nodes. If no value is provided, this defaults to the value of k8s_version."
  default     = "1.13.6-gke.6 "
}

variable "allowed_ips" {
  type        = list(string)
  description = "CIDR to allow access from"
}

variable "agent_cidr" {
  description = "Jenkins agent CIDR to allow access for CI jobs or your WAN address in case of locla run"
}

variable "ssh_user" {
  default     = "ubuntu"
  description = "default ssh user"
}

variable "ssh_public_key" {
  description = "SSH public key for Odahuflow cluster nodes and bastion host"
}

variable "cluster_autoscaling_cpu_max_limit" {
  default     = 20
  description = "Maximum CPU limit for autoscaling if it is enabled."
}

variable "cluster_autoscaling_cpu_min_limit" {
  default     = 2
  description = "Minimum CPU limit for autoscaling if it is enabled."
}

variable "cluster_autoscaling_memory_max_limit" {
  default     = 64
  description = "Maximum memory limit for autoscaling if it is enabled."
}

variable "cluster_autoscaling_memory_min_limit" {
  default     = 4
  description = "Minimum memory limit for autoscaling if it is enabled."
}

variable "master_ipv4_cidr_block" {
  default     = "172.25.100.0/28"
  description = "GKE master CIDR"
}

variable "pods_cidr" {
  description = "GKE pods CIDR"
}

variable "service_cidr" {
  description = "GKE service CIDR"
}

#############
# Node pool
#############

variable "nodes_sa" {
  default     = "default"
  description = "Service account for cluster nodes"
}

variable "gke_node_tag" {
  description = "GKE cluster nodes tag"
}

variable "node_pools" {
  description = "Default node pools configurations"
  default = {
    main = {
      init_node_count = 1
      min_node_count  = 1
      max_node_count  = 5
    }
  }
}

###############
# Bastion host
###############

variable "bastion_machine_type" {
  default = "f1-micro"
}

variable "bastion_hostname" {
  default     = "bastion"
  description = "bastion hostname"
}

variable "bastion_tag" {
  default     = ""
  description = "Bastion network tags"
}

