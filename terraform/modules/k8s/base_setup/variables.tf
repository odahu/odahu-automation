##################
# Common
##################
variable "project_id" {
  description = "Target project id"
}
variable "cluster_name" {
  default     = "legion"
  description = "Legion cluster name"
}
variable "aws_profile" {
  description = "AWS profile name"
}
variable "aws_credentials_file" {
  description = "AWS credentials file location"
}
variable "zone" {
  description = "Default zone"
}
variable "region" {
  description = "Region of resources"
}
variable "region_aws" {
  description = "Region of AWS resources"
}
variable "secrets_storage" {
  description = "Cluster secrets storage"
}
variable "tls_namespaces" {
  default = ["default", "kube-system"]
  description = "Default namespaces with TLS secret"
}