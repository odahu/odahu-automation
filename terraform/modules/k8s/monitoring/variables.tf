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
variable "namespace" {
  default     = "odahu-flow-monitoring"
  description = "ODAHU flow monitoring namespace"
}

variable "odahu_infra_version" {
  description = "Odahuflow infra release version"
}

variable "grafana_admin" {
  description = "Grafana admin username"
}

variable "grafana_pass" {
  description = "Grafana admin password"
}

variable "grafana_storage_class" {
  default     = "standard"
  description = "Grafana storage class"
}
