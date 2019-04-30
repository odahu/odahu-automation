##################
# Common
##################


variable "project_id" {
  description = "Target project id"
}

variable "zone" {
  default     = "us-east1-b"
  description = "Default zone"
}

variable "region" {
  default = "us-east1"
  description = "Region of resources"
}

variable "region_aws" {
  default = "us-east-2"
  description = "Region of AWS resources"
}

variable "tls_name" {
  description = "Cluster TLS certificate name"
}

variable "tls_namespaces" {
  default = ["default", "kube-system"]
  description = "Default namespaces with TLS secret"
}

variable "secrets_storage" {
  description = "Cluster secrets storage"
}

variable "cluster_name" {
  default     = "legion"
  description = "Legion cluster name"
}

variable "allowed_ips" {
  description = "CIDR to allow access from"
}

##################
# Prometheus monitoring
##################

variable "monitoring_namespace" {
  default     = "monitoring"
  description = "clusterwide monitoring namespace"
}