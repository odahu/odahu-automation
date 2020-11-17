##################
# Required
##################
variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "allowed_ips" {
  type        = list(string)
  description = "CIDR to allow access from"
}

variable "master_role_arn" {
  type        = string
  description = "EKS Master IAM role ARN"
}

variable "master_sg_id" {
  type        = string
  description = "EKS Master Security Group ID"
}

variable "node_role_arn" {
  type        = string
  description = "EKS Node IAM role ARN"
}

variable "node_sg_id" {
  type        = string
  description = "EKS Node Security Group ID"
}

variable "kms_key_id" {
  type        = string
  description = "The ARN of the AWS Key Management Service (AWS KMS) customer master key (CMK) to use when creating the encrypted volume"
}

##################
# Optional
##################
variable "cluster_name" {
  type        = string
  default     = "odahuflow"
  description = "ODAHU flow cluster name"
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

variable "node_ami" {
  type        = string
  default     = "ami-03d9393d97f5959fe"
  description = "Version of Amazon EKS-optimized Linux AMI"
  # Some memo to get AMI:
  # aws ssm get-parameter --name /aws/service/eks/optimized-ami/1.14/amazon-linux-2/recommended/image_id \
  #   --region $AWS_DEFAULT_REGION --query "Parameter.Value" --output text
  # aws ssm get-parameter --name /aws/service/eks/optimized-ami/1.14/amazon-linux-2-gpu/recommended/image_id \
  #   --region $AWS_DEFAULT_REGION --query "Parameter.Value" --output text
}

variable "node_instance_profile_name" {
  type        = string
  description = "Instance profile for EKS nodes"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs where to setup cluster"
}

variable "nat_subnet_id" {
  type        = string
  description = "Subnet ID to start bastion instance in"
}

variable "vpc_id" {
  type        = string
  description = "VPC Network ID"
}

variable "k8s_version" {
  type        = string
  default     = "1.14"
  description = "Kubernetes master version"
}

variable "autoscaler_version" {
  type        = string
  default     = "1.16.5"
  description = "Kubernetes Cluster Autoscaler component version"
}

variable "ssh_user" {
  type        = string
  default     = "ubuntu"
  description = "Default SSH user"
}

variable "cluster_autoscaling_cpu_max_limit" {
  type        = number
  default     = 30
  description = "Maximum CPU limit for autoscaling if it is enabled."
}

variable "cluster_autoscaling_cpu_min_limit" {
  type        = number
  default     = 2
  description = "Minimum CPU limit for autoscaling if it is enabled."
}

variable "cluster_autoscaling_memory_max_limit" {
  type        = number
  default     = 64
  description = "Maximum memory limit for autoscaling if it is enabled."
}

variable "cluster_autoscaling_memory_min_limit" {
  type        = number
  default     = 4
  description = "Minimum memory limit for autoscaling if it is enabled."
}

###############
# Bastion host
###############
variable "bastion_enabled" {
  type        = bool
  default     = false
  description = "Flag to install bastion host or not"
}

variable "bastion_ami" {
  type        = string
  default     = "ami-0cdab515472ca0bac"
  description = "AMI to use for bastion (Official Ubuntu 18.04)"
}

variable "bastion_machine_type" {
  type        = string
  default     = "t2.micro"
  description = "Bastion host VM type"
}

variable "bastion_hostname" {
  type        = string
  default     = "bastion"
  description = "Bastion hostname"
}

variable "bastion_tag" {
  type        = string
  default     = ""
  description = "Bastion network tags"
}

variable "bastion_sg_id" {
  type        = string
  description = "Bastion Security Group ID"
}
