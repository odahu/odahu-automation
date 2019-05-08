
###
# GKE variables
###

variable "project_id" {
  description = "Target project id"
}

variable "cluster_name" {
  default     = "legion"
  description = "Legion cluster name"
}
variable "region" {
  default = "us-east1"
  description = "Region of resources"
}

variable "zone" {
  default     = "us-east1-b"
  description = "Default zone"
}

variable "location" {
  default = "us-east1-b"
  description = "The location (region or zone) in which the cluster master will be created"
}

variable "network" {
  description = "The VPC network to host the cluster in"
}

variable "subnetwork" {
  description = "The subnetwork to host the cluster in"
}

variable "k8s_version" {
  default = "1.11.7-gke.12"
  description = "Kubernetes master version"
}

variable "node_version" {
  description = "K8s version for Nodes. If no value is provided, this defaults to the value of k8s_version."
  default     = "1.11.7-gke.12"
}

variable "master_authorized_network" {
  description = "CIDR to allow master access from"
}

###
### Node pool
###

variable "node_disk_size_gb" {
  default = "20"
  description = "Persistent disk size for cluster worker nodes"
}

variable "gke_node_machine_type" {
  default = "n1-standard-1"
  description = "Machine type of GKE nodes"
}

variable "gke_num_nodes_min" {
  default = "1"
  description = "Number of nodes in each GKE cluster zone"
}

variable "gke_num_nodes_max" {
  default = "5"
  description = "Number of nodes in each GKE cluster zone"
}

variable "service_account" {
  default = "default"
  description = "Service account for cluster nodes"
}

######

# variable "ip_range_pods" {
#   default = "10.1.1.0/24"
#   description = "The secondary ip range to use for pods"
# }

# variable "ip_range_services" {
#   default = "10.1.2.0/24"
#   description = "The secondary ip range to use for pods"
# }

###
# Bastion host
###

variable "bastion_machine_type" {
  default = "f1-micro"
}

variable "bastion_tags" {
  default = []
}

variable "bastion_hostname" {
  default = "bastion"
  description = "bastion hpstname"
}
