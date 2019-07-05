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
variable "gcp_network" {
  description = "VPC Netwrok name at GCP"
}
variable "aws_profile" {
  description = "AWS profile name"
}
variable "aws_credentials_file" {
  description = "AWS credentials file location"
}
variable "region_aws" {
  description = "Region of AWS resources"
}
variable "aws_vpc_id" {
  description = "AWS VPC id to establish peering with"
}
variable "gcp_cidr" {
  description = "GCP network CIDR"
}
variable "aws_sg" {
  description = "AWS SG id for gcp access"
}
variable "aws_private_gw_name" {
  default     = "legion-gcp-gw"
  description = "AWS SG id for gcp access"
}
variable "aws_cidr" {
  description = "AWS network CIDR"
}
variable "aws_route_table_id" {
  description = "AWS Route table ID"
}