variable "elk_enabled" {
  default     = true
  description = "Flag to install ELK stack (true) or not (false)"
  type        = bool
}

variable "elk_namespace" {
  default     = "odahu-flow-elk"
  description = "ELK stack namespace name"
  type        = string
}

variable "odahu_helm_repo" {
  description = "ODAHU-flow helm repo"
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

variable "elasticsearch_memory" {
  default     = "4"
  description = "Memory limit for Elasticsearch process (in GiB)"
  type        = string
}

variable "logstash_chart_version" {
  default     = "7.6.2"
  description = "Logstash helm chart version"
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

variable "logstash_replicas" {
  default     = "1"
  description = "Replica count for the Logstash StatefulSet"
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

# Docker
variable "docker_repo" {
  description = "Odahuflow Docker repo url"
}

variable "docker_username" {
  default     = ""
  description = "Odahuflow Docker repo username"
}

variable "docker_password" {
  default     = ""
  description = "Odahuflow Docker repo password"
}

variable "odahu_infra_version" {
  description = "Odahuflow infra release version"
}

variable "logstash_input_config" {
  description = "Raw logstash input config"
}

variable "sa_key" {
  default = ""
}

variable "logstash_annotations" {
  default = {}
}

variable "cloud_type" {
  default = ""
}
