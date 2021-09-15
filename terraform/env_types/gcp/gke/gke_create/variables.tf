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

variable "master_ipv4_cidr_block" {
  type        = string
  default     = "172.25.100.0/28"
  description = "GKE master CIDR"
}

variable "nat_enabled" {
  type        = bool
  default     = true
  description = "If NAT should be created"
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

variable "kms_key_id" {
  type        = string
  default     = ""
  description = "The ID of a Cloud KMS key that will be used to encrypt cluster disks"
}

variable "block_project_ssh_key" {
  type        = string
  description = "Should project-wide ssh keys be blocked for nodes"
}

variable "autoscaling_profile" {
  type        = string
  default     = "OPTIMIZE_UTILIZATION"
  description = "GKE autoscaling profile, possible values: BALANCED|OPTIMIZE_UTILIZATION"
}

variable "logging_service" {
  type        = string
  default     = "logging.googleapis.com/kubernetes"
  description = "Logging service to write logs to. Possible values: logging.googleapis.com|logging.googleapis.com/kubernetes|none"
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

variable "resource_usage_export_config" {
  type    = map
  default = {
    enable_network_egress_metering       = false
    enable_resource_consumption_metering = false
    dataset_id                           = ""
  }
  description = "Resource consumption metrics configuration"
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

variable "argo" {
  type = object({
    enabled         = bool
    namespace       = string
    artifact_bucket = string
    node_pool       = any
  })
  default = {
    enabled         = false
    namespace       = "argo"
    artifact_bucket = ""
    node_pool = {
      argo-workflows = {
        init_node_count = 0
        min_node_count  = 0
        max_node_count  = 1
        preemptible     = true
        machine_type    = "n1-standard-2"
        disk_size_gb    = 40
        labels = {
          machine_type = "n1-standard-2"
          mode         = "argo-workflows"
        }
        taints = [
          {
            key    = "dedicated"
            effect = "NO_SCHEDULE"
            value  = "argo"
          }
        ]
      }
    }
  }
  description = "Argo configuration"
}
