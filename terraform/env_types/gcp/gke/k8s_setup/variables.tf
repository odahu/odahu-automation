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
  default     = "us-east1"
  description = "Region of resources"
}

variable "config_context_auth_info" {
  description = "Legion cluster context auth"
}

variable "config_context_cluster" {
  description = "Legion cluster context name"
}

variable "region_aws" {
  default     = "us-east-2"
  description = "Region of AWS resources"
}

variable "aws_profile" {
  description = "AWS profile name"
}

variable "aws_credentials_file" {
  default     = "~/.aws/config"
  description = "AWS credentials file location"
}

variable "secrets_storage" {
  description = "Cluster secrets storage"
}

variable "cluster_name" {
  default     = "legion"
  description = "Legion cluster name"
}

variable "legion_helm_repo" {
  description = "Legion helm repo"
}

variable "legion_infra_version" {
  description = "Legion infra release version"
}

variable "root_domain" {
  description = "Legion cluster root domain"
}

variable "docker_repo" {
  description = "Legion Docker repo url"
}

variable "dns_zone_name" {
  description = "Cluster root DNS zone name"
}

variable "network_name" {
  description = "The VPC network to host the cluster in"
}

########################
# Prometheus monitoring
########################
variable "allowed_ips" {
  type        = list(string)
  description = "CIDR to allow access from"
}

variable "alert_slack_url" {
  description = "Alert slack usrl"
}

variable "grafana_admin" {
  description = "Grafana admion username"
}

variable "grafana_pass" {
  description = "Grafana admin password"
}

variable "cluster_context" {
  description = "Kubectl cluster context"
}

variable "github_org_name" {
  description = "Github Organization for dex authentication"
}

variable "monitoring_namespace" {
  default     = "kube-monitoring"
  description = "clusterwide monitoring namespace"
}

##################
# Dex
##################
variable "dex_github_clientid" {
  description = "Github Organization clientID"
}

variable "dex_github_clientSecret" {
  description = "Github Organization client Secret"
}

variable "dex_client_secret" {
  description = "Dex default client Secret"
}

variable "dex_client_id" {
  description = "Dex default client Secret"
}

variable "dex_static_user_email" {
  description = "Dex static user email"
}

variable "dex_static_user_pass" {
  description = "Dex static user pass"
}

variable "dex_static_user_hash" {
  description = "Dex static user hash"
}

variable "dex_static_user_name" {
  description = "Dex static user name"
}

variable "dex_static_user_id" {
  description = "Dex static user user id"
}

variable "oauth2_github_cookieSecret" {
  description = "oauth2 secret for cookies"
}

########################
# Istio
########################
variable "istio_namespace" {
  default     = "istio-system"
  description = "istio namespace"
}

