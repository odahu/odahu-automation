##################
# Common
##################
variable "helm_repo" {
  type        = string
  default     = "https://kubernetes-charts.storage.googleapis.com"
  description = "URL of used Helm chart repository"
}

variable "helm_timeout" {
  type        = number
  default     = 600
  description = "Helm chart deploy timeout in seconds"
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
  default     = "kube-monitoring"
  description = "Clusterwide namespace for monitoring stuff"
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
  default     = "1Gi"
  description = "Grafana PVC size"
}

variable "grafana_image_tag" {
  type        = string
  default     = "7.1.5"
  description = "Default Grafana docker image tag"
}

variable "prom_storage_size" {
  type        = string
  default     = "20Gi"
  description = "Prometheus PVC size"
}

variable "prom_retention_size" {
  type        = string
  default     = "19GiB"
  description = "Used Storage Prometheus shall retain data for"
}

variable "prom_retention_time" {
  type        = string
  default     = "14d"
  description = "Time duration Prometheus shall retain data for"
}

variable "tls_secret_crt" {
  type        = string
  description = "ODAHU flow cluster TLS certificate"
}

variable "tls_secret_key" {
  type        = string
  description = "ODAHU flow cluster TLS key"
}
