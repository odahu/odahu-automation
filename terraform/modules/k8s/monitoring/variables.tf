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

variable "zone" {
  description = "Default zone"
}

variable "region" {
  description = "Region of resources"
}

variable "legion_helm_repo" {
  description = "Legion helm repo"
}

variable "root_domain" {
  description = "Legion cluster root domain"
}

########################
# Prometheus monitoring
########################
variable "monitoring_namespace" {
  default     = "kube-monitoring"
  description = "clusterwide monitoring namespace"
}

variable "legion_infra_version" {
  description = "Legion infra release version"
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

variable "docker_repo" {
  description = "Legion Docker repo url"
}

variable "grafana_storage_class" {
  default     = "standard"
  description = "Grafana storage class"
}

variable "tls_secret_crt" {
  description = "Legion cluster TLS certificate"
}

variable "tls_secret_key" {
  description = "Legion cluster TLS key"
}

