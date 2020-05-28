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
  default     = "kube-monitoring"
  description = "Clusterwide namespace for monitoring stuff"
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
  default     = "1Gi"
  description = "Grafana DB storage size"
}

variable "storage_class" {
  type        = string
  default     = "standard"
  description = "Kubernetes storage class to create Persistent Volumes"
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
  type    = string
  default = "600"
}
