variable "cluster_name" {
  default     = "legion"
  description = "Legion cluster name"
}

variable "root_domain" {
  description = "Legion cluster root domain"
}

variable "tls_secret_crt" {
  description = "Legion cluster TLS certificate"
}

variable "tls_secret_key" {
  description = "Legion cluster TLS key"
}

variable "istio_version" {
  default = "1.2.2"
}

variable "istio_namespace" {
  default     = "istio-system"
  description = "istio namespace"
}

variable "monitoring_namespace" {
  default     = "kube-monitoring"
  description = "Monitoring namespace"
}

variable "knative_namespace" {
  default     = "knative-serving"
  description = "knative namespace"
}

variable "legion_infra_version" {
  description = "Legion infra release version"
}

variable "legion_helm_repo" {
  description = "Legion helm repo"
}