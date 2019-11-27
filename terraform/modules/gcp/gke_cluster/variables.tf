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

variable "root_domain" {
  description = "Odahuflow cluster root domain"
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

variable "dns_zone_name" {
  description = "Cluster root DNS zone name"
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

variable "main_node_pool" {
  description = "List of parameters for main node pool"
  default = {
    initial_node_count = 1

    autoscaling = {
      min_node_count = "1"
      max_node_count = "5"
    }

    node_config = {}
  }
}

variable "training_node_pool" {
  description = "List of parameters for training node pool"
  default = {
    node_config = {
      machine_type = "n1-highcpu-8"
      disk_size_gb = "100"
      labels = {
        "mode" = "odahu-flow-training"
      }
      taint = [{
        key    = "dedicated"
        value  = "training"
        effect = "NO_SCHEDULE"
      }]
    }
  }
}

variable "training_gpu_node_pool" {
  description = "List of parameters for training gpu node pool"
  default = {
    node_config = {
      machine_type = "n1-highcpu-8"
      disk_size_gb = "100"
      labels = {
        "mode" = "odahu-flow-training-gpu"
      }
      guest_accelerator = [{
        type  = "nvidia-tesla-p100"
        count = "2"
      }]
    }
  }
}

variable "packaging_node_pool" {
  description = "List of parameters for packaging node pool"
  default = {
    autoscaling = {
      max_node_count = "3"
    }

    node_config = {
      disk_size_gb = "100"
      labels = {
        "mode" = "odahu-flow-packaging"
      }
      taint = [{
        key    = "dedicated"
        value  = "packaging"
        effect = "NO_SCHEDULE"
      }]
    }
  }
}

variable "model_deployment_node_pool" {
  description = "List of parameters for model deployment node pool"
  default = {
    autoscaling = {
      max_node_count = "3"
    }

    node_config = {
      labels = {
        "mode" = "odahu-flow-deployment"
      }
      taint = [{
        key    = "dedicated"
        value  = "deployment"
        effect = "NO_SCHEDULE"
      }]
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

