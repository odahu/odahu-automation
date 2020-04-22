variable "elasticsearch_enabled" {
  default     = true
  description = "Flag to install Elasticsearch (true) or not (false)"
  type        = bool
}

variable "elasticsearch_namespace" {
  default     = "elasticsearch"
  description = "Elasticsearch namespace name"
  type        = string
}

variable "elasticsearch_helm_repo" {
  default     = "https://helm.elastic.co"
  description = "Elasticsearch helm repository"
  type        = string
}

variable "elasticsearch_chart_version" {
  default     = "7.6.2"
  description = "Elasticsearch helm chart version"
  type        = string
}

variable "elasticsearch_replicas" {
  default     = "1"
  description = "Replica count for the Elasticsearch StatefulSet"
  type        = string
}


variable "kibana_chart_version" {
  default     = "7.6.2"
  description = "Kibana helm chart version"
  type        = string
}

variable "storage_size" {
  default     = "30Gi"
  description = "Elasticsearch nodes attached PVC size"
  type        = string
}

variable "cluster_domain" {
  description = "ODAHU Flow cluster FQDN"
  type        = string
}

variable "tls_secret_crt" {
  description = "Ingress TLS certificate"
  default     = ""
}

variable "tls_secret_key" {
  description = "Ingress TLS key"
  default     = ""
}
