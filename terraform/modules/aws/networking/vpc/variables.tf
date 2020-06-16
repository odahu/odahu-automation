variable "cluster_name" {
  type        = string
  default     = "odahuflow"
  description = "ODAHU flow cluster name"
}

variable "cidr" {
  type        = string
  description = "VPC CIDR range"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet ranges, will be used to create eks nodes in"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet range"
}

variable "nat_subnet_cidr" {
  type        = string
  description = "Subnet range"
}

variable "az_list" {
  type        = list(string)
  description = "AWS AZ list to use"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}
