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
  default     = "kube-monitoring"
  description = "clusterwide monitoring namespace"
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

variable "monitoring_prometheus_operator_crd_url" {
  default     = "https://raw.githubusercontent.com/coreos/prometheus-operator/v0.29.0/example/prometheus-operator-crd"
  description = "Prometheus operator CRD url"
}

variable "cluster_context" {
  description = "Kubectl cluster context"
}

variable "prometheus_crds" {
  default = ["alertmanager", "prometheus", "prometheusrule", "servicemonitor"]
  description = "Default namespaces with TLS secret"
}

variable "grafana_storage_class" {
  default     = "standard"
  description = "Grafana storage class"
}

##################
# Dex auth
##################
variable "dex_replicas" {
  default = 1
  description = "Number of dex replicas"
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
  description = "Dex static user username"
}

variable "dex_static_user_id" {
  description = "Dex static user user id"
}
