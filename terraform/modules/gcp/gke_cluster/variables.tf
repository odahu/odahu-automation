##################
# Common
##################
variable "project_id" {
  type        = string
  description = "Target project id"
}

variable "cluster_name" {
  type        = string
  default     = "odahuflow"
  description = "ODAHU flow cluster name"
}

variable "zone" {
  type        = string
  description = "Default zone"
}

################
# GKE variables
################
variable "location" {
  type        = string
  description = "The location (region or zone) in which the cluster master will be created"
}

variable "node_locations" {
  type        = list(string)
  description = "The list of zones in which nodes will be created"
}

variable "network" {
  type        = string
  description = "The VPC network to host the cluster in"
}

variable "subnetwork" {
  type        = string
  description = "The subnetwork to host the cluster in"
}

variable "k8s_version" {
  type        = string
  default     = "1.13.6"
  description = "Kubernetes master version"
}

variable "node_version" {
  type        = string
  default     = "1.13.6-gke.6"
  description = "Kubernetes worker nodes version. If no value is provided, this defaults to the value of k8s_version."
}

variable "allowed_ips" {
  type        = list(string)
  description = "CIDR to allow access from"
}

variable "ssh_user" {
  type        = string
  default     = "ubuntu"
  description = "Default ssh username"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for Odahuflow cluster nodes and bastion host"
}

variable "kms_key_id" {
  type        = string
  description = "The id of a Cloud KMS key that will be used to encrypt cluster disks"
}

variable "storage_type" {
  type        = string
  default     = "pd-standard"
  description = "Default encrypted storage class storage type"
}

variable "storage_class_name" {
  type        = string
  default     = "standard-encrypted"
  description = "Default encrypted storage class name"
}

variable "master_ipv4_cidr_block" {
  type        = string
  default     = "172.25.100.0/28"
  description = "GKE master CIDR"
}

variable "pods_cidr" {
  type        = string
  description = "GKE pods CIDR"
}

variable "service_cidr" {
  type        = string
  description = "GKE service CIDR"
}

variable "block_project_ssh_key" {
  type        = string
  default     = "true"
  description = "Should project-wide ssh keys be blocked for nodes"
}

variable "autoscaling_profile" {
  type        = string
  default     = "OPTIMIZE_UTILIZATION"
  description = "GKE autoscaling profile, possible values: BALANCED|OPTIMIZE_UTILIZATION"
}

variable "logging_service" {
  type        = string
  default     = "none"
  description = "Logging service to write logs to. Possible values: logging.googleapis.com|logging.googleapis.com/kubernetes|none"
}
#############
# Node pools
#############
variable "nodes_sa" {
  type        = string
  default     = "default"
  description = "Service account for cluster nodes"
}

variable "node_gcp_tags" {
  type        = list(string)
  default     = []
  description = "GKE cluster nodes GCP network tags"
}

variable "node_labels" {
  default     = {}
  type        = map(string)
  description = "GKE cluster nodes GCP labels"
}

variable "node_pools" {
  type = any
  default = {
    main = {
      init_node_count = 1
      min_node_count  = 1
      max_node_count  = 5
    }
  }
  description = "Default node pools configurations"
}

###############
# Bastion host
###############
variable "bastion_enabled" {
  type        = bool
  default     = false
  description = "Flag to install bastion host or not"
}

variable "bastion_machine_type" {
  type        = string
  default     = "f1-micro"
  description = "Bastion host VM type"
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
