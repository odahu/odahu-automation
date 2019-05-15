# Common variables

variable "project_id" {
  description = "Target project id"
}

variable "gcp_credentials" {
  description = "GCP credentials"
}

variable "region" {
  description = "Region of resources"
}

variable "tfstore" {
  description = "Cluster terraform state store"
}

# Network variables
variable "subnet_cidr" {
  description = "Subnet range"
}

variable "cluster_location" {
  description = "Cluster location - regional or zonal"
}

variable "vpc_name" {
  description = "vpc name"
}
variable "subnet_name" {
  description = "subnet name"
}

# GCP variables

variable "cluster_name" {
  description = "Legion cluster name"
}

variable "service_account" {
  default = "default"
  description = "Service account for cluster nodes"
}