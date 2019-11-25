variable "cluster_name" {
  default     = "odahuflow"
  description = "Odahuflow cluster name"
}

variable "root_domain" {
  description = "Odahuflow cluster root domain"
}

variable "tls_secret_crt" {
  description = "Odahuflow cluster TLS certificate"
}

variable "tls_secret_key" {
  description = "Odahuflow cluster TLS key"
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

variable "odahu_infra_version" {
  description = "Odahuflow infra release version"
}

variable "helm_repo" {
  description = "Odahuflow helm repo"
}