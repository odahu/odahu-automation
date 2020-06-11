##################
# Common
##################
variable "helm_repo" {
  type        = string
  description = "ODAHU flow helm repo"
}

variable "cluster_domain" {
  type        = string
  description = "ODAHU flow cluster domain"
}

########################
# Prometheus monitoring
########################
variable "monitoring_namespace" {
  type        = string
  description = "Clusterwide namespace for monitoring stuff"
  default     = "kube-monitoring"
}

variable "odahu_infra_version" {
  type        = string
  description = "ODAHU flow infra release version"
}

variable "grafana_admin" {
  type        = string
  description = "Grafana admin username"
}

variable "grafana_pass" {
  type        = string
  description = "Grafana admin password"
}

variable "grafana_storage_size" {
  type        = string
  description = "Grafana PVC size"
  default     = "1Gi"
}

variable "grafana_image_tag" {
  type        = string
  description = "Default Grafana docker image tag"
  default     = "6.7.4"
}

variable "prom_storage_size" {
  type        = string
  description = "Prometheus PVC size"
  default     = "20Gi"
}

variable "prom_retention_size" {
  type        = string
  description = "Used Storage Prometheus shall retain data for"
  default     = "19GiB"
}

variable "prom_retention_time" {
  type        = string
  description = "Time duration Prometheus shall retain data for"
  default     = "14d"
}

variable "storage_class" {
  type        = string
  description = "Used kubernetes storage class name"
  default     = "standard"
}

variable "tls_secret_crt" {
  type        = string
  description = "ODAHU flow cluster TLS certificate"
}

variable "tls_secret_key" {
  type        = string
  description = "ODAHU flow cluster TLS key"
}

variable "helm_timeout" {
  type        = string
  description = "Helm chart installation timeout"
  default     = "600"
}
