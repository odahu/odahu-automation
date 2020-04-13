variable "cluster_name" {
  default     = "odahuflow"
  description = "Odahuflow cluster name"
}

variable "cidr" {
  description = "VPC CIDR range"
}

variable "vpc_name" {
  default     = ""
  description = "Name of existing VPC to use"
}

variable "private_subnet_cidrs" {
  default     = []
  description = "Private Subnet ranges, will be used to create eks nodes in"
}

variable "private_subnet_ids" {
  default     = []
  description = "Private Subnet ID list, will be used to create eks nodes in"
}

variable "public_subnet_cidrs" {
  default     = []
  description = "Public Subnet range,"
}

variable "public_subnet_ids" {
  default     = []
  description = "Public Subnet ID list, will be used to create eks nodes in"
}

variable "nat_subnet_cidr" {
  description = "Subnet range"
}

variable "az_list" {
  description = "AWS AZ list to use"
}

variable "aws_region" {
  description = "AWS region"
}
