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

variable "tls_name" {
  description = "Cluster TLS certificate name"
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


variable "legion_helm_repo" {
  description = "Legion helm repo"
}

variable "legion_infra_version" {
  description = "Legion infra release version"
}

variable "alert_slack_url" {
  description = "Alert slack usrl"
}

variable "root_domain" {
  description = "Legion cluster root domain"
}

variable "grafana_admin" {
  description = "Grafana admion username"
}
variable "grafana_pass" {
  description = "Grafana admin password"
}

variable "docker_repo" {
  description = "Legion Docker repo url"
}

variable "cluster_context" {
  description = "Kubectl cluster context"
}

variable "github_org_name" {
  description = "Github Organization for dex authentication"
}

variable "dex_github_clientid" {
  description = "Github Organization clientID"
}

variable "dex_github_clientSecret" {
  description = "Github Organization client Secret"
}

variable "dex_client_secret" {
  description = "Github default client Secret"
}