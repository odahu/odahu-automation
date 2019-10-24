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
  default     = "legion"
  description = "Legion cluster name"
}

variable "bastion_ami" {
  default     = "ami-0cdab515472ca0bac"
  description = "AMI to use for bastion"
}

variable "node_ami" {
  default     = "ami-038bd8d3a2345061f"
  description = "AMI to use for EKS nodes"
}

variable "node_ami_gpu" {
  default     = "ami-07b7cbb235789cc31"
  description = "AMI to use for EKS GPU nodes"
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

variable "node_machine_type" {
  default     = "m5.large"
  description = "Machine type of EKS nodes"
}

variable "node_machine_type_highcpu" {
  default     = "c5.2xlarge"
  description = "Machine type of EKS nodes with high CPU resource"
}

variable "node_machine_type_gpu" {
  default     = "c5.2xlarge"
  description = "Machine type of EKS nodes with GPU"
}

variable "num_nodes_min" {
  default     = "1"
  description = "Number of nodes in cluster"
}

variable "num_nodes_max" {
  default     = "7"
  description = "Max number of nodes in cluster"
}

variable "num_nodes_highcpu_max" {
  default     = "2"
  description = "Number of nodes in High CPU node pool"
}

variable "num_nodes_gpu_max" {
  default     = "2"
  description = "Number of nodes in GPU node pool"
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

