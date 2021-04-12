##################
# Common
##################
variable "cluster_name" {
  type        = string
  description = "ODAHU flow cluster name"
}

variable "k8s_version" {
  type        = string
  default     = "1.16"
  description = "Kubernetes master version"
}

variable "allowed_ips" {
  type        = list(string)
  description = "CIDR list to allow access from"
}

##################
# AWS
##################
variable "az_list" {
  type        = list(string)
  description = "EKS Availability zones list"
}

variable "aws_region" {
  type        = string
  description = "Region of AWS resources"
}

variable "cidr" {
  type        = string
  default     = ""
  description = "network CIDR"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  default     = []
  description = "network CIDR"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  default     = []
  description = "AWS public network CIDR, will be used to place ELB"
}

variable "nat_subnet_cidr" {
  type        = string
  default     = ""
  description = "AWS NAT network CIDR, will be used to place bastion host"
}

variable "kms_key_arn" {
  type        = string
  default     = ""
  description = "The ARN of the AWS Key Management Service (AWS KMS) customer master key (CMK) to use when creating the encrypted volume"
}

#############
# Node pool
#############
variable "node_pools" {
  type        = any
  default     = {}
  description = "Default node pool configuration"
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
  type        = string
  default     = "f1-micro"
  description = "Bastion host VM type"
}

variable "bastion_hostname" {
  type        = string
  default     = "bastion"
  description = "Bastion hostname"
}

variable "argo" {
  type = object({
    enabled             = bool
    namespace           = string
    workflows_namespace = string
    artifact_bucket     = string
    node_pool           = any
  })
  default = {
    enabled             = false
    namespace           = "argo"
    workflows_namespace = "argo-workflows"
    artifact_bucket     = ""
    node_pool = {
      argo-workflows = {
        init_node_count = 0
        min_node_count  = 0
        max_node_count  = 1
        preemptible     = true
        machine_type    = "m5.large"
        disk_size_gb    = 40
        labels = {
          machine_type = "m5.large"
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
