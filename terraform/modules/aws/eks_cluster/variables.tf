##################
# Required
##################
variable "aws_region" {
  description = "AWS region"
}

variable "allowed_ips" {
  type        = list(string)
  description = "CIDR to allow access from"
}

variable "master_role_arn" {
  description = "EKS Master IAM role ARN"
}

variable "master_sg_id" {
  description = "EKS Master Security Group ID"
}

variable "node_role_arn" {
  description = "EKS Node IAM role ARN"
}

variable "node_sg_id" {
  description = "EKS Node Security Group ID"
}

variable "bastion_sg_id" {
  description = "Bastion Security Group ID"
}

##################
# Optional
##################
variable "cluster_name" {
  default     = "odahuflow"
  description = "Odahuflow cluster name"
}

variable "bastion_enabled" {
  default     = false
  type        = bool
  description = "Flag to install bastion host or not"
}

variable "bastion_ami" {
  default     = "ami-0cdab515472ca0bac"
  description = "AMI to use for bastion"
}

variable "node_instance_profile_name" {
  description = "Instance profile for EKS nodes"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs where to setup cluster"
}

variable "nat_subnet_id" {
  description = "Subnet ID to start bastion instance in"
}

variable "vpc_id" {
  description = "VPC Network ID"
}

variable "k8s_version" {
  default     = "1.13"
  description = "Kubernetes master version"
}

variable "autoscaler_version" {
  default     = "1.13.8"
  description = "Kubernetes master version"
}

variable "ssh_user" {
  default     = "ubuntu"
  description = "default ssh user"
}

variable "cluster_autoscaling_cpu_max_limit" {
  default     = 30
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

###############
# Bastion host
###############

variable "bastion_machine_type" {
  default = "t2.micro"
}

variable "bastion_hostname" {
  default     = "bastion"
  description = "bastion hostname"
}

variable "bastion_tag" {
  default     = ""
  description = "Bastion network tags"
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

