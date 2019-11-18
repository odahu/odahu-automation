##################
# Common
##################
variable "cluster_name" {
  default     = "odahuflow"
  description = "Odahuflow cluster name"
}

variable "helm_repo" {
  description = "Odahuflow helm repo"
}

variable "root_domain" {
  description = "Odahuflow cluster root domain"
}

########################
# Prometheus monitoring
########################
variable "monitoring_namespace" {
  default     = "kube-monitoring"
  description = "clusterwide monitoring namespace"
}

variable "odahu_infra_version" {
  description = "Odahuflow infra release version"
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
  description = "Odahuflow Docker repo url"
}

variable "grafana_storage_class" {
  default     = "standard"
  description = "Grafana storage class"
}

variable "tls_secret_crt" {
  description = "Odahuflow cluster TLS certificate"
}

variable "tls_secret_key" {
  description = "Odahuflow cluster TLS key"
}
