##################
# Common
##################
variable "helm_repo" {
  description = "Odahuflow helm repo"
}

variable "cluster_domain" {
  description = "Odahuflow cluster domain"
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

variable "grafana_admin" {
  description = "Grafana admion username"
}

variable "grafana_pass" {
  description = "Grafana admin password"
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
