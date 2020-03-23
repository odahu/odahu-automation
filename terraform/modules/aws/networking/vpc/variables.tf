variable "cluster_name" {
  default     = "odahuflow"
  description = "Odahuflow cluster name"
}

variable "cidr" {
  description = "VPC CIDR range"
}

variable "private_subnet_cidrs" {
  description = "Private Subnet ranges, will be used to create eks nodes in"
}

variable "public_subnet_cidrs" {
  description = "Public Subnet range,"
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
