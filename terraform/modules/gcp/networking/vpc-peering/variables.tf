variable "project_id" {
  description = "Target project id"
}
variable "zone" {
  description = "Default zone"
}
variable "region" {
  description = "Region of resources"
}
variable "cluster_name" {
  default     = "legion"
  description = "Legion cluster name"
}
variable "network_name" {
  description = "VPC Netwrok name"
}
variable "allowed_ips" {
  description = "Subnet ranges to whitelist on cluster"
}
